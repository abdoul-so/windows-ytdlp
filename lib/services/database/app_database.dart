import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Table 1 : Historique des téléchargements ─────────────────────────────────
class DownloadHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  IntColumn get downloadedAt => integer()(); // timestamp UNIX (secondes)
  TextColumn get type =>
      text().withDefault(const Constant('video'))(); // 'video' | 'playlist'
  TextColumn get formatExt => text().withDefault(const Constant('mp4'))();
  TextColumn get targetFolder => text().withDefault(const Constant(''))();
}

// ── Table 2 : Cache des métadonnées yt-dlp ───────────────────────────────────
class MetadataCacheTable extends Table {
  // Clé primaire = URL de la vidéo / playlist
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get thumbnail => text().withDefault(const Constant(''))();
  TextColumn get formatsJson => text()(); // formats sérialisés en JSON
  IntColumn get cachedAt => integer()();  // timestamp UNIX (secondes)

  @override
  Set<Column> get primaryKey => {url};
}

// ── Définition de la base de données Drift ───────────────────────────────────
@DriftDatabase(tables: [DownloadHistoryTable, MetadataCacheTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Migration ────────────────────────────────────────────────────────────
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Réservé pour les futures migrations
        },
      );
}

// ── Singleton ─────────────────────────────────────────────────────────────────
AppDatabase? _instance;
AppDatabase get database => _instance ??= AppDatabase();

// ── Ouverture de la connexion SQLite ─────────────────────────────────────────
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file =
        File(p.join(dbFolder.path, 'ytdlp_desktop_app', 'app_data.db'));
    // Crée le dossier parent si absent
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}
