import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

Future<String> _resolveDatabasePath() async {
  try {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory(docDir.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return p.join(dir.path, 'veloce_extractor.sqlite');
  } catch (_) {
    final fallbackDir = Directory('.');
    if (!await fallbackDir.exists()) {
      await fallbackDir.create(recursive: true);
    }
    return p.join(fallbackDir.path, 'veloce_extractor.sqlite');
  }
}

// ── TABLE : HISTORIQUE ────────────────────────────────────────────────────────
class HistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get type => text()(); // 'video' ou 'playlist'
  TextColumn get formatExt => text().withDefault(const Constant('mp4'))();
  TextColumn get targetFolder => text()();
  IntColumn get downloadedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch ~/ 1000)();
}

// ── TABLE : CACHE MÉTADONNÉES ──────────────────────────────────────────────────
class CacheTable extends Table {
  TextColumn get url => text()();
  TextColumn get metadataJson => text()();
  IntColumn get cachedAt => integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch ~/ 1000)();

  @override
  Set<Column> get primaryKey => {url};
}

// ── TABLE : FILE D'ATTENTE PERSISTANTE ─────────────────────────────────────────
class DownloadQueueTable extends Table {
  TextColumn get taskId => text()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get thumbnail => text()();
  TextColumn get targetFolder => text()();
  TextColumn get formatId => text().nullable()();
  TextColumn get formatExt => text().withDefault(const Constant('mp4'))();
  TextColumn get displayLabel => text().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('queued'))();

  @override
  Set<Column> get primaryKey => {taskId};
}

// ── BASE DE DONNÉES DRIFT ─────────────────────────────────────────────────────
@DriftDatabase(tables: [HistoryTable, CacheTable, DownloadQueueTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Ajout de la colonne task_id à la file persistante

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(downloadQueueTable);
          }

          if (from < 3) {
            final existingColumns = await customSelect(
              'PRAGMA table_info(download_queue_table)',
              variables: const [],
            ).get();
            final hasTaskId = existingColumns.any(
              (row) => row.data['name'] == 'task_id',
            );
            if (!hasTaskId) {
              await customStatement(
                  'ALTER TABLE download_queue_table ADD COLUMN task_id TEXT');
            }
            await customStatement(
                'UPDATE download_queue_table SET task_id = lower(hex(randomblob(8))) WHERE task_id IS NULL OR task_id = ""');
          }
        },
      );

  // ── MÉTHODES HISTORIQUE ──────────────────────────────────────────────────────
  Future<List<HistoryTableData>> getHistory() => select(historyTable).get();

  Future<int> insertHistory({
    required String title,
    required String url,
    required String type,
    required String formatExt,
    required String targetFolder,
  }) {
    return into(historyTable).insert(
      HistoryTableCompanion.insert(
        title: title,
        url: url,
        type: type,
        formatExt: Value(formatExt),
        targetFolder: targetFolder,
      ),
    );
  }

  Future<bool> updateHistoryTitle(int id, String newTitle) {
    return (update(historyTable)..where((t) => t.id.equals(id))).write(
      HistoryTableCompanion(title: Value(newTitle)),
    ).then((rows) => rows > 0);
  }

  Future<int> deleteHistoryEntry(int id) {
    return (delete(historyTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearHistory() => delete(historyTable).go();

  // ── MÉTHODES CACHE ───────────────────────────────────────────────────────────
  Future<CacheTableData?> getCache(String url) {
    return (select(cacheTable)..where((t) => t.url.equals(url))).getSingleOrNull();
  }

  Future<int> clearCache() => delete(cacheTable).go();

  Future<int> pruneExpiredCache() {
    final oneDayAgo = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 86400;
    return (delete(cacheTable)..where((t) => t.cachedAt.isSmallerThanValue(oneDayAgo))).go();
  }

  // ── MÉTHODES FILE D'ATTENTE (DOWNLOAD QUEUE) ──────────────────────────────────
  Future<List<DownloadQueueTableData>> getDownloadQueue() => select(downloadQueueTable).get();

  Future<int> insertOrUpdateQueue(DownloadQueueTableCompanion companion) async {
    final taskId = companion.taskId.value;
    await (delete(downloadQueueTable)..where((t) => t.taskId.equals(taskId))).go();
    return into(downloadQueueTable).insert(companion);
  }

  Future<bool> updateQueueProgress(String taskId, double progress) {
    return (update(downloadQueueTable)..where((t) => t.taskId.equals(taskId))).write(
      DownloadQueueTableCompanion(progress: Value(progress)),
    ).then((rows) => rows > 0);
  }

  Future<int> deleteQueueEntry(String taskId) {
    return (delete(downloadQueueTable)..where((t) => t.taskId.equals(taskId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final databasePath = await _resolveDatabasePath();
    final file = File(databasePath);
    return NativeDatabase.createInBackground(file);
  });
}

// Instance globale unique
final AppDatabase database = AppDatabase();