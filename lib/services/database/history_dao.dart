import 'package:drift/drift.dart';
import 'app_database.dart';

/// DAO (Data Access Object) pour l'historique des téléchargements.
/// Toutes les opérations sur la table [DownloadHistoryTable] passent par ici.
extension HistoryDao on AppDatabase {
  // ── Lecture ──────────────────────────────────────────────────────────────

  /// Retourne tous les entrées de l'historique, du plus récent au plus ancien.
  Future<List<DownloadHistoryTableData>> getHistory({int limit = 100}) {
    return (select(downloadHistoryTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.downloadedAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Insère un nouvel élément dans l'historique.
  Future<int> insertHistory({
    required String title,
    required String url,
    required String type,
    String formatExt = 'mp4',
    String targetFolder = '',
  }) {
    return into(downloadHistoryTable).insert(
      DownloadHistoryTableCompanion.insert(
        title: title,
        url: url,
        downloadedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        type: Value(type),
        formatExt: Value(formatExt),
        targetFolder: Value(targetFolder),
      ),
    );
  }

  // ── Suppression ───────────────────────────────────────────────────────────

  /// Supprime un élément de l'historique par son ID.
  Future<int> deleteHistoryEntry(int id) {
    return (delete(downloadHistoryTable)..where((t) => t.id.equals(id))).go();
  }

  /// Vide tout l'historique.
  Future<int> clearHistory() {
    return delete(downloadHistoryTable).go();
  }

  /// Met à jour le titre d'une entrée de l'historique par son ID.
  Future<bool> updateHistoryTitle(int id, String newTitle) {
    return (update(downloadHistoryTable)..where((t) => t.id.equals(id)))
        .write(DownloadHistoryTableCompanion(
          title: Value(newTitle),
        ))
        .then((rows) => rows > 0);
  }
}
