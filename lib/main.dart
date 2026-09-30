import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ytdlp/models/video_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdlp/models/download_task.dart';
import 'package:file_picker/file_picker.dart';
import 'services/ytdlp_service.dart';
import 'services/database/app_database.dart';
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

          // Injecte l'URL captée puis la nettoie après un court délai pour permettre
          // à l'UI de la consommer sans perdre la prochaine interception.
          remoteUrlNotifier.value = url;
          Future.delayed(const Duration(milliseconds: 150), () {
            if (remoteUrlNotifier.value == url) {
              remoteUrlNotifier.value = null;
            }
          });

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
      BuildContext context, VoidCallback onCancelled) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (MainScreenState.activeTasks.isNotEmpty) {
      final task = MainScreenState.activeTasks.first;
      if (task.activeProcess != null) {
        task.activeProcess!.kill();
      }
      task.status = 'failed';
      MainScreenState.downloadQueue.remove(task);
      await database.deleteQueueEntry(task.taskId);
      onCancelled();
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
              content: Text("Téléchargement de ${task.metadata.title} annulé."),
              backgroundColor: Colors.red),
        );
      }
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
  static final List<DownloadTask> _activeTasks = [];

  static final ValueNotifier<int> queueNotifier = ValueNotifier(0);

  static List<DownloadTask> get downloadQueue => _downloadQueue;
  static List<DownloadTask> get activeTasks => _activeTasks;

  static void addTaskToQueue(DownloadTask task) async {
    _downloadQueue.add(task);
    await database.insertOrUpdateQueue(task.toCompanion());
    queueNotifier.value++;
  }

  static bool isUrlDownloading(String url) {
    return _activeTasks.any((t) => t.url == url && t.status == 'downloading');
  }

  static double getTaskProgressForUrl(String url) {
    try {
      final task = _downloadQueue.firstWhere((t) => t.url == url);
      return task.progress;
    } catch (_) {
      return 0.0;
    }
  }

  static void cancelTaskByUrl(
      BuildContext context, String url, VoidCallback onCancelled) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    DownloadTask? taskToCancel;
    for (var task in _downloadQueue) {
      if (task.url == url) {
        taskToCancel = task;
        break;
      }
    }
    if (taskToCancel != null) {
      if (taskToCancel.activeProcess != null) {
        taskToCancel.activeProcess!.kill();
      }
      taskToCancel.status = 'failed';
      _activeTasks.remove(taskToCancel);
      _downloadQueue.remove(taskToCancel);
      await database.deleteQueueEntry(taskToCancel.taskId);
      onCancelled();
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
              content: Text("Téléchargement annulé : ${taskToCancel.metadata.title}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  static bool get isQueueActive =>
      _activeTasks.isNotEmpty || _downloadQueue.any((t) => t.status == 'queued');
  static String? get activeTaskUrl => _activeTasks.isNotEmpty ? _activeTasks.first.url : null;
  static double get activeTaskProgress => _activeTasks.isNotEmpty ? _activeTasks.first.progress : 0.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _downloadHistory = [];
  String _customDownloadFolder = "Par défaut (Dossier App)";

  bool _isSettingUp = false;
  double _setupProgress = 0.0;
  String _setupError = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndSetupComponents();
    _loadQueueFromDatabase().then((_) {
      _processQueue();
    });
    _loadSettingsAndHistory();
  }

  Future<void> _loadQueueFromDatabase() async {
    final cachedQueue = await database.getDownloadQueue();
    if (cachedQueue.isEmpty) {
      return;
    }

    final loadedTasks = <DownloadTask>[];
    for (var data in cachedQueue) {
      final task = DownloadTask.fromDbData(data);
      if (task.taskId.isEmpty) {
        final newTask = task.cloneForRetry(statusOverride: task.status);
        await database.insertOrUpdateQueue(newTask.toCompanion());
        loadedTasks.add(newTask);
      } else {
        loadedTasks.add(task);
      }
    }

    for (final task in loadedTasks) {
      if (task.status == 'downloading') {
        task.status = 'paused';
        await database.insertOrUpdateQueue(task.toCompanion());
      }
    }

    setState(() {
      _downloadQueue
        ..clear()
        ..addAll(loadedTasks);
    });
    queueNotifier.value++;
  }

  @override
  void dispose() {
    _pauseActiveDownloads();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _pauseActiveDownloads();
    }
  }

  Future<void> _pauseActiveDownloads() async {
    for (final task in List<DownloadTask>.from(_activeTasks)) {
      if (task.status == 'downloading' && task.activeProcess != null) {
        task.status = 'paused';
        try {
          task.activeProcess!.kill();
        } catch (_) {}
        task.activeProcess = null;
        await database.insertOrUpdateQueue(task.toCompanion());
      }
    }
    if (mounted) {
      setState(() {});
      queueNotifier.value++;
    }
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Quitter Veloce Extractor Pro'),
          content: const Text(
              'Les téléchargements en cours seront mis en pause avant de quitter.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _pauseActiveDownloads();
      exit(0);
    }
  }

  Future<void> _checkAndSetupComponents() async {
    if (!mounted) return;

    setState(() {
      _isSettingUp = true;
      _setupProgress = 0.0;
      _setupError = "";
    });

    try {
      final ready = await ComponentManager.checkComponentsReady();
      if (!ready) {
        await ComponentManager.downloadAndSetup(onProgress: (p) {
          if (mounted) {
            setState(() => _setupProgress = p);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _setupError = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSettingUp = false;
          _setupProgress = 1.0;
        });
      }
    }
  }

  /// 🚀 BOUCLE DE TÉLÉCHARGEMENT AVEC CONCURRENCE DYNAMIQUE
  void _processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final maxConcurrency = prefs.getInt('download_concurrency') ?? 1;

    while (_activeTasks.length < maxConcurrency) {
      final nextTasks =
          _downloadQueue.where((t) => t.status == 'queued').toList();
      if (nextTasks.isEmpty) break;

      final task = nextTasks.first;
      setState(() => task.status = 'downloading');
      _activeTasks.add(task);
      await database.insertOrUpdateQueue(task.toCompanion());
      queueNotifier.value++;

      _runTask(task);
    }
  }

  void _runTask(DownloadTask task) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final process = await YtdlpService.downloadVideo(
      url: task.url,
      targetFolder: task.targetFolder,
      format: task.selectedFormat,
      onProgress: (p) {
        if (mounted &&
            task.status == 'downloading') {
          setState(() => task.progress = p);
          database.updateQueueProgress(task.taskId, p);
          queueNotifier.value++;
        }
      },
      onComplete: () {},
    );

    task.activeProcess = process;

    int exitCode = await process.exitCode;

    if (!mounted) return;

    if (task.status == 'paused') {
      setState(() {
        task.activeProcess = null;
        _activeTasks.remove(task);
      });
      await database.insertOrUpdateQueue(task.toCompanion());
      queueNotifier.value++;
      _processQueue();
      return;
    }

    if (exitCode == 0) {
      setState(() => task.status = 'completed');

      String finalTitle = task.metadata.title;

      if (task.customTitle != null &&
          task.customTitle!.trim().isNotEmpty) {
        try {
          final directory = Directory(task.targetFolder);
          if (await directory.exists()) {
            String sanitizedNewTitle = task.customTitle!
                .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
                .trim();
            final files = directory.listSync();
            File? fileToRename;
            String extension = '.mp4';

            for (var file in files) {
              if (file is File) {
                final fileName = file.uri.pathSegments.last;
                if (fileName.startsWith(task.metadata.title)) {
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
                  '${task.targetFolder}/$sanitizedNewTitle$extension';
              await fileToRename.rename(newPath);
              finalTitle = sanitizedNewTitle;
              debugPrint("🔥 Fichier renommé en : $newPath");
            }
          }
        } catch (e) {
          debugPrint("Erreur lors du renommage du fichier : $e");
        }
      }

      await database.deleteQueueEntry(task.taskId);
      await database.insertHistory(
        title: finalTitle,
        url: task.url,
        type: task.targetFolder.contains('Playlists')
            ? 'playlist'
            : 'video',
        formatExt: task.selectedFormat?.ext ?? 'mp4',
        targetFolder: task.targetFolder,
      );
      _loadSettingsAndHistory();

      if (mounted && messenger != null) {
        messenger.showSnackBar(
            SnackBar(content: Text("Téléchargé : $finalTitle")));
      }
    } else {
      if (_downloadQueue.contains(task)) {
        setState(() => task.status = 'failed');
        await database.insertOrUpdateQueue(task.toCompanion());
        if (mounted && messenger != null) {
          messenger.showSnackBar(SnackBar(
              content: Text("Échec : ${task.metadata.title}"),
              backgroundColor: Colors.orange));
        }
      }
    }

    setState(() {
      _activeTasks.remove(task);
      _downloadQueue.remove(task);
    });
    queueNotifier.value++;

    _processQueue();
  }

  /// 🚀 ACTIONS ACTIONNÉES PAR LA PAGE DE TÉLÉCHARGEMENT
  Future<void> _deleteTaskArtifacts(DownloadTask task) async {
    final folder = Directory(task.targetFolder);
    if (!await folder.exists()) return;

    final rawBaseName = (task.customTitle ?? task.metadata.title)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    final baseName = rawBaseName.isEmpty ? 'download' : rawBaseName;

    for (final entity in folder.listSync()) {
      if (entity is! File) continue;

      final name = entity.uri.pathSegments.last;
      final lowerName = name.toLowerCase();
      final isLikelyCurrentArtifact = name.startsWith(baseName) ||
          name.startsWith(task.metadata.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim()) ||
          lowerName.endsWith('.ts') ||
          lowerName.endsWith('.m3u8') ||
          lowerName.endsWith('.m4s') ||
          lowerName.endsWith('.part') ||
          lowerName.endsWith('.f248.mp4') ||
          lowerName.endsWith('.f251.mp4') ||
          lowerName.endsWith('.f302.mp4');

      if (isLikelyCurrentArtifact) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> cancelDownloadTask(DownloadTask task) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (task.activeProcess != null) {
      try {
        task.activeProcess!.kill();
      } catch (_) {}
    }

    task.status = 'failed';
    task.activeProcess = null;

    setState(() {
      _activeTasks.remove(task);
      _downloadQueue.remove(task);
    });

    await database.deleteQueueEntry(task.taskId);
    await _deleteTaskArtifacts(task);
    queueNotifier.value++;

    if (mounted && messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Téléchargement annulé : ${task.metadata.title}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    _processQueue();
  }

  void togglePauseTask(DownloadTask task) async {
    if (task.status == 'downloading' && task.activeProcess != null) {
      setState(() {
        task.status = 'paused';
      });
      task.activeProcess!.kill(); // Tue yt-dlp. Grâce à --continue, il reprendra au même octet !
    } else if (task.status == 'paused' || task.status == 'failed') {
      setState(() {
        task.status = 'queued'; // Repasse en attente
      });
    }
    await database.insertOrUpdateQueue(task.toCompanion());
    queueNotifier.value++;
    _processQueue(); // Relance la file
  }

  void triggerReDownload(Map<String, dynamic> historyItem) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
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
    await database.insertOrUpdateQueue(task.toCompanion());
    queueNotifier.value++;
    _processQueue();

    if (messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Téléchargement relancé instantanément !"),
          backgroundColor: Colors.blue,
        ),
      );
    }
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
    final messenger = ScaffoldMessenger.maybeOf(context);
    await database.clearHistory();
    _loadSettingsAndHistory();

    if (!mounted || messenger == null) return;
    messenger.showSnackBar(
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
      child: PopScope<void>(
        onPopInvokedWithResult: (didPop, result) {
          _pauseActiveDownloads();
        },
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
                      onCancelTask: cancelDownloadTask,
                      onReDownload: triggerReDownload,
                      onClearHistory: _clearAllHistory,
                      onRefreshHistory: _loadSettingsAndHistory,
                      onRenameHistoryItem: (id, oldTitleWithDate, targetFolder, formatExt,
                          newTitle) async {
                        final messenger = ScaffoldMessenger.maybeOf(this.context);
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

                          if (mounted && messenger != null) {
                            messenger.showSnackBar(
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
            leading: const Icon(Icons.system_update_rounded, color: Colors.blue),
            title: const Text("Mettre à jour les composants"),
            subtitle: const Text("Forcer la mise à jour de yt-dlp & FFmpeg"),
            onTap: () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.pop(context);
              setState(() {
                _isSettingUp = true;
                _setupProgress = 0.0;
                _setupError = "";
              });
              try {
                final bool wasUpdated = await ComponentManager.forceUpdate(onProgress: (p) {
                  if (mounted) setState(() => _setupProgress = p);
                });
                if (mounted && messenger != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(wasUpdated
                          ? "Composants mis à jour avec succès !"
                          : "Les composants sont déjà à jour."),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _setupError = e.toString().replaceFirst('Exception: ', ''));
                }
              } finally {
                if (mounted && _setupError.isEmpty) {
                  setState(() => _isSettingUp = false);
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_applications_rounded, color: Colors.blue),
            title: const Text("Paramètres Avancés"),
            subtitle: const Text("URLs, concurrence, arguments yt-dlp"),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog(context);
            },
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
          ListTile(
            leading: const Icon(Icons.power_settings_new_rounded,
                color: Colors.redAccent),
            title: const Text("Quitter l'application"),
            subtitle: const Text("Mettre en pause les téléchargements puis quitter."),
            onTap: () async {
              Navigator.pop(context);
              await _confirmQuit(context);
            },
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

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final prefs = snapshot.data!;

                final winCtrl = TextEditingController(
                    text: prefs.getString('ffmpeg_url_windows') ??
                        "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-06-21-13-34/ffmpeg-N-125146-gc6bb22dea0-win64-gpl.zip");
                final linCtrl = TextEditingController(
                    text: prefs.getString('ffmpeg_url_linux') ??
                        "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-06-21-13-34/ffmpeg-N-125146-gc6bb22dea0-linux64-gpl.tar.xz");
                final macCtrl = TextEditingController(
                    text: prefs.getString('ffmpeg_url_macos') ??
                        "https://evermeet.cx/ffmpeg/getrelease/zip");
                final pipCtrl = TextEditingController(
                    text: prefs.getString('ytdlp_pip_packages') ??
                        "yt-dlp curl-cffi");
                final argsCtrl = TextEditingController(
                    text: prefs.getString('ytdlp_custom_args') ?? "");

                int concurrency = prefs.getInt('download_concurrency') ?? 1;

                return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.settings_rounded, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Paramètres Avancés"),
                    ],
                  ),
                  content: SizedBox(
                    width: 500,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text("URLs de téléchargement FFmpeg",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: winCtrl,
                            decoration: const InputDecoration(
                              labelText: "Windows (.zip)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: linCtrl,
                            decoration: const InputDecoration(
                              labelText: "Linux (.tar.xz ou .tar.gz)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: macCtrl,
                            decoration: const InputDecoration(
                              labelText: "macOS (.zip)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const Divider(height: 24),
                          const Text("Environnement yt-dlp",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: pipCtrl,
                            decoration: const InputDecoration(
                              labelText: "Paquets Pip (séparés par espace)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: argsCtrl,
                            decoration: const InputDecoration(
                              labelText: "Arguments additionnels (ex. --proxy)",
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Téléchargements Simultanés",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14)),
                              DropdownButton<int>(
                                value: concurrency,
                                items: [1, 2, 3, 4, 5]
                                    .map((val) => DropdownMenuItem<int>(
                                          value: val,
                                          child: Text("$val tâche(s)"),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    prefs.setInt('download_concurrency', val);
                                    setDialogState(() {
                                      concurrency = val;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text("Actions Système",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                                label: const Text("Vider le cache"),
                                onPressed: () async {
                                  await database.clearCache();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Le cache des métadonnées a été vidé."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.restore_rounded, size: 18),
                                label: const Text("Par défaut"),
                                onPressed: () async {
                                  await prefs.remove('ffmpeg_url_windows');
                                  await prefs.remove('ffmpeg_url_linux');
                                  await prefs.remove('ffmpeg_url_macos');
                                  await prefs.remove('ytdlp_pip_packages');
                                  await prefs.remove('ytdlp_custom_args');
                                  await prefs.setInt('download_concurrency', 1);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Paramètres réinitialisés par défaut."),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await prefs.setString('ffmpeg_url_windows', winCtrl.text.trim());
                        await prefs.setString('ffmpeg_url_linux', linCtrl.text.trim());
                        await prefs.setString('ffmpeg_url_macos', macCtrl.text.trim());
                        await prefs.setString('ytdlp_pip_packages', pipCtrl.text.trim());
                        await prefs.setString('ytdlp_custom_args', argsCtrl.text.trim());
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Paramètres enregistrés avec succès !"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}