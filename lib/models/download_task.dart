import 'dart:io';
import 'video_metadata.dart';

/// Représente une tâche unique dans la file d'attente de téléchargement.
class DownloadTask {
  final String url;
  final VideoMetadata metadata;
  final FileFormat? selectedFormat;
  final String targetFolder;
  String? customTitle;
  double progress;
  String status; // 'queued', 'downloading', 'paused', 'completed', 'failed'

  /// Référence vers le processus yt-dlp en cours (permet de mettre en pause / tuer)
  Process? activeProcess;

  DownloadTask({
    required this.url,
    required this.metadata,
    required this.selectedFormat,
    required this.targetFolder,
    this.progress = 0.0,
    this.status = 'queued',
    this.activeProcess,
    this.customTitle,
  });

  /// Permet de cloner une tâche existante pour la re-télécharger
  DownloadTask cloneForRetry() {
    return DownloadTask(
      url: url,
      metadata: metadata,
      selectedFormat: selectedFormat,
      targetFolder: targetFolder,
      progress: 0.0,
      status: 'queued',
    );
  }
}
