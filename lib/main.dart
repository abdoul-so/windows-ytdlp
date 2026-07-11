import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ytdlp/models/video_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdlp/models/download_task.dart';
import 'package:file_picker/file_picker.dart';
import 'services/ytdlp_service.dart';
import 'services/database/app_database.dart';
import 'services/database/history_dao.dart';
import 'services/database/cache_dao.dart';
import 'video/single_video_view.dart';
import 'playlist/playlist_view.dart';
import 'downloads/downloads_view.dart';
import 'services/component_manager.dart';

// Contrôleur global pour envoyer instantanément l'URL reçue du serveur vers l'IHM
final ValueNotifier<String?> remoteUrlNotifier = ValueNotifier<String?>(null);

// ── Point d'entrée & Serveur HTTP Local ────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Démarrage du serveur d'écoute pour l'extension Chrome/Firefox (Port 8888)
  _startLocalReceiver();

  // Nettoie le cache expiré au démarrage (tâche silencieuse)
  await database.clearCache();
  database.pruneExpiredCache();
  runApp(const MyApp());
}

/// Démarre le serveur HTTP local en tâche de fond pour capter les requêtes de l'extension
void _startLocalReceiver() async {
  try {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8888);
    debugPrint("🚀 Serveur récepteur Veloce à l'écoute sur http://localhost:8888");

    await for (HttpRequest request in server) {
      // Configuration CORS pour permettre au navigateur d'envoyer la requête
      request.response.headers.add("Access-Control-Allow-Origin", "*");
      request.response.headers
          .add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
      request.response.headers
          .add("Access-Control-Allow-Headers", "Content-Type");

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        continue;
      }

      if (request.method == 'POST' && request.uri.path == '/api/catch') {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content);

        if (data != null && data['url'] != null) {
          String url = data['url'];

          // Injecte l'URL captée
          remoteUrlNotifier.value = url;

          // 🚀 Nettoie immédiatement après pour permettre d'intercepter la même URL plus tard
          remoteUrlNotifier.value = null;

          // Amène l'application au premier plan sous Linux sans bloquer
          try {
            Process.run('wmctrl', ['-a', 'ytdlp']);
          } catch (_) {}
        }

        request.response
          ..statusCode = HttpStatus.ok
          ..write(jsonEncode(
              {"status": "success", "message": "URL captée avec succès !"}));
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    }
  } catch (e) {
    debugPrint("Erreur démarrage serveur local: $e");
  }
}

// ── Application racine ────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veloce Extractor Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardThemeData(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: _themeMode,
      home: MainScreen(onThemeChanged: toggleTheme),
    );
  }
}

// ── Écran principal ───────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const MainScreen({super.key, required this.onThemeChanged});

  static void cancelGlobalDownload(
      BuildContext context, VoidCallback onCancelled) {
    if (MainScreenState._activeTask != null &&
        MainScreenState._activeTask!.activeProcess != null) {
      MainScreenState._activeTask!.activeProcess!.kill();
      onCancelled();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Téléchargement annulé."),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  static VideoMetadata? lastSingleVideoMetadata;
  static String lastSingleVideoUrl = "";

  static VideoMetadata? lastPlaylistMetadata;
  static String lastPlaylistUrl = "";
  static int lastPlaylistPage = 1;
  static Set<String> lastPlaylistSelectedUrls = {};
  static Map<String, FileFormat?> lastPlaylistSelectedFormats = {};

  static final List<DownloadTask> _downloadQueue = [];
  static DownloadTask? _activeTask;

  static final ValueNotifier<int> queueNotifier = ValueNotifier(0);

  static List<DownloadTask> get downloadQueue => _downloadQueue;
  static DownloadTask? get activeTask => _activeTask;

  static void addTaskToQueue(DownloadTask task) {
    _downloadQueue.add(task);
    queueNotifier.value++;
  }

  static bool get isQueueActive =>
      _activeTask != null || _downloadQueue.any((t) => t.status == 'queued');
  static String? get activeTaskUrl => _activeTask?.url;
  static double get activeTaskProgress => _activeTask?.progress ?? 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _downloadHistory = [];
  String _customDownloadFolder = "Par défaut (Dossier App)";
  bool _hasUpdateAvailable = true;

  bool _isSettingUp = false;
  double _setupProgress = 0.0;
  String _setupError = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndSetupComponents();
    _processQueue();
    _loadSettingsAndHistory();
  }

  Future<void> _checkAndSetupComponents() async {
    bool ready = await ComponentManager.checkComponentsReady();
    if (!ready) {
      setState(() => _isSettingUp = true);
      try {
        await ComponentManager.downloadAndSetup(onProgress: (p) {
          if (mounted) setState(() => _setupProgress = p);
        });
      } catch (e) {
        if (mounted) {
          setState(
              () => _setupError = e.toString().replaceFirst('Exception: ', ''));
        }
      } finally {
        if (mounted && _setupError.isEmpty) {
          setState(() => _isSettingUp = false);
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🚀 BOUCLE DE TÉLÉCHARGEMENT AVEC PRISE EN CHARGE DES PAUSES ET REPRISES
  void _processQueue() async {
    if (_activeTask != null) return;

    // Filtre uniquement pour choper les tâches en attente 'queued'
    final nextTasks =
        _downloadQueue.where((t) => t.status == 'queued').toList();
    if (nextTasks.isEmpty) return;

    _activeTask = nextTasks.first;
    setState(() => _activeTask!.status = 'downloading');
    queueNotifier.value++;

    // Lancement et assignation du processus directement à la tâche active
    final process = await YtdlpService.downloadVideo(
      url: _activeTask!.url,
      targetFolder: _activeTask!.targetFolder,
      format: _activeTask!.selectedFormat,
      onProgress: (p) {
        if (mounted &&
            _activeTask != null &&
            _activeTask!.status == 'downloading') {
          setState(() => _activeTask!.progress = p);
          queueNotifier.value++;
        }
      },
      onComplete: () {},
    );

    _activeTask!.activeProcess = process;

    int exitCode = await process.exitCode;

    if (!mounted) return;

    // 🛑 GESTION SPÉCIALE SI INTERROMPU PAR LE BOUTON PAUSE
    if (_activeTask != null && _activeTask!.status == 'paused') {
      setState(() {
        _activeTask!.activeProcess = null;
        _activeTask = null; // Libère l'emplacement actif
      });
      queueNotifier.value++;
      _processQueue(); // Passe au téléchargement suivant de la liste
      return;
    }

    if (exitCode == 0) {
      if (_activeTask != null) {
        setState(() => _activeTask!.status = 'completed');

        String finalTitle = _activeTask!.metadata.title;

        // 🚀 CODE DE RENOMMAGE NATIF POST-TÉLÉCHARGEMENT SÉCURISÉ
        if (_activeTask!.customTitle != null &&
            _activeTask!.customTitle!.trim().isNotEmpty) {
          try {
            final directory = Directory(_activeTask!.targetFolder);
            if (await directory.exists()) {
              String sanitizedNewTitle = _activeTask!.customTitle!
                  .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
                  .trim();
              final files = directory.listSync();
              File? fileToRename;
              String extension = '.mp4';

              for (var file in files) {
                if (file is File) {
                  final fileName = file.uri.pathSegments.last;
                  // Vérifie si le fichier commence par le titre original de la vidéo
                  if (fileName.startsWith(_activeTask!.metadata.title)) {
                    fileToRename = file;
                    if (fileName.contains('.')) {
                      extension = fileName.substring(fileName.lastIndexOf('.'));
                    }
                    break;
                  }
                }
              }

              if (fileToRename != null && await fileToRename.exists()) {
                final newPath =
                    '${_activeTask!.targetFolder}/$sanitizedNewTitle$extension';
                await fileToRename.rename(newPath);
                finalTitle = sanitizedNewTitle; // Le titre renommé part en BDD
                debugPrint(
                    "🔥 Fichier renommé avec succès via dart:io en : $newPath");
              }
            }
          } catch (e) {
            debugPrint("Erreur lors du renommage du fichier : $e");
          }
        }

        await database.insertHistory(
          title: finalTitle,
          url: _activeTask!.url,
          type: _activeTask!.targetFolder.contains('Playlists')
              ? 'playlist'
              : 'video',
          formatExt: _activeTask!.selectedFormat?.ext ?? 'mp4',
          targetFolder: _activeTask!.targetFolder,
        );
        _loadSettingsAndHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Téléchargé : $finalTitle")));
        }
      }
    } else {
      if (_activeTask != null) {
        setState(() => _activeTask!.status = 'failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Échec : ${_activeTask!.metadata.title}"),
              backgroundColor: Colors.orange));
        }
      }
    }

    // Nettoie l'emplacement actif si terminé ou en échec, et retire de la liste active
    setState(() {
      if (_activeTask != null) {
        _downloadQueue.remove(_activeTask);
      }
      _activeTask = null;
    });
    queueNotifier.value++;

    _processQueue();
  }

  /// 🚀 ACTIONS ACTIONNÉES PAR LA PAGE DE TÉLÉCHARGEMENT
  void togglePauseTask(DownloadTask task) {
    setState(() {
      if (task.status == 'downloading' && task.activeProcess != null) {
        task.status = 'paused';
        task.activeProcess!
            .kill(); // Tue yt-dlp. Grâce à --continue, il reprendra au même octet !
      } else if (task.status == 'paused') {
        task.status = 'queued'; // Repasse en attente
      }
    });
    queueNotifier.value++;
    _processQueue(); // Relance la file
  }

  void triggerReDownload(Map<String, dynamic> historyItem) {
    // Nettoie le suffixe de la date dans le titre pour reconstruire les métadonnées de secours
    final cleanTitle = historyItem['title'].toString().split(' (').first;

    final mockMetadata = VideoMetadata(
      title: cleanTitle,
      thumbnail: '',
      formats: [],
    );

    final task = DownloadTask(
      url: historyItem['url'],
      metadata: mockMetadata,
      selectedFormat:
          null, // Sélection automatique du meilleur format par défaut
      targetFolder: historyItem['targetFolder'] ?? _customDownloadFolder,
      status: 'queued',
    );

    setState(() {
      _downloadQueue.add(task);
    });
    queueNotifier.value++;
    _processQueue();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Téléchargement relancé instantanément !"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _loadSettingsAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rows = await database.getHistory();
    if (!mounted) return;
    setState(() {
      _downloadHistory = rows.map((r) {
        final dt = DateTime.fromMillisecondsSinceEpoch(r.downloadedAt * 1000);
        final label =
            "${dt.day}/${dt.month}/${dt.year} à ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
        return <String, dynamic>{
          'title': '${r.title} ($label)',
          'url': r.url,
          'type': r.type,
          'id': r.id,
          'targetFolder': r.targetFolder,
          'formatExt': r.formatExt,
        };
      }).toList();
      _customDownloadFolder =
          prefs.getString('download_folder') ?? "Par défaut (Dossier App)";
    });
  }

  Future<void> _pickDownloadFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('download_folder', selectedDirectory);
      setState(() => _customDownloadFolder = selectedDirectory);
    }
  }

  Future<void> _clearAllHistory() async {
    await database.clearHistory();
    _loadSettingsAndHistory();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("L'historique des téléchargements a été vidé."),
          backgroundColor: Colors.green),
    );
  }

  Widget _buildSetupScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_setupError.isNotEmpty) ...[
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text("Erreur d'installation",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 8),
              Text(_setupError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.withAlpha(180))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _setupError = "";
                    _isSettingUp = true;
                  });
                  _checkAndSetupComponents();
                },
                child: const Text("Réessayer"),
              )
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text("Installation de l'environnement Python...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _setupProgress),
              const SizedBox(height: 8),
              Text("${(_setupProgress * 100).toStringAsFixed(0)}%"),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Veloce Extractor Pro",
              style: TextStyle(fontWeight: FontWeight.w800)),
          leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer()),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(
                  icon: Icon(Icons.movie_creation_rounded),
                  text: "Vidéo Unique"),
              Tab(icon: Icon(Icons.video_library_rounded), text: "Playlist"),
              Tab(
                  icon: Icon(Icons.download_done_rounded),
                  text: "Téléchargements"),
            ],
          ),
        ),
        drawer: _buildDrawer(isDarkMode),
        body: _isSettingUp
            ? _buildSetupScreen()
            : TabBarView(
                children: [
                  SingleVideoView(
                      onTaskAdded: () => setState(_processQueue),
                      customFolder: _customDownloadFolder,
                      onHistoryUpdate: _loadSettingsAndHistory),
                  PlaylistView(
                      customFolder: _customDownloadFolder,
                      onTasksAdded: () => setState(_processQueue),
                      onHistoryUpdate: _loadSettingsAndHistory),
                  DownloadsView(
                    history: _downloadHistory,
                    queue: _downloadQueue,
                    onTogglePause: togglePauseTask,
                    onReDownload: triggerReDownload,
                    onClearHistory: _clearAllHistory,
                    onRefreshHistory: _loadSettingsAndHistory,
                    // 🔥 IMPLÉMENTATION DU BOUTON DE SECOURS DE L'HISTORIQUE :
                    onRenameHistoryItem: (id, oldTitleWithDate, targetFolder, formatExt,
                        newTitle) async {
                      try {
                        final sanitizedNew = newTitle
                            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
                            .trim();
                        
                        // Isole le vrai nom du fichier original sans le tag de date (JJ/MM/AAAA...)
                        final cleanOldTitle = oldTitleWithDate.split(' (').first.trim();

                        final oldFile =
                            File('$targetFolder/$cleanOldTitle.$formatExt');
                        final newFile =
                            File('$targetFolder/$sanitizedNew.$formatExt');

                        // 1. On renomme physiquement sur le support de stockage
                        if (await oldFile.exists()) {
                          await oldFile.rename(newFile.path);
                        }

                        // 2. On met à jour l'enregistrement SQLite Drift
                        await database.updateHistoryTitle(id, sanitizedNew);

                        // 3. On recharge l'historique à l'écran
                        _loadSettingsAndHistory();

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Fichier renommé en : $sanitizedNew")),
                          );
                        }
                      } catch (e) {
                        debugPrint("Erreur renommage manuel historique : $e");
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDrawer(bool isDarkMode) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.settings_suggest_rounded,
                      size: 40, color: Colors.blue),
                  SizedBox(height: 10),
                  Text("Options Avancées",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
          ),
          ListTile(
            tileColor: _hasUpdateAvailable ? Colors.red.withAlpha(30) : null,
            leading: Icon(Icons.system_update,
                color: _hasUpdateAvailable ? Colors.red : null),
            title: Text(
                _hasUpdateAvailable ? "Mise à jour requise" : "Système à jour",
                style: TextStyle(
                    color: _hasUpdateAvailable ? Colors.red : null,
                    fontWeight: _hasUpdateAvailable
                        ? FontWeight.bold
                        : FontWeight.normal)),
            onTap: () => setState(() => _hasUpdateAvailable = false),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.folder_open_rounded, color: Colors.amber),
            title: const Text("Destination"),
            subtitle: Text(_customDownloadFolder,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.mode_edit_outline_rounded, size: 16),
            onTap: _pickDownloadFolder,
          ),
          const Divider(),
          SwitchListTile(
            secondary: Icon(isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            title: Text(isDarkMode ? "Bleu Nuit" : "Mode Clair"),
            value: isDarkMode,
            onChanged: (val) => widget.onThemeChanged(val),
          ),
          const Divider(),
        ],
      ),
    );
  }
}