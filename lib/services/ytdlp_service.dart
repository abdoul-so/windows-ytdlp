import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/video_metadata.dart';
import 'component_manager.dart';
import 'database/app_database.dart';
import 'database/cache_dao.dart';

class YtdlpService {
  static String? lastError;

  /// Wrapper de compatibilité pour récupérer les métadonnées automatiquement
  static Future<VideoMetadata> getMetadata(String url) async {
    // Détection automatique : si l'URL contient 'list=', c'est une playlist
    final isPlaylist = url.contains('list=') && !url.contains('watch?v=');

    final meta = await fetchVideoInfo(
      url,
      isPlaylistRequest: isPlaylist,
    );

    if (meta == null) {
      throw Exception(lastError ?? "Impossible de récupérer les métadonnées.");
    }
    return meta;
  }

  /// Retourne la commande pour exécuter yt-dlp, en forçant l'interpréteur Python du venv sur Linux.
  static (String executable, List<String> initialArgs) _getVenvCommand(
      String binFolder) {
    if (Platform.isLinux) {
      final pythonVenvPath = p.join(binFolder, 'venv_ytdlp', 'bin', 'python3');
      final ytDlpScriptPath = p.join(binFolder, 'venv_ytdlp', 'bin', 'yt-dlp');

      if (File(pythonVenvPath).existsSync()) {
        return (pythonVenvPath, [ytDlpScriptPath]);
      }
    }

    final executableName = ComponentManager.getYtdlpFileName();
    return (p.join(binFolder, executableName), []);
  }

  /// Récupère les métadonnées d'une vidéo ou d'une playlist.
  static Future<VideoMetadata?> fetchVideoInfo(String url,
      {int page = 1,
      int itemsPerPage = 5,
      required bool isPlaylistRequest}) async {
    lastError = null;
    try {
      // 1. Vérification du cache pour les vidéos uniques
      if (!isPlaylistRequest) {
        final cached = await database.getCachedMetadata(url);
        if (cached != null) return cached;
      }

      final folder = await ComponentManager.getTargetFolderPath();
      final (executable, initialArgs) = _getVenvCommand(folder);

      // 2. Arguments de base pour yt-dlp avec usurpation d'identité pour extraire les en-têtes réseau
      List<String> args = [
        ...initialArgs,
        '--dump-json',
        '--impersonate',
        'chrome',
      ];

      // 3. Arguments spécifiques aux listes de lecture vs vidéos simples
      if (isPlaylistRequest) {
        int startIndex = (page - 1) * itemsPerPage + 1;
        int endIndex = page * itemsPerPage;
        args.addAll([
          '--flat-playlist',
          '--write-thumbnail',
          '--playlist-items',
          '$startIndex-$endIndex',
        ]);
      } else {
        // Pour les vidéos simples, on force l'extraction complète en évitant les coupures
        args.addAll([
          '--no-playlist',
        ]);
      }
      args.add(url);

      // 4. Exécution de la commande avec mécanisme de secours pour l'erreur 403
      ProcessResult result = await Process.run(executable, args);
      if (result.exitCode != 0 && result.stderr.toString().contains('403')) {
        final retryArgs = [
          ...args.sublist(0, args.length - 1),
          '--impersonate',
          'chrome',
          url
        ];
        result = await Process.run(executable, retryArgs);
      }

      if (result.exitCode != 0) {
        lastError = _extractUserFriendlyError(result.stderr.toString());
        return null;
      }

      final lines = const LineSplitter().convert(result.stdout.toString());

      // 5. Analyse des lignes reçues
      if (isPlaylistRequest) {
        return _parsePlaylist(lines);
      } else {
        return await _parseSingleVideo(lines, url);
      }
    } catch (e) {
      lastError = "Erreur inattendue : $e";
      return null;
    }
  }

  /// Analyse les données JSON d'une playlist.
  static VideoMetadata? _parsePlaylist(List<String> lines) {
    Map<String, dynamic>? playlistInfo;
    List<Map<String, dynamic>> entries = [];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final decodedLine = jsonDecode(line) as Map<String, dynamic>;
        if (decodedLine['_type'] == 'url' || decodedLine['url'] != null) {
          entries.add(decodedLine);
        } else if (decodedLine['_type'] == 'playlist') {
          playlistInfo = decodedLine;
        }
      } catch (_) {}
    }

    if (playlistInfo != null) {
      playlistInfo['entries'] = entries;
      return VideoMetadata.fromJson(playlistInfo);
    }
    if (entries.isNotEmpty) {
      return VideoMetadata.fromJson({
        '_type': 'playlist',
        'title': 'Liste de lecture',
        'entries': entries
      });
    }

    lastError = "Aucune vidéo trouvée dans cette playlist.";
    return null;
  }

  /// Analyse une vidéo unique et génère des sélecteurs de formats résilients avec transmission des débits
  static Future<VideoMetadata?> _parseSingleVideo(
      List<String> lines, String originalUrl) async {
    String jsonStr = lines.firstWhere((line) => line.trim().startsWith('{'),
        orElse: () => '');
    if (jsonStr.isEmpty) {
      lastError = "Aucune donnée JSON valide reçue de yt-dlp.";
      return null;
    }

    late Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      lastError = "Impossible de lire la réponse JSON de yt-dlp.";
      return null;
    }

    // Extraction de la durée globale et du débit parent si présents
    final int? globalDuration = decoded['duration'] != null
        ? (decoded['duration'] as num).toInt()
        : null;
    double? globalTbr =
        decoded['tbr'] != null ? (decoded['tbr'] as num).toDouble() : null;

    final rawMetadata = VideoMetadata.fromJson(decoded);
    List<FileFormat> simplifiedFormats = [];

    // 1. Option MP3 toujours disponible avec estimation liée au flux d'origine
    simplifiedFormats.add(FileFormat(
        formatId: 'bestaudio/best',
        ext: 'mp3',
        vcodec: 'none',
        acodec: 'mp3',
        height: null,
        tbr:
            decoded['abr'] != null ? (decoded['abr'] as num).toDouble() : 128.0,
        duration: globalDuration,
        displayLabel: 'Audio (MP3)'));

    // 2. Extraction dynamique basée sur les résolutions trouvées ou via des sélecteurs standards
    final videoFormatsRaw =
        rawMetadata.formats.where((f) => f.vcodec != 'none').toList();
    final Set<int> heightsTrouvees = {};

    for (var f in videoFormatsRaw) {
      if (f.height != null && f.height! > 0) {
        heightsTrouvees.add(f.height!);
      }
    }

    // Injecter les fallbacks si aucun format brut n'a été mappé
    if (heightsTrouvees.isEmpty) {
      heightsTrouvees.addAll([1080, 720, 480, 360]);
    }

    // Génération de formats simplifiés et calcul chiffré basé sur le flux
    for (int h in heightsTrouvees) {
      String targetFormatId = "bestvideo[height<=$h]+bestaudio/best";

      if (originalUrl.contains("xnxx") ||
          originalUrl.contains("xvideos") ||
          originalUrl.contains("ukdevilz")) {
        targetFormatId = "best[height<=$h]/best";
      }

      // Chercher s'il existe un débit binaire (tbr/vbr) correspondant à cette hauteur dans le JSON brut
      double? targetedTbr = globalTbr;
      final matchingFormats = videoFormatsRaw.where((f) => f.height == h);
      if (matchingFormats.isNotEmpty) {
        targetedTbr = matchingFormats.first.tbr ?? globalTbr;
      }

      // Si aucun tbr n'est trouvé, assigner des débits standards de flux vidéo pour l'estimation
      if (targetedTbr == null || targetedTbr == 0) {
        if (h >= 1080) {
          targetedTbr = 3500;
        } else if (h >= 720) {
          targetedTbr = 2200;
        } else if (h >= 480) {
          targetedTbr = 1200;
        } else {
          targetedTbr = 600;
        }
      }

      simplifiedFormats.add(FileFormat(
          formatId: targetFormatId,
          ext: 'mp4',
          vcodec: 'any',
          acodec: 'any',
          height: h,
          tbr: targetedTbr,
          duration: globalDuration,
          displayLabel: 'Vidéo (${h}p)'));
    }

    // 3. Tri décroissant des résolutions
    simplifiedFormats.sort((a, b) {
      if (a.ext == 'mp3') return -1;
      if (b.ext == 'mp3') return 1;
      final heightA = a.height ?? 0;
      final heightB = b.height ?? 0;
      return heightB.compareTo(heightA);
    });

    // 4. Sécurité universelle
    if (simplifiedFormats.length <= 1) {
      simplifiedFormats.add(FileFormat(
          formatId: 'bv*+ba/b',
          ext: 'mp4',
          vcodec: 'any',
          acodec: 'any',
          height: null,
          tbr: globalTbr ?? 1500.0,
          duration: globalDuration,
          displayLabel: 'Meilleure qualité (Automatique)'));
    }

    final finalMeta = rawMetadata.copyWith(formats: simplifiedFormats);
    await database.cacheMetadata(originalUrl, finalMeta);
    return finalMeta;
  }

  /// Lance le processus de téléchargement (reprend les arguments intensifs du script Python).
  static Future<Process> downloadVideo({
    required String url,
    required String targetFolder,
    FileFormat? format,
    required Function(double) onProgress,
    required Function() onComplete,
  }) async {
    final binFolder = await ComponentManager.getTargetFolderPath();
    final ffmpegPath = p.join(binFolder, ComponentManager.getFfmpegFileName());
    final (executable, initialArgs) = _getVenvCommand(binFolder);

    // Intégration des options de résilience infinie du script Python
    List<String> arguments = [
      ...initialArgs,
      '--ffmpeg-location',
      ffmpegPath,
      '--retries',
      'infinite',
      '--fragment-retries',
      'infinite'
    ];

    // 🚀 AJOUT PRINCIPAL : On force yt-dlp à renommer le fichier sur le disque
    // avec le titre du modèle (qui contient ton titre personnalisé s'il a été changé)
    if (format != null) {
      // Pour une vidéo ou un format spécifique
      arguments.addAll(['-o', '%(title)s.%(ext)s']);
    } else {
      // Configuration automatique par défaut
      arguments.addAll(['-o', '%(title)s.mp4']);
    }

    if (format?.ext == 'mp3') {
      arguments.addAll([
        '--extract-audio',
        '--audio-format',
        'mp3',
        '-f',
        format?.formatId ?? 'bestaudio/best'
      ]);
    } else if (format != null) {
      arguments.addAll(['-f', format.formatId, '--merge-output-format', 'mp4']);
    } else {
      arguments.addAll(['-f', 'bv*+ba/b', '--merge-output-format', 'mp4']);
    }

    // Optimisation de la capture réseau
    arguments.addAll([
      '--impersonate',
      'chrome',
      '--hls-prefer-native',
      '--concurrent-fragments',
      '1',
      url
    ]);

    final process = await Process.start(executable, arguments,
        workingDirectory: targetFolder);

    process.stdout.transform(utf8.decoder).listen((data) {
      RegExp regExp = RegExp(r"\[download\]\s+(\d+\.\d+)%");
      var match = regExp.firstMatch(data);
      if (match != null) {
        double pct = double.parse(match.group(1)!) / 100;
        onProgress(pct);
      }
    });

    process.exitCode.then((_) => onComplete());
    return process;
  }

  static String _extractUserFriendlyError(String stderr) {
    if (stderr.isEmpty) return "Analyse échouée. Vérifiez l'URL.";
    if (stderr.contains('Unsupported URL')) return "URL non supportée.";

    final errorLines = stderr
        .split('\n')
        .where((l) => l.toLowerCase().contains('error:'))
        .toList();

    if (errorLines.isNotEmpty) {
      final relevantError = errorLines.first
          .replaceFirst(RegExp(r'ERROR:\s*', caseSensitive: false), '')
          .trim();
      if (relevantError.contains("Unable to extract")) {
        return "Extraction impossible sur cette page.";
      }
      return relevantError;
    }

    return "Erreur d'analyse inconnue.";
  }
}
