import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/foundation.dart';

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

  static Future<String> _getFfmpegUrl() async {
    final prefs = await SharedPreferences.getInstance();
    const String base =
        "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-06-21-13-34";
    if (Platform.isWindows) {
      return prefs.getString('ffmpeg_url_windows') ??
          "$base/ffmpeg-N-125146-gc6bb22dea0-win64-gpl.zip";
    }
    if (Platform.isLinux) {
      return prefs.getString('ffmpeg_url_linux') ??
          "$base/ffmpeg-N-125146-gc6bb22dea0-linux64-gpl.tar.xz";
    }
    if (Platform.isMacOS) {
      return prefs.getString('ffmpeg_url_macos') ??
          "https://evermeet.cx/ffmpeg/getrelease/zip";
    }
    return "https://evermeet.cx/ffmpeg/getrelease/zip";
  }

  static Future<bool> downloadAndSetup(
      {required Function(double) onProgress}) async {
    // 1. Vérification Python
    await _ensurePythonIsInstalled();

    final folderPath = await getTargetFolderPath();
    final targetFolder = Directory(folderPath);
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }

    // 2. Création de l'environnement virtuel
    await _createVenv(folderPath);
    onProgress(0.2);

    // 3. Installation de yt-dlp et curl-cffi via pip
    await _installPipPackages(folderPath);
    onProgress(0.5);

    // 4. Téléchargement et extraction de FFmpeg si nécessaire
    final ffmpegFile = File(p.join(folderPath, getFfmpegFileName()));
    if (!ffmpegFile.existsSync()) {
      await _downloadAndExtractFfmpeg(folderPath, (progress) {
        onProgress(0.5 + (progress * 0.5));
      });
    } else {
      onProgress(1.0);
    }

    onProgress(1.0);
    return true; // Une mise à jour physique a été effectuée
  }

  static Future<void> _ensurePythonIsInstalled() async {
    if (!await isPythonInstalled()) {
      throw Exception(
          "Python n'est pas installé. Veuillez l'installer pour continuer.");
    }
  }

  static Future<void> _createVenv(String folderPath) async {
    final venvPath = p.join(folderPath, 'venv_ytdlp');
    if (await Directory(venvPath).exists()) return; // Déjà créé

    final pythonCmd = getPythonCmd();
    var venvResult = await Process.run(pythonCmd, ['-m', 'venv', venvPath]);
    if (venvResult.exitCode != 0) {
      throw Exception("Échec de la création de l'environnement virtuel Python: ${venvResult.stderr}");
    }
  }

  static Future<void> _installPipPackages(String folderPath) async {
    final venvPath = p.join(folderPath, 'venv_ytdlp');
    final pipCmd = Platform.isWindows
        ? p.join(venvPath, 'Scripts', 'pip.exe')
        : p.join(venvPath, 'bin', 'pip');

    final prefs = await SharedPreferences.getInstance();
    final pipPackagesRaw = prefs.getString('ytdlp_pip_packages') ?? 'yt-dlp curl-cffi';
    final List<String> pipPackages = pipPackagesRaw.split(' ').where((s) => s.isNotEmpty).toList();
    if (pipPackages.isEmpty) pipPackages.addAll(['yt-dlp', 'curl-cffi']);

    var pipResult = await Process.run(pipCmd, ['install', '--upgrade', ...pipPackages]);
    if (pipResult.exitCode != 0) {
      throw Exception("Échec de l'installation des paquets yt-dlp: ${pipResult.stderr}");
    }
  }

  static Future<void> _downloadAndExtractFfmpeg(String folderPath, Function(double) onProgress) async {
    final ffmpegUrl = await _getFfmpegUrl();
    final archiveName = ffmpegUrl.endsWith('.zip') ? 'ffmpeg.zip' : 'ffmpeg.tar.xz';
    final archivePath = p.join(folderPath, archiveName);

    try {
      await _dio.download(ffmpegUrl, archivePath, onReceiveProgress: (rec, tot) {
        if (tot != -1) onProgress((rec / tot) * 0.8); // 80% pour le téléchargement
      });

      await _extractFileFromArchive(archivePath, folderPath);
      onProgress(1.0); // 20% pour l'extraction

    } finally {
      final arcFile = File(archivePath);
      if (await arcFile.exists()) {
        await arcFile.delete();
      }
    }
  }

  static Future<void> _extractFileFromArchive(String archivePath, String folderPath) async {
    final bytes = await File(archivePath).readAsBytes();
    final ffmpegBinName = getFfmpegFileName();
    final finalFfmpegPath = p.join(folderPath, ffmpegBinName);

    Archive archive;
    if (archivePath.endsWith('.zip')) {
      archive = ZipDecoder().decodeBytes(bytes);
    } else if (archivePath.endsWith('.tar.xz')) {
      archive = TarDecoder().decodeBytes(XZDecoder().decodeBytes(bytes));
    } else if (archivePath.endsWith('.tar.gz') || archivePath.endsWith('.tgz')) {
      archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
    } else {
      throw Exception("Format d'archive FFmpeg non supporté: $archivePath");
    }

    for (final file in archive) {
      if (file.isFile && file.name.endsWith('/$ffmpegBinName')) {
        final outFile = File(finalFfmpegPath);
        await outFile.writeAsBytes(file.content as List<int>);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', finalFfmpegPath]);
        }
        return;
      }
    }
    throw Exception("Impossible de trouver '$ffmpegBinName' dans l'archive FFmpeg.");
  }

  static Future<bool> forceUpdate({required Function(double) onProgress}) async {
    return await downloadAndSetup(onProgress: onProgress);
  }
}
