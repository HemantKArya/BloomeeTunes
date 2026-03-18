// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboardingTitle => 'Willkommen bei Bloomee';

  @override
  String get onboardingSubtitle => 'Richten wir deine Sprache und Region ein.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get navHome => 'Start';

  @override
  String get navLibrary => 'Mediathek';

  @override
  String get navSearch => 'Suche';

  @override
  String get navLocal => 'Lokal';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Wird abgespielt von';

  @override
  String get playerQueue => 'Warteschlange';

  @override
  String get playerPlayWithMix => 'Auto-Mix Wiedergabe';

  @override
  String get playerPlayNext => 'Als Nächstes spielen';

  @override
  String get playerAddToQueue => 'In Warteschlange';

  @override
  String get playerAddToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get playerNoLyricsFound => 'Kein Songtext gefunden';

  @override
  String get playerLyricsNoPlugin =>
      'Kein Songtext-Anbieter konfiguriert. Gehe zu Einstellungen → Plugins, um einen zu installieren.';

  @override
  String get playerFullscreenLyrics => 'Vollbild-Songtext';

  @override
  String get localMusicTitle => 'Lokal';

  @override
  String get localMusicGrantPermission => 'Berechtigung erteilen';

  @override
  String get localMusicStorageAccessRequired => 'Speicherzugriff erforderlich';

  @override
  String get localMusicStorageAccessDesc =>
      'Bitte erlaube den Zugriff, um auf deinem Gerät gespeicherte Audiodateien zu finden und abzuspielen.';

  @override
  String get localMusicAddFolder => 'Musikordner hinzufügen';

  @override
  String get localMusicScanNow => 'Jetzt scannen';

  @override
  String localMusicScanFailed(String message) {
    return 'Scan fehlgeschlagen: $message';
  }

  @override
  String get localMusicScanning => 'Gerät wird nach Audiodateien durchsucht...';

  @override
  String get localMusicEmpty => 'Keine lokale Musik gefunden';

  @override
  String get localMusicSearchEmpty =>
      'Keine Titel gefunden, die deiner Suche entsprechen.';

  @override
  String get localMusicShuffle => 'Shuffle';

  @override
  String get localMusicPlayAll => 'Alle abspielen';

  @override
  String get localMusicSearchHint => 'Lokale Musik suchen...';

  @override
  String get localMusicRescanDevice => 'Gerät neu scannen';

  @override
  String get localMusicRemoveFolder => 'Ordner entfernen';

  @override
  String get localMusicMusicFolders => 'Musikordner';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonDelete => 'Löschen';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Update';

  @override
  String get buttonDownload => 'Download';

  @override
  String get buttonShare => 'Teilen';

  @override
  String get buttonLater => 'Später';

  @override
  String get buttonInfo => 'Info';

  @override
  String get buttonMore => 'Mehr';

  @override
  String get dialogDeleteTrack => 'Titel löschen';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Bist du sicher, dass du „$title“ von deinem Gerät löschen möchtest? Dieser Vorgang kann nicht rückgängig gemacht werden.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Dieser Titel wird auch entfernt aus:';

  @override
  String get dialogDontAskAgain => 'Nicht erneut fragen';

  @override
  String get dialogDeletePlugin => 'Plugin löschen?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'Bist du sicher, dass du „$name“ löschen möchtest? Dies wird alle zugehörigen Dateien dauerhaft entfernen.';
  }

  @override
  String get dialogUpdateAvailable => 'Update verfügbar';

  @override
  String get dialogUpdateNow => 'Jetzt aktualisieren';

  @override
  String get dialogDownloadPlaylist => 'Playlist herunterladen';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Möchtest du $count Songs aus „$title“ herunterladen? Sie werden zur Download-Warteschlange hinzugefügt.';
  }

  @override
  String get dialogDownloadAll => 'Alle herunterladen';

  @override
  String get playlistEdit => 'Playlist bearbeiten';

  @override
  String get playlistShareFile => 'Datei teilen';

  @override
  String get playlistExportFile => 'Datei exportieren';

  @override
  String get playlistPlay => 'Abspielen';

  @override
  String get playlistAddToQueue => 'Playlist zur Warteschlange hinzufügen';

  @override
  String get playlistShare => 'Playlist teilen';

  @override
  String get playlistDelete => 'Playlist löschen';

  @override
  String get playlistEmptyState => 'Noch keine Songs vorhanden!';

  @override
  String get playlistAvailableOffline => 'Offline verfügbar';

  @override
  String get playlistShuffle => 'Zufallswiedergabe';

  @override
  String get playlistMoreOptions => 'Weitere Optionen';

  @override
  String get playlistNoMatchSearch =>
      'Keine Playlists entsprechen deiner Suche';

  @override
  String get playlistCreateNew => 'Neue Playlist erstellen';

  @override
  String get playlistCreateFirstOne =>
      'Noch keine Playlists. Erstelle eine, um loszulegen!';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Songs',
      one: '1 Song',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '„$title“ aus $playlist entfernt';
  }

  @override
  String get playlistFailedToLoad => 'Playlist konnte nicht geladen werden';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsPlugins => 'Plugins';

  @override
  String get settingsPluginsSubtitle =>
      'Plugins installieren, laden und verwalten.';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsUpdatesSubtitle => 'Nach neuen Versionen suchen';

  @override
  String get settingsDownloads => 'Downloads';

  @override
  String get settingsDownloadsSubtitle => 'Speicherpfad, Qualität und mehr...';

  @override
  String get settingsLocalTracks => 'Lokale Titel';

  @override
  String get settingsLocalTracksSubtitle =>
      'Ordner verwalten und Scan-Einstellungen.';

  @override
  String get settingsPlayer => 'Player-Einstellungen';

  @override
  String get settingsPlayerSubtitle => 'Streaming-Qualität, Auto-Play etc.';

  @override
  String get settingsPluginDefaults => 'Plugin-Standards';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Entdeckungsquelle, Resolver-Priorität.';

  @override
  String get settingsUIElements => 'Benutzeroberfläche';

  @override
  String get settingsUIElementsSubtitle => 'Auto-Slide, UI-Anpassungen etc.';

  @override
  String get settingsLastFM => 'Last.FM Einstellungen';

  @override
  String get settingsLastFMSubtitle => 'API-Key und Scrobbling-Einstellungen.';

  @override
  String get settingsStorage => 'Speicher';

  @override
  String get settingsStorageSubtitle =>
      'Backup, Cache, Verlauf, Wiederherstellung.';

  @override
  String get settingsLanguageCountry => 'Sprache & Region';

  @override
  String get settingsLanguageCountrySubtitle =>
      'Wähle deine Sprache und dein Land.';

  @override
  String get settingsAbout => 'Über Bloomee';

  @override
  String get settingsAboutSubtitle => 'Version, Entwickler und App-Info.';

  @override
  String get settingsScanning => 'Scanning';

  @override
  String get settingsMusicFolders => 'Musikordner';

  @override
  String get settingsQuality => 'Qualität';

  @override
  String get settingsHistory => 'Verlauf';

  @override
  String get settingsBackupRestore => 'Sicherung & Wiederherstellung';

  @override
  String get settingsAutomatic => 'Automatisch';

  @override
  String get settingsDangerZone => 'Gefahrenzone';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'Authentifizierung';

  @override
  String get settingsHomeScreen => 'Startbildschirm';

  @override
  String get settingsChartVisibility => 'Charts-Sichtbarkeit';

  @override
  String get settingsLocation => 'Standort';

  @override
  String get pluginRepositoryTitle => 'Plugin-Repositorys';

  @override
  String get pluginRepositorySubtitle =>
      'JSON-Quelle hinzufügen zum Suchen von Remote-Plugins.';

  @override
  String get pluginRepositoryAddAction => 'Repository hinzufügen';

  @override
  String get pluginRepositoryAddTitle => 'Repository hinzufügen';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Gib die URL einer gültigen Plugin-Repository JSON ein.';

  @override
  String get pluginRepositoryEmpty => 'Noch keine Repositorys hinzugefügt.';

  @override
  String get pluginRepositoryUrlCopied =>
      'Repository-URL in Zwischenablage kopiert';

  @override
  String get pluginRepositoryNoDescription => 'Keine Beschreibung vorhanden.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Unbekanntes Update';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plugins',
      one: '1 Plugin',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Fehler beim Laden der Repositorys.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'Ungültige Repository-URL oder Datei.';

  @override
  String get pluginRepositoryErrorRemove =>
      'Fehler beim Entfernen des Repositorys.';

  @override
  String pluginRepositoryError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get dialogAddingToDownloadQueue =>
      'Wird zur Download-Warteschlange hinzugefügt';

  @override
  String get emptyNoInternet => 'Keine Internetverbindung!';

  @override
  String get emptyNoContentPlugin =>
      'Kein Content-Plugin geladen. Installiere einen Content Resolver im Plugin-Manager.';

  @override
  String get emptyRefreshingSource =>
      'Entdeckungsquelle wird aktualisiert... Die vorherige Quelle ist nicht mehr verfügbar.';

  @override
  String get emptyNoTracks => 'Keine Titel verfügbar';

  @override
  String get emptyNoResults => 'Keine Treffer gefunden';

  @override
  String snackbarDeletedTrack(String title) {
    return '„$title“ gelöscht';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Löschen von „$title“ fehlgeschlagen';
  }

  @override
  String get snackbarAddedToNextQueue =>
      'Als Nächstes in Warteschlange hinzugefügt';

  @override
  String get snackbarAddedToQueue => 'Zur Warteschlange hinzugefügt';

  @override
  String snackbarAddedToLiked(String title) {
    return '„$title“ wurde zu deinen Favoriten hinzugefügt!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Spielt gerade $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name zur Warteschlange hinzugefügt';
  }

  @override
  String get snackbarPlaylistQueued =>
      'Playlist zur Download-Warteschlange hinzugefügt';

  @override
  String get snackbarPlaylistUpdated => 'Playlist aktualisiert!';

  @override
  String get snackbarNoInternet => 'Keine Internetverbindung.';

  @override
  String get snackbarImportFailed => 'Import fehlgeschlagen!';

  @override
  String get snackbarImportCompleted => 'Import abgeschlossen';

  @override
  String get snackbarBackupFailed => 'Sicherung fehlgeschlagen!';

  @override
  String snackbarExportedTo(String path) {
    return 'Exportiert nach: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'Media-ID kopiert';

  @override
  String get snackbarLinkCopied => 'Link kopiert';

  @override
  String get snackbarNoLinkAvailable => 'Kein Link verfügbar';

  @override
  String get snackbarCouldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Download für „$title“ wird vorbereitet...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '„$title“ ist bereits heruntergeladen.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '„$title“ ist bereits in der Warteschlange.';
  }

  @override
  String snackbarDownloaded(String title) {
    return '„$title“ heruntergeladen';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Fehler: Download-Dienst ist nicht verfügbar.';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count Songs zur Download-Warteschlange hinzugefügt';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Fehler beim Löschen des Titels vom Gerätespeicher.';

  @override
  String get searchHintExplore => 'Was möchtest du hören?';

  @override
  String get searchHintLibrary => 'Mediathek durchsuchen...';

  @override
  String get searchHintOfflineMusic => 'Deine Songs durchsuchen...';

  @override
  String get searchHintPlaylists => 'Playlists durchsuchen...';

  @override
  String get searchStartTyping => 'Tippe, um zu suchen...';

  @override
  String get searchNoSuggestions => 'Keine Vorschläge gefunden!';

  @override
  String get searchNoResults =>
      'Keine Ergebnisse gefunden!\nVersuche es mit einem anderen Begriff oder einer anderen Quelle.';

  @override
  String get searchFailed => 'Suche fehlgeschlagen!';

  @override
  String get searchDiscover => 'Entdecke neue Musik...';

  @override
  String get searchSources => 'QUELLEN';

  @override
  String get searchNoPlugins => 'Keine Plugins installiert';

  @override
  String get searchTracks => 'Titel';

  @override
  String get searchAlbums => 'Alben';

  @override
  String get searchArtists => 'Interpreten';

  @override
  String get searchPlaylists => 'Playlists';

  @override
  String get exploreDiscover => 'Entdecken';

  @override
  String get exploreRecently => 'Zuletzt gehört';

  @override
  String get exploreLastFmPicks => 'Last.Fm Empfehlungen';

  @override
  String get exploreFailedToLoad =>
      'Startbildschirm konnte nicht geladen werden.';

  @override
  String get libraryTitle => 'Mediathek';

  @override
  String get libraryEmptyState =>
      'Deine Mediathek wirkt etwas einsam. Füge ein paar Titel hinzu, um sie zum Leben zu erwecken!';

  @override
  String libraryIn(String playlistName) {
    return 'in $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Zu Playlist hinzufügen';

  @override
  String get menuSmartReplace => 'Intelligentes Ersetzen';

  @override
  String get menuShare => 'Teilen';

  @override
  String get menuAvailableOffline => 'Offline verfügbar';

  @override
  String get menuDownload => 'Download';

  @override
  String get menuOpenOriginalLink => 'Original-Link öffnen';

  @override
  String get menuDeleteTrack => 'Löschen';

  @override
  String get songInfoTitle => 'Titel';

  @override
  String get songInfoArtist => 'Interpret';

  @override
  String get songInfoAlbum => 'Album';

  @override
  String get songInfoMediaId => 'Media-ID';

  @override
  String get songInfoCopyId => 'ID kopieren';

  @override
  String get songInfoCopyLink => 'Link kopieren';

  @override
  String get songInfoOpenBrowser => 'Im Browser öffnen';

  @override
  String get tooltipRemoveFromLibrary => 'Aus Mediathek entfernen';

  @override
  String get tooltipSaveToLibrary => 'In Mediathek speichern';

  @override
  String get tooltipOpenOriginalLink => 'Original-Link öffnen';

  @override
  String get tooltipShuffle => 'Zufallswiedergabe';

  @override
  String get tooltipAvailableOffline => 'Offline verfügbar';

  @override
  String get tooltipDownloadPlaylist => 'Playlist herunterladen';

  @override
  String get tooltipMoreOptions => 'Weitere Optionen';

  @override
  String get tooltipInfo => 'Info';

  @override
  String get appuiTitle => 'UI & Dienste';

  @override
  String get appuiAutoSlideCharts => 'Charts automatisch wechseln';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Charts auf dem Startbildschirm automatisch durchwechseln.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Vorschläge von Last.FM anzeigen. Login & Neustart erforderlich.';

  @override
  String get appuiNoChartsAvailable =>
      'Keine Charts verfügbar. Installiere ein Chart-Plugin.';

  @override
  String get appuiLoginToLastFm => 'Bitte melde dich zuerst bei Last.FM an.';

  @override
  String get appuiShowInCarousel => 'Im Karussell auf Start anzeigen.';

  @override
  String get countrySettingTitle => 'Land & Sprache';

  @override
  String get countrySettingAutoDetect => 'Land automatisch erkennen';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Erkennt dein Land automatisch beim Start der App.';

  @override
  String get countrySettingCountryLabel => 'Land';

  @override
  String get countrySettingLanguageLabel => 'Sprache';

  @override
  String get countrySettingSystemDefault => 'Systemstandard';

  @override
  String get downloadSettingTitle => 'Downloads';

  @override
  String get downloadSettingQuality => 'Download-Qualität';

  @override
  String get downloadSettingQualitySubtitle =>
      'Standard-Audioqualität für heruntergeladene Titel.';

  @override
  String get downloadSettingFolder => 'Download-Ordner';

  @override
  String get downloadSettingResetFolder => 'Ordner zurücksetzen';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Standard-Downloadpfad wiederherstellen.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Titel scrobbeln';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Überträgt gehörte Titel in dein Last.FM-Profil.';

  @override
  String get lastfmAuthFirst => 'Zuerst Last.FM API authentifizieren.';

  @override
  String get lastfmAuthenticatedAs => 'Angemeldet als';

  @override
  String get lastfmAuthFailed => 'Authentifizierung fehlgeschlagen:';

  @override
  String get lastfmNotAuthenticated => 'Nicht authentifiziert';

  @override
  String get lastfmSteps =>
      'Schritte zur Anmeldung:\n1. Last.FM-Konto erstellen/öffnen\n2. API-Key generieren unter last.fm/api/account/create\n3. API-Key & Secret unten eingeben\n4. Auf „Authentifizierung starten“ tippen und im Browser bestätigen\n5. Auf „Session-Key speichern“ tippen';

  @override
  String get lastfmApiKey => 'API-Key';

  @override
  String get lastfmApiSecret => 'API-Secret';

  @override
  String get lastfmStartAuth => '1. Authentifizierung starten';

  @override
  String get lastfmGetSession => '2. Session-Key speichern';

  @override
  String get lastfmRemoveKeys => 'Keys entfernen';

  @override
  String get lastfmStartAuthFirst =>
      'Starte zuerst die Authentifizierung und bestätige im Browser.';

  @override
  String get localSettingTitle => 'Lokale Titel';

  @override
  String get localSettingAutoScan => 'Beim Start scannen';

  @override
  String get localSettingAutoScanSubtitle =>
      'Sucht beim App-Start automatisch nach neuen lokalen Titeln.';

  @override
  String get localSettingLastScan => 'Letzter Scan';

  @override
  String get localSettingNeverScanned => 'Nie';

  @override
  String get localSettingScanInProgress => 'Scan läuft...';

  @override
  String get localSettingScanNowSubtitle =>
      'Manuellen vollständigen Mediathek-Scan starten.';

  @override
  String get localSettingNoFolders =>
      'Keine Ordner hinzugefügt. Füge einen Ordner hinzu, um zu scannen.';

  @override
  String get localSettingAddFolder => 'Ordner hinzufügen';

  @override
  String get playerSettingTitle => 'Player-Einstellungen';

  @override
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Streaming-Qualität';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Globale Audio-Bitrate für Online-Wiedergabe.';

  @override
  String get playerSettingQualityLow => 'Niedrig';

  @override
  String get playerSettingQualityMedium => 'Mittel';

  @override
  String get playerSettingQualityHigh => 'Hoch';

  @override
  String get playerSettingPlaybackHeader => 'Wiedergabe';

  @override
  String get playerSettingAutoPlay => 'Auto-Play';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Ähnliche Songs hinzufügen, wenn die Warteschlange endet.';

  @override
  String get playerSettingAutoFallback => 'Automatisches Fallback';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Wenn ein Plugin fehlschlägt, wird automatisch ein kompatibler Resolver versucht.';

  @override
  String get playerSettingCrossfade => 'Überblenden';

  @override
  String get playerSettingCrossfadeOff => 'Aus';

  @override
  String get playerSettingCrossfadeInstant => 'Titel sofort wechseln';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '${seconds}s Überblendung zwischen Titeln';
  }

  @override
  String get playerSettingEqualizer => 'Equalizer';

  @override
  String get playerSettingEqualizerActive => 'Aktiv';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Aktiviert — $preset Profil';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Parametrischer 10-Band-EQ (via FFmpeg).';

  @override
  String get pluginDefaultsTitle => 'Plugin-Standards';

  @override
  String get pluginDefaultsDiscoverHeader => 'Entdeckungsquelle';

  @override
  String get pluginDefaultsNoResolver =>
      'Kein Content Resolver geladen. Installiere ein Plugin, um eine Quelle zu wählen.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Ersten verfügbaren Content Resolver verwenden.';

  @override
  String get pluginDefaultsPriorityHeader => 'Resolver-Priorität';

  @override
  String get pluginDefaultsNoPriority =>
      'Keine Resolver geladen. Die Priorisierung erscheint hier nach der Installation.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Ziehen zum Sortieren. Höher priorisierte Plugins werden zuerst zur Wiedergabe versucht.';

  @override
  String get pluginDefaultsLyricsHeader => 'Songtext-Priorität';

  @override
  String get pluginDefaultsLyricsNone => 'Keine Songtext-Anbieter geladen.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Ziehen zum Sortieren. Der oberste Anbieter wird zuerst versucht.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Suchvorschläge';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'Keine Vorschlags-Anbieter geladen.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Keine';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Nur Suchverlauf verwenden.';

  @override
  String get storageSettingTitle => 'Speicher';

  @override
  String get storageClearHistoryEvery => 'Verlauf löschen alle';

  @override
  String get storageClearHistorySubtitle =>
      'Löscht den Hörverlauf nach dem gewählten Zeitraum.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get storageBackupLocation => 'Backup-Speicherort';

  @override
  String get storageBackupLocationAndroid =>
      'Downloads / App-Daten Verzeichnis';

  @override
  String get storageBackupLocationDownloads => 'Downloads Verzeichnis';

  @override
  String get storageCreateBackup => 'Sicherung erstellen';

  @override
  String get storageCreateBackupSubtitle =>
      'Speichere Einstellungen und Daten in einer Backup-Datei.';

  @override
  String storageBackupCreatedAt(String path) {
    return 'Sicherung erstellt unter $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Freigabe der Sicherung fehlgeschlagen: $error';
  }

  @override
  String get storageBackupFailed => 'Sicherung fehlgeschlagen!';

  @override
  String get storageRestoreBackup => 'Sicherung wiederherstellen';

  @override
  String get storageRestoreBackupSubtitle =>
      'Wiederherstellen von Einstellungen und Daten aus einer Datei.';

  @override
  String get storageAutoBackup => 'Auto-Backup';

  @override
  String get storageAutoBackupSubtitle =>
      'Erstellt regelmäßig automatisch eine Sicherung deiner Daten.';

  @override
  String get storageAutoLyrics => 'Songtexte automatisch speichern';

  @override
  String get storageAutoLyricsSubtitle =>
      'Speichert Songtexte automatisch beim Abspielen eines Titels.';

  @override
  String get storageResetApp => 'Bloomee App zurücksetzen';

  @override
  String get storageResetAppSubtitle =>
      'Alle Daten löschen und App in den Werkszustand versetzen.';

  @override
  String get storageResetConfirmTitle => 'Zurücksetzen bestätigen';

  @override
  String get storageResetConfirmMessage =>
      'Bist du sicher, dass du Bloomee zurücksetzen möchtest? Dies löscht alle deine Daten unwiderruflich.';

  @override
  String get storageResetButton => 'Zurücksetzen';

  @override
  String get storageResetSuccess =>
      'App wurde in den Standardzustand zurückgesetzt.';

  @override
  String get storageLocationDialogTitle => 'Backup-Speicherort';

  @override
  String get storageLocationAndroid =>
      'Sicherungen befinden sich in:\n\n1. Downloads-Verzeichnis\n2. Android/data/ls.bloomee.musicplayer/data\n\nKopiere die Datei von einem dieser Orte.';

  @override
  String get storageLocationOther =>
      'Sicherungen werden im Downloads-Verzeichnis gespeichert.';

  @override
  String get storageRestoreOptionsTitle => 'Wiederherstellungsoptionen';

  @override
  String get storageRestoreOptionsDesc =>
      'Wähle die Daten zur Wiederherstellung. Deaktiviere Elemente, die NICHT importiert werden sollen.';

  @override
  String get storageRestoreSelectAll => 'Alle auswählen';

  @override
  String get storageRestoreMediaItems => 'Medien-Elemente (Songs, Mediathek)';

  @override
  String get storageRestoreSearchHistory => 'Suchverlauf';

  @override
  String get storageRestoreContinue => 'Weiter';

  @override
  String get storageRestoreNoFile => 'Keine Datei ausgewählt.';

  @override
  String get storageRestoreSaveFailed =>
      'Fehler beim Speichern der ausgewählten Datei.';

  @override
  String get storageRestoreConfirmTitle => 'Wiederherstellung bestätigen';

  @override
  String get storageRestoreConfirmPrefix =>
      'Dies wird die gewählten Teile in der App mit den Backup-Daten überschreiben/zusammenführen:';

  @override
  String get storageRestoreConfirmSuffix =>
      'Deine aktuellen Daten werden geändert. Möchtest du fortfahren?';

  @override
  String get storageRestoreYes => 'Ja, wiederherstellen';

  @override
  String get storageRestoreNo => 'Nein';

  @override
  String get storageRestoring => 'Wiederherstellung läuft...\nBitte warten.';

  @override
  String get storageRestoreMediaBullet => '• Medien-Elemente';

  @override
  String get storageRestoreHistoryBullet => '• Suchverlauf';

  @override
  String get storageUnexpectedError =>
      'Ein unerwarteter Fehler ist bei der Wiederherstellung aufgetreten.';

  @override
  String get storageRestoreCompleted => 'Wiederherstellung abgeschlossen';

  @override
  String get storageRestoreFailedTitle => 'Wiederherstellung fehlgeschlagen';

  @override
  String get storageRestoreSuccessMessage =>
      'Die Daten wurden erfolgreich wiederhergestellt. Bitte starte die App jetzt neu.';

  @override
  String get storageRestoreFailedMessage =>
      'Wiederherstellung fehlgeschlagen mit Fehlern:';

  @override
  String get storageRestoreUnknownError =>
      'Unbekannter Fehler bei der Wiederherstellung.';

  @override
  String get storageRestoreRestartHint =>
      'Bitte starte die App für eine saubere Übernahme neu.';

  @override
  String get updateSettingTitle => 'Updates';

  @override
  String get updateAppUpdatesHeader => 'App-Updates';

  @override
  String get updateCheckForUpdates => 'Nach Updates suchen';

  @override
  String get updateCheckSubtitle =>
      'Prüfen, ob eine neuere Version von Bloomee verfügbar ist.';

  @override
  String get updateAutoNotify => 'Update-Benachrichtigung';

  @override
  String get updateAutoNotifySubtitle =>
      'Benachrichtigen, wenn beim App-Start Updates verfügbar sind.';

  @override
  String get updateCheckTitle => 'Update-Suche';

  @override
  String get updateUpToDate => 'Bloomee🌸 ist auf dem neuesten Stand!!!';

  @override
  String get updateViewPreRelease => 'Neueste Pre-Release ansehen';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Aktuelle Version: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Neue Version von Bloomee🌸 verfügbar!';

  @override
  String updateVersion(String ver, String build) {
    return 'Version: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Jetzt herunterladen';

  @override
  String get updateChecking => 'Es wird nach neuen Versionen gesucht...';

  @override
  String get timerTitle => 'Sleep Timer';

  @override
  String get timerInterludeMessage => 'Die Musik wird gestoppt in…';

  @override
  String get timerHours => 'Stunden';

  @override
  String get timerMinutes => 'Minuten';

  @override
  String get timerSeconds => 'Sekunden';

  @override
  String get timerStop => 'Timer stoppen';

  @override
  String get timerFinishedMessage => 'Musikwiedergabe beendet. Gute Nacht 🥰.';

  @override
  String get timerGotIt => 'Alles klar';

  @override
  String get timerSetTimeError => 'Bitte stelle eine Zeit ein';

  @override
  String get timerStart => 'Timer starten';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsEmpty => 'Noch keine Benachrichtigungen!';

  @override
  String get recentsTitle => 'Verlauf';

  @override
  String playlistByCreator(String creator) {
    return 'von $creator';
  }

  @override
  String get playlistTypeAlbum => 'Album';

  @override
  String get playlistTypePlaylist => 'Playlist';

  @override
  String get playlistYou => 'Du';

  @override
  String get pluginManagerTitle => 'Plugins';

  @override
  String get pluginManagerEmpty =>
      'Keine Plugins installiert.\nTippe auf +, um eine .bex Datei hinzuzufügen.';

  @override
  String get pluginManagerFilterAll => 'Alle';

  @override
  String get pluginManagerFilterContent => 'Content Resolver';

  @override
  String get pluginManagerFilterCharts => 'Chart-Anbieter';

  @override
  String get pluginManagerFilterLyrics => 'Songtext-Anbieter';

  @override
  String get pluginManagerFilterSuggestions => 'Vorschlags-Anbieter';

  @override
  String get pluginManagerFilterImporters => 'Importer';

  @override
  String get pluginManagerTooltipRefresh => 'Aktualisieren';

  @override
  String get pluginManagerTooltipInstall => 'Plugin installieren';

  @override
  String get pluginManagerNoMatch => 'Keine Plugins entsprechen diesem Filter';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Datei konnte nicht gewählt werden: $error';
  }

  @override
  String get pluginManagerInstalling => 'Plugin wird installiert...';

  @override
  String get pluginManagerTypeContentResolver => 'Content Resolver';

  @override
  String get pluginManagerTypeChartProvider => 'Chart-Anbieter';

  @override
  String get pluginManagerTypeLyricsProvider => 'Songtext-Anbieter';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Suchvorschläge';

  @override
  String get pluginManagerTypeContentImporter => 'Importer';

  @override
  String get pluginManagerDeleteTitle => 'Plugin löschen?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Möchtest du „$name“ wirklich löschen? Dies entfernt alle zugehörigen Dateien.';
  }

  @override
  String get pluginManagerDeleteAction => 'Löschen';

  @override
  String get pluginManagerCancel => 'Abbrechen';

  @override
  String get pluginManagerEnablePlugin => 'Plugin aktivieren';

  @override
  String get pluginManagerUnloadPlugin => 'Plugin deaktivieren';

  @override
  String get pluginManagerDeleting => 'Löscht...';

  @override
  String get pluginManagerApiKeysTitle => 'API-Keys';

  @override
  String get pluginManagerApiKeysSaved => 'API-Keys gespeichert';

  @override
  String get pluginManagerSave => 'Speichern';

  @override
  String get pluginManagerDetailVersion => 'Version';

  @override
  String get pluginManagerDetailType => 'Typ';

  @override
  String get pluginManagerDetailPublisher => 'Herausgeber';

  @override
  String get pluginManagerDetailLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get pluginManagerDetailCreated => 'Erstellt am';

  @override
  String get pluginManagerDetailHomepage => 'Homepage';

  @override
  String get pluginManagerDowngradeTitle => 'Plugin downgraden?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'Du installierst eine ältere oder gleiche Version von „$name“. Fortfahren?';
  }

  @override
  String get pluginManagerDowngradeAction => 'Trotzdem installieren';

  @override
  String get pluginManagerDeleteStorageTitle => 'Plugin-Daten löschen?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Sollen auch gespeicherte API-Keys und Einstellungen für „$name“ entfernt werden?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Daten behalten';

  @override
  String get pluginManagerDeleteStorageRemove => 'Daten entfernen';

  @override
  String get segmentsSheetTitle => 'Segmente';

  @override
  String get segmentsSheetEmpty => 'Keine Segmente verfügbar';

  @override
  String get segmentsSheetUntitled => 'Unbenanntes Segment';

  @override
  String get smartReplaceTitle => 'Smart Replace';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Wähle einen spielbaren Ersatz für „$title“ und aktualisiere Verweise in deinen Playlists.';
  }

  @override
  String get smartReplaceClose => 'Schließen';

  @override
  String get smartReplaceNoMatch => 'Kein Ersatz gefunden';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Keines der Plugins lieferte einen ausreichend guten Treffer.';

  @override
  String get smartReplaceBestMatch => 'Bester Treffer';

  @override
  String get smartReplaceSearchFailed => 'Suche fehlgeschlagen';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Smart Replace fehlgeschlagen: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Ersatz angewendet$queue.';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return 'In $count Playlist$plural ersetzt$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' und Warteschlange aktualisiert';

  @override
  String get playerUnknownQueue => 'Unbekannt';

  @override
  String playerLiked(String title) {
    return 'Zu Favoriten hinzugefügt!';
  }

  @override
  String playerUnliked(String title) {
    return 'Aus Favoriten entfernt!';
  }

  @override
  String get offlineNoDownloads => 'Keine Downloads';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Deine Songs durchsuchen...';

  @override
  String get offlineRefreshTooltip => 'Downloads aktualisieren';

  @override
  String get offlineCloseSearch => 'Suche schließen';

  @override
  String get offlineSearchTooltip => 'Suche';

  @override
  String get offlineOpenFailed =>
      'Dieser Offline-Titel konnte nicht geöffnet werden. Versuche, die Downloads zu aktualisieren.';

  @override
  String get offlinePlayFailed =>
      'Song konnte nicht abgespielt werden. Bitte erneut versuchen.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Album konnte nicht geladen werden';

  @override
  String get aboutCraftingSubtitle => 'Sinfonien aus Code erschaffen.';

  @override
  String get aboutFollowGitHub => 'Folge ihm auf GitHub';

  @override
  String get aboutSendInquiry => 'Geschäftliche Anfrage senden';

  @override
  String get aboutCreativeHighlights => 'Updates und kreative Highlights';

  @override
  String get aboutTipQuote =>
      'Gefällt dir Bloomee? Eine kleine Unterstützung lässt die App weiter blühen. 🌸';

  @override
  String get aboutTipButton => 'Ich möchte helfen';

  @override
  String get aboutTipDesc => 'Ich möchte, dass Bloomee immer besser wird.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Song-Details';

  @override
  String get songInfoSectionTechnical => 'Technische Info';

  @override
  String get songInfoSectionActions => 'Aktionen';

  @override
  String get songInfoLabelTitle => 'Titel';

  @override
  String get songInfoLabelArtist => 'Interpret';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Dauer';

  @override
  String get songInfoLabelSource => 'Quelle';

  @override
  String get songInfoLabelMediaId => 'Media-ID';

  @override
  String get songInfoLabelPluginId => 'Plugin-ID';

  @override
  String get songInfoIdCopied => 'Media-ID kopiert';

  @override
  String get songInfoLinkCopied => 'Link kopiert';

  @override
  String get songInfoNoLink => 'Kein Link verfügbar';

  @override
  String get songInfoOpenFailed => 'Link konnte nicht geöffnet werden';

  @override
  String get songInfoUpdateMetadata => 'Metadaten aktualisieren';

  @override
  String get songInfoMetadataUpdated => 'Metadaten aktualisiert';

  @override
  String get songInfoMetadataUpdateFailed =>
      'Fehler beim Aktualisieren der Metadaten';

  @override
  String get songInfoMetadataUnavailable =>
      'Metadaten-Update für diese Quelle nicht verfügbar';

  @override
  String get songInfoSearchTitle => 'In Bloomee nach diesem Song suchen';

  @override
  String get songInfoSearchArtist =>
      'In Bloomee nach diesem Interpreten suchen';

  @override
  String get songInfoSearchAlbum => 'In Bloomee nach diesem Album suchen';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get eqResetTooltip => 'Auf Standard zurücksetzen';

  @override
  String get chartNoItems => 'Keine Einträge in diesem Chart';

  @override
  String get chartLoadFailed => 'Chart konnte nicht geladen werden';

  @override
  String get chartPlay => 'Abspielen';

  @override
  String get chartResolving => 'Wird aufgelöst';

  @override
  String get chartReady => 'Bereit';

  @override
  String get chartAddToPlaylist => 'Zu Playlist hinzufügen';

  @override
  String get chartNoResolver =>
      'Kein Content Resolver geladen. Plugin installieren zum Abspielen.';

  @override
  String get chartResolveFailed =>
      'Konnte nicht aufgelöst werden. Suche stattdessen...';

  @override
  String get chartNoResolverAdd => 'Kein Content Resolver geladen.';

  @override
  String get chartNoMatch =>
      'Kein Treffer gefunden. Versuche es mit einer manuellen Suche.';

  @override
  String get chartStatPeak => 'Spitze';

  @override
  String get chartStatWeeks => 'Wochen';

  @override
  String get chartStatChange => 'Wechsel';

  @override
  String menuSharePreparing(String title) {
    return 'Bereite „$title“ zum Teilen vor.';
  }

  @override
  String get menuOpenLinkFailed => 'Link konnte nicht geöffnet werden';

  @override
  String get localMusicFolders => 'Musikordner';

  @override
  String get localMusicCloseSearch => 'Suche schließen';

  @override
  String get localMusicOpenSearch => 'Suche';

  @override
  String get localMusicNoMusicFound => 'Keine lokale Musik gefunden';

  @override
  String get localMusicNoSearchResults =>
      'Keine Titel gefunden, die deiner Suche entsprechen.';

  @override
  String get importSongsTitle => 'Songs importieren';

  @override
  String get importNoPluginsLoaded =>
      'Keine Importer-Plugins geladen.\nInstalliere ein Plugin, um Playlists externer Dienste zu importieren.';

  @override
  String get importBloomeeFiles => 'Bloomee-Dateien importieren';

  @override
  String get importM3UFiles => 'M3U-Playlist importieren';

  @override
  String get importM3UNameDialogTitle => 'Playlist-Name';

  @override
  String get importM3UNameHint => 'Gib einen Namen für diese Playlist ein';

  @override
  String get importM3UNoTracks =>
      'Keine gültigen Titel in der M3U-Datei gefunden.';

  @override
  String get importNoteTitle => 'Hinweis';

  @override
  String get importNoteMessage =>
      'Du kannst nur Dateien importieren, die von Bloomee erstellt wurden. Andere Dateien funktionieren nicht. Trotzdem fortfahren?';

  @override
  String get importTitle => 'Import';

  @override
  String get importCheckingUrl => 'URL wird geprüft...';

  @override
  String get importFetchingTracks => 'Titel werden abgerufen...';

  @override
  String get importSavingToLibrary => 'In Mediathek gespeichert...';

  @override
  String get importPasteUrlHint =>
      'Playlist- oder Album-URL zum Importieren einfügen';

  @override
  String get importAction => 'Import';

  @override
  String importTrackCount(int count) {
    return '$count Titel';
  }

  @override
  String get importResolving => 'Wird aufgelöst...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'Titel werden aufgelöst: $done / $total';
  }

  @override
  String get importReviewTitle => 'Import-Vorschau';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved aufgelöst, $failed fehlgeschlagen von $total';
  }

  @override
  String importSaveTracks(int count) {
    return '$count Titel speichern';
  }

  @override
  String importTracksSaved(int count) {
    return '$count Titel gespeichert!';
  }

  @override
  String get importDone => 'Fertig';

  @override
  String get importMore => 'Mehr importieren';

  @override
  String get importUnknownError => 'Unbekannter Fehler';

  @override
  String get importTryAgain => 'Erneut versuchen';

  @override
  String get importSkipTrack => 'Diesen Titel überspringen';

  @override
  String get importMatchOptions => 'Treffer-Optionen';

  @override
  String get importAutoMatched => 'Auto-Match';

  @override
  String get importUserSelected => 'Ausgewählt';

  @override
  String get importSkipped => 'Übersprungen';

  @override
  String get importNoMatch => 'Kein Treffer';

  @override
  String get importReorderTip => 'Playlist gedrückt halten zum Sortieren';

  @override
  String get importErrorCannotHandleUrl =>
      'Dieses Plugin kann die angegebene URL nicht verarbeiten.';

  @override
  String get importErrorUnexpectedResponse => 'Unerwartete Antwort vom Plugin.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Fehler beim Prüfen der URL: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Fehler beim Abrufen der Info: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Fehler beim Abrufen der Titel: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Fehler beim Speichern der Playlist: $error';
  }

  @override
  String get playlistPinToTop => 'Oben anheften';

  @override
  String get playlistUnpin => 'Anheften lösen';

  @override
  String get snackbarImportingMedia => 'Medien werden importiert...';

  @override
  String get snackbarPlaylistSaved => 'Playlist in Mediathek gespeichert!';

  @override
  String get snackbarInvalidFileFormat => 'Ungültiges Dateiformat';

  @override
  String get snackbarMediaItemImported => 'Medien-Element importiert';

  @override
  String get snackbarPlaylistImported => 'Playlist importiert';

  @override
  String get snackbarOpenImportForUrl =>
      'Öffne die Import-Seite in der Mediathek, um diese URL zu importieren.';

  @override
  String get snackbarProcessingFile => 'Datei wird verarbeitet...';

  @override
  String snackbarPreparingShare(String title) {
    return 'Bereite „$title“ zum Teilen vor';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Bereite „$title“ zum Export vor.';
  }

  @override
  String get pluginManagerTabInstalled => 'Installiert';

  @override
  String get pluginManagerTabStore => 'Plugin Store';

  @override
  String get pluginManagerSelectPackage => 'Plugin-Paket wählen (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'Plugin nutzt ein veraltetes Manifest. Einige Features könnten nicht funktionieren.';

  @override
  String get pluginManagerStatusActive => 'Aktiv';

  @override
  String get pluginManagerStatusInactive => 'Inaktiv';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Aktualisiert am $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plugins verfügbar',
      one: '1 Plugin verfügbar',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Veraltetes Manifest. Fehler möglich.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Unbekannter Herausgeber';

  @override
  String get pluginRepositoryActionRetry => 'Erneut versuchen';

  @override
  String get pluginRepositoryActionOutdated => 'Veraltet';

  @override
  String get pluginRepositoryActionInstalled => 'Installiert';

  @override
  String get pluginRepositoryActionInstall => 'Installieren';

  @override
  String get pluginRepositoryActionUnavailable => 'Nicht verfügbar';

  @override
  String get pluginRepositoryInstallFailed => 'Installation fehlgeschlagen.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Fehler beim Download von $name.';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Playlists',
      one: '1 Playlist',
    );
    return 'In $_temp0 ersetzt$queue.';
  }

  @override
  String get lyricsSearchFieldLabel => 'Songtext suchen...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Tippe Song oder Interpret, um Texte zu finden.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Kein Songtext für „$query“ gefunden';
  }

  @override
  String get lyricsSearchApplied => 'Songtext erfolgreich angewendet';

  @override
  String get lyricsSearchFetchFailed => 'Songtext konnte nicht geladen werden';

  @override
  String get lyricsSearchPreview => 'Vorschau';

  @override
  String get lyricsSearchPreviewTooltip => 'Songtext-Vorschau';

  @override
  String get lyricsSearchSynced => 'SYNCHRONISIERT';

  @override
  String get lyricsSearchPreviewLoadFailed =>
      'Vorschau konnte nicht geladen werden.';

  @override
  String get lyricsSearchApplyAction => 'Songtext anwenden';

  @override
  String get lyricsSettingsSearchTitle => 'Benutzerdefinierte Texte suchen';

  @override
  String get lyricsSettingsSearchSubtitle => 'Online nach Alternativen suchen';

  @override
  String get lyricsSettingsSyncTitle => 'Synchronisierung anpassen';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Texte korrigieren, die zu schnell/langsam sind';

  @override
  String get lyricsSettingsSaveTitle => 'Offline speichern';

  @override
  String get lyricsSettingsSaveSubtitle => 'Songtexte auf dem Gerät speichern';

  @override
  String get lyricsSettingsDeleteTitle => 'Gespeicherte Texte löschen';

  @override
  String get lyricsSettingsDeleteSubtitle => 'Offline-Songtextdaten entfernen';

  @override
  String get lyricsSyncTapToReset => 'Tippe zum Zurücksetzen';

  @override
  String get upNextTitle => 'Nächste Titel';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente in Warteschlange',
      one: '1 Element in Warteschlange',
    );
    return '$_temp0';
  }

  @override
  String get upNextAutoPlay => 'Auto-Play';

  @override
  String get tooltipCopyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get snackbarCopiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get tooltipSongInfo => 'Song-Info';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Aktuell spielender Titel kann nicht gelöscht werden';

  @override
  String get playerLoopOff => 'Aus';

  @override
  String get playerLoopOne => 'Titel wiederholen';

  @override
  String get playerLoopAll => 'Alles wiederholen';

  @override
  String get snackbarOpeningAlbumPage => 'Originale Album-Seite wird geöffnet.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Neue Version von Bloomee🌸 verfügbar!\n\nVersion: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Plugin „$id“ erfolgreich installiert';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'Plugin „$id“ geladen';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Plugin „$id“ erfolgreich gelöscht';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee wird eingerichtet';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Neues Plugin-System wird konfiguriert... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Dies passiert nur einmal.';

  @override
  String get pluginBootstrapErrorTitle => 'Verbindung zu langsam';

  @override
  String get pluginBootstrapErrorBody =>
      'Einige Plugins konnten nicht installiert werden. Du kannst Bloomee dennoch nutzen – Plugins werden beim nächsten Start erneut versucht.';

  @override
  String get pluginBootstrapContinue => 'Trotzdem fortfahren';
}
