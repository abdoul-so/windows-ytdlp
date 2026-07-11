import 'package:flutter/material.dart';
import 'package:ytdlp/models/video_metadata.dart';
import 'package:ytdlp/main.dart';

/// Carte d'une vidéo individuelle dans une playlist.
/// Affichage premium : miniature 16:9 avec dégradé, badge de statut,
/// sélecteur de format stylé, barre de progression en cours de téléchargement.
class PlaylistVideoCard extends StatelessWidget {
  final PlaylistEntry video;
  final bool isChecked;
  final bool isDownloading;
  final bool isAnalyzingItem;
  final bool isDisabled;
  final VideoMetadata? itemMetadata;
  final FileFormat? selectedFormat;
  final ValueChanged<bool?> onCheckChanged;
  final ValueChanged<FileFormat?> onFormatChanged;
  final VoidCallback onCancelDownload;

  const PlaylistVideoCard({
    super.key,
    required this.video,
    required this.isChecked,
    required this.isDownloading,
    required this.isAnalyzingItem,
    required this.isDisabled,
    required this.itemMetadata,
    required this.selectedFormat,
    required this.onCheckChanged,
    required this.onFormatChanged,
    required this.onCancelDownload,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDetails = itemMetadata != null;
    final String thumbnail =
        hasDetails ? itemMetadata!.thumbnail : video.thumbnail;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Miniature 16:9 avec dégradé et badge ──
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderThumb(),
                      )
                    : _placeholderThumb(),

                // Dégradé sombre du bas
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black38,
                        Colors.black87,
                      ],
                      stops: [0.5, 0.78, 1.0],
                    ),
                  ),
                ),

                // Titre positionné en bas de la miniature
                Positioned(
                  left: 12,
                  right: 56,
                  bottom: 12,
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge statut (coin haut-droit)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _StatusBadge(
                    isDownloading: isDownloading,
                    isAnalyzing: isAnalyzingItem,
                    isChecked: isChecked,
                  ),
                ),

                // Checkbox (coin bas-droit)
                Positioned(
                  bottom: 6,
                  right: 4,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: isDisabled ? null : onCheckChanged,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).colorScheme.primary;
                        }
                        return Colors.white.withAlpha(180);
                      }),
                      checkColor: Colors.white,
                      side: const BorderSide(color: Colors.white70, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Barre de progression si en cours ──
          if (isDownloading) _DownloadProgressBar(onCancel: onCancelDownload),

          // ── Chargement des détails ──
          if (isAnalyzingItem && !hasDetails)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text("Analyse du format...",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

          // ── Sélecteur de format (si détails disponibles) ──
          if (hasDetails)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 14, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        "Format pour cette vidéo :",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withAlpha(120),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FileFormat>(
                        value: selectedFormat,
                        isExpanded: true,
                        onChanged: isDownloading ? null : onFormatChanged,
                        items: itemMetadata!.formats
                            .map((f) => DropdownMenuItem<FileFormat>(
                                  value: f,
                                  child: Text(f.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Index / infos basiques si pas encore analysé ──
          if (!hasDetails && !isAnalyzingItem)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  const Icon(Icons.video_library_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "Vidéo #${video.index} · Appuyer pour charger les formats",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholderThumb() => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.video_library_rounded,
            size: 48, color: Colors.white30),
      );
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isDownloading;
  final bool isAnalyzing;
  final bool isChecked;

  const _StatusBadge({
    required this.isDownloading,
    required this.isAnalyzing,
    required this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color color;
    late String label;

    if (isDownloading) {
      icon = Icons.download_rounded;
      color = Colors.blue;
      label = "DL";
    } else if (isAnalyzing) {
      icon = Icons.hourglass_top_rounded;
      color = Colors.orange;
      label = "...";
    } else if (isChecked) {
      icon = Icons.check_circle;
      color = Colors.green;
      label = "Sélec.";
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DownloadProgressBar extends StatelessWidget {
  final VoidCallback onCancel;
  const _DownloadProgressBar({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final double progress =
        MainScreenState.activeTaskProgress;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: Colors.grey.withAlpha(60),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  "Téléchargement : ${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
            padding: EdgeInsets.zero,
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }
}
