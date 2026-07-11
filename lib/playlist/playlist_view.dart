import 'package:flutter/material.dart';
import 'package:ytdlp/models/download_task.dart';
import 'package:ytdlp/models/video_metadata.dart';
import 'package:ytdlp/services/ytdlp_service.dart';
import 'package:ytdlp/main.dart';
import 'playlist_video_card.dart';

class PlaylistView extends StatefulWidget {
  final String customFolder;
  final VoidCallback onHistoryUpdate;
  final VoidCallback onTasksAdded;
  const PlaylistView({
    super.key,
    required this.customFolder,
    required this.onHistoryUpdate,
    required this.onTasksAdded,
  });

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final TextEditingController _urlController = TextEditingController();
  bool _isAnalyzing = false;
  VideoMetadata? _metadata;
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  Set<String> _selectedUrls = {};
  final bool _isQueueRunning = false;

  final Map<String, VideoMetadata> _detailedMetadata = {};
  Map<String, FileFormat?> _selectedFormats = {};
  final Map<String, bool> _isAnalyzingItem = {};

  bool get isAnyTaskActive => MainScreenState.isQueueActive;

  @override
  void initState() {
    super.initState();
    _metadata = MainScreenState.lastPlaylistMetadata;
    _urlController.text = MainScreenState.lastPlaylistUrl;
    _currentPage = MainScreenState.lastPlaylistPage;
    _selectedUrls = MainScreenState.lastPlaylistSelectedUrls;
    _selectedFormats = MainScreenState.lastPlaylistSelectedFormats;
  }

  /// Réinitialise complètement l'état de l'écran pour analyser un nouveau lien
  void _clearPlaylist() {
    setState(() {
      _metadata = null;
      _urlController.clear();
      _selectedUrls.clear();
      _selectedFormats.clear();
      _detailedMetadata.clear();
      _isAnalyzingItem.clear();
      _currentPage = 1;

      // Nettoyage de la persistance globale
      MainScreenState.lastPlaylistMetadata = null;
      MainScreenState.lastPlaylistUrl = "";
      MainScreenState.lastPlaylistPage = 1;
      MainScreenState.lastPlaylistSelectedUrls = {};
      MainScreenState.lastPlaylistSelectedFormats = {};
    });
  }

  Future<void> _analyzePlaylist({int page = 1}) async {
    if (_urlController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      if (page == 1) {
        _metadata = null;
        _selectedUrls.clear();
        _selectedFormats.clear();
        _detailedMetadata.clear();
        _isAnalyzingItem.clear();
      }
    });

    try {
      final meta = await YtdlpService.getMetadata(_urlController.text.trim());
      if (mounted) {
        setState(() {
          _metadata = meta;
          _currentPage = page;

          MainScreenState.lastPlaylistMetadata = meta;
          MainScreenState.lastPlaylistUrl = _urlController.text.trim();
          MainScreenState.lastPlaylistPage = page;
          MainScreenState.lastPlaylistSelectedUrls = _selectedUrls;
          MainScreenState.lastPlaylistSelectedFormats = _selectedFormats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Erreur d'analyse : ${e.toString().replaceFirst('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _analyzeSingleItem(PlaylistEntry video) async {
    if (_detailedMetadata.containsKey(video.url)) return;

    setState(() => _isAnalyzingItem[video.url] = true);

    try {
      final itemMeta = await YtdlpService.getMetadata(video.url);
      if (mounted) {
        setState(() {
          _detailedMetadata[video.url] = itemMeta;
          if (itemMeta.formats.isNotEmpty) {
            _selectedFormats[video.url] = itemMeta.formats.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Échec de l'analyse de l'élément : ${video.title}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzingItem[video.url] = false);
      }
    }
  }

  void _downloadSelected() {
    if (_selectedUrls.isEmpty) return;

    int addedCount = 0;
    for (var videoUrl in _selectedUrls) {
      final video =
          _metadata!.playlistVideos.firstWhere((v) => v.url == videoUrl);
      final hasDetails = _detailedMetadata.containsKey(videoUrl);
      final metaToUse = hasDetails
          ? _detailedMetadata[videoUrl]!
          : VideoMetadata(
              title: video.title,
              thumbnail: video.thumbnail,
              formats: [],
            );

      final task = DownloadTask(
        url: video.url,
        metadata: metaToUse,
        targetFolder: widget.customFolder,
        selectedFormat: _selectedFormats[video.url],
      );

      MainScreenState.addTaskToQueue(task);
      addedCount++;
    }

    widget.onTasksAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "$addedCount vidéo(s) ajoutée(s) à la file globale de téléchargement !"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction dynamique des widgets de la playlist
    Widget playlistContent = const SizedBox.shrink();

    if (_metadata != null) {
      final totalItems = _metadata!.playlistVideos.length;
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      var endIndex = startIndex + _itemsPerPage;
      if (endIndex > totalItems) endIndex = totalItems;

      final paginatedVideos =
          _metadata!.playlistVideos.sublist(startIndex, endIndex);
      final totalPages = (totalItems / _itemsPerPage).ceil();

      playlistContent = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metadata!.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$totalItems vidéos trouvées",
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                        ],
                      ),
                    ),
                    TextButtonSelectAll(
                      metadata: _metadata,
                      selectedUrls: _selectedUrls,
                      isQueueRunning: _isQueueRunning,
                      onChanged: () => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: paginatedVideos.length,
                itemBuilder: (context, index) {
                  final video = paginatedVideos[index];
                  final isChecked = _selectedUrls.contains(video.url);
                  final isDownloading =
                      MainScreenState.activeTaskUrl == video.url;

                  if (isChecked &&
                      !_detailedMetadata.containsKey(video.url) &&
                      !(_isAnalyzingItem[video.url] ?? false)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _analyzeSingleItem(video);
                    });
                  }

                  return PlaylistVideoCard(
                    video: video,
                    isChecked: isChecked,
                    isDownloading: isDownloading,
                    isAnalyzingItem: _isAnalyzingItem[video.url] ?? false,
                    isDisabled: _isQueueRunning,
                    itemMetadata: _detailedMetadata[video.url],
                    selectedFormat: _selectedFormats[video.url],
                    onCheckChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedUrls.add(video.url);
                        } else {
                          _selectedUrls.remove(video.url);
                        }
                      });
                    },
                    onFormatChanged: (val) =>
                        setState(() => _selectedFormats[video.url] = val),
                    onCancelDownload: () => MainScreen.cancelGlobalDownload(
                        context, () => setState(() {})),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () => setState(() {
                            _currentPage--;
                            MainScreenState.lastPlaylistPage = _currentPage;
                          })
                      : null,
                ),
                Text("Page $_currentPage sur $totalPages"),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages
                      ? () => setState(() {
                            _currentPage++;
                            MainScreenState.lastPlaylistPage = _currentPage;
                          })
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(isAnyTaskActive
                  ? Icons.queue_play_next_rounded
                  : Icons.download_rounded),
              label: Text(
                "Télécharger la Sélection (${_selectedUrls.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _selectedUrls.isEmpty ? null : _downloadSelected,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🚀 CHAMP DE RECHERCHE DE PLAYLIST MODIFIÉ
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "Coller le lien de la Playlist YouTube...",
              prefixIcon: const Icon(Icons.playlist_play_rounded),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_urlController.text.isNotEmpty && !_isAnalyzing)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearPlaylist, // Bouton de réinitialisation
                    ),
                  // Le bouton change dynamiquement selon l'état d'analyse
                  IconButton(
                    icon: Icon(
                      _isAnalyzing
                          ? Icons.stop_circle_rounded // Icône Stop si en cours
                          : Icons.arrow_forward, // Flèche standard sinon
                      color: _isAnalyzing ? Colors.red : null,
                    ),
                    tooltip: _isAnalyzing ? "Arrêter l'analyse" : "Analyser",
                    // Appelle la même fonction : elle gèrera l'annulation en interne
                    onPressed: _urlController.text.trim().isEmpty
                        ? null
                        : () => _analyzePlaylist(page: 1),
                  ),
                ],
              ),
            ),
            onSubmitted: (_) => _analyzePlaylist(page: 1),
          ),
          // Insertion dynamique du contenu (vide ou liste complète)
          playlistContent,
        ],
      ),
    );
  }
}

class TextButtonSelectAll extends StatelessWidget {
  final VideoMetadata? metadata;
  final Set<String> selectedUrls;
  final bool isQueueRunning;
  final VoidCallback onChanged;

  const TextButtonSelectAll({
    super.key,
    required this.metadata,
    required this.selectedUrls,
    required this.isQueueRunning,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool allChecked = selectedUrls.length == metadata?.playlistVideos.length;
    return TextButton.icon(
      icon: Icon(
        allChecked
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        size: 18,
      ),
      label: Text(allChecked ? "Tout décocher" : "Tout cocher",
          style: const TextStyle(fontSize: 13)),
      onPressed: isQueueRunning
          ? null
          : () {
              if (allChecked) {
                selectedUrls.clear();
              } else {
                for (var v in metadata!.playlistVideos) {
                  selectedUrls.add(v.url);
                }
              }
              onChanged();
            },
    );
  }
}
