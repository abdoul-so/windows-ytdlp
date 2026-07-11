class VideoMetadata {
  final String title;
  final String thumbnail;
  final List<FileFormat> formats;
  final bool isPlaylist;
  final List<PlaylistEntry> playlistVideos;
  final int? playlistCount;

  VideoMetadata({
    required this.title,
    required this.thumbnail,
    required this.formats,
    this.isPlaylist = false,
    this.playlistVideos = const [],
    this.playlistCount,
  });

  // 🚀 AJOUT DE LA MÉTHODE COPYWITH POUR TOUT CLONER PROPREMENT
  VideoMetadata copyWith({
    String? title,
    String? thumbnail,
    List<FileFormat>? formats,
    bool? isPlaylist,
    List<PlaylistEntry>? playlistVideos,
    int? playlistCount,
  }) {
    return VideoMetadata(
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      formats: formats ?? this.formats,
      isPlaylist: isPlaylist ?? this.isPlaylist,
      playlistVideos: playlistVideos ?? this.playlistVideos,
      playlistCount: playlistCount ?? this.playlistCount,
    );
  }

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    if (json['_type'] == 'playlist' || json['entries'] != null) {
      var entriesList = json['entries'] as List? ?? [];

      // 🚀 CORRECTION PRÉCÉDENTE : On filtre uniquement les entrées valides qui possèdent une URL
      List<PlaylistEntry> videos = entriesList
          .where((e) =>
              e != null && (e['webpage_url'] != null || e['url'] != null))
          .map((e) => PlaylistEntry.fromJson(e))
          .toList();

      return VideoMetadata(
        title: json['title'] ?? 'Playlist inconnue',
        thumbnail: videos.isNotEmpty ? videos.first.thumbnail : '',
        formats: [],
        isPlaylist: true,
        playlistVideos: videos,
        playlistCount: json['playlist_count'] ?? videos.length,
      );
    }

    // 🚀 AJOUT POUR L'ESTIMATION : Récupération de la durée générale du média (en secondes)
    final int? globalDuration =
        json['duration'] != null ? (json['duration'] as num).toInt() : null;

    var list = json['formats'] as List? ?? [];
    List<FileFormat> formatList = list
        .map((i) => FileFormat.fromJson(i, globalDuration: globalDuration))
        .toList();

    // Filtre souple : On accepte tout format lisible ayant une hauteur ou une piste audio valide.
    formatList = formatList
        .where((f) =>
            f.formatId.isNotEmpty && (f.height != null || f.acodec != 'none'))
        .toList();

    return VideoMetadata(
      title: json['title'] ?? 'Vidéo inconnue',
      thumbnail: json['thumbnail'] ?? '',
      formats: formatList,
    );
  }
}

class PlaylistEntry {
  final String title;
  final String url;
  final String thumbnail;
  final int index; // 🚀 Ajout du champ index

  PlaylistEntry({
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.index, // 🚀 Requis dans le constructeur
  });

  factory PlaylistEntry.fromJson(Map<String, dynamic> json) {
    String foundUrl = json['webpage_url'] ?? json['url'] ?? '';
    // yt-dlp fournit généralement l'index dans 'playlist_index' (commence à 1)
    int extractedIndex = json['playlist_index'] != null
        ? (json['playlist_index'] as num).toInt()
        : 0;

    return PlaylistEntry(
      title: json['title'] ?? 'Vidéo sans titre',
      url: foundUrl,
      thumbnail: json['thumbnail'] ?? '',
      index: extractedIndex, // 🚀 Extraction de l'index
    );
  }
}

class FileFormat {
  final String formatId;
  final String ext;
  final int? filesize;
  final int? height;
  final String vcodec;
  final String acodec;
  final String? displayLabel;

  // 🚀 NOUVEAUX CHAMPS POUR L'ESTIMATION
  final double? tbr; // Bitrate total global (en kbps)
  final int? duration; // Durée en secondes de la vidéo

  FileFormat({
    required this.formatId,
    required this.ext,
    this.filesize,
    this.height,
    required this.vcodec,
    required this.acodec,
    this.displayLabel,
    this.tbr,
    this.duration,
  });

  factory FileFormat.fromJson(Map<String, dynamic> json,
      {int? globalDuration}) {
    // Lecture sécurisée du débit total fourni par yt-dlp (tbr)
    double? extractedTbr;
    if (json['tbr'] != null) {
      extractedTbr = (json['tbr'] as num).toDouble();
    } else if (json['vbr'] != null || json['abr'] != null) {
      // Si tbr n'est pas fourni, on additionne le bitrate vidéo (vbr) et audio (abr)
      double vbr = json['vbr'] != null ? (json['vbr'] as num).toDouble() : 0.0;
      double abr = json['abr'] != null ? (json['abr'] as num).toDouble() : 0.0;
      extractedTbr = (vbr + abr > 0) ? (vbr + abr) : null;
    }

    return FileFormat(
      formatId: json['format_id'] ?? '',
      ext: json['ext'] ?? '',
      filesize: json['filesize'] ?? json['filesize_approx'],
      height: json['height'],
      vcodec: json['vcodec'] ?? 'none',
      acodec: json['acodec'] ?? 'none',
      displayLabel: json['display_label'],
      tbr: extractedTbr,
      duration: json['duration'] != null
          ? (json['duration'] as num).toInt()
          : globalDuration,
    );
  }

  String get formattedSize {
    // 1. Si la taille réelle ou approximative est fournie, on l'affiche directement
    if (filesize != null) {
      double sizeInMb = filesize! / (1024 * 1024);
      if (sizeInMb > 1024) return "${(sizeInMb / 1024).toStringAsFixed(2)} Go";
      return "${sizeInMb.toStringAsFixed(1)} Mo";
    }

    // 2. 🚀 ALGORITHME D'ESTIMATION SI TAILLE INCONNUE
    if (duration != null && duration! > 0 && tbr != null && tbr! > 0) {
      // Formule : (Durée en sec * Débit en kbps) / 8 = Ko. Puis divisé par 1024 = Mo.
      double estimatedMb = (duration! * tbr!) / (8 * 1024);

      if (estimatedMb > 1024) {
        return "~ ${(estimatedMb / 1024).toStringAsFixed(2)} Go (est.)";
      }
      return "~ ${estimatedMb.toStringAsFixed(1)} Mo (est.)";
    }

    return "Taille variable";
  }

  String get label {
    if (displayLabel != null && displayLabel!.isNotEmpty) {
      return displayLabel!;
    }

    final sizeInfo = formattedSize;

    if (vcodec == 'none' || ext == 'mp3') {
      return "Audio uniquement (MP3) - $sizeInfo";
    }

    if (height != null && height! > 0) {
      if (acodec == 'none') {
        return "Vidéo seule ${height}p ($ext) - Mute - $sizeInfo";
      }
      return "Vidéo ${height}p ($ext) - $sizeInfo";
    }

    return "Format direct ($ext) - $sizeInfo";
  }
}
