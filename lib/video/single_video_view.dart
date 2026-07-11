import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytdlp/models/download_task.dart';
import 'package:ytdlp/models/video_metadata.dart';
import 'package:ytdlp/services/ytdlp_service.dart';
import 'package:ytdlp/main.dart';
import 'package:flutter/scheduler.dart';

class SingleVideoView extends StatefulWidget {
  final String customFolder;
  final VoidCallback onHistoryUpdate;
  final VoidCallback onTaskAdded;

  const SingleVideoView({
    super.key,
    required this.customFolder,
    required this.onHistoryUpdate,
    required this.onTaskAdded,
  });

  @override
  State<SingleVideoView> createState() => _SingleVideoViewState();
}

class _SingleVideoViewState extends State<SingleVideoView> {
  bool _isAnalyzing = false;
  bool _isCancelRequested = false; // 🔥 Ajouté pour traquer la demande d'arrêt
  String? _customTitle; // Stockera le titre modifié par l'utilisateur
  final TextEditingController _urlController = TextEditingController();
  VideoMetadata? _metadata;
  FileFormat? _selectedFormat;
  String? _clipboardUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // 1. Restauration d'abord de l'ancienne analyse sauvegardée globalement
    _metadata = MainScreenState.lastSingleVideoMetadata;
    _urlController.text = MainScreenState.lastSingleVideoUrl;
    if (_metadata != null && _metadata!.formats.isNotEmpty) {
      _selectedFormat = _metadata!.formats.first;
    }
    _checkClipboard();

    // 2. Écoute des URLs interceptées par le serveur HTTP local (prioritaire)
    remoteUrlNotifier.addListener(() {
      final incomingUrl = remoteUrlNotifier.value;
      if (incomingUrl != null && incomingUrl.isNotEmpty && mounted) {
        // On force l'exécution en toute sécurité sur le thread principal de Flutter
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _urlController.text = incomingUrl;
            });
            // Déclenche proprement l'analyse
            _analyzeVideo();
          }
        });
      }
    });
  }

  Future<void> _checkClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        String text = data!.text!.trim();
        if ((text.contains("youtube.com") || text.contains("youtu.be")) &&
            !text.contains("list=")) {
          if (mounted) {
            setState(() => _clipboardUrl = text);
          }
        }
      }
    } catch (_) {}
  }

  void _pasteClipboard() {
    if (_clipboardUrl != null) {
      _urlController.text = _clipboardUrl!;
      _analyzeVideo();
    }
  }

  Future<void> _analyzeVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    // 🔥 SI ON ANALYSE DÉJÀ : Le bouton agit comme un bouton "Arrêter"
    if (_isAnalyzing) {
      setState(() {
        _isCancelRequested = true;
        _isAnalyzing = false;
        _errorMessage = "Analyse interrompue par l'utilisateur.";
      });
      return; // On stoppe l'exécution ici
    }

    // ÉTAT DE DÉPART STANDARD
    setState(() {
      _isAnalyzing = true;
      _isCancelRequested = false; // Réinitialisation du jeton d'annulation
      _errorMessage = null;
      _metadata = null;
      _selectedFormat = null;
    });

    try {
      final meta = await YtdlpService.getMetadata(url);

      // 🔥 SÉCURITÉ : Si l'utilisateur a cliqué sur "Arrêter" pendant la requête réseau, on ignore le résultat
      if (_isCancelRequested) return;

      if (mounted) {
        setState(() {
          _metadata = meta;
          _customTitle =
              meta.title; // 🚀 INITIALISATION DU TITRE MODIFIABLE ICI
          if (meta.formats.isNotEmpty) {
            _selectedFormat = meta.formats.first;
          }
          // Sauvegarde dans l'état global persistant
          MainScreenState.lastSingleVideoMetadata = meta;
          MainScreenState.lastSingleVideoUrl = url;
        });
      }
    } catch (e) {
      if (_isCancelRequested) {
        return; // Ignore l'erreur si on a annulé volontairement
      }
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted && !_isCancelRequested) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _download() {
    if (_metadata == null) return;

    // 🚀 On garde les métadonnées d'origine intactes (pour que yt-dlp trouve le fichier)
    // et on transmet proprement le titre personnalisé à part dans le champ dédié.
    final task = DownloadTask(
      url: _urlController.text.trim(),
      metadata: _metadata!,
      selectedFormat: _selectedFormat,
      targetFolder: widget.customFolder,
      customTitle:
          _customTitle, // 🔥 Transmis nativement au paramètre de la tâche
    );

    MainScreenState.addTaskToQueue(task);
    widget.onTaskAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_customTitle != null
            ? "Ajouté à la file avec le nom personnalisé !"
            : "Ajouté à la file d'attente !"),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  // Bloc de rendu des détails de la vidéo analysée
  @override
  Widget build(BuildContext context) {
    final bool isQueueActive = MainScreenState.isQueueActive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ d'insertion d'URL
// Champ d'insertion d'URL
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: "Coller le lien de la vidéo YouTube...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        prefixIcon: const Icon(Icons.link_rounded),
                      ),
                      onSubmitted: (_) => _analyzeVideo(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_clipboardUrl != null &&
                      _urlController.text != _clipboardUrl)
                    IconButton.filledTonal(
                      tooltip: "Coller depuis le presse-papiers",
                      icon: const Icon(Icons.assignment_turned_in_rounded),
                      onPressed: _pasteClipboard,
                    ),
                  const SizedBox(width: 4),

                  // 🚀 LE NOUVEAU BOUTON DYNAMIQUE (ANALYSER / ARRÊTER) ICI :
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Passe au rouge vif si l'analyse est en cours
                      backgroundColor: _isAnalyzing
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    // Reste cliquable même pendant l'analyse pour intercepter l'arrêt
                    onPressed: _analyzeVideo,
                    icon: Icon(_isAnalyzing
                        ? Icons.stop_rounded
                        : Icons.analytics_rounded),
                    label: Text(_isAnalyzing ? "Arrêter" : "Analyser"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Message d'erreur s'il y en a un
          if (_errorMessage != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_metadata != null) ...[
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Miniature de la vidéo
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      _metadata!.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.play_circle_outline,
                            size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🚀 BLOC INTERACTIF ET CLIQUABLE
                        InkWell(
                          onTap: () => _showRenameDialog(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _customTitle ?? _metadata!.title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sélecteur de format
                        DropdownButtonFormField<FileFormat>(
                          decoration: InputDecoration(
                            labelText: "Choisir la Résolution / Qualité",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon:
                                const Icon(Icons.video_settings_rounded),
                          ),
                          // Utilisation correcte de 'value' (non déprécié sur DropdownButtonFormField)
                          initialValue: _selectedFormat,
                          items: _metadata!.formats.map((f) {
                            final sizeStr = f.formattedSize;
                            return DropdownMenuItem<FileFormat>(
                              value: f,
                              child: Text("${f.label} ($sizeStr)"),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedFormat = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Bouton d'action principal
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: isQueueActive
                                ? Colors.orange.shade700
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          icon: Icon(isQueueActive
                              ? Icons.queue_music_rounded
                              : Icons.download_rounded),
                          label: Text(
                            isQueueActive
                                ? "Ajouter à la file d'attente"
                                : "Démarrer l'extraction",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _download,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController renameController =
        TextEditingController(text: _customTitle ?? _metadata?.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Renommer la vidéo"),
          content: TextField(
            controller: renameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Nom du fichier",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (renameController.text.trim().isNotEmpty) {
                  setState(() {
                    _customTitle = renameController.text.trim();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }
}
