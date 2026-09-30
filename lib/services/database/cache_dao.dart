import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'app_database.dart';
import '../../models/video_metadata.dart';

/// Durée de validité du cache (24 heures).
const Duration kCacheTtl = Duration(hours: 24);

/// DAO pour le cache des métadonnées yt-dlp.
/// Évite de relancer yt-dlp si la même URL a déjà été analysée récemment.
extension CacheDao on AppDatabase {
  // ── Lecture ──────────────────────────────────────────────────────────────

  /// Retourne les métadonnées en cache pour [url] si elles existent
  /// et ne sont pas expirées (< [kCacheTtl]). Sinon retourne null.
  Future<VideoMetadata?> getCachedMetadata(String url) async {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final ttlSec = kCacheTtl.inSeconds;

    final row = await (select(cacheTable)
          ..where((t) => t.url.equals(url))
          ..where((t) => t.cachedAt.isBiggerOrEqualValue(nowSec - ttlSec))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return null;

    try {
      final decoded = jsonDecode(row.metadataJson) as Map<String, dynamic>;
      debugPrint('[Cache] HIT pour : $url');
      return VideoMetadata.fromJson(decoded);
    } catch (e) {
      debugPrint('[Cache] Erreur de désérialisation : $e');
      return null;
    }
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Met en cache les métadonnées d'une vidéo (INSERT OR REPLACE).
  Future<void> cacheMetadata(String url, VideoMetadata meta) async {
    final formatsJson = jsonEncode(meta.toJson());
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (delete(cacheTable)..where((t) => t.url.equals(url))).go();
    await into(cacheTable).insert(
      CacheTableCompanion.insert(
        url: url,
        metadataJson: formatsJson,
        cachedAt: Value(now),
      ),
    );
    debugPrint('[Cache] MISS → mis en cache : $url');
  }

  // ── Suppression ───────────────────────────────────────────────────────────

  /// Supprime toutes les entrées expirées (ménage périodique).
  Future<int> pruneExpiredCache() {
    final expiredBefore =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - kCacheTtl.inSeconds;
      return (delete(cacheTable)
        ..where((t) => t.cachedAt.isSmallerThanValue(expiredBefore)))
      .go();
  }

  /// Vide tout le cache (utile pour forcer un rafraîchissement).
  Future<int> clearCache() {
    return delete(cacheTable).go();
  }
}
