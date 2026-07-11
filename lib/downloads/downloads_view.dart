import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Requis pour Clipboard
import 'package:ytdlp/models/download_task.dart';
import '../services/database/app_database.dart';
import '../services/database/history_dao.dart';

class DownloadsView extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final List<DownloadTask> queue;
  final Function(DownloadTask) onTogglePause;
  final Function(Map<String, dynamic>) onReDownload;
  final VoidCallback onClearHistory;
  final VoidCallback onRefreshHistory;
  final Function(int id, String oldTitle, String targetFolder, String formatExt, String newTitle)
      onRenameHistoryItem; 

  const DownloadsView({
    super.key,
    required this.history,
    required this.queue,
    required this.onTogglePause,
    required this.onReDownload,
    required this.onClearHistory,
    required this.onRefreshHistory,
    required this.onRenameHistoryItem, 
  });

  void _copyToClipboard(BuildContext context, String url) {
    if (url.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lien copié dans le presse-papiers ! 📋"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openFolder(String folderPath) {
    if (Platform.isLinux) {
      Process.run('xdg-open', [folderPath]);
    } else if (Platform.isWindows) {
      Process.run('explorer', [folderPath]);
    } else if (Platform.isMacOS) {
      Process.run('open', [folderPath]);
    }
  }

  void _showManualRenameDialog(
      BuildContext context, Map<String, dynamic> item) {
    final int id = item['id'];
    final String currentTitleWithDate = item['title'] ?? '';
    final String targetFolder = item['targetFolder'] ?? '';
    final String formatExt = item['formatExt'] ?? 'mp4';

    final String currentCleanTitle = currentTitleWithDate.split(' (').first.trim();

    final TextEditingController renameController =
        TextEditingController(text: currentCleanTitle);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Renommer le fichier"),
          content: TextField(
            controller: renameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Nouveau nom",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final String newTitle = renameController.text.trim();
                if (newTitle.isNotEmpty && newTitle != currentCleanTitle) {
                  onRenameHistoryItem(
                      id, currentTitleWithDate, targetFolder, formatExt, newTitle);
                }
                Navigator.pop(ctx);
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = queue
        .where((task) =>
            task.status == 'downloading' ||
            task.status == 'paused' ||
            task.status == 'queued')
        .toList();

    // Si tout est vide, on garde le centrage propre de l'écran vide
    if (activeTasks.isEmpty && history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_done_rounded,
                size: 64, color: Colors.grey.withAlpha(100)),
            const SizedBox(height: 16),
            Text(
              "Aucun téléchargement en cours ni terminé",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.withAlpha(180),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // ================= SECTION : EN COURS =================
        if (activeTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.cloud_download_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "En cours (${activeTasks.length})",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = activeTasks[index];
                final isDownloading = task.status == 'downloading';
                final isPaused = task.status == 'paused';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: isPaused
                        ? const Icon(Icons.pause_circle_filled_rounded,
                            color: Colors.orange, size: 32)
                        : const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                    title: Text(
                      task.metadata.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withAlpha(50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPaused
                              ? "En pause • ${(task.progress * 100).toStringAsFixed(1)}%"
                              : "Téléchargement... • ${(task.progress * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                              fontSize: 12,
                              color: isPaused ? Colors.orange : Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isDownloading
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isDownloading ? Colors.orange : Colors.green,
                      ),
                      tooltip: isDownloading ? "Mettre en pause" : "Reprendre",
                      onPressed: () => onTogglePause(task),
                    ),
                  ),
                );
              },
              childCount: activeTasks.length,
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 24)),
        ],

        // ================= SECTION : HISTORIQUE =================
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Historique (${history.length})",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                    label: const Text("Tout effacer"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Vider l'historique ?"),
                          content: const Text("Cette action est irréversible."),
                          actions: [
                            TextButton(
                              child: const Text("Annuler"),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white),
                              onPressed: onClearHistory,
                              child: const Text("Effacer"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        if (history.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  "Aucun téléchargement terminé",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withAlpha(180),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = history[index];
                final String itemUrl = item['url'] ?? '';
                final String targetFolder = item['targetFolder'] ?? '';
                final bool isPlaylist = item['type'] == 'playlist';

                return Dismissible(
                  key: Key(item['id'].toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    if (item['id'] != null) {
                      await database.deleteHistoryEntry(item['id']);
                      onRefreshHistory();
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(
                        item['title'] ?? 'Vidéo téléchargée',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(isPlaylist ? 'Playlist' : 'Vidéo'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mode_edit_outline_rounded,
                                color: Colors.blueAccent, size: 20),
                            tooltip: "Renommer le fichier",
                            onPressed: () => _showManualRenameDialog(context, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.replay_rounded,
                                color: Colors.blue, size: 20),
                            tooltip: "Re-télécharger",
                            onPressed: () => onReDownload(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy_rounded,
                                color: Colors.grey, size: 20),
                            tooltip: "Copier l'URL d'origine",
                            onPressed: () => _copyToClipboard(context, itemUrl),
                          ),
                          IconButton(
                            icon: const Icon(Icons.folder_open,
                                color: Colors.blue, size: 20),
                            tooltip: "Ouvrir le dossier",
                            onPressed: () => _openFolder(targetFolder),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: history.length,
            ),
          ),
      ],
    );
  }
}
