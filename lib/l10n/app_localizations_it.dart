// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get onboardingTitle => 'Benvenuto in Bloomee';

  @override
  String get onboardingSubtitle => 'Impostiamo lingua e regione.';

  @override
  String get continueButton => 'Continua';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navSearch => 'Cerca';

  @override
  String get navLocal => 'Locale';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Stai ascoltando da';

  @override
  String get playerPlayWithMix => 'Riproduzione Auto-Mix';

  @override
  String get playerPlayNext => 'Riproduci dopo';

  @override
  String get playerAddToQueue => 'Aggiungi alla coda';

  @override
  String get playerAddToFavorites => 'Aggiungi ai preferiti';

  @override
  String get playerNoLyricsFound => 'Nessun testo trovato';

  @override
  String get playerLyricsNoPlugin =>
      'Nessun provider testi configurato. Vai in Impostazioni → Plugin per installarne uno.';

  @override
  String get localMusicTitle => 'Locale';

  @override
  String get localMusicGrantPermission => 'Concedi permesso';

  @override
  String get localMusicStorageAccessRequired => 'Accesso allo spazio di archiviazione richiesto';

  @override
  String get localMusicStorageAccessDesc =>
      'Concedi il permesso per scansionare e riprodurre i file audio sul tuo dispositivo.';

  @override
  String get localMusicAddFolder => 'Aggiungi cartella musicale';

  @override
  String get localMusicScanNow => 'Scansiona ora';

  @override
  String localMusicScanFailed(String message) {
    return 'Scansione fallita: $message';
  }

  @override
  String get localMusicScanning => 'Scansione del dispositivo per file audio in corso...';

  @override
  String get localMusicShuffle => 'Casuale';

  @override
  String get localMusicPlayAll => 'Riproduci tutto';

  @override
  String get localMusicSearchHint => 'Cerca nella musica locale...';

  @override
  String get localMusicRescanDevice => 'Riesegui scansione dispositivo';

  @override
  String get buttonCancel => 'Annulla';

  @override
  String get buttonDelete => 'Elimina';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Aggiorna';

  @override
  String get buttonDownload => 'Scarica';

  @override
  String get buttonLater => 'Più tardi';

  @override
  String get buttonInfo => 'Info';

  @override
  String get buttonMore => 'Altro';

  @override
  String get dialogDeleteTrack => 'Elimina brano';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Sei sicuro di voler eliminare \"$title\" dal dispositivo? Questa azione non può essere annullata.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Questo brano verrà rimosso anche da:';

  @override
  String get dialogDontAskAgain => 'Non chiedermelo più';

  @override
  String get dialogUpdateAvailable => 'Aggiornamento disponibile';

  @override
  String get dialogUpdateNow => 'Aggiorna ora';

  @override
  String get dialogDownloadPlaylist => 'Scarica playlist';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Vuoi scaricare $count brani da \"$title\"? Verranno aggiunti alla coda di download.';
  }

  @override
  String get dialogDownloadAll => 'Scarica tutto';

  @override
  String get playlistEdit => 'Modifica playlist';

  @override
  String get playlistShareFile => 'Condividi file';

  @override
  String get playlistExportFile => 'Esporta file';

  @override
  String get playlistPlay => 'Riproduci';

  @override
  String get playlistAddToQueue => 'Aggiungi playlist alla coda';

  @override
  String get playlistShare => 'Condividi playlist';

  @override
  String get playlistDelete => 'Elimina playlist';

  @override
  String get playlistEmptyState => 'Ancora nessun brano';

  @override
  String get playlistAvailableOffline => 'Disponibile offline';

  @override
  String get playlistShuffle => 'Casuale';

  @override
  String get playlistNoMatchSearch => 'Nessuna playlist corrisponde alla tua ricerca';

  @override
  String get playlistCreateNew => 'Crea playlist';

  @override
  String get playlistCreateFirstOne =>
      'Ancora nessuna playlist. Creane una per iniziare.';

  @override
  String get addToPlaylistNoSongSelected => 'Nessun brano selezionato';

  @override
  String get createPlaylistDialogBarrierLabel => 'Finestra creazione playlist';

  @override
  String get createPlaylistDialogNameHint => 'Summer Vibes';

  @override
  String get createPlaylistDialogCreate => 'Crea';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Brani',
      one: '1 Brano',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title rimosso da $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Impossibile caricare la playlist';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsPlugins => 'Plugin';

  @override
  String get settingsPluginsSubtitle => 'Installa, carica e gestisci i plugin.';

  @override
  String get settingsUpdates => 'Aggiornamenti';

  @override
  String get settingsUpdatesSubtitle => 'Verifica nuovi aggiornamenti';

  @override
  String get settingsDownloads => 'Download';

  @override
  String get settingsDownloadsSubtitle =>
      'Percorso download, qualità download e altro...';

  @override
  String get settingsLocalTracks => 'Brani locali';

  @override
  String get settingsLocalTracksSubtitle =>
      'Scansiona, gestisci cartelle e impostazioni auto-scan.';
      
  @override
  String get settingsPlayer => 'Impostazioni player';

  @override
  String get settingsPlayerSubtitle => 'Qualità streaming, Auto Play, ecc.';

  @override
  String get settingsPluginDefaults => 'Predefiniti plugin';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Sorgente Discover, priorità resolver.';

  @override
  String get settingsUIElements => 'Elementi UI e servizi';

  @override
  String get settingsUIElementsSubtitle => 'Scorrimento automatico, tweaks UI ecc.';

  @override
  String get settingsLastFM => 'Impostazioni Last.FM';

  @override
  String get settingsLastFMSubtitle =>
      'Chiave API, Secret e impostazioni scrobbling.';

  @override
  String get settingsStorage => 'Archiviazione';

  @override
  String get settingsStorageSubtitle =>
      'Backup, Cache, Cronologia, Ripristino e altro...';

  @override
  String get settingsLanguageCountry => 'Lingua e Paese';

  @override
  String get settingsLanguageCountrySubtitle =>
      'Seleziona lingua e paese.';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get settingsAboutSubtitle => 'Info sull\'app, versione, sviluppatore, ecc.';

  @override
  String get settingsScanning => 'Scansione';

  @override
  String get settingsMusicFolders => 'Cartelle musicali';

  @override
  String get settingsQuality => 'Qualità';

  @override
  String get settingsHistory => 'Cronologia';

  @override
  String get settingsBackupRestore => 'Backup e ripristino';

  @override
  String get settingsAutomatic => 'Automatico';

  @override
  String get settingsDangerZone => 'Zona pericolosa';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'Autenticazione';

  @override
  String get settingsHomeScreen => 'Schermata Home';

  @override
  String get settingsChartVisibility => 'Visibilità classifiche';

  @override
  String get dialogAddingToDownloadQueue => 'Aggiunta alla coda di download';

  @override
  String get emptyNoInternet => 'Nessuna connessione Internet!';

  @override
  String get emptyNoContentPlugin =>
      'Nessun plugin contenuti caricato. Carica un Content Resolver nel Gestore Plugin.';

  @override
  String get emptyRefreshingSource =>
      'Aggiornamento sorgente Discover in corso... La sorgente precedente non è più disponibile.';

  @override
  String get emptyNoTracks => 'Nessun brano disponibile';

  @override
  String get emptyNoResults => 'Nessuna corrispondenza trovata';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Eliminato \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Impossibile eliminare \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue => 'Aggiunto come prossimo in coda';

  @override
  String get snackbarAddedToQueue => 'Aggiunto alla coda';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title aggiunto ai preferiti';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'In riproduzione $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Aggiunta $name alla coda';
  }

  @override
  String get snackbarPlaylistUpdated => 'Playlist aggiornata';

  @override
  String get snackbarLinkCopied => 'Link copiato';

  @override
  String get snackbarCouldNotOpenLink => 'Impossibile aprire il link';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Aggiunti $count brani alla coda di download';
  }

  @override
  String get searchHintExplore => 'Cosa vuoi ascoltare?';

  @override
  String get searchHintLibrary => 'Cerca in libreria...';

  @override
  String get searchHintPlaylists => 'Cerca playlist...';

  @override
  String get searchStartTyping => 'Inizia a digitare per cercare...';

  @override
  String get searchNoSuggestions => 'Nessun suggerimento trovato!';

  @override
  String get searchNoResults =>
      'Nessun risultato trovato!\nProva un\'altra parola chiave o sorgente.';

  @override
  String get searchFailed => 'Ricerca fallita!';

  @override
  String get searchDiscover => 'Scopri nuova musica';

  @override
  String get searchSources => 'SORGENTI';

  @override
  String get searchNoPlugins => 'Nessun plugin installato';

  @override
  String get searchTracks => 'Brani';

  @override
  String get searchAlbums => 'Album';

  @override
  String get searchArtists => 'Artisti';

  @override
  String get searchPlaylists => 'Playlist';

  @override
  String get exploreDiscover => 'Scopri';

  @override
  String get exploreRecently => 'Recenti';

  @override
  String get exploreLastFmPicks => 'Scelte Last.FM';

  @override
  String get exploreFailedToLoad => 'Impossibile caricare le sezioni home.';

  @override
  String get libraryTitle => 'Libreria';

  @override
  String get libraryEmptyState =>
      'La tua libreria è vuota. Aggiungi brani e playlist per iniziare.';

  @override
  String libraryIn(String playlistName) {
    return 'in $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Aggiungi a playlist';

  @override
  String get menuSmartReplace => 'Sostituzione intelligente';

  @override
  String get menuShare => 'Condividi';

  @override
  String get menuAvailableOffline => 'Disponibile offline';

  @override
  String get menuDownload => 'Scarica';

  @override
  String get menuOpenOriginalLink => 'Apri link originale';

  @override
  String get menuDeleteTrack => 'Elimina';

  @override
  String get tooltipRemoveFromLibrary => 'Rimuovi dalla libreria';

  @override
  String get tooltipSaveToLibrary => 'Salva in libreria';

  @override
  String get tooltipOpenOriginalLink => 'Apri link originale';

  @override
  String get tooltipAvailableOffline => 'Disponibile offline';

  @override
  String get tooltipMoreOptions => 'Altre opzioni';

  @override
  String get appuiTitle => 'UI e servizi';

  @override
  String get appuiAutoSlideCharts => 'Scorrimento automatico classifiche';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Scorri automaticamente le classifiche nella schermata home.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Mostra suggerimenti da Last.FM. Login e riavvio richiesti.';

  @override
  String get appuiNoChartsAvailable =>
      'Nessuna classifica disponibile. Carica un plugin provider classifiche.';

  @override
  String get appuiLoginToLastFm => 'Effettua prima il login a Last.FM.';

  @override
  String get appuiShowInCarousel => 'Mostra nel carosello home.';

  @override
  String get countrySettingTitle => 'Paese e lingua';

  @override
  String get countrySettingAutoDetect => 'Rileva paese automaticamente';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Rileva automaticamente il tuo paese all\'apertura dell\'app.';

  @override
  String get countrySettingCountryLabel => 'Paese';

  @override
  String get countrySettingLanguageLabel => 'Lingua';

  @override
  String get countrySettingSystemDefault => 'Predefinito di sistema';

  @override
  String get downloadSettingTitle => 'Download';

  @override
  String get downloadSettingQuality => 'Qualità download';

  @override
  String get downloadSettingQualitySubtitle =>
      'Preferenza qualità audio universale per i brani scaricati.';

  @override
  String get downloadSettingFolder => 'Cartella download';

  @override
  String get downloadSettingResetFolder => 'Ripristina cartella download';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Ripristina il percorso di download predefinito.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Scrobble brani';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Invia i brani riprodotti al tuo profilo Last.FM.';

  @override
  String get lastfmAuthFirst => 'Prima autentica le API Last.FM.';

  @override
  String get lastfmAuthenticatedAs => 'Autenticato come';

  @override
  String get lastfmAuthFailed => 'Autenticazione fallita:';

  @override
  String get lastfmNotAuthenticated => 'Non autenticato';

  @override
  String get lastfmSteps =>
      'Passi per autenticarsi:\n1. Crea / apri un account Last.FM su last.fm\n2. Genera una chiave API su last.fm/api/account/create\n3. Inserisci chiave API e Secret qui sotto\n4. Tocca \"Inizia autenticazione\" e approva nel browser\n5. Tocca \"Ottieni e salva Session Key\" per finire';

  @override
  String get lastfmApiKey => 'Chiave API';

  @override
  String get lastfmApiSecret => 'Secret API';

  @override
  String get lastfmStartAuth => '1. Inizia autenticazione';

  @override
  String get lastfmGetSession => '2. Ottieni e salva Session Key';
  
  @override
String get lastfmRemoveKeys => 'Rimuovi chiavi';

  @override
  String get lastfmStartAuthFirst =>
      'Prima inizia l\'autenticazione, poi approva nel browser.';

  @override
  String get localSettingTitle => 'Brani locali';

  @override
  String get localSettingAutoScan => 'Auto-scan all\'avvio';

  @override
  String get localSettingAutoScanSubtitle =>
      'Scansiona automaticamente nuovi brani locali all\'avvio dell\'app.';

  @override
  String get localSettingLastScan => 'Ultima scansione';

  @override
  String get localSettingNeverScanned => 'Mai';

  @override
  String get localSettingScanInProgress => 'Scansione in corso…';

  @override
  String get localSettingScanNowSubtitle =>
      'Avvia manualmente una scansione completa della libreria.';

  @override
  String get localSettingNoFolders =>
      'Nessuna cartella aggiunta. Aggiungi una cartella per iniziare la scansione.';

  @override
  String get localSettingAddFolder => 'Aggiungi cartella';

  @override
  String get playerSettingTitle => 'Impostazioni player';

  @override
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Qualità streaming';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Bitrate audio globale per la riproduzione online.';

  @override
  String get playerSettingQualityLow => 'Bassa';

  @override
  String get playerSettingQualityMedium => 'Media';

  @override
  String get playerSettingQualityHigh => 'Alta';

  @override
  String get playerSettingPlaybackHeader => 'Riproduzione';

  @override
  String get playerSettingAutoPlay => 'Auto Play';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Accoda brani simili quando la coda finisce.';

  @override
  String get playerSettingAutoFallback => 'Fallback automatico riproduzione';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Se un plugin manca o non restituisce stream, prova un resolver compatibile solo per la riproduzione.';

  @override
  String get playerSettingCrossfade => 'Crossfade';

  @override
  String get playerSettingCrossfadeOff => 'Off';

  @override
  String get playerSettingCrossfadeInstant => 'I brani cambiano istantaneamente';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Dissolvenza di ${seconds}s tra i brani';
  }

  @override
  String get playerSettingEqualizer => 'Equalizzatore';

  @override
  String get playerSettingEqualizerActive => 'Attivo';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Attivo — preset $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'EQ parametrico a 10 bande via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Predefiniti plugin';

  @override
  String get pluginDefaultsDiscoverHeader => 'Sorgente Discover';

  @override
  String get pluginDefaultsNoResolver =>
      'Nessun content resolver caricato. Carica un plugin per scegliere una sorgente Discover.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Usa il primo content resolver disponibile.';

  @override
  String get pluginDefaultsPriorityHeader => 'Priorità Resolver';

  @override
  String get pluginDefaultsNoPriority =>
      'Nessun content resolver caricato. L\'ordinamento priorità apparirà qui una volta caricati i plugin.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Trascina per riordinare. I resolver con priorità più alta vengono provati per primi quando si risolvono elementi classifica o brani importati in brani riproducibili.';

  @override
  String get pluginDefaultsLyricsHeader => 'Priorità testi';

  @override
  String get pluginDefaultsLyricsNone => 'Nessun provider testi caricato.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Trascina per riordinare i provider testi. Il primo provider viene provato per primo.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Suggerimenti ricerca';

  @override
  String get pluginDefaultsSuggestionsNone => 'Nessun provider suggerimenti caricato.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Nessuno';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Usa solo cronologia ricerche.';

  @override
  String get storageSettingTitle => 'Archiviazione';

  @override
  String get storageClearHistoryEvery => 'Cancella cronologia ogni';

  @override
  String get storageClearHistorySubtitle =>
      'Cancella la cronologia di ascolto dopo il periodo scelto.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Giorni',
      one: '1 Giorno',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Backup creato in $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Condivisione backup fallita: $error';
  }

  @override
  String get storageRestoreBackup => 'Ripristina backup';

  @override
  String get storageRestoreBackupSubtitle =>
      'Ripristina impostazioni e dati da un file di backup.';

  @override
  String get storageAutoBackup => 'Backup automatico';

  @override
  String get storageAutoLyrics => 'Salvataggio automatico testi';

  @override
  String get storageAutoLyricsSubtitle =>
      'Salva automaticamente i testi quando un brano viene riprodotto.';

  @override
  String get storageResetApp => 'Reimposta app Bloomee';

  @override
  String get storageResetConfirmTitle => 'Conferma reimpostazione';

  @override
  String get storageResetButton => 'Reimposta';

  @override
  String get storageRestoreOptionsTitle => 'Opzioni di ripristino';

  @override
  String get storageRestoreContinue => 'Continua';

  @override
  String get storageRestoreConfirmTitle => 'Conferma ripristino';

  @override
  String get storageRestoreYes => 'Sì, ripristina';

  @override
  String get storageRestoring =>
      'Ripristino dati selezionati in corso…\nAttendi fino al completamento dell\'operazione.';

  @override
  String get storageRestoreFailedTitle => 'Ripristino fallito';

  @override
  String get updateSettingTitle => 'Aggiornamenti';

  @override
  String get updateCheckForUpdates => 'Verifica aggiornamenti';

  @override
  String get updateCheckSubtitle =>
      'Verifica se è disponibile una versione più recente di Bloomee.';

  @override
  String get updateAutoNotify => 'Notifica aggiornamento automatico';

  @override
  String get updateAutoNotifySubtitle =>
      'Ricevi notifica all\'avvio quando sono disponibili nuovi aggiornamenti.';

  @override
  String get updateCheckTitle => 'Verifica aggiornamenti';

  @override
  String get updateUpToDate => 'Bloomee è aggiornato';

  @override
  String get updateViewPreRelease => 'Vedi ultima pre-release';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versione attuale: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'È disponibile una nuova versione di Bloomee';

  @override
  String updateVersion(String ver, String build) {
    return 'Versione: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Scarica ora';

  @override
  String get updateChecking => 'Verifica aggiornamenti in corso…';

  @override
  String get timerTitle => 'Timer spegnimento';

  @override
  String get timerInterludeMessage => 'La riproduzione si fermerà tra…';

  @override
  String get timerHours => 'Ore';

  @override
  String get timerMinutes => 'Minuti';

  @override
  String get timerSeconds => 'Secondi';

  @override
  String get timerStop => 'Ferma timer';

  @override
  String get timerFinishedMessage => 'Il timer di spegnimento ha fermato la riproduzione.';

  @override
  String get timerGotIt => 'Capito!';

  @override
  String get timerSetTimeError => 'Imposta un orario';

  @override
  String get timerStart => 'Avvia timer';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsEmpty => 'Ancora nessuna notifica!';

  @override
  String get recentsTitle => 'Cronologia';

  @override
  String playlistByCreator(String creator) {
    return 'di $creator';
  }

  @override
  String get playlistYou => 'Tu';

  @override
  String get pluginManagerTitle => 'Plugin';

  @override
  String get pluginManagerEmpty =>
      'Nessun plugin installato.\nTocca + per aggiungere un file .bex.';

  @override
  String get pluginManagerFilterAll => 'Tutti';

  @override
  String get pluginManagerFilterContent => 'Content Resolver';

  @override
  String get pluginManagerFilterCharts => 'Provider classifiche';

  @override
  String get pluginManagerFilterLyrics => 'Provider testi';

  @override
  String get pluginManagerFilterSuggestions => 'Provider suggerimenti';

  @override
  String get pluginManagerFilterImporters => 'Importatori contenuti';

  @override
  String get pluginManagerTooltipRefresh => 'Aggiorna';

  @override
  String get pluginManagerTooltipInstall => 'Installa plugin';

  @override
  String get pluginManagerNoMatch => 'Nessun plugin corrisponde a questo filtro';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Selezione file fallita: $error';
  }

  @override
  String get pluginManagerInstalling => 'Installazione plugin in corso...';

  @override
  String get pluginManagerTypeContentResolver => 'Content Resolver';

  @override
  String get pluginManagerTypeChartProvider => 'Provider classifiche';

  @override
  String get pluginManagerTypeLyricsProvider => 'Provider testi';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Suggerimenti ricerca';

  @override
  String get pluginManagerTypeContentImporter => 'Importatore contenuti';

  @override
  String get pluginManagerDeleteTitle => 'Eliminare plugin?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"? Rimuoverà permanentemente i suoi file.';
  }

  @override
  String get pluginManagerDeleteAction => 'Elimina';

  @override
  String get pluginManagerCancel => 'Annulla';

  @override
  String get pluginManagerEnablePlugin => 'Abilita plugin';

  @override
  String get pluginManagerUnloadPlugin => 'Disattiva plugin';

  @override
  String get pluginManagerDeleting => 'Eliminazione in corso...';

  @override
  String get pluginManagerApiKeysTitle => 'Chiavi API';

  @override
  String get pluginManagerApiKeysSaved => 'Chiavi API salvate';

  @override
  String get pluginManagerSave => 'Salva';

  @override
  String get pluginManagerDetailVersion => 'Versione';

  @override
  String get pluginManagerDetailType => 'Tipo';

  @override
  String get pluginManagerDetailPublisher => 'Publisher';

  @override
  String get pluginManagerDetailLastUpdated => 'Ultimo aggiornamento';

  @override
  String get pluginManagerDetailCreated => 'Creato';

  @override
  String get pluginManagerDetailHomepage => 'Homepage';

  @override
  String get pluginManagerDeleteStorageTitle => 'Eliminare dati plugin?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Rimuovere anche chiavi API salvate e impostazioni per \"$name\"?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Mantieni dati';

  @override
  String get pluginManagerDeleteStorageRemove => 'Rimuovi dati';

  @override
  String get segmentsSheetTitle => 'Segmenti';

  @override
  String get segmentsSheetEmpty => 'Nessun segmento disponibile';

  @override
  String get segmentsSheetUntitled => 'Segmento senza titolo';

  @override
  String get smartReplaceTitle => 'Sostituzione intelligente';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Scegli una sostituzione riproducibile per \"$title\" e aggiorna i riferimenti playlist salvati.';
  }

  @override
  String get smartReplaceClose => 'Chiudi';

  @override
  String get smartReplaceNoMatch => 'Nessuna sostituzione trovata';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Nessuno dei plugin resolver caricati ha restituito una corrispondenza abbastanza forte.';

  @override
  String get smartReplaceBestMatch => 'Migliore corrispondenza';

  @override
  String get smartReplaceSearchFailed => 'Ricerca fallita';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Sostituzione intelligente fallita: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Sostituzione applicata$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' e coda aggiornata';

  @override
  String get playerUnknownQueue => 'Sconosciuto';

  @override
  String playerLiked(String title) {
    return '$title aggiunto ai preferiti';
  }

  @override
  String playerUnliked(String title) {
    return '$title rimosso dai preferiti';
  }

  @override
  String get offlineNoDownloads => 'Nessun download';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Cerca nei tuoi brani...';

  @override
  String get offlineRefreshTooltip => 'Aggiorna download';

  @override
  String get offlineCloseSearch => 'Chiudi ricerca';

  @override
  String get offlineSearchTooltip => 'Cerca';

  @override
  String get offlineOpenFailed =>
      'Impossibile aprire questo brano offline. Prova ad aggiornare i download.';

  @override
  String get offlinePlayFailed =>
      'Impossibile riprodurre questo brano offline. Riprova.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Brani',
      one: '1 Brano',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Caricamento album fallito';

  @override
  String get aboutCraftingSubtitle => 'Creato per la musica.';

  @override
  String get aboutFollowGitHub => 'Seguilo su GitHub';

  @override
  String get aboutSendInquiry => 'Invia una richiesta business';

  @override
  String get aboutCreativeHighlights => 'Aggiornamenti e highlights creativi';

  @override
  String get aboutTipQuote =>
      'Ti piace Bloomee? Puoi supportarne lo sviluppo.';

  @override
  String get aboutTipButton => 'Supporta il progetto';

  @override
  String get aboutTipDesc => 'Il tuo contributo aiuta a migliorare Bloomee.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Dettagli brano';

  @override
  String get songInfoSectionTechnical => 'Info tecniche';

  @override
  String get songInfoSectionActions => 'Azioni';

  @override
  String get songInfoLabelTitle => 'Titolo';

  @override
  String get songInfoLabelArtist => 'Artista';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Durata';

  @override
  String get songInfoLabelSource => 'Sorgente';

  @override
  String get songInfoLabelMediaId => 'ID Media';

  @override
  String get songInfoLabelPluginId => 'ID Plugin';

  @override
  String get songInfoCopyId => 'Copia ID';

  @override
  String get songInfoCopyLink => 'Copia link';

  @override
  String get songInfoOpenBrowser => 'Apri nel browser';

  @override
  String get songInfoIdCopied => 'ID Media copiato';

  @override
  String get songInfoLinkCopied => 'Link copiato';

  @override
  String get songInfoNoLink => 'Nessun link disponibile';

  @override
  String get songInfoOpenFailed => 'Impossibile aprire il link';

  @override
  String get songInfoUpdateMetadata => 'Ottieni ultimi metadati';

  @override
  String get songInfoMetadataUpdated => 'Metadati aggiornati';

  @override
  String get songInfoMetadataUpdateFailed => 'Impossibile aggiornare i metadati';

  @override
  String get songInfoMetadataUnavailable =>
      'Aggiornamento metadati non disponibile per questa sorgente';

  @override
  String get songInfoSearchTitle => 'Cerca questo brano in Bloomee';

  @override
  String get songInfoSearchArtist => 'Cerca questo artista in Bloomee';

  @override
  String get songInfoSearchAlbum => 'Cerca questo album in Bloomee';

  @override
  String get eqTitle => 'Equalizzatore';

  @override
  String get chartNoItems => 'Nessun elemento in questa classifica';

  @override
  String get chartLoadFailed => 'Caricamento classifica fallito';

  @override
  String get chartPlay => 'Riproduci';

  @override
  String get chartResolving => 'Risoluzione in corso';

  @override
  String get chartReady => 'Pronto';

  @override
  String get chartAddToPlaylist => 'Aggiungi a playlist';

  @override
  String get chartNoResolver =>
      'Nessun content resolver caricato. Installa un plugin per riprodurre.';

  @override
  String get chartResolveFailed => 'Impossibile risolvere. Cerco invece...';

  @override
  String get chartNoResolverAdd => 'Nessun content resolver caricato.';

  @override
  String get chartNoMatch => 'Nessuna corrispondenza trovata. Prova a cercare manualmente.';

  @override
  String get chartStatPeak => 'Picco';

  @override
  String get chartStatWeeks => 'Settimane';

  @override
  String get chartStatChange => 'Variazione';

  @override
  String menuSharePreparing(String title) {
    return 'Preparazione di $title per la condivisione.';
  }

  @override
  String get menuOpenLinkFailed => 'Impossibile aprire il link';

  @override
  String get localMusicFolders => 'Cartelle musicali';

  @override
  String get localMusicRemoveFolder => 'Rimuovi cartella';

  @override
  String get localMusicCloseSearch => 'Chiudi ricerca';

  @override
  String get localMusicOpenSearch => 'Cerca';

  @override
  String get localMusicNoMusicFound => 'Nessuna musica locale trovata';

  @override
  String get localMusicNoSearchResults =>
      'Nessun brano trovato per la tua ricerca.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani',
      one: '1 brano',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Importa brani';

  @override
  String get importNoPluginsLoaded =>
      'Nessun plugin importatore contenuti caricato.\nInstalla un plugin importatore per importare playlist da servizi esterni.';

  @override
  String get importBloomeeFiles => 'Importa file Bloomee';

  @override
  String get importM3UFiles => 'Importa playlist M3U';

  @override
  String get importM3UNameDialogTitle => 'Nome playlist';

  @override
  String get importM3UNameHint => 'Inserisci un nome per questa playlist';

  @override
  String get importM3UNoTracks => 'Nessun brano valido trovato nel file M3U.';

  @override
  String get importNoteTitle => 'Nota';

  @override
  String get importNoteMessage =>
      'Puoi importare solo file creati da Bloomee.\nSe il file proviene da un\'altra sorgente, non funzionerà. Continuare comunque?';

  @override
  String get importTitle => 'Importa';

  @override
  String get importCheckingUrl => 'Verifica URL in corso...';

  @override
  String get importFetchingTracks => 'Recupero brani in corso...';

  @override
  String get importSavingToLibrary => 'Salvataggio in libreria in corso...';

  @override
  String get importPasteUrlHint => 'Incolla un URL di playlist o album da importare';

  @override
  String get importAction => 'Importa';

  @override
  String importTrackCount(int count) {
    return '$count brani';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Risoluzione brani: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Salva $count brani';
  }

  @override
  String importTracksSaved(int count) {
    return '$count brani salvati!';
  }

  @override
  String get importDone => 'Fatto';

  @override
  String get importMore => 'Importa altro';

  @override
  String get importUnknownError => 'Errore sconosciuto';

  @override
  String get importTryAgain => 'Riprova';

  @override
  String get importSkipTrack => 'Salta questo brano';

  @override
  String get importMatchOptions => 'Opzioni corrispondenza';

  @override
  String get importSkipped => 'Saltato';

  @override
  String get importReorderTip => 'Tieni premuta una playlist per iniziare a riordinare';

  @override
  String get importErrorCannotHandleUrl =>
      'Questo plugin non può gestire l\'URL fornito.';

  @override
  String get importErrorUnexpectedResponse =>
      'Risposta inaspettata dal plugin.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Verifica URL fallita: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Recupero info collezione fallito: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Recupero brani fallito: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Salvataggio playlist fallito: $error';
  }

  @override
  String get playlistPinToTop => 'Fissa in alto';

  @override
  String get playlistUnpin => 'Rimuovi fissaggio';

  @override
  String get snackbarInvalidFileFormat => 'Formato file non valido';

  @override
  String get snackbarProcessingFile => 'Elaborazione file in corso...';

  @override
  String get pluginManagerTabInstalled => 'Installati';

  @override
  String get pluginManagerTabStore => 'Store plugin';

  @override
  String get pluginManagerSelectPackage => 'Seleziona pacchetto plugin (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'Il plugin usa una versione manifest obsoleta. Alcune funzionalità potrebbero non funzionare. Valuta l\'aggiornamento.';

  @override
  String get pluginManagerStatusActive => 'Attivo';

  @override
  String get pluginManagerStatusInactive => 'Inattivo';

  @override
  String get pluginRepositoryAddTitle => 'Aggiungi repository';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Inserisci l\'URL di un file JSON repository plugin valido.';

  @override
  String get pluginRepositoryAddAction => 'Aggiungi repository';

  @override
  String get pluginRepositoryTitle => 'Repository plugin';

  @override
  String get pluginRepositorySubtitle =>
      'Aggiungi una sorgente JSON per sfogliare plugin remoti.';

  @override
  String get pluginRepositoryEmpty => 'Nessun repository aggiunto ancora.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Aggiornamento sconosciuto';

  @override
  String get pluginRepositoryNoDescription => 'Nessuna descrizione fornita.';

  @override
  String get pluginRepositoryUrlCopied => 'URL repository copiato negli appunti';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugin',
      one: '1 plugin',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Aggiornato $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugin disponibili',
      one: '1 plugin disponibile',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Manifest obsoleto. Le funzionalità potrebbero non funzionare.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Publisher sconosciuto';

  @override
  String get pluginRepositoryActionRetry => 'Riprova';

  @override
  String get pluginRepositoryActionOutdated => 'Obsoleto';

  @override
  String get pluginRepositoryActionInstalled => 'Installato';

  @override
  String get pluginRepositoryActionInstall => 'Installa';

  @override
  String get pluginRepositoryActionUnavailable => 'Non disponibile';

  @override
  String get pluginRepositoryInstallFailed => 'Installazione fallita.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Download di $name fallito.';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Caricamento repository fallito.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'URL repository non valido o file repository non valido.';

  @override
  String get pluginRepositoryErrorRemove => 'Rimozione repository fallita.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sostituito in $count playlist$queue.',
      one: 'Sostituito in 1 playlist$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Cerca testi...';

  @override
  String get lyricsSearchEmptyPrompt => 'Digita un brano o artista per trovare i testi.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Nessun testo trovato per \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'Testi applicati con successo';

  @override
  String get lyricsSearchFetchFailed => 'Recupero testi fallito';

  @override
  String get lyricsSearchPreview => 'Anteprima';

  @override
  String get lyricsSearchPreviewTooltip => 'Anteprima testi';

  @override
  String get lyricsSearchSynced => 'SINCRONIZZATO';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Caricamento testi fallito.';

  @override
  String get lyricsSearchApplyAction => 'Applica testo';

  @override
  String get lyricsSettingsSearchTitle => 'Cerca testi personalizzati';

  @override
  String get lyricsSettingsSearchSubtitle => 'Trova versioni alternative online';

  @override
  String get lyricsSettingsSyncTitle => 'Regola sincronizzazione (ritardo/offset)';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Correggi testi troppo veloci o lenti';

  @override
  String get lyricsSettingsSaveTitle => 'Salva offline';

  @override
  String get lyricsSettingsSaveSubtitle => 'Salva questi testi sul dispositivo';

  @override
  String get lyricsSettingsDeleteTitle => 'Elimina testi salvati';

  @override
  String get lyricsSettingsDeleteSubtitle => 'Rimuovi dati testi offline';

  @override
  String get lyricsSyncTapToReset => 'Tocca per reimpostare';

  @override
  String get upNextTitle => 'Prossimi';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi in coda',
      one: '1 elemento in coda',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Copia negli appunti';

  @override
  String get snackbarCopiedToClipboard => 'Copiato negli appunti';

  @override
  String get tooltipSongInfo => 'Info brano';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Impossibile eliminare il brano in riproduzione';

  @override
  String get playerLoopOff => 'Off';

  @override
  String get playerLoopOne => 'Ripeti uno';

  @override
  String get playerLoopAll => 'Ripeti tutti';

  @override
  String get snackbarOpeningAlbumPage => 'Apertura pagina album originale.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'È disponibile una nuova versione di Bloomee.\n\nVersione: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Plugin \"$id\" installato con successo';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Plugin \"$id\" eliminato con successo';
  }

  @override
  String get pluginBootstrapTitle => 'Configurazione Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Configurazione nuovo motore plugin in corso... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Succede solo una volta.';

  @override
  String get backupSave => 'Salva backup come JSON';

  @override
  String get backupShare => 'Condividi backup JSON';

  @override
  String get backupPortableDetails =>
      'Include playlist, preferiti, collezioni salvate, cronologie e preferenze portabili. File audio, account e cartelle dispositivo sono esclusi.';

  @override
  String get backupHistories => 'Cronologie riproduzione e ricerca';

  @override
  String get backupPreferences => 'Preferenze portabili';

  @override
  String get backupNewCopy => 'Importa come nuove playlist';

  @override
  String get backupMerge => 'Unisci con dati esistenti';

  @override
  String get backupReplace => 'Sostituisci sezioni selezionate';

  @override
  String get backupMergeDetails =>
      'Brani esistenti, metadati e preferenze sono preservati. I brani mancanti vengono aggiunti in ordine file. I preferiti vengono uniti.';

  @override
  String get backupReplaceWarning =>
      'Questo sostituisce le sezioni selezionate, incluse playlist e preferiti esistenti quando è selezionata la libreria. Sezioni non selezionate e file dispositivo sono preservati. Viene creata prima una copia privata di recupero.';

  @override
  String get backupAutoDetails =>
      'Mantiene sette copie private di recupero. Verificato all\'apertura dell\'app, al massimo una volta ogni 24 ore. Le copie private vengono rimosse alla disinstallazione.';

  @override
  String get backupLocationDetails =>
      'Scegli una destinazione con Salva backup. Le copie private di recupero sono conservate dentro l\'app.';

  @override
  String get backupResetDetails =>
      'Reimposta tutti i dati database al prossimo avvio dell\'app. File audio scaricati e file plugin installati rimangono su questo dispositivo. Viene creata prima una copia privata di recupero.';

  @override
  String get backupResetPending =>
      'Reimpostazione programmata. Chiudi e riapri Bloomee per completarla.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return '$playlists playlist e $tracks brani';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'Importazione completata: $playlists playlist create, $tracks voci brano aggiunte, $history record cronologia aggiunti e $settings preferenze applicate.';
  }

  @override
  String get backupRefreshFailed =>
      'Dati importati. Chiudi e riapri Bloomee per aggiornare tutte le preferenze.';

  @override
  String get backupRecoveryCopies => 'Copie di recupero';

  @override
  String get backupNoRecoveryCopies => 'Ancora nessuna copia di recupero.';

  @override
  String get backupRecoveryAutomatic => 'Backup automatico';

  @override
  String get backupRecoveryBeforeImport => 'Prima di un\'importazione';

  @override
  String get backupRecoveryBeforeReset => 'Prima di una reimpostazione';

  @override
  String get backupCancelReset => 'Annulla reimpostazione';

  @override
  String get libraryRecoveryTitle => 'Recupera libreria mancante';

  @override
  String get libraryRecoverySubtitle =>
      'Cerca playlist e record download conservati da versioni precedenti.';

  @override
  String get libraryRecoveryChooseSource =>
      'Scegli un database conservato da scansionare. La tua libreria attuale e i file originali saranno preservati.';

  @override
  String get libraryRecoveryNoSources =>
      'Nessun database conservato trovato. I soli file audio non possono ripristinare l\'appartenenza originale alle playlist.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return 'Trovati $tracks brani, $playlists playlist e $downloads record download. $unavailable file sono attualmente non disponibili; i loro record saranno preservati.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return '$broken riferimenti playlist danneggiati non possono essere ricostruiti da questa copia.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'Il recupero aggiunge brani mancanti, voci playlist e record download. Playlist esistenti, mappature file e impostazioni sono preservate. Viene creata prima una copia di recupero. Ripeti con un\'altra copia conservata se contiene più della tua libreria.';

  @override
  String get libraryRecoveryMerge => 'Unisci libreria recuperata';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Recupero completato: $entries voci playlist e $downloads record download aggiunti.';
  }

  @override
  String get backupStartupFailed => 'Bloomee non si è avviato';

  @override
  String get backupStartupFailedDetails =>
      'Avvio interrotto senza riparare o sostituire automaticamente il database. Chiudi l\'app e riprova. Conserva i dati app quando segnali questo errore.';

  @override
  String get lyricsTitle => 'Testi';

  @override
  String get lyricsEnterFullscreen => 'Testi a schermo intero';

  @override
  String get lyricsExitFullscreen => 'Esci da schermo intero';

  @override
  String get lyricsFollowPlayback => 'Segui riproduzione';

  @override
  String get lyricsTimingEarlier => 'Prima';

  @override
  String get lyricsTimingLater => 'Dopo';

  @override
  String get lyricsTimingSave => 'Salva timing';

  @override
  String get lyricsSaved => 'Testi salvati.';

  @override
  String get lyricsSaveFailed => 'Impossibile salvare i testi. Riprova.';

  @override
  String get lyricsDeleteFailed => 'Impossibile eliminare i testi salvati. Riprova.';

  @override
  String get artistTopSongs => 'Brani top';

  @override
  String get artistLoadFailed => 'Caricamento artista fallito';

  @override
  String get artistNoTopSongs => 'Nessun brano top disponibile';

  @override
  String get artistNoAlbums => 'Nessun album disponibile';

  @override
  String get snackbarOpeningArtistPage => 'Apertura pagina artista originale.';

  @override
  String get snackbarOpeningPlaylistPage => 'Apertura pagina playlist originale.';

  @override
  String get playlistSaveOrderFailed =>
      'Impossibile salvare l\'ordine playlist. Riprova.';

  @override
  String get playlistReorderTracksHint => 'Tieni premuto il cursore per riordinare i brani';

  @override
  String get playlistTrackCountLabel => 'Numero brani';

  @override
  String get playlistDescription => 'Descrizione';

  @override
  String get playlistOriginalUrl => 'URL originale';

  @override
  String get searchSearching => 'Ricerca in corso…';

  @override
  String get searchSuggestions => 'Suggerimenti';

  @override
  String get searchTopResults => 'Top risultati';

  @override
  String get changelogEmpty => 'Nessuna info changelog disponibile.';

  @override
  String get changelogTitle => 'Novità';

  @override
  String get changelogLatest => 'Ultima';

  @override
  String get changelogNext => 'Prossima versione';

  @override
  String changelogVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Setup incompleto';

  @override
  String get pluginBootstrapRetryBody =>
      'Alcuni plugin non possono essere installati ora. Riprova per finire il setup.';

  @override
  String get pluginBootstrapInternetTitle => 'Internet richiesta';

  @override
  String get pluginBootstrapInternetBody =>
      'Bloomee necessita una connessione Internet una volta per rilevare il tuo paese e configurare il motore plugin.';

  @override
  String get buttonExit => 'Esci';

  @override
  String get eqSource => 'Sorgente equalizzatore';

  @override
  String get eqBuiltin => 'Equalizzatore in-app';

  @override
  String get eqBuiltinSubtitle => 'Equalizzatore a 10 bande';

  @override
  String get eqDevice => 'Equalizzatore dispositivo';

  @override
  String get eqDeviceSubtitle => 'Sistema / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'L\'equalizzatore in-app è disabilitato. Configura l\'equalizzatore dispositivo nelle impostazioni audio del tuo dispositivo.';

  @override
  String get eqPresets => 'Preset';

  @override
  String get eqCustomCurve => 'Curva personalizzata';

  @override
  String get shortcutMuted => 'Silenzioso';

  @override
  String get shortcutUnmuted => 'Audio attivo';

  @override
  String get shortcutShuffleOn => 'Casuale attivo';

  @override
  String get shortcutShuffleOff => 'Casuale disattivo';

  @override
  String get shortcutRepeatOff => 'Ripetizione off';

  @override
  String get shortcutLiked => 'Aggiunto ai preferiti';

  @override
  String get shortcutUnliked => 'Rimosso dai preferiti';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'Impossibile selezionare cartella download: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Versione non disponibile';

  @override
  String get backupNewCopyDetails =>
      'Crea playlist separate e unisce i preferiti. Le playlist esistenti sono preservate. Anche cronologie e preferenze selezionate vengono importate.';

  @override
  String get changelogCurrent => 'Attuale';

  @override
  String get backupLibrary =>
      'Libreria (playlist, preferiti e collezioni salvate)';

  @override
  String get eqPresetFlat => 'Piatto';

  @override
  String get eqPresetAcoustic => 'Acustico';

  @override
  String get eqPresetBassBoost => 'Bassi potenziati';

  @override
  String get eqPresetBassReducer => 'Bassi ridotti';

  @override
  String get eqPresetClassical => 'Classico';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetDeep => 'Profondo';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Elettronico';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latino';

  @override
  String get eqPresetLive => 'Live';

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
  String get eqPresetSmallSpeakers => 'Piccoli altoparlanti';

  @override
  String get eqPresetSpokenWord => 'Parlato';

  @override
  String get eqPresetTrebleBoost => 'Alti potenziati';

  @override
  String get eqPresetTrebleReducer => 'Alti ridotti';

  @override
  String get eqPresetVocalBooster => 'Voce potenziata';

  @override
  String get eqPresetCustom => 'Personalizzato';
}
