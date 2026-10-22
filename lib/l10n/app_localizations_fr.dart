// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get onboardingTitle => 'Bienvenue sur Bloomee';

  @override
  String get onboardingSubtitle => 'Choisissez votre langue et votre région.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navLocal => 'Sur l\'appareil';

  @override
  String get navOffline => 'Hors connexion';

  @override
  String get playerEnjoyingFrom => 'Lecture depuis';

  @override
  String get playerPlayWithMix => 'Lire avec le mix automatique';

  @override
  String get playerPlayNext => 'Lire ensuite';

  @override
  String get playerAddToQueue => 'Ajouter à la file d\'attente';

  @override
  String get playerAddToFavorites => 'Ajouter aux favoris';

  @override
  String get playerNoLyricsFound => 'Aucune parole trouvée';

  @override
  String get playerLyricsNoPlugin =>
      'Aucun fournisseur de paroles configuré. Accédez à Paramètres → Extensions pour en installer un.';

  @override
  String get localMusicTitle => 'Sur l\'appareil';

  @override
  String get localMusicGrantPermission => 'Autoriser l\'accès';

  @override
  String get localMusicStorageAccessRequired => 'Accès au stockage requis';

  @override
  String get localMusicStorageAccessDesc =>
      'Autorisez l\'accès pour rechercher et lire les fichiers audio de votre appareil.';

  @override
  String get localMusicAddFolder => 'Ajouter un dossier de musique';

  @override
  String get localMusicScanNow => 'Analyser maintenant';

  @override
  String localMusicScanFailed(String message) {
    return 'Échec de l\'analyse : $message';
  }

  @override
  String get localMusicScanning =>
      'Recherche des fichiers audio sur l\'appareil…';

  @override
  String get localMusicShuffle => 'Lecture aléatoire';

  @override
  String get localMusicPlayAll => 'Tout lire';

  @override
  String get localMusicSearchHint =>
      'Rechercher de la musique sur l\'appareil…';

  @override
  String get localMusicRescanDevice => 'Analyser à nouveau l\'appareil';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonDelete => 'Supprimer';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Mettre à jour';

  @override
  String get buttonDownload => 'Télécharger';

  @override
  String get buttonLater => 'Plus tard';

  @override
  String get buttonInfo => 'Informations';

  @override
  String get buttonMore => 'Plus';

  @override
  String get dialogDeleteTrack => 'Supprimer le titre';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Supprimer « $title » de votre appareil ? Cette action est irréversible.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Ce titre sera également retiré de :';

  @override
  String get dialogDontAskAgain => 'Ne plus demander';

  @override
  String get dialogUpdateAvailable => 'Mise à jour disponible';

  @override
  String get dialogUpdateNow => 'Mettre à jour maintenant';

  @override
  String get dialogDownloadPlaylist => 'Télécharger la playlist';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Télécharger les morceaux de « $title » ? Total : $count. Ils seront ajoutés à la file de téléchargement.';
  }

  @override
  String get dialogDownloadAll => 'Tout télécharger';

  @override
  String get playlistEdit => 'Modifier la playlist';

  @override
  String get playlistShareFile => 'Partager le fichier';

  @override
  String get playlistExportFile => 'Exporter le fichier';

  @override
  String get playlistPlay => 'Lire';

  @override
  String get playlistAddToQueue => 'Ajouter la playlist à la file d\'attente';

  @override
  String get playlistShare => 'Partager la playlist';

  @override
  String get playlistDelete => 'Supprimer la playlist';

  @override
  String get playlistEmptyState => 'Aucun morceau pour le moment';

  @override
  String get playlistAvailableOffline => 'Disponible hors connexion';

  @override
  String get playlistShuffle => 'Lecture aléatoire';

  @override
  String get playlistNoMatchSearch =>
      'Aucune playlist ne correspond à votre recherche';

  @override
  String get playlistCreateNew => 'Créer une playlist';

  @override
  String get playlistCreateFirstOne =>
      'Vous n\'avez pas encore de playlist. Créez-en une pour commencer.';

  @override
  String get addToPlaylistNoSongSelected => 'Aucun morceau sélectionné';

  @override
  String get createPlaylistDialogBarrierLabel =>
      'Fenêtre de création de playlist';

  @override
  String get createPlaylistDialogNameHint => 'Musiques d\'été';

  @override
  String get createPlaylistDialogCreate => 'Créer';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux',
      one: '$count morceau',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title retiré de $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Impossible de charger la playlist';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPlugins => 'Extensions';

  @override
  String get settingsPluginsSubtitle =>
      'Installez, activez et gérez les extensions.';

  @override
  String get settingsUpdates => 'Mises à jour';

  @override
  String get settingsUpdatesSubtitle => 'Rechercher des mises à jour';

  @override
  String get settingsDownloads => 'Téléchargements';

  @override
  String get settingsDownloadsSubtitle =>
      'Dossier de téléchargement, qualité audio et autres options';

  @override
  String get settingsLocalTracks => 'Titres sur l\'appareil';

  @override
  String get settingsLocalTracksSubtitle =>
      'Analyse des fichiers, dossiers et analyse automatique';

  @override
  String get settingsPlayer => 'Paramètres de lecture';

  @override
  String get settingsPlayerSubtitle =>
      'Qualité audio, lecture automatique et autres options';

  @override
  String get settingsPluginDefaults => 'Extensions par défaut';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Source de Découvrir et priorité des résolveurs';

  @override
  String get settingsUIElements => 'Interface et services';

  @override
  String get settingsUIElementsSubtitle =>
      'Défilement automatique et réglages de l\'interface';

  @override
  String get settingsLastFM => 'Paramètres Last.fm';

  @override
  String get settingsLastFMSubtitle =>
      'Clés API et envoi de l\'historique d\'écoute';

  @override
  String get settingsStorage => 'Stockage';

  @override
  String get settingsStorageSubtitle =>
      'Sauvegarde, cache, historique et restauration';

  @override
  String get settingsLanguageCountry => 'Langue et pays';

  @override
  String get settingsLanguageCountrySubtitle =>
      'Choisissez votre langue et votre pays.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutSubtitle =>
      'Informations sur l\'application, la version et le développeur';

  @override
  String get settingsScanning => 'Analyse des fichiers';

  @override
  String get settingsMusicFolders => 'Dossiers de musique';

  @override
  String get settingsQuality => 'Qualité';

  @override
  String get settingsHistory => 'Historique';

  @override
  String get settingsBackupRestore => 'Sauvegarde et restauration';

  @override
  String get settingsAutomatic => 'Automatique';

  @override
  String get settingsDangerZone => 'Réinitialisation des données';

  @override
  String get settingsScrobbling => 'Envoi de l\'historique d\'écoute';

  @override
  String get settingsAuthentication => 'Authentification';

  @override
  String get settingsHomeScreen => 'Écran d\'accueil';

  @override
  String get settingsChartVisibility => 'Visibilité des classements';

  @override
  String get dialogAddingToDownloadQueue => 'Ajout à la file de téléchargement';

  @override
  String get emptyNoInternet => 'Aucune connexion Internet';

  @override
  String get emptyNoContentPlugin =>
      'Aucun résolveur de contenu actif. Activez-en un dans le gestionnaire d\'extensions.';

  @override
  String get emptyRefreshingSource =>
      'Actualisation de la source de Découvrir… La source précédente n\'est plus disponible.';

  @override
  String get emptyNoTracks => 'Aucun titre disponible';

  @override
  String get emptyNoResults => 'Aucune correspondance trouvée';

  @override
  String snackbarDeletedTrack(String title) {
    return '« $title » supprimé';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Impossible de supprimer « $title »';
  }

  @override
  String get snackbarAddedToNextQueue => 'Ajouté pour être lu ensuite';

  @override
  String get snackbarAddedToQueue => 'Ajouté à la file d\'attente';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title ajouté aux favoris';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Lecture de $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name ajouté à la file d\'attente';
  }

  @override
  String get snackbarPlaylistUpdated => 'Playlist mise à jour';

  @override
  String get snackbarLinkCopied => 'Lien copié';

  @override
  String get snackbarCouldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Morceaux ajoutés à la file de téléchargement : $count';
  }

  @override
  String get searchHintExplore => 'Que souhaitez-vous écouter ?';

  @override
  String get searchHintLibrary => 'Rechercher dans la bibliothèque…';

  @override
  String get searchHintPlaylists => 'Rechercher des playlists…';

  @override
  String get searchStartTyping => 'Saisissez du texte pour rechercher';

  @override
  String get searchNoSuggestions => 'Aucune suggestion trouvée';

  @override
  String get searchNoResults =>
      'Aucun résultat trouvé.\nEssayez un autre terme ou une autre source.';

  @override
  String get searchFailed => 'Échec de la recherche';

  @override
  String get searchDiscover => 'Découvrez de nouveaux morceaux';

  @override
  String get searchSources => 'Sources';

  @override
  String get searchNoPlugins => 'Aucune extension installée';

  @override
  String get searchTracks => 'Titres';

  @override
  String get searchAlbums => 'Albums';

  @override
  String get searchArtists => 'Artistes';

  @override
  String get searchPlaylists => 'Playlists';

  @override
  String get exploreDiscover => 'Découvrir';

  @override
  String get exploreRecently => 'Écoutes récentes';

  @override
  String get exploreLastFmPicks => 'Sélection Last.fm';

  @override
  String get exploreFailedToLoad =>
      'Impossible de charger les rubriques de l\'accueil.';

  @override
  String get libraryTitle => 'Bibliothèque';

  @override
  String get libraryEmptyState =>
      'Votre bibliothèque est vide. Ajoutez des morceaux et des playlists pour commencer.';

  @override
  String libraryIn(String playlistName) {
    return 'dans $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Ajouter à une playlist';

  @override
  String get menuSmartReplace => 'Remplacer par un titre équivalent';

  @override
  String get menuShare => 'Partager';

  @override
  String get menuAvailableOffline => 'Disponible hors connexion';

  @override
  String get menuDownload => 'Télécharger';

  @override
  String get menuOpenOriginalLink => 'Ouvrir le lien d\'origine';

  @override
  String get menuDeleteTrack => 'Supprimer';

  @override
  String get tooltipRemoveFromLibrary => 'Retirer de la bibliothèque';

  @override
  String get tooltipSaveToLibrary => 'Enregistrer dans la bibliothèque';

  @override
  String get tooltipOpenOriginalLink => 'Ouvrir le lien d\'origine';

  @override
  String get tooltipAvailableOffline => 'Disponible hors connexion';

  @override
  String get tooltipMoreOptions => 'Plus d\'options';

  @override
  String get appuiTitle => 'Interface et services';

  @override
  String get appuiAutoSlideCharts => 'Faire défiler les classements';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Faire défiler automatiquement les classements sur l\'accueil.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Afficher les suggestions Last.fm. Une connexion au compte et un redémarrage sont nécessaires.';

  @override
  String get appuiNoChartsAvailable =>
      'Aucun classement disponible. Activez une extension de classements.';

  @override
  String get appuiLoginToLastFm => 'Connectez-vous d\'abord à Last.fm.';

  @override
  String get appuiShowInCarousel => 'Afficher dans le carrousel de l\'accueil.';

  @override
  String get countrySettingTitle => 'Pays et langue';

  @override
  String get countrySettingAutoDetect => 'Détecter le pays automatiquement';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Détecter automatiquement votre pays à l\'ouverture de l\'application.';

  @override
  String get countrySettingCountryLabel => 'Pays';

  @override
  String get countrySettingLanguageLabel => 'Langue';

  @override
  String get countrySettingSystemDefault => 'Langue du système';

  @override
  String get downloadSettingTitle => 'Téléchargements';

  @override
  String get downloadSettingQuality => 'Qualité des téléchargements';

  @override
  String get downloadSettingQualitySubtitle =>
      'Qualité audio souhaitée pour tous les titres téléchargés.';

  @override
  String get downloadSettingFolder => 'Dossier de téléchargement';

  @override
  String get downloadSettingResetFolder =>
      'Rétablir le dossier de téléchargement';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Rétablir l\'emplacement de téléchargement par défaut.';

  @override
  String get lastfmTitle => 'Last.fm';

  @override
  String get lastfmScrobbleTracks => 'Envoyer l\'historique d\'écoute';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Envoyer les titres écoutés à votre profil Last.fm.';

  @override
  String get lastfmAuthFirst => 'Autorisez d\'abord l\'accès à l\'API Last.fm.';

  @override
  String get lastfmAuthenticatedAs => 'Connecté en tant que';

  @override
  String get lastfmAuthFailed => 'Échec de l\'authentification :';

  @override
  String get lastfmNotAuthenticated => 'Non authentifié';

  @override
  String get lastfmSteps =>
      'Étapes d\'authentification :\n1. Créez un compte ou connectez-vous sur last.fm.\n2. Générez une clé API sur last.fm/api/account/create.\n3. Saisissez la clé API et la clé secrète ci-dessous.\n4. Appuyez sur « 1. Autoriser l\'accès » et validez dans le navigateur.\n5. Appuyez sur « 2. Obtenir et enregistrer la clé de session ».';

  @override
  String get lastfmApiKey => 'Clé API';

  @override
  String get lastfmApiSecret => 'Clé secrète API';

  @override
  String get lastfmStartAuth => '1. Autoriser l\'accès';

  @override
  String get lastfmGetSession => '2. Obtenir et enregistrer la clé de session';

  @override
  String get lastfmRemoveKeys => 'Supprimer les clés';

  @override
  String get lastfmStartAuthFirst =>
      'Lancez d\'abord l\'autorisation, puis validez dans le navigateur.';

  @override
  String get localSettingTitle => 'Titres sur l\'appareil';

  @override
  String get localSettingAutoScan => 'Analyser au démarrage';

  @override
  String get localSettingAutoScanSubtitle =>
      'Rechercher automatiquement les nouveaux titres sur l\'appareil au démarrage.';

  @override
  String get localSettingLastScan => 'Dernière analyse';

  @override
  String get localSettingNeverScanned => 'Jamais';

  @override
  String get localSettingScanInProgress => 'Analyse en cours…';

  @override
  String get localSettingScanNowSubtitle =>
      'Lancer une analyse complète de la bibliothèque.';

  @override
  String get localSettingNoFolders =>
      'Aucun dossier ajouté. Ajoutez-en un pour rechercher des morceaux.';

  @override
  String get localSettingAddFolder => 'Ajouter un dossier';

  @override
  String get playerSettingTitle => 'Paramètres de lecture';

  @override
  String get playerSettingStreamingHeader => 'Audio en ligne';

  @override
  String get playerSettingStreamQuality => 'Qualité audio en ligne';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Débit audio utilisé pour la lecture en ligne.';

  @override
  String get playerSettingQualityLow => 'Faible';

  @override
  String get playerSettingQualityMedium => 'Moyenne';

  @override
  String get playerSettingQualityHigh => 'Élevée';

  @override
  String get playerSettingPlaybackHeader => 'Lecture';

  @override
  String get playerSettingAutoPlay => 'Lecture automatique';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Ajouter des morceaux similaires à la fin de la file d\'attente.';

  @override
  String get playerSettingAutoFallback => 'Utiliser une source de secours';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Si une extension manque ou ne fournit aucun flux audio, essayer un résolveur compatible uniquement pour la lecture.';

  @override
  String get playerSettingCrossfade => 'Fondu enchaîné';

  @override
  String get playerSettingCrossfadeOff => 'Désactivé';

  @override
  String get playerSettingCrossfadeInstant =>
      'Passage immédiat d\'un titre à l\'autre';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Fondu de $seconds s entre les titres';
  }

  @override
  String get playerSettingEqualizer => 'Égaliseur';

  @override
  String get playerSettingEqualizerActive => 'Actif';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Activé — $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Égaliseur paramétrique à 10 bandes via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Extensions par défaut';

  @override
  String get pluginDefaultsDiscoverHeader => 'Source de Découvrir';

  @override
  String get pluginDefaultsNoResolver =>
      'Aucun résolveur de contenu actif. Activez une extension pour choisir la source de Découvrir.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Utiliser le premier résolveur de contenu disponible.';

  @override
  String get pluginDefaultsPriorityHeader => 'Priorité des résolveurs';

  @override
  String get pluginDefaultsNoPriority =>
      'Aucun résolveur de contenu actif. L\'ordre de priorité apparaîtra ici une fois les extensions activées.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Faites glisser pour réorganiser. Les résolveurs prioritaires sont essayés en premier pour trouver une version lisible des titres des classements ou des titres importés.';

  @override
  String get pluginDefaultsLyricsHeader => 'Priorité des paroles';

  @override
  String get pluginDefaultsLyricsNone => 'Aucun fournisseur de paroles actif.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Faites glisser pour réorganiser les fournisseurs de paroles. Le premier est essayé en priorité.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Suggestions de recherche';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'Aucun fournisseur de suggestions actif.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Aucun';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Utiliser uniquement l\'historique de recherche.';

  @override
  String get storageSettingTitle => 'Stockage';

  @override
  String get storageClearHistoryEvery => 'Effacer l\'historique tous les';

  @override
  String get storageClearHistorySubtitle =>
      'Effacer l\'historique d\'écoute après la durée choisie.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Sauvegarde enregistrée dans $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Impossible de partager la sauvegarde : $error';
  }

  @override
  String get storageRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restaurer vos paramètres et vos données à partir d\'un fichier de sauvegarde.';

  @override
  String get storageAutoBackup => 'Sauvegarde automatique';

  @override
  String get storageAutoLyrics => 'Enregistrer les paroles automatiquement';

  @override
  String get storageAutoLyricsSubtitle =>
      'Enregistrer automatiquement les paroles pendant la lecture.';

  @override
  String get storageResetApp => 'Réinitialiser Bloomee';

  @override
  String get storageResetConfirmTitle => 'Confirmer la réinitialisation';

  @override
  String get storageResetButton => 'Réinitialiser';

  @override
  String get storageRestoreOptionsTitle => 'Options de restauration';

  @override
  String get storageRestoreContinue => 'Continuer';

  @override
  String get storageRestoreConfirmTitle => 'Confirmer la restauration';

  @override
  String get storageRestoreYes => 'Oui, restaurer';

  @override
  String get storageRestoring =>
      'Restauration des données sélectionnées…\nVeuillez patienter jusqu\'à la fin de l\'opération.';

  @override
  String get storageRestoreFailedTitle => 'Échec de la restauration';

  @override
  String get updateSettingTitle => 'Mises à jour';

  @override
  String get updateCheckForUpdates => 'Rechercher des mises à jour';

  @override
  String get updateCheckSubtitle =>
      'Vérifier si une nouvelle version de Bloomee est disponible.';

  @override
  String get updateAutoNotify => 'Signaler les mises à jour';

  @override
  String get updateAutoNotifySubtitle =>
      'Recevoir une notification des mises à jour disponibles au démarrage.';

  @override
  String get updateCheckTitle => 'Rechercher des mises à jour';

  @override
  String get updateUpToDate => 'Bloomee est à jour';

  @override
  String get updateViewPreRelease => 'Voir la dernière préversion';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Version actuelle : $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Une nouvelle version de Bloomee est disponible';

  @override
  String updateVersion(String ver, String build) {
    return 'Version : $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Télécharger maintenant';

  @override
  String get updateChecking => 'Recherche de mises à jour…';

  @override
  String get timerTitle => 'Minuterie de sommeil';

  @override
  String get timerInterludeMessage => 'La lecture s\'arrêtera dans :';

  @override
  String get timerHours => 'Heures';

  @override
  String get timerMinutes => 'Minutes';

  @override
  String get timerSeconds => 'Secondes';

  @override
  String get timerStop => 'Arrêter la minuterie';

  @override
  String get timerFinishedMessage =>
      'La minuterie de sommeil a arrêté la lecture.';

  @override
  String get timerGotIt => 'Compris';

  @override
  String get timerSetTimeError => 'Choisissez une durée';

  @override
  String get timerStart => 'Démarrer la minuterie';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Aucune notification pour le moment';

  @override
  String get recentsTitle => 'Historique';

  @override
  String playlistByCreator(String creator) {
    return 'par $creator';
  }

  @override
  String get playlistYou => 'Vous';

  @override
  String get pluginManagerTitle => 'Extensions';

  @override
  String get pluginManagerEmpty =>
      'Aucune extension installée.\nAppuyez sur + pour ajouter un fichier .bex.';

  @override
  String get pluginManagerFilterAll => 'Toutes';

  @override
  String get pluginManagerFilterContent => 'Résolveurs de contenu';

  @override
  String get pluginManagerFilterCharts => 'Fournisseurs de classements';

  @override
  String get pluginManagerFilterLyrics => 'Fournisseurs de paroles';

  @override
  String get pluginManagerFilterSuggestions => 'Fournisseurs de suggestions';

  @override
  String get pluginManagerFilterImporters => 'Importateurs de contenu';

  @override
  String get pluginManagerTooltipRefresh => 'Actualiser';

  @override
  String get pluginManagerTooltipInstall => 'Installer une extension';

  @override
  String get pluginManagerNoMatch =>
      'Aucune extension ne correspond à ce filtre';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Impossible de sélectionner le fichier : $error';
  }

  @override
  String get pluginManagerInstalling => 'Installation de l\'extension…';

  @override
  String get pluginManagerTypeContentResolver => 'Résolveur de contenu';

  @override
  String get pluginManagerTypeChartProvider => 'Fournisseur de classements';

  @override
  String get pluginManagerTypeLyricsProvider => 'Fournisseur de paroles';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Suggestions de recherche';

  @override
  String get pluginManagerTypeContentImporter => 'Importateur de contenu';

  @override
  String get pluginManagerDeleteTitle => 'Supprimer l\'extension ?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Supprimer « $name » ? Ses fichiers seront supprimés définitivement.';
  }

  @override
  String get pluginManagerDeleteAction => 'Supprimer';

  @override
  String get pluginManagerCancel => 'Annuler';

  @override
  String get pluginManagerEnablePlugin => 'Activer l\'extension';

  @override
  String get pluginManagerUnloadPlugin => 'Désactiver l\'extension';

  @override
  String get pluginManagerDeleting => 'Suppression…';

  @override
  String get pluginManagerApiKeysTitle => 'Clés API';

  @override
  String get pluginManagerApiKeysSaved => 'Clés API enregistrées';

  @override
  String get pluginManagerSave => 'Enregistrer';

  @override
  String get pluginManagerDetailVersion => 'Version';

  @override
  String get pluginManagerDetailType => 'Type';

  @override
  String get pluginManagerDetailPublisher => 'Éditeur';

  @override
  String get pluginManagerDetailLastUpdated => 'Dernière mise à jour';

  @override
  String get pluginManagerDetailCreated => 'Création';

  @override
  String get pluginManagerDetailHomepage => 'Site web';

  @override
  String get pluginManagerDeleteStorageTitle =>
      'Supprimer les données de l\'extension ?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Supprimer aussi les clés API et les paramètres enregistrés pour « $name » ?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Conserver les données';

  @override
  String get pluginManagerDeleteStorageRemove => 'Supprimer les données';

  @override
  String get segmentsSheetTitle => 'Segments';

  @override
  String get segmentsSheetEmpty => 'Aucun segment disponible';

  @override
  String get segmentsSheetUntitled => 'Segment sans titre';

  @override
  String get smartReplaceTitle => 'Remplacer par un titre équivalent';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Choisissez une version lisible de « $title » pour mettre à jour ses références dans les playlists enregistrées.';
  }

  @override
  String get smartReplaceClose => 'Fermer';

  @override
  String get smartReplaceNoMatch => 'Aucun remplacement trouvé';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Les extensions de résolution actives n\'ont pas trouvé de correspondance suffisamment proche.';

  @override
  String get smartReplaceBestMatch => 'Meilleure correspondance';

  @override
  String get smartReplaceSearchFailed => 'Échec de la recherche';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Impossible de remplacer le titre : $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Titre remplacé$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' et file d\'attente mise à jour';

  @override
  String get playerUnknownQueue => 'Inconnu';

  @override
  String playerLiked(String title) {
    return '$title ajouté aux favoris';
  }

  @override
  String playerUnliked(String title) {
    return '$title retiré des favoris';
  }

  @override
  String get offlineNoDownloads => 'Aucun téléchargement';

  @override
  String get offlineTitle => 'Hors connexion';

  @override
  String get offlineSearchHint => 'Rechercher dans vos morceaux…';

  @override
  String get offlineRefreshTooltip => 'Actualiser les téléchargements';

  @override
  String get offlineCloseSearch => 'Fermer la recherche';

  @override
  String get offlineSearchTooltip => 'Rechercher';

  @override
  String get offlineOpenFailed =>
      'Impossible d\'ouvrir ce titre hors connexion. Essayez d\'actualiser les téléchargements.';

  @override
  String get offlinePlayFailed =>
      'Impossible de lire ce morceau hors connexion. Réessayez.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '$count titre',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Impossible de charger l\'album';

  @override
  String get aboutCraftingSubtitle => 'Développé pour la musique.';

  @override
  String get aboutFollowGitHub => 'Suivre sur GitHub';

  @override
  String get aboutSendInquiry => 'Envoyer une demande professionnelle';

  @override
  String get aboutCreativeHighlights => 'Actualités et projets';

  @override
  String get aboutTipQuote =>
      'Vous appréciez Bloomee ? Vous pouvez soutenir son développement.';

  @override
  String get aboutTipButton => 'Soutenir le projet';

  @override
  String get aboutTipDesc => 'Votre contribution aide à améliorer Bloomee.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Détails du morceau';

  @override
  String get songInfoSectionTechnical => 'Informations techniques';

  @override
  String get songInfoSectionActions => 'Actions';

  @override
  String get songInfoLabelTitle => 'Titre';

  @override
  String get songInfoLabelArtist => 'Artiste';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Durée';

  @override
  String get songInfoLabelSource => 'Source';

  @override
  String get songInfoLabelMediaId => 'Identifiant du média';

  @override
  String get songInfoLabelPluginId => 'Identifiant de l\'extension';

  @override
  String get songInfoCopyId => 'Copier l\'identifiant';

  @override
  String get songInfoCopyLink => 'Copier le lien';

  @override
  String get songInfoOpenBrowser => 'Ouvrir dans le navigateur';

  @override
  String get songInfoIdCopied => 'Identifiant du média copié';

  @override
  String get songInfoLinkCopied => 'Lien copié';

  @override
  String get songInfoNoLink => 'Aucun lien disponible';

  @override
  String get songInfoOpenFailed => 'Impossible d\'ouvrir le lien';

  @override
  String get songInfoUpdateMetadata => 'Actualiser les métadonnées';

  @override
  String get songInfoMetadataUpdated => 'Métadonnées actualisées';

  @override
  String get songInfoMetadataUpdateFailed =>
      'Impossible d\'actualiser les métadonnées';

  @override
  String get songInfoMetadataUnavailable =>
      'L\'actualisation des métadonnées n\'est pas disponible pour cette source';

  @override
  String get songInfoSearchTitle => 'Rechercher ce morceau dans Bloomee';

  @override
  String get songInfoSearchArtist => 'Rechercher cet artiste dans Bloomee';

  @override
  String get songInfoSearchAlbum => 'Rechercher cet album dans Bloomee';

  @override
  String get eqTitle => 'Égaliseur';

  @override
  String get chartNoItems => 'Ce classement est vide';

  @override
  String get chartLoadFailed => 'Impossible de charger le classement';

  @override
  String get chartPlay => 'Lire';

  @override
  String get chartResolving => 'Recherche d\'une correspondance';

  @override
  String get chartReady => 'Prêt';

  @override
  String get chartAddToPlaylist => 'Ajouter à une playlist';

  @override
  String get chartNoResolver =>
      'Aucun résolveur de contenu actif. Installez une extension pour lancer la lecture.';

  @override
  String get chartResolveFailed =>
      'Aucune correspondance trouvée. Ouverture de la recherche…';

  @override
  String get chartNoResolverAdd => 'Aucun résolveur de contenu actif.';

  @override
  String get chartNoMatch =>
      'Aucune correspondance trouvée. Essayez une recherche manuelle.';

  @override
  String get chartStatPeak => 'Meilleure position';

  @override
  String get chartStatWeeks => 'Semaines';

  @override
  String get chartStatChange => 'Évolution';

  @override
  String menuSharePreparing(String title) {
    return 'Préparation de $title pour le partage.';
  }

  @override
  String get menuOpenLinkFailed => 'Impossible d\'ouvrir le lien';

  @override
  String get localMusicFolders => 'Dossiers de musique';

  @override
  String get localMusicRemoveFolder => 'Retirer le dossier';

  @override
  String get localMusicCloseSearch => 'Fermer la recherche';

  @override
  String get localMusicOpenSearch => 'Rechercher';

  @override
  String get localMusicNoMusicFound => 'Aucun morceau trouvé sur l\'appareil';

  @override
  String get localMusicNoSearchResults =>
      'Aucun titre ne correspond à votre recherche.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '$count titre',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Importer des morceaux';

  @override
  String get importNoPluginsLoaded =>
      'Aucune extension d\'importation de contenu active.\nInstallez-en une pour importer des playlists d\'autres services.';

  @override
  String get importBloomeeFiles => 'Importer des fichiers Bloomee';

  @override
  String get importM3UFiles => 'Importer une playlist M3U';

  @override
  String get importM3UNameDialogTitle => 'Nom de la playlist';

  @override
  String get importM3UNameHint => 'Saisissez un nom pour cette playlist';

  @override
  String get importM3UNoTracks =>
      'Aucun titre valide trouvé dans le fichier M3U.';

  @override
  String get importNoteTitle => 'Remarque';

  @override
  String get importNoteMessage =>
      'Seuls les fichiers créés par Bloomee peuvent être importés.\nLes fichiers d\'autres sources ne fonctionneront pas. Continuer quand même ?';

  @override
  String get importTitle => 'Importer';

  @override
  String get importCheckingUrl => 'Vérification du lien…';

  @override
  String get importFetchingTracks => 'Récupération des titres…';

  @override
  String get importSavingToLibrary => 'Enregistrement dans la bibliothèque…';

  @override
  String get importPasteUrlHint =>
      'Collez le lien d\'une playlist ou d\'un album à importer';

  @override
  String get importAction => 'Importer';

  @override
  String importTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '$count titre',
    );
    return '$_temp0';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Recherche de correspondances : $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Enregistrer les titres ($count)';
  }

  @override
  String importTracksSaved(int count) {
    return 'Titres enregistrés : $count';
  }

  @override
  String get importDone => 'Terminé';

  @override
  String get importMore => 'Importer d\'autres éléments';

  @override
  String get importUnknownError => 'Erreur inconnue';

  @override
  String get importTryAgain => 'Réessayer';

  @override
  String get importSkipTrack => 'Ignorer ce titre';

  @override
  String get importMatchOptions => 'Options de correspondance';

  @override
  String get importSkipped => 'Ignoré';

  @override
  String get importReorderTip =>
      'Appuyez longuement sur une playlist pour la réorganiser';

  @override
  String get importErrorCannotHandleUrl =>
      'Cette extension ne prend pas en charge le lien fourni.';

  @override
  String get importErrorUnexpectedResponse =>
      'Réponse inattendue de l\'extension.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Impossible de vérifier le lien : $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Impossible de récupérer les informations de la collection : $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Impossible de récupérer les titres : $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Impossible d\'enregistrer la playlist : $error';
  }

  @override
  String get playlistPinToTop => 'Épingler en haut';

  @override
  String get playlistUnpin => 'Désépingler';

  @override
  String get snackbarInvalidFileFormat => 'Format de fichier non valide';

  @override
  String get snackbarProcessingFile => 'Traitement du fichier…';

  @override
  String get pluginManagerTabInstalled => 'Installées';

  @override
  String get pluginManagerTabStore => 'Catalogue d\'extensions';

  @override
  String get pluginManagerSelectPackage =>
      'Choisir un paquet d\'extension (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'L\'extension utilise une ancienne version du manifeste. Certaines fonctions peuvent ne pas fonctionner. Envisagez une mise à jour.';

  @override
  String get pluginManagerStatusActive => 'Actif';

  @override
  String get pluginManagerStatusInactive => 'Inactif';

  @override
  String get pluginRepositoryAddTitle => 'Ajouter un dépôt';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Saisissez le lien d\'un fichier JSON de dépôt d\'extensions valide.';

  @override
  String get pluginRepositoryAddAction => 'Ajouter un dépôt';

  @override
  String get pluginRepositoryTitle => 'Dépôts d\'extensions';

  @override
  String get pluginRepositorySubtitle =>
      'Ajoutez une source JSON pour parcourir les extensions disponibles en ligne.';

  @override
  String get pluginRepositoryEmpty => 'Aucun dépôt ajouté pour le moment.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Mise à jour inconnue';

  @override
  String get pluginRepositoryNoDescription => 'Aucune description fournie.';

  @override
  String get pluginRepositoryUrlCopied =>
      'Lien du dépôt copié dans le presse-papiers';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count extensions',
      one: '$count extension',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Mise à jour : $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count extensions disponibles',
      one: '$count extension disponible',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Manifeste obsolète. Certaines fonctions peuvent ne pas fonctionner.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Éditeur inconnu';

  @override
  String get pluginRepositoryActionRetry => 'Réessayer';

  @override
  String get pluginRepositoryActionOutdated => 'Obsolète';

  @override
  String get pluginRepositoryActionInstalled => 'Installée';

  @override
  String get pluginRepositoryActionInstall => 'Installer';

  @override
  String get pluginRepositoryActionUnavailable => 'Indisponible';

  @override
  String get pluginRepositoryInstallFailed => 'Échec de l\'installation.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Impossible de télécharger $name.';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Impossible de charger les dépôts.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'Lien ou fichier de dépôt non valide.';

  @override
  String get pluginRepositoryErrorRemove => 'Impossible de retirer le dépôt.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Titre remplacé dans $count playlists$queue.',
      one: 'Titre remplacé dans $count playlist$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Rechercher des paroles…';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Saisissez le nom d\'un morceau ou d\'un artiste pour trouver des paroles.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Aucune parole trouvée pour « $query »';
  }

  @override
  String get lyricsSearchApplied => 'Paroles appliquées';

  @override
  String get lyricsSearchFetchFailed => 'Impossible de récupérer les paroles';

  @override
  String get lyricsSearchPreview => 'Aperçu';

  @override
  String get lyricsSearchPreviewTooltip => 'Afficher un aperçu des paroles';

  @override
  String get lyricsSearchSynced => 'Synchronisées';

  @override
  String get lyricsSearchPreviewLoadFailed =>
      'Impossible de charger les paroles.';

  @override
  String get lyricsSearchApplyAction => 'Appliquer les paroles';

  @override
  String get lyricsSettingsSearchTitle => 'Rechercher d\'autres paroles';

  @override
  String get lyricsSettingsSearchSubtitle =>
      'Trouver d\'autres versions en ligne';

  @override
  String get lyricsSettingsSyncTitle => 'Régler la synchronisation';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Corriger les paroles qui s\'affichent trop tôt ou trop tard';

  @override
  String get lyricsSettingsSaveTitle => 'Enregistrer hors connexion';

  @override
  String get lyricsSettingsSaveSubtitle =>
      'Conserver ces paroles sur votre appareil';

  @override
  String get lyricsSettingsDeleteTitle => 'Supprimer les paroles enregistrées';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Retirer les paroles conservées hors connexion';

  @override
  String get lyricsSyncTapToReset => 'Appuyer pour réinitialiser';

  @override
  String get upNextTitle => 'À suivre';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments dans la file d\'attente',
      one: '$count élément dans la file d\'attente',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get snackbarCopiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get tooltipSongInfo => 'Informations du morceau';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Impossible de supprimer le morceau en cours de lecture';

  @override
  String get playerLoopOff => 'Désactivé';

  @override
  String get playerLoopOne => 'Répéter le titre';

  @override
  String get playerLoopAll => 'Tout répéter';

  @override
  String get snackbarOpeningAlbumPage =>
      'Ouverture de la page d\'origine de l\'album.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Une nouvelle version de Bloomee est disponible.\n\nVersion : $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Extension « $id » installée';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Extension « $id » supprimée';
  }

  @override
  String get pluginBootstrapTitle => 'Configuration de Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Configuration du nouveau moteur d\'extensions… $percent %';
  }

  @override
  String get pluginBootstrapHint =>
      'Cette étape n\'est nécessaire qu\'une seule fois.';

  @override
  String get backupSave => 'Enregistrer la sauvegarde en JSON';

  @override
  String get backupShare => 'Partager la sauvegarde JSON';

  @override
  String get backupPortableDetails =>
      'Inclut les playlists, les favoris, les collections enregistrées, les historiques et les préférences transférables. Les fichiers audio, les comptes et les dossiers de l\'appareil sont exclus.';

  @override
  String get backupHistories => 'Historiques d\'écoute et de recherche';

  @override
  String get backupPreferences => 'Préférences transférables';

  @override
  String get backupNewCopy => 'Importer comme nouvelles playlists';

  @override
  String get backupMerge => 'Fusionner avec les données existantes';

  @override
  String get backupReplace => 'Remplacer les sections sélectionnées';

  @override
  String get backupMergeDetails =>
      'Les titres, les métadonnées et les préférences existants sont conservés. Les titres manquants sont ajoutés à la fin, dans l\'ordre du fichier. Les favoris sont fusionnés.';

  @override
  String get backupReplaceWarning =>
      'Les sections sélectionnées seront remplacées, y compris les playlists et les favoris existants si la bibliothèque est sélectionnée. Les sections non sélectionnées et les fichiers de l\'appareil seront conservés. Une copie de récupération privée sera d\'abord créée.';

  @override
  String get backupAutoDetails =>
      'Conserve sept copies de récupération privées. La vérification a lieu à l\'ouverture de l\'application, avec au maximum une copie par période de 24 heures. Ces copies sont supprimées lors de la désinstallation.';

  @override
  String get backupLocationDetails =>
      'Choisissez un emplacement lors de l\'enregistrement de la sauvegarde. Les copies de récupération privées restent dans l\'application.';

  @override
  String get backupResetDetails =>
      'Réinitialise toutes les données de la base au prochain démarrage. Les fichiers audio téléchargés et les fichiers des extensions installées restent sur l\'appareil. Une copie de récupération privée est d\'abord créée.';

  @override
  String get backupResetPending =>
      'Réinitialisation programmée. Fermez puis rouvrez Bloomee pour la terminer.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return 'Playlists : $playlists · Titres : $tracks';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'Importation terminée. Playlists créées : $playlists ; entrées de titres ajoutées : $tracks ; entrées d\'historique ajoutées : $history ; préférences appliquées : $settings.';
  }

  @override
  String get backupRefreshFailed =>
      'Les données ont été importées. Fermez puis rouvrez Bloomee pour actualiser toutes les préférences.';

  @override
  String get backupRecoveryCopies => 'Copies de récupération';

  @override
  String get backupNoRecoveryCopies =>
      'Aucune copie de récupération pour le moment.';

  @override
  String get backupRecoveryAutomatic => 'Sauvegarde automatique';

  @override
  String get backupRecoveryBeforeImport => 'Avant une importation';

  @override
  String get backupRecoveryBeforeReset => 'Avant une réinitialisation';

  @override
  String get backupCancelReset => 'Annuler la réinitialisation';

  @override
  String get libraryRecoveryTitle => 'Récupérer la bibliothèque manquante';

  @override
  String get libraryRecoverySubtitle =>
      'Rechercher les playlists et les entrées de téléchargement conservées des versions précédentes.';

  @override
  String get libraryRecoveryChooseSource =>
      'Choisissez une base de données conservée à analyser. Votre bibliothèque actuelle et les fichiers d\'origine seront conservés.';

  @override
  String get libraryRecoveryNoSources =>
      'Aucune base de données conservée trouvée. Les fichiers audio seuls ne permettent pas de retrouver les playlists auxquelles ils appartenaient.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return 'Éléments trouvés : $tracks titres, $playlists playlists et $downloads entrées de téléchargement. Fichiers actuellement indisponibles : $unavailable ; leurs entrées seront conservées.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return 'Références de playlists endommagées qui n\'ont pas pu être reconstruites à partir de cette copie : $broken.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'La récupération ajoute les titres, les entrées de playlists et les entrées de téléchargement manquants. Les playlists, les associations de fichiers et les paramètres existants sont conservés. Une copie de récupération est d\'abord créée. Répétez l\'opération avec une autre copie conservée si elle contient d\'autres éléments de votre bibliothèque.';

  @override
  String get libraryRecoveryMerge => 'Fusionner la bibliothèque récupérée';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Récupération terminée. Entrées de playlists ajoutées : $entries ; entrées de téléchargement ajoutées : $downloads.';
  }

  @override
  String get backupStartupFailed => 'Impossible de démarrer Bloomee';

  @override
  String get backupStartupFailedDetails =>
      'Le démarrage a été interrompu sans réparer ni remplacer automatiquement votre base de données. Fermez l\'application et réessayez. Conservez les données de l\'application lorsque vous signalez cette erreur.';

  @override
  String get lyricsTitle => 'Paroles';

  @override
  String get lyricsEnterFullscreen => 'Paroles en plein écran';

  @override
  String get lyricsExitFullscreen => 'Quitter le plein écran';

  @override
  String get lyricsFollowPlayback => 'Suivre la lecture';

  @override
  String get lyricsTimingEarlier => 'Afficher plus tôt';

  @override
  String get lyricsTimingLater => 'Afficher plus tard';

  @override
  String get lyricsTimingSave => 'Enregistrer la synchronisation';

  @override
  String get lyricsSaved => 'Paroles enregistrées.';

  @override
  String get lyricsSaveFailed =>
      'Impossible d\'enregistrer les paroles. Réessayez.';

  @override
  String get lyricsDeleteFailed =>
      'Impossible de supprimer les paroles enregistrées. Réessayez.';

  @override
  String get artistTopSongs => 'Titres populaires';

  @override
  String get artistLoadFailed => 'Impossible de charger l\'artiste';

  @override
  String get artistNoTopSongs => 'Aucun titre populaire disponible';

  @override
  String get artistNoAlbums => 'Aucun album disponible';

  @override
  String get snackbarOpeningArtistPage =>
      'Ouverture de la page d\'origine de l\'artiste.';

  @override
  String get snackbarOpeningPlaylistPage =>
      'Ouverture de la page d\'origine de la playlist.';

  @override
  String get playlistSaveOrderFailed =>
      'Impossible d\'enregistrer l\'ordre de la playlist. Réessayez.';

  @override
  String get playlistReorderTracksHint =>
      'Maintenez la poignée pour réorganiser les titres';

  @override
  String get playlistTrackCountLabel => 'Nombre de titres';

  @override
  String get playlistDescription => 'Description';

  @override
  String get playlistOriginalUrl => 'Lien d\'origine';

  @override
  String get searchSearching => 'Recherche…';

  @override
  String get searchSuggestions => 'Suggestions';

  @override
  String get searchTopResults => 'Meilleurs résultats';

  @override
  String get changelogEmpty =>
      'Aucune information sur les modifications disponible.';

  @override
  String get changelogTitle => 'Nouveautés';

  @override
  String get changelogLatest => 'Dernière version';

  @override
  String get changelogNext => 'Prochaine version';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Configuration incomplète';

  @override
  String get pluginBootstrapRetryBody =>
      'Certaines extensions n\'ont pas pu être installées. Réessayez pour terminer la configuration.';

  @override
  String get pluginBootstrapInternetTitle => 'Connexion Internet requise';

  @override
  String get pluginBootstrapInternetBody =>
      'Bloomee a besoin d\'une connexion Internet lors de la configuration initiale pour détecter votre pays et configurer le moteur d\'extensions.';

  @override
  String get buttonExit => 'Quitter';

  @override
  String get eqSource => 'Source de l\'égaliseur';

  @override
  String get eqBuiltin => 'Égaliseur de l\'application';

  @override
  String get eqBuiltinSubtitle => 'Égaliseur à 10 bandes';

  @override
  String get eqDevice => 'Égaliseur de l\'appareil';

  @override
  String get eqDeviceSubtitle => 'Système / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'L\'égaliseur de l\'application est désactivé. Configurez celui de votre appareil dans ses paramètres audio.';

  @override
  String get eqPresets => 'Préréglages';

  @override
  String get eqCustomCurve => 'Courbe personnalisée';

  @override
  String get shortcutMuted => 'Son coupé';

  @override
  String get shortcutUnmuted => 'Son rétabli';

  @override
  String get shortcutShuffleOn => 'Lecture aléatoire activée';

  @override
  String get shortcutShuffleOff => 'Lecture aléatoire désactivée';

  @override
  String get shortcutRepeatOff => 'Répétition désactivée';

  @override
  String get shortcutLiked => 'Ajouté aux favoris';

  @override
  String get shortcutUnliked => 'Retiré des favoris';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'Impossible de sélectionner le dossier de téléchargement : $error';
  }

  @override
  String get aboutVersionUnavailable => 'Version indisponible';

  @override
  String get backupNewCopyDetails =>
      'Crée des playlists distinctes et fusionne les favoris. Les playlists existantes sont conservées. Les historiques et les préférences sélectionnés sont aussi importés.';

  @override
  String get changelogCurrent => 'Actuelle';

  @override
  String get backupLibrary =>
      'Bibliothèque (playlists, favoris et collections enregistrées)';

  @override
  String get eqPresetFlat => 'Neutre';

  @override
  String get eqPresetAcoustic => 'Acoustique';

  @override
  String get eqPresetBassBoost => 'Renforcement des graves';

  @override
  String get eqPresetBassReducer => 'Réduction des graves';

  @override
  String get eqPresetClassical => 'Classique';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetDeep => 'Profond';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Électronique';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latino';

  @override
  String get eqPresetLive => 'Concert';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetPiano => 'Piano';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRB => 'R&B';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetSmallSpeakers => 'Petites enceintes';

  @override
  String get eqPresetSpokenWord => 'Voix parlée';

  @override
  String get eqPresetTrebleBoost => 'Renforcement des aigus';

  @override
  String get eqPresetTrebleReducer => 'Réduction des aigus';

  @override
  String get eqPresetVocalBooster => 'Renforcement des voix';

  @override
  String get eqPresetCustom => 'Personnalisé';
}
