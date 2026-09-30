# Résumé du projet YTDLP

## Objectif
Cette application Flutter desktop permet d’analyser et de télécharger des vidéos, playlists ou liens de média directs via yt-dlp et FFmpeg. Elle est pensée pour un usage local, avec une file de téléchargement, un historique, un cache de métadonnées et une intégration possible avec une extension navigateur via un petit serveur HTTP local.

## Architecture générale
- Frontend Flutter Material 3 pour desktop (Linux/macOS/Windows).
- Moteur de téléchargement : yt-dlp, avec FFmpeg pour le traitement des formats.
- Persistance locale : SQLite via Drift + SharedPreferences.
- Composants externes installés localement dans le dossier de l’application au premier lancement.

## Fichiers principaux dans lib/

### Point d’entrée et orchestration
- [lib/main.dart](lib/main.dart)
  - Point d’entrée de l’application.
  - Gère le thème, le serveur HTTP local sur localhost:8888, la réception d’URLs depuis une extension navigateur, la file d’attente globale et l’interface principale.
  - Contient l’état global partagé entre les écrans via MainScreenState.

### Modèles de données
- [lib/models/video_metadata.dart](lib/models/video_metadata.dart)
  - Représente les métadonnées de vidéo/playlist et les formats disponibles.
  - Inclut la logique de parsing des résultats yt-dlp et des formats de téléchargement.
- [lib/models/download_task.dart](lib/models/download_task.dart)
  - Représente une tâche de téléchargement dans la file.
  - Contient le statut, la progression, le Process actif et les métadonnées associées.

### Services
- [lib/services/ytdlp_service.dart](lib/services/ytdlp_service.dart)
  - Cœur de l’intégration avec yt-dlp.
  - Détecte les liens de média directs, construit des headers réalistes, ajoute la prise en charge des cookies, gère des retries sur erreur 403 et interagit avec le cache.
- [lib/services/component_manager.dart](lib/services/component_manager.dart)
  - Vérifie et installe les composants locaux nécessaires : yt-dlp, FFmpeg et l’environnement Python/venv.
  - Gère aussi les URLs de téléchargement de FFmpeg selon la plateforme.

### Interface utilisateur
- [lib/video/single_video_view.dart](lib/video/single_video_view.dart)
  - Écran pour analyser et télécharger une seule vidéo.
  - Permet de coller une URL, d’analyser les métadonnées, de choisir un format et d’ajouter la tâche à la file.
- [lib/playlist/playlist_view.dart](lib/playlist/playlist_view.dart)
  - Écran pour analyser une playlist et sélectionner certaines vidéos à télécharger.
  - Gère l’analyse de chaque entrée et la construction de tâches de téléchargement groupées.
- [lib/playlist/playlist_video_card.dart](lib/playlist/playlist_video_card.dart)
  - Widget de carte pour chaque élément d’une playlist.
  - Affiche l’aperçu, l’état de téléchargement et le sélecteur de format.
- [lib/downloads/downloads_view.dart](lib/downloads/downloads_view.dart)
  - Vue de la file active et de l’historique des téléchargements.
  - Permet de mettre en pause/reprendre, copier un lien, ouvrir le dossier cible ou renommer un élément de l’historique.

### Persistances
- [lib/services/database/app_database.dart](lib/services/database/app_database.dart)
  - Définition de la base SQLite Drift avec les tables historique et cache.
- [lib/services/database/history_dao.dart](lib/services/database/history_dao.dart)
  - DAO pour l’historique des téléchargements.
- [lib/services/database/cache_dao.dart](lib/services/database/cache_dao.dart)
  - DAO pour les métadonnées mises en cache afin d’éviter de relancer yt-dlp inutilement.

## Flux de fonctionnement
1. Au démarrage, l’application vérifie si yt-dlp et FFmpeg sont prêts.
2. Si nécessaire, elle installe ou met à jour ces composants localement.
3. Le serveur HTTP local écoute les URLs envoyées depuis une extension navigateur.
4. L’utilisateur colle ou reçoit une URL ; l’application l’analyse via yt-dlp.
5. Les formats disponibles sont affichés et l’utilisateur sélectionne ce qu’il veut télécharger.
6. Une DownloadTask est ajoutée à la file globale et exécutée par le moteur de téléchargement.
7. Le résultat est enregistré dans l’historique et potentiellement mis en cache.

## Points importants à connaître pour continuer le développement
- Le cœur de la file est centralisé dans MainScreenState dans [lib/main.dart](lib/main.dart).
- Les tâches sont stockées dans des listes statiques, donc tout changement de logique de queue doit rester cohérent avec ce modèle.
- Les paramètres de configuration (arguments yt-dlp, chemin des cookies, dossier de téléchargement) sont stockés en SharedPreferences.
- Le service [lib/services/ytdlp_service.dart](lib/services/ytdlp_service.dart) contient déjà des protections pour les liens directs et les erreurs 403, ce qui est le point le plus sensible du projet.
- Les chemins et binaires des composants sont gérés dans [lib/services/component_manager.dart](lib/services/component_manager.dart), donc toute modification d’installation doit passer par cette couche.

## État actuel du projet
- Fonctionne comme une application de téléchargement locale robuste pour les vidéos/playlist.
- Supporte relativement bien les liens directs de média et les cas de blocage via headers/cookies.
- Le projet est prêt pour des évolutions autour de la stabilité, du support de nouveaux sites et de l’expérience utilisateur.
