import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'video_metadata.dart';
import '../services/database/app_database.dart';

String _generateTaskId() {
  final rand = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
}

/// Représente une tâche unique dans la file d'attente de téléchargement.
class DownloadTask {
  final String taskId;
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
    String? taskId,
    required this.url,
    required this.metadata,
    required this.selectedFormat,
    required this.targetFolder,
    this.progress = 0.0,
    this.status = 'queued',
    this.activeProcess,
    this.customTitle,
  }) : taskId = taskId ?? _generateTaskId();

  /// Permet de cloner une tâche existante et de lui attribuer un nouvel ID.
  DownloadTask cloneForRetry({String? statusOverride}) {
    return DownloadTask(
      taskId: _generateTaskId(),
      url: url,
      metadata: metadata,
      selectedFormat: selectedFormat,
      targetFolder: targetFolder,
      progress: 0.0,
      status: statusOverride ?? status,
      customTitle: customTitle,
    );
  }

  /// Convertit la tâche en compagnon Drift pour l'insertion ou la mise à jour
  DownloadQueueTableCompanion toCompanion() {
    return DownloadQueueTableCompanion(
      taskId: drift.Value(taskId),
      url: drift.Value(url),
      title: drift.Value(customTitle ?? metadata.title),
      thumbnail: drift.Value(metadata.thumbnail),
      targetFolder: drift.Value(targetFolder),
      formatId: drift.Value(selectedFormat?.formatId),
      formatExt: drift.Value(selectedFormat?.ext ?? 'mp4'),
      displayLabel: drift.Value(selectedFormat?.displayLabel),
      progress: drift.Value(progress),
      status: drift.Value(status == 'downloading' ? 'queued' : status), // Évite de sauvegarder en état 'downloading' instable
    );
  }

  /// Reconstruit une instance de DownloadTask à partir des données de la base de données
  factory DownloadTask.fromDbData(DownloadQueueTableData data) {
    final format = data.formatId != null
        ? FileFormat(
            formatId: data.formatId!,
            ext: data.formatExt,
            vcodec: 'unknown',
            acodec: 'unknown',
            displayLabel: data.displayLabel ?? '${data.formatExt} (Format sauvegardé)',
          )
        : null;

    return DownloadTask(
      taskId: data.taskId,
      url: data.url,
      metadata: VideoMetadata(
        title: data.title,
        thumbnail: data.thumbnail,
        formats: format != null ? [format] : [],
      ),
      selectedFormat: format,
      targetFolder: data.targetFolder,
      progress: data.progress,
      status: data.status,
      customTitle: data.title,
    );
  }
}