import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';

class ComponentManager {
  static final Dio _dio = Dio();

  static Future<String> getTargetFolderPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, 'ytdlp_desktop_app');
  }

  /// Dossier pour les vidéos uniques : .../ytdlp_desktop_app/Videos/
  static Future<String> getVideosFolderPath() async {
    final base = await getTargetFolderPath();
    final dir = Directory(p.join(base, 'Videos'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  /// Dossier pour les playlists : .../ytdlp_desktop_app/Playlists/
  static Future<String> getPlaylistsFolderPath() async {
    final base = await getTargetFolderPath();
    final dir = Directory(p.join(base, 'Playlists'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  static String getYtdlpFileName() => Platform.isWindows
      ? p.join('venv_ytdlp', 'Scripts', 'yt-dlp.exe')
      : p.join('venv_ytdlp', 'bin', 'yt-dlp');
  static String getFfmpegFileName() =>
      Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';

  static Future<bool> checkComponentsReady() async {
    final folder = await getTargetFolderPath();
    final ytdlp = File(p.join(folder, getYtdlpFileName()));
    final ffmpeg = File(p.join(folder, getFfmpegFileName()));
    return ytdlp.existsSync() && ffmpeg.existsSync();
  }

  static Future<bool> isPythonInstalled() async {
    try {
      final String cmd = Platform.isWindows ? 'python' : 'python3';
      final result = await Process.run(cmd, ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static String getPythonCmd() => Platform.isWindows ? 'python' : 'python3';

  static String _getFfmpegUrl() {
    const String base =
        "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-06-21-13-34";
    if (Platform.isWindows) {
      return "$base/ffmpeg-N-125146-gc6bb22dea0-win64-gpl.zip";
    }
    if (Platform.isLinux) {
      return "$base/ffmpeg-N-125146-gc6bb22dea0-linux64-gpl.tar.xz";
    }
    return "https://evermeet.cx/ffmpeg/getrelease/zip";
  }

  static Future<void> downloadAndSetup(
      {required Function(double) onProgress}) async {
    // 1. Vérification Python
    if (!await isPythonInstalled()) {
      throw Exception(
          "Python n'est pas installé sur ce système. Veuillez l'installer pour continuer.");
    }

    final folderPath = await getTargetFolderPath();
    final targetFolder = Directory(folderPath);
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }
    onProgress(0.1);

    // 2. Création de l'environnement virtuel
    final venvPath = p.join(folderPath, 'venv_ytdlp');
    final pythonCmd = getPythonCmd();
    var venvResult = await Process.run(pythonCmd, ['-m', 'venv', venvPath]);
    if (venvResult.exitCode != 0) {
      throw Exception(
          "Échec de la création de l'environnement virtuel Python.");
    }
    onProgress(0.3);

    // 3. Installation de yt-dlp et curl-cffi via pip
    final pipCmd = Platform.isWindows
        ? p.join(venvPath, 'Scripts', 'pip.exe')
        : p.join(venvPath, 'bin', 'pip');

    var pipResult =
        await Process.run(pipCmd, ['install', 'yt-dlp', 'curl-cffi']);
    if (pipResult.exitCode != 0) {
      throw Exception(
          "Échec de l'installation des paquets yt-dlp et curl-cffi.");
    }
    onProgress(0.6);

    String archiveName = Platform.isWindows
        ? 'ffmpeg.zip'
        : Platform.isLinux
            ? 'ffmpeg.tar.xz'
            : 'ffmpeg_mac.zip';
    String archivePath = p.join(folderPath, archiveName);

    await _dio.download(_getFfmpegUrl(), archivePath,
        onReceiveProgress: (rec, tot) {
      if (tot != -1) onProgress(0.6 + ((rec / tot) * 0.25));
    });

    onProgress(0.85);

    final bytes = File(archivePath).readAsBytesSync();
    String finalFfmpegPath = p.join(folderPath, getFfmpegFileName());

    if (archivePath.endsWith('.zip')) {
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.isFile && file.name.endsWith(getFfmpegFileName())) {
          final outFile = File(finalFfmpegPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          break;
        }
      }
    } else if (archivePath.endsWith('.tar.xz')) {
      final xzBytes = XZDecoder().decodeBytes(bytes);
      final archive = TarDecoder().decodeBytes(xzBytes);
      for (final file in archive) {
        if (file.isFile && file.name.endsWith('/bin/ffmpeg')) {
          final outFile = File(finalFfmpegPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          break;
        }
      }
    }

    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', finalFfmpegPath]);
    }
    final arcFile = File(archivePath);
    if (arcFile.existsSync()) {
      await arcFile.delete();
    }

    onProgress(1.0);
  }
}
