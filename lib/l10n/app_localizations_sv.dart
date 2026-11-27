// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get onboardingTitle => 'Välkommen till Bloomee';

  @override
  String get onboardingSubtitle => 'Välj språk och region.';

  @override
  String get continueButton => 'Fortsätt';

  @override
  String get navHome => 'Hem';

  @override
  String get navLibrary => 'Bibliotek';

  @override
  String get navSearch => 'Sök';

  @override
  String get navLocal => 'Lokalt';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Spelas från';

  @override
  String get playerPlayWithMix => 'Spela med automatisk mix';

  @override
  String get playerPlayNext => 'Spela härnäst';

  @override
  String get playerAddToQueue => 'Lägg till i kön';

  @override
  String get playerAddToFavorites => 'Lägg till i favoriter';

  @override
  String get playerNoLyricsFound => 'Ingen låttext hittades';

  @override
  String get playerLyricsNoPlugin =>
      'Ingen låttextkälla har valts. Gå till Inställningar → Tillägg för att installera en.';

  @override
  String get localMusicTitle => 'Lokalt';

  @override
  String get localMusicGrantPermission => 'Tillåt åtkomst';

  @override
  String get localMusicStorageAccessRequired => 'Åtkomst till lagring krävs';

  @override
  String get localMusicStorageAccessDesc =>
      'Tillåt åtkomst för att söka efter och spela upp ljudfiler som finns på din enhet.';

  @override
  String get localMusicAddFolder => 'Lägg till musikmapp';

  @override
  String get localMusicScanNow => 'Sök nu';

  @override
  String localMusicScanFailed(String message) {
    return 'Sökningen misslyckades: $message';
  }

  @override
  String get localMusicScanning => 'Söker efter ljudfiler på enheten…';

  @override
  String get localMusicShuffle => 'Blanda';

  @override
  String get localMusicPlayAll => 'Spela alla';

  @override
  String get localMusicSearchHint => 'Sök i lokal musik…';

  @override
  String get localMusicRescanDevice => 'Sök igenom enheten igen';

  @override
  String get buttonCancel => 'Avbryt';

  @override
  String get buttonDelete => 'Radera';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Uppdatera';

  @override
  String get buttonDownload => 'Hämta';

  @override
  String get buttonLater => 'Senare';

  @override
  String get buttonInfo => 'Info';

  @override
  String get buttonMore => 'Mer';

  @override
  String get dialogDeleteTrack => 'Radera låt';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Vill du radera ”$title” från din enhet? Det går inte att ångra.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists => 'Låten tas också bort från:';

  @override
  String get dialogDontAskAgain => 'Fråga inte igen';

  @override
  String get dialogUpdateAvailable => 'Uppdatering tillgänglig';

  @override
  String get dialogUpdateNow => 'Uppdatera nu';

  @override
  String get dialogDownloadPlaylist => 'Hämta spellista';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Vill du hämta $count låtar från ”$title”? De läggs till i hämtningskön.';
  }

  @override
  String get dialogDownloadAll => 'Hämta alla';

  @override
  String get playlistEdit => 'Redigera spellista';

  @override
  String get playlistShareFile => 'Dela fil';

  @override
  String get playlistExportFile => 'Exportera fil';

  @override
  String get playlistPlay => 'Spela';

  @override
  String get playlistAddToQueue => 'Lägg till spellistan i kön';

  @override
  String get playlistShare => 'Dela spellista';

  @override
  String get playlistDelete => 'Radera spellista';

  @override
  String get playlistEmptyState => 'Inga låtar ännu';

  @override
  String get playlistAvailableOffline => 'Tillgänglig offline';

  @override
  String get playlistShuffle => 'Blanda';

  @override
  String get playlistNoMatchSearch => 'Inga spellistor matchar din sökning';

  @override
  String get playlistCreateNew => 'Skapa spellista';

  @override
  String get playlistCreateFirstOne =>
      'Inga spellistor ännu. Skapa en för att komma igång.';

  @override
  String get addToPlaylistNoSongSelected => 'Ingen låt har valts';

  @override
  String get createPlaylistDialogBarrierLabel =>
      'Dialogruta för att skapa spellista';

  @override
  String get createPlaylistDialogNameHint => 'Sommarkänsla';

  @override
  String get createPlaylistDialogCreate => 'Skapa';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar',
      one: '1 låt',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title har tagits bort från $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Det gick inte att läsa in spellistan';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get settingsPlugins => 'Tillägg';

  @override
  String get settingsPluginsSubtitle =>
      'Installera, läs in och hantera tillägg.';

  @override
  String get settingsUpdates => 'Uppdateringar';

  @override
  String get settingsUpdatesSubtitle => 'Sök efter uppdateringar';

  @override
  String get settingsDownloads => 'Hämtningar';

  @override
  String get settingsDownloadsSubtitle =>
      'Hämtningsmapp, ljudkvalitet och mer…';

  @override
  String get settingsLocalTracks => 'Lokala låtar';

  @override
  String get settingsLocalTracksSubtitle =>
      'Sök efter låtar, hantera mappar och ställ in automatisk genomsökning.';

  @override
  String get settingsPlayer => 'Spelarinställningar';

  @override
  String get settingsPlayerSubtitle =>
      'Strömningskvalitet, automatisk uppspelning med mera.';

  @override
  String get settingsPluginDefaults => 'Standardval för tillägg';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Källa för Upptäck och källornas prioritetsordning.';

  @override
  String get settingsUIElements => 'Gränssnitt och tjänster';

  @override
  String get settingsUIElementsSubtitle =>
      'Automatisk växling, gränssnittsinställningar med mera.';

  @override
  String get settingsLastFM => 'Last.fm-inställningar';

  @override
  String get settingsLastFMSubtitle =>
      'API-nyckel, API-hemlighet och skrobbling.';

  @override
  String get settingsStorage => 'Lagring';

  @override
  String get settingsStorageSubtitle =>
      'Säkerhetskopior, cache, historik, återställning och mer…';

  @override
  String get settingsLanguageCountry => 'Språk och land';

  @override
  String get settingsLanguageCountrySubtitle => 'Välj språk och land.';

  @override
  String get settingsAbout => 'Om';

  @override
  String get settingsAboutSubtitle =>
      'Om appen, versionen, utvecklaren med mera.';

  @override
  String get settingsScanning => 'Genomsökning';

  @override
  String get settingsMusicFolders => 'Musikmappar';

  @override
  String get settingsQuality => 'Kvalitet';

  @override
  String get settingsHistory => 'Historik';

  @override
  String get settingsBackupRestore => 'Säkerhetskopiering och återställning';

  @override
  String get settingsAutomatic => 'Automatiskt';

  @override
  String get settingsDangerZone => 'Riskfyllda åtgärder';

  @override
  String get settingsScrobbling => 'Skrobbling';

  @override
  String get settingsAuthentication => 'Autentisering';

  @override
  String get settingsHomeScreen => 'Startsida';

  @override
  String get settingsChartVisibility => 'Visa topplistor';

  @override
  String get dialogAddingToDownloadQueue => 'Lägger till i hämtningskön';

  @override
  String get emptyNoInternet => 'Ingen internetanslutning';

  @override
  String get emptyNoContentPlugin =>
      'Inget innehållstillägg har lästs in. Läs in en innehållskälla i tilläggshanteraren.';

  @override
  String get emptyRefreshingSource =>
      'Uppdaterar källan för Upptäck… Den tidigare källan är inte längre tillgänglig.';

  @override
  String get emptyNoTracks => 'Inga låtar tillgängliga';

  @override
  String get emptyNoResults => 'Inga träffar hittades';

  @override
  String snackbarDeletedTrack(String title) {
    return '”$title” har raderats';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Det gick inte att radera ”$title”';
  }

  @override
  String get snackbarAddedToNextQueue => 'Tillagd som nästa i kön';

  @override
  String get snackbarAddedToQueue => 'Tillagd i kön';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title har lagts till i favoriter';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Spelar $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name har lagts till i kön';
  }

  @override
  String get snackbarPlaylistUpdated => 'Spellistan har uppdaterats';

  @override
  String get snackbarLinkCopied => 'Länken har kopierats';

  @override
  String get snackbarCouldNotOpenLink => 'Det gick inte att öppna länken';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count låtar har lagts till i hämtningskön';
  }

  @override
  String get searchHintExplore => 'Vad vill du lyssna på?';

  @override
  String get searchHintLibrary => 'Sök i biblioteket…';

  @override
  String get searchHintPlaylists => 'Sök bland spellistor…';

  @override
  String get searchStartTyping => 'Börja skriva för att söka…';

  @override
  String get searchNoSuggestions => 'Inga förslag hittades';

  @override
  String get searchNoResults =>
      'Inga resultat hittades.\nProva ett annat sökord eller en annan källa.';

  @override
  String get searchFailed => 'Sökningen misslyckades';

  @override
  String get searchDiscover => 'Upptäck ny musik';

  @override
  String get searchSources => 'KÄLLOR';

  @override
  String get searchNoPlugins => 'Inga tillägg installerade';

  @override
  String get searchTracks => 'Låtar';

  @override
  String get searchAlbums => 'Album';

  @override
  String get searchArtists => 'Artister';

  @override
  String get searchPlaylists => 'Spellistor';

  @override
  String get exploreDiscover => 'Upptäck';

  @override
  String get exploreRecently => 'Senaste';

  @override
  String get exploreLastFmPicks => 'Tips från Last.fm';

  @override
  String get exploreFailedToLoad =>
      'Det gick inte att läsa in startsidans innehåll.';

  @override
  String get libraryTitle => 'Bibliotek';

  @override
  String get libraryEmptyState =>
      'Ditt bibliotek är tomt. Lägg till låtar och spellistor för att komma igång.';

  @override
  String libraryIn(String playlistName) {
    return 'i $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Lägg till i spellista';

  @override
  String get menuSmartReplace => 'Smart ersättning';

  @override
  String get menuShare => 'Dela';

  @override
  String get menuAvailableOffline => 'Tillgänglig offline';

  @override
  String get menuDownload => 'Hämta';

  @override
  String get menuOpenOriginalLink => 'Öppna ursprunglig länk';

  @override
  String get menuDeleteTrack => 'Radera';

  @override
  String get tooltipRemoveFromLibrary => 'Ta bort från biblioteket';

  @override
  String get tooltipSaveToLibrary => 'Spara i biblioteket';

  @override
  String get tooltipOpenOriginalLink => 'Öppna ursprunglig länk';

  @override
  String get tooltipAvailableOffline => 'Tillgänglig offline';

  @override
  String get tooltipMoreOptions => 'Fler alternativ';

  @override
  String get appuiTitle => 'Gränssnitt och tjänster';

  @override
  String get appuiAutoSlideCharts => 'Växla topplistor automatiskt';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Växla automatiskt mellan topplistor på startsidan.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Visa förslag från Last.fm. Inloggning och omstart krävs.';

  @override
  String get appuiNoChartsAvailable =>
      'Inga topplistor tillgängliga. Läs in ett tillägg för topplistor.';

  @override
  String get appuiLoginToLastFm => 'Logga först in på Last.fm.';

  @override
  String get appuiShowInCarousel => 'Visa i karusellen på startsidan.';

  @override
  String get countrySettingTitle => 'Land och språk';

  @override
  String get countrySettingAutoDetect => 'Identifiera land automatiskt';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Identifiera ditt land automatiskt när appen öppnas.';

  @override
  String get countrySettingCountryLabel => 'Land';

  @override
  String get countrySettingLanguageLabel => 'Språk';

  @override
  String get countrySettingSystemDefault => 'Systemstandard';

  @override
  String get downloadSettingTitle => 'Hämtningar';

  @override
  String get downloadSettingQuality => 'Ljudkvalitet vid hämtning';

  @override
  String get downloadSettingQualitySubtitle =>
      'Gemensam inställning för ljudkvaliteten på hämtade låtar.';

  @override
  String get downloadSettingFolder => 'Hämtningsmapp';

  @override
  String get downloadSettingResetFolder => 'Återställ hämtningsmapp';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Återställ standardmappen för hämtningar.';

  @override
  String get lastfmTitle => 'Last.fm';

  @override
  String get lastfmScrobbleTracks => 'Skrobbla låtar';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Skicka spelade låtar till din Last.fm-profil.';

  @override
  String get lastfmAuthFirst => 'Autentisera först Last.fm-API:et.';

  @override
  String get lastfmAuthenticatedAs => 'Autentiserad som';

  @override
  String get lastfmAuthFailed => 'Autentiseringen misslyckades:';

  @override
  String get lastfmNotAuthenticated => 'Inte autentiserad';

  @override
  String get lastfmSteps =>
      'Så autentiserar du:\n1. Skapa eller öppna ett Last.fm-konto på last.fm\n2. Skapa en API-nyckel på last.fm/api/account/create\n3. Ange API-nyckeln och API-hemligheten nedan\n4. Tryck på ”Starta autentisering” och godkänn i webbläsaren\n5. Tryck på ”Hämta och spara sessionsnyckel” för att slutföra';

  @override
  String get lastfmApiKey => 'API-nyckel';

  @override
  String get lastfmApiSecret => 'API-hemlighet';

  @override
  String get lastfmStartAuth => '1. Starta autentisering';

  @override
  String get lastfmGetSession => '2. Hämta och spara sessionsnyckel';

  @override
  String get lastfmRemoveKeys => 'Ta bort nycklar';

  @override
  String get lastfmStartAuthFirst =>
      'Starta autentiseringen först och godkänn sedan i webbläsaren.';

  @override
  String get localSettingTitle => 'Lokala låtar';

  @override
  String get localSettingAutoScan => 'Sök automatiskt vid start';

  @override
  String get localSettingAutoScanSubtitle =>
      'Sök automatiskt efter nya lokala låtar när appen startar.';

  @override
  String get localSettingLastScan => 'Senaste genomsökning';

  @override
  String get localSettingNeverScanned => 'Aldrig';

  @override
  String get localSettingScanInProgress => 'Genomsökning pågår…';

  @override
  String get localSettingScanNowSubtitle =>
      'Starta en fullständig genomsökning av biblioteket.';

  @override
  String get localSettingNoFolders =>
      'Inga mappar har lagts till. Lägg till en mapp för att börja söka.';

  @override
  String get localSettingAddFolder => 'Lägg till mapp';

  @override
  String get playerSettingTitle => 'Spelarinställningar';

  @override
  String get playerSettingStreamingHeader => 'Strömning';

  @override
  String get playerSettingStreamQuality => 'Strömningskvalitet';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Bithastighet för strömmad musik.';

  @override
  String get playerSettingQualityLow => 'Låg';

  @override
  String get playerSettingQualityMedium => 'Medel';

  @override
  String get playerSettingQualityHigh => 'Hög';

  @override
  String get playerSettingPlaybackHeader => 'Uppspelning';

  @override
  String get playerSettingAutoPlay => 'Automatisk uppspelning';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Lägg till liknande låtar när kön tar slut.';

  @override
  String get playerSettingAutoFallback => 'Automatiskt källbyte';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Om ett tillägg saknas eller inte hittar någon ljudström, prova en kompatibel källa enbart för uppspelningen.';

  @override
  String get playerSettingCrossfade => 'Övertoning';

  @override
  String get playerSettingCrossfadeOff => 'Av';

  @override
  String get playerSettingCrossfadeInstant => 'Låtarna växlar direkt';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '$seconds s övertoning mellan låtar';
  }

  @override
  String get playerSettingEqualizer => 'Equalizer';

  @override
  String get playerSettingEqualizerActive => 'Aktiv';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Aktiverad – förinställning: $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      '10-bands parametrisk equalizer via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Standardval för tillägg';

  @override
  String get pluginDefaultsDiscoverHeader => 'Källa för Upptäck';

  @override
  String get pluginDefaultsNoResolver =>
      'Ingen innehållskälla är inläst. Läs in ett tillägg för att välja en källa för Upptäck.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Använd den första tillgängliga innehållskällan.';

  @override
  String get pluginDefaultsPriorityHeader => 'Källornas prioritet';

  @override
  String get pluginDefaultsNoPriority =>
      'Inga innehållskällor är inlästa. Prioritetsordningen visas här när tilläggen har lästs in.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Dra för att ändra ordningen. Källor med högre prioritet provas först när topplisteposter eller importerade låtar ska matchas med spelbara låtar.';

  @override
  String get pluginDefaultsLyricsHeader => 'Låttextkällornas prioritet';

  @override
  String get pluginDefaultsLyricsNone => 'Inga låttextkällor är inlästa.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Dra för att ändra ordningen på låttextkällorna. Den översta källan provas först.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Sökförslag';

  @override
  String get pluginDefaultsSuggestionsNone => 'Inga förslagskällor är inlästa.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Ingen';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Använd endast sökhistoriken.';

  @override
  String get storageSettingTitle => 'Lagring';

  @override
  String get storageClearHistoryEvery => 'Rensa historik efter';

  @override
  String get storageClearHistorySubtitle =>
      'Rensa lyssningshistoriken efter den valda perioden.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagar',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Säkerhetskopia skapad i $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Kunde inte dela säkerhetskopian: $error';
  }

  @override
  String get storageRestoreBackup => 'Återställ säkerhetskopia';

  @override
  String get storageRestoreBackupSubtitle =>
      'Återställ inställningar och data från en säkerhetskopia.';

  @override
  String get storageAutoBackup => 'Automatisk säkerhetskopiering';

  @override
  String get storageAutoLyrics => 'Spara låttexter automatiskt';

  @override
  String get storageAutoLyricsSubtitle =>
      'Spara låttexten automatiskt när en låt spelas.';

  @override
  String get storageResetApp => 'Nollställ Bloomee';

  @override
  String get storageResetConfirmTitle => 'Bekräfta nollställning';

  @override
  String get storageResetButton => 'Nollställ';

  @override
  String get storageRestoreOptionsTitle => 'Återställningsalternativ';

  @override
  String get storageRestoreContinue => 'Fortsätt';

  @override
  String get storageRestoreConfirmTitle => 'Bekräfta återställning';

  @override
  String get storageRestoreYes => 'Ja, återställ';

  @override
  String get storageRestoring =>
      'Återställer valda data…\nVänta tills åtgärden är klar.';

  @override
  String get storageRestoreFailedTitle => 'Återställningen misslyckades';

  @override
  String get updateSettingTitle => 'Uppdateringar';

  @override
  String get updateCheckForUpdates => 'Sök efter uppdateringar';

  @override
  String get updateCheckSubtitle =>
      'Kontrollera om en nyare version av Bloomee finns.';

  @override
  String get updateAutoNotify => 'Avisera om uppdateringar';

  @override
  String get updateAutoNotifySubtitle =>
      'Avisera om nya uppdateringar när appen startas.';

  @override
  String get updateCheckTitle => 'Sök efter uppdateringar';

  @override
  String get updateUpToDate => 'Bloomee är uppdaterat';

  @override
  String get updateViewPreRelease => 'Visa senaste förhandsversionen';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Nuvarande version: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'En ny version av Bloomee finns';

  @override
  String updateVersion(String ver, String build) {
    return 'Version: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Hämta nu';

  @override
  String get updateChecking => 'Söker efter uppdateringar…';

  @override
  String get timerTitle => 'Insomningstimer';

  @override
  String get timerInterludeMessage => 'Uppspelningen stoppas om…';

  @override
  String get timerHours => 'Timmar';

  @override
  String get timerMinutes => 'Minuter';

  @override
  String get timerSeconds => 'Sekunder';

  @override
  String get timerStop => 'Stoppa timern';

  @override
  String get timerFinishedMessage => 'Insomningstimern stoppade uppspelningen.';

  @override
  String get timerGotIt => 'Jag förstår';

  @override
  String get timerSetTimeError => 'Ange en tid';

  @override
  String get timerStart => 'Starta timern';

  @override
  String get notificationsTitle => 'Aviseringar';

  @override
  String get notificationsEmpty => 'Inga aviseringar ännu';

  @override
  String get recentsTitle => 'Historik';

  @override
  String playlistByCreator(String creator) {
    return 'av $creator';
  }

  @override
  String get playlistYou => 'Du';

  @override
  String get pluginManagerTitle => 'Tillägg';

  @override
  String get pluginManagerEmpty =>
      'Inga tillägg är installerade.\nTryck på + för att lägga till en .bex-fil.';

  @override
  String get pluginManagerFilterAll => 'Alla';

  @override
  String get pluginManagerFilterContent => 'Innehållskällor';

  @override
  String get pluginManagerFilterCharts => 'Topplistekällor';

  @override
  String get pluginManagerFilterLyrics => 'Låttextkällor';

  @override
  String get pluginManagerFilterSuggestions => 'Förslagskällor';

  @override
  String get pluginManagerFilterImporters => 'Innehållsimportörer';

  @override
  String get pluginManagerTooltipRefresh => 'Uppdatera';

  @override
  String get pluginManagerTooltipInstall => 'Installera tillägg';

  @override
  String get pluginManagerNoMatch => 'Inga tillägg matchar filtret';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Kunde inte välja fil: $error';
  }

  @override
  String get pluginManagerInstalling => 'Installerar tillägg…';

  @override
  String get pluginManagerTypeContentResolver => 'Innehållskälla';

  @override
  String get pluginManagerTypeChartProvider => 'Topplistekälla';

  @override
  String get pluginManagerTypeLyricsProvider => 'Låttextkälla';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Sökförslag';

  @override
  String get pluginManagerTypeContentImporter => 'Innehållsimportör';

  @override
  String get pluginManagerDeleteTitle => 'Radera tillägg?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Vill du radera ”$name”? Tilläggets filer tas bort permanent.';
  }

  @override
  String get pluginManagerDeleteAction => 'Radera';

  @override
  String get pluginManagerCancel => 'Avbryt';

  @override
  String get pluginManagerEnablePlugin => 'Aktivera tillägg';

  @override
  String get pluginManagerUnloadPlugin => 'Inaktivera tillägg';

  @override
  String get pluginManagerDeleting => 'Raderar…';

  @override
  String get pluginManagerApiKeysTitle => 'API-nycklar';

  @override
  String get pluginManagerApiKeysSaved => 'API-nycklar sparade';

  @override
  String get pluginManagerSave => 'Spara';

  @override
  String get pluginManagerDetailVersion => 'Version';

  @override
  String get pluginManagerDetailType => 'Typ';

  @override
  String get pluginManagerDetailPublisher => 'Utgivare';

  @override
  String get pluginManagerDetailLastUpdated => 'Senast uppdaterat';

  @override
  String get pluginManagerDetailCreated => 'Skapat';

  @override
  String get pluginManagerDetailHomepage => 'Webbplats';

  @override
  String get pluginManagerDeleteStorageTitle => 'Radera tilläggsdata?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Vill du även radera sparade API-nycklar och inställningar för ”$name”?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Behåll data';

  @override
  String get pluginManagerDeleteStorageRemove => 'Radera data';

  @override
  String get segmentsSheetTitle => 'Segment';

  @override
  String get segmentsSheetEmpty => 'Inga segment finns';

  @override
  String get segmentsSheetUntitled => 'Namnlöst segment';

  @override
  String get smartReplaceTitle => 'Smart ersättning';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Välj en spelbar ersättning för ”$title” och uppdatera hänvisningarna i sparade spellistor.';
  }

  @override
  String get smartReplaceClose => 'Stäng';

  @override
  String get smartReplaceNoMatch => 'Ingen ersättning hittades';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Ingen av de inlästa innehållskällorna hittade en tillräckligt bra matchning.';

  @override
  String get smartReplaceBestMatch => 'Bästa matchning';

  @override
  String get smartReplaceSearchFailed => 'Sökningen misslyckades';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Smart ersättning misslyckades: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Ersatte låten$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' och uppdaterade kön';

  @override
  String get playerUnknownQueue => 'Okänd';

  @override
  String playerLiked(String title) {
    return '$title har lagts till i favoriter';
  }

  @override
  String playerUnliked(String title) {
    return '$title har tagits bort från favoriter';
  }

  @override
  String get offlineNoDownloads => 'Inga hämtade låtar';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Sök bland dina låtar…';

  @override
  String get offlineRefreshTooltip => 'Uppdatera hämtade låtar';

  @override
  String get offlineCloseSearch => 'Stäng sökningen';

  @override
  String get offlineSearchTooltip => 'Sök';

  @override
  String get offlineOpenFailed =>
      'Kunde inte öppna den här offlinelåten. Prova att uppdatera listan över hämtade låtar.';

  @override
  String get offlinePlayFailed =>
      'Kunde inte spela den här offlinelåten. Försök igen.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar',
      one: '1 låt',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Kunde inte läsa in albumet';

  @override
  String get aboutCraftingSubtitle => 'Skapat för musik.';

  @override
  String get aboutFollowGitHub => 'Följ honom på GitHub';

  @override
  String get aboutSendInquiry => 'Skicka en affärsförfrågan';

  @override
  String get aboutCreativeHighlights =>
      'Uppdateringar och kreativa höjdpunkter';

  @override
  String get aboutTipQuote => 'Gillar du Bloomee? Du kan stödja utvecklingen.';

  @override
  String get aboutTipButton => 'Stöd projektet';

  @override
  String get aboutTipDesc => 'Ditt bidrag hjälper till att förbättra Bloomee.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Låtinformation';

  @override
  String get songInfoSectionTechnical => 'Teknisk information';

  @override
  String get songInfoSectionActions => 'Åtgärder';

  @override
  String get songInfoLabelTitle => 'Titel';

  @override
  String get songInfoLabelArtist => 'Artist';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Speltid';

  @override
  String get songInfoLabelSource => 'Källa';

  @override
  String get songInfoLabelMediaId => 'Medie-ID';

  @override
  String get songInfoLabelPluginId => 'Tilläggs-ID';

  @override
  String get songInfoCopyId => 'Kopiera ID';

  @override
  String get songInfoCopyLink => 'Kopiera länk';

  @override
  String get songInfoOpenBrowser => 'Öppna i webbläsaren';

  @override
  String get songInfoIdCopied => 'Medie-ID kopierat';

  @override
  String get songInfoLinkCopied => 'Länk kopierad';

  @override
  String get songInfoNoLink => 'Ingen länk finns';

  @override
  String get songInfoOpenFailed => 'Kunde inte öppna länken';

  @override
  String get songInfoUpdateMetadata => 'Hämta senaste metadata';

  @override
  String get songInfoMetadataUpdated => 'Metadata uppdaterade';

  @override
  String get songInfoMetadataUpdateFailed => 'Kunde inte uppdatera metadata';

  @override
  String get songInfoMetadataUnavailable =>
      'Det går inte att uppdatera metadata från den här källan';

  @override
  String get songInfoSearchTitle => 'Sök efter den här låten i Bloomee';

  @override
  String get songInfoSearchArtist => 'Sök efter den här artisten i Bloomee';

  @override
  String get songInfoSearchAlbum => 'Sök efter det här albumet i Bloomee';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get chartNoItems => 'Topplistan är tom';

  @override
  String get chartLoadFailed => 'Kunde inte läsa in topplistan';

  @override
  String get chartPlay => 'Spela';

  @override
  String get chartResolving => 'Söker spelbara låtar';

  @override
  String get chartReady => 'Klart';

  @override
  String get chartAddToPlaylist => 'Lägg till i spellista';

  @override
  String get chartNoResolver =>
      'Ingen innehållskälla är inläst. Installera ett tillägg för att spela.';

  @override
  String get chartResolveFailed =>
      'Kunde inte hitta en spelbar låt. Söker i stället…';

  @override
  String get chartNoResolverAdd => 'Ingen innehållskälla är inläst.';

  @override
  String get chartNoMatch =>
      'Ingen matchning hittades. Prova att söka manuellt.';

  @override
  String get chartStatPeak => 'Högsta placering';

  @override
  String get chartStatWeeks => 'Veckor';

  @override
  String get chartStatChange => 'Förändring';

  @override
  String menuSharePreparing(String title) {
    return 'Förbereder delning av $title.';
  }

  @override
  String get menuOpenLinkFailed => 'Kunde inte öppna länken';

  @override
  String get localMusicFolders => 'Musikmappar';

  @override
  String get localMusicRemoveFolder => 'Ta bort mapp';

  @override
  String get localMusicCloseSearch => 'Stäng sökningen';

  @override
  String get localMusicOpenSearch => 'Sök';

  @override
  String get localMusicNoMusicFound => 'Ingen lokal musik hittades';

  @override
  String get localMusicNoSearchResults => 'Inga låtar matchar din sökning.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar',
      one: '1 låt',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Importera låtar';

  @override
  String get importNoPluginsLoaded =>
      'Inga importtillägg är inlästa.\nInstallera ett importtillägg för att importera spellistor från andra tjänster.';

  @override
  String get importBloomeeFiles => 'Importera Bloomee-filer';

  @override
  String get importM3UFiles => 'Importera M3U-spellista';

  @override
  String get importM3UNameDialogTitle => 'Spellistans namn';

  @override
  String get importM3UNameHint => 'Ange ett namn för spellistan';

  @override
  String get importM3UNoTracks => 'Inga giltiga låtar hittades i M3U-filen.';

  @override
  String get importNoteTitle => 'Observera';

  @override
  String get importNoteMessage =>
      'Du kan bara importera filer som har skapats av Bloomee.\nOm filen kommer från en annan källa fungerar det inte. Vill du fortsätta ändå?';

  @override
  String get importTitle => 'Importera';

  @override
  String get importCheckingUrl => 'Kontrollerar webbadress…';

  @override
  String get importFetchingTracks => 'Hämtar låtar…';

  @override
  String get importSavingToLibrary => 'Sparar i biblioteket…';

  @override
  String get importPasteUrlHint =>
      'Klistra in webbadressen till en spellista eller ett album att importera';

  @override
  String get importAction => 'Importera';

  @override
  String importTrackCount(int count) {
    return '$count låtar';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Matchar låtar: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Spara $count låtar';
  }

  @override
  String importTracksSaved(int count) {
    return '$count låtar har sparats!';
  }

  @override
  String get importDone => 'Klart';

  @override
  String get importMore => 'Importera fler';

  @override
  String get importUnknownError => 'Okänt fel';

  @override
  String get importTryAgain => 'Försök igen';

  @override
  String get importSkipTrack => 'Hoppa över den här låten';

  @override
  String get importMatchOptions => 'Matchningsalternativ';

  @override
  String get importSkipped => 'Överhoppad';

  @override
  String get importReorderTip =>
      'Håll en spellista nedtryckt för att ändra ordningen';

  @override
  String get importErrorCannotHandleUrl =>
      'Tillägget kan inte hantera den angivna webbadressen.';

  @override
  String get importErrorUnexpectedResponse => 'Oväntat svar från tillägget.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Kunde inte kontrollera webbadressen: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Kunde inte hämta information om samlingen: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Kunde inte hämta låtar: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Kunde inte spara spellistan: $error';
  }

  @override
  String get playlistPinToTop => 'Fäst överst';

  @override
  String get playlistUnpin => 'Lossa';

  @override
  String get snackbarInvalidFileFormat => 'Ogiltigt filformat';

  @override
  String get snackbarProcessingFile => 'Bearbetar fil…';

  @override
  String get pluginManagerTabInstalled => 'Installerade';

  @override
  String get pluginManagerTabStore => 'Tilläggsbutik';

  @override
  String get pluginManagerSelectPackage => 'Välj tilläggspaket (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'Tillägget använder en föråldrad manifestversion. Vissa funktioner kanske inte fungerar. Överväg att uppdatera tillägget.';

  @override
  String get pluginManagerStatusActive => 'Aktivt';

  @override
  String get pluginManagerStatusInactive => 'Inaktivt';

  @override
  String get pluginRepositoryAddTitle => 'Lägg till källa';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Ange webbadressen till en giltig JSON-fil för en tilläggskälla.';

  @override
  String get pluginRepositoryAddAction => 'Lägg till källa';

  @override
  String get pluginRepositoryTitle => 'Tilläggskällor';

  @override
  String get pluginRepositorySubtitle =>
      'Lägg till en JSON-källa för att bläddra bland tillägg på nätet.';

  @override
  String get pluginRepositoryEmpty => 'Inga källor har lagts till ännu.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Okänd uppdatering';

  @override
  String get pluginRepositoryNoDescription => 'Ingen beskrivning finns.';

  @override
  String get pluginRepositoryUrlCopied =>
      'Källans webbadress kopierades till urklipp';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tillägg',
      one: '1 tillägg',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Uppdaterad $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tillägg tillgängliga',
      one: '1 tillägg tillgängligt',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Föråldrat manifest. Vissa funktioner kanske inte fungerar.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Okänd utgivare';

  @override
  String get pluginRepositoryActionRetry => 'Försök igen';

  @override
  String get pluginRepositoryActionOutdated => 'Föråldrat';

  @override
  String get pluginRepositoryActionInstalled => 'Installerat';

  @override
  String get pluginRepositoryActionInstall => 'Installera';

  @override
  String get pluginRepositoryActionUnavailable => 'Otillgängligt';

  @override
  String get pluginRepositoryInstallFailed => 'Installationen misslyckades.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Kunde inte hämta $name.';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Kunde inte läsa in källorna.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'Ogiltig källadress eller källfil.';

  @override
  String get pluginRepositoryErrorRemove => 'Kunde inte ta bort källan.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ersatte låten i $count spellistor$queue.',
      one: 'Ersatte låten i 1 spellista$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Sök efter låttext…';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Ange en låt eller artist för att hitta låttexter.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Ingen låttext hittades för ”$query”';
  }

  @override
  String get lyricsSearchApplied => 'Låttexten har lagts till';

  @override
  String get lyricsSearchFetchFailed => 'Kunde inte hämta låttexten';

  @override
  String get lyricsSearchPreview => 'Förhandsgranska';

  @override
  String get lyricsSearchPreviewTooltip => 'Förhandsgranska låttext';

  @override
  String get lyricsSearchSynced => 'SYNKRONISERAD';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Kunde inte läsa in låttexten.';

  @override
  String get lyricsSearchApplyAction => 'Använd låttext';

  @override
  String get lyricsSettingsSearchTitle => 'Sök annan låttext';

  @override
  String get lyricsSettingsSearchSubtitle => 'Hitta andra versioner på nätet';

  @override
  String get lyricsSettingsSyncTitle => 'Justera tidsförskjutning';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Anpassa låttextens visning till musiken';

  @override
  String get lyricsSettingsSaveTitle => 'Spara offline';

  @override
  String get lyricsSettingsSaveSubtitle => 'Spara låttexten på enheten';

  @override
  String get lyricsSettingsDeleteTitle => 'Radera sparad låttext';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Ta bort låttexten som sparats offline';

  @override
  String get lyricsSyncTapToReset => 'Tryck för att återställa';

  @override
  String get upNextTitle => 'Härnäst';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count poster i kön',
      one: '1 post i kön',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Kopiera till urklipp';

  @override
  String get snackbarCopiedToClipboard => 'Kopierat till urklipp';

  @override
  String get tooltipSongInfo => 'Låtinformation';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Låten som spelas kan inte raderas';

  @override
  String get playerLoopOff => 'Av';

  @override
  String get playerLoopOne => 'Upprepa en';

  @override
  String get playerLoopAll => 'Upprepa alla';

  @override
  String get snackbarOpeningAlbumPage => 'Öppnar albumets ursprungliga sida.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'En ny version av Bloomee finns tillgänglig.\n\nVersion: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Tillägget ”$id” har installerats';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Tillägget ”$id” har raderats';
  }

  @override
  String get pluginBootstrapTitle => 'Ställer in Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Ställer in den nya tilläggsmotorn… $percent %';
  }

  @override
  String get pluginBootstrapHint => 'Det här görs bara en gång.';

  @override
  String get backupSave => 'Spara säkerhetskopia som JSON';

  @override
  String get backupShare => 'Dela JSON-säkerhetskopia';

  @override
  String get backupPortableDetails =>
      'Innehåller spellistor, favoriter, sparade samlingar, historik och inställningar som kan överföras mellan enheter. Ljudfiler, konton och enhetens mappar ingår inte.';

  @override
  String get backupHistories => 'Uppspelnings- och sökhistorik';

  @override
  String get backupPreferences => 'Inställningar som kan överföras';

  @override
  String get backupNewCopy => 'Importera som nya spellistor';

  @override
  String get backupMerge => 'Slå samman med befintliga data';

  @override
  String get backupReplace => 'Ersätt valda delar';

  @override
  String get backupMergeDetails =>
      'Befintliga låtar, metadata och inställningar bevaras. Saknade låtar läggs till sist i samma ordning som i filen. Favoriter slås samman.';

  @override
  String get backupReplaceWarning =>
      'De valda delarna ersätts. Om biblioteket är valt ersätts även befintliga spellistor och favoriter. Delar som inte valts och filer på enheten bevaras. Först skapas en privat återställningskopia.';

  @override
  String get backupAutoDetails =>
      'Sparar sju privata återställningskopior. Kontrollen görs när appen öppnas, högst en gång per 24 timmar. De privata kopiorna tas bort om appen avinstalleras.';

  @override
  String get backupLocationDetails =>
      'Välj var kopian ska sparas med Spara säkerhetskopia. Privata återställningskopior sparas inne i appen.';

  @override
  String get backupResetDetails =>
      'Alla data i databasen raderas nästa gång appen startas. Hämtade ljudfiler och installerade tilläggsfiler finns kvar på enheten. Först skapas en privat återställningskopia.';

  @override
  String get backupResetPending =>
      'Nollställning schemalagd. Stäng och öppna Bloomee igen för att genomföra den.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return '$playlists spellistor och $tracks låtar';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'Importen är klar: $playlists spellistor skapades, $tracks låtposter och $history historikposter lades till och $settings inställningar tillämpades.';
  }

  @override
  String get backupRefreshFailed =>
      'Data har importerats. Stäng och öppna Bloomee igen för att läsa in alla inställningar på nytt.';

  @override
  String get backupRecoveryCopies => 'Återställningskopior';

  @override
  String get backupNoRecoveryCopies => 'Inga återställningskopior ännu.';

  @override
  String get backupRecoveryAutomatic => 'Automatisk säkerhetskopia';

  @override
  String get backupRecoveryBeforeImport => 'Före en import';

  @override
  String get backupRecoveryBeforeReset => 'Före en nollställning';

  @override
  String get backupCancelReset => 'Avbryt nollställning';

  @override
  String get libraryRecoveryTitle => 'Återställ saknat bibliotek';

  @override
  String get libraryRecoverySubtitle =>
      'Sök efter spellistor och hämtningsposter som sparats från tidigare versioner.';

  @override
  String get libraryRecoveryChooseSource =>
      'Välj en sparad databas att söka igenom. Ditt nuvarande bibliotek och originalfilerna bevaras.';

  @override
  String get libraryRecoveryNoSources =>
      'Inga sparade databaser hittades. Enbart ljudfiler räcker inte för att återställa vilka spellistor låtarna ingick i.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return 'Hittade $tracks låtar, $playlists spellistor och $downloads hämtningsposter. $unavailable filer är för närvarande otillgängliga, men deras poster bevaras.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return '$broken trasiga spellistereferenser kunde inte återskapas från den här kopian.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'Återställningen lägger till saknade låtar, spellisteposter och hämtningsposter. Befintliga spellistor, filkopplingar och inställningar bevaras. Först skapas en återställningskopia. Upprepa med en annan sparad kopia om den innehåller mer av ditt bibliotek.';

  @override
  String get libraryRecoveryMerge => 'Slå samman återställt bibliotek';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Återställningen är klar: $entries spellisteposter och $downloads hämtningsposter lades till.';
  }

  @override
  String get backupStartupFailed => 'Bloomee kunde inte startas';

  @override
  String get backupStartupFailedDetails =>
      'Starten avbröts utan att databasen reparerades eller ersattes automatiskt. Stäng appen och försök igen. Behåll appdata när du rapporterar felet.';

  @override
  String get lyricsTitle => 'Låttext';

  @override
  String get lyricsEnterFullscreen => 'Låttext i helskärm';

  @override
  String get lyricsExitFullscreen => 'Lämna helskärm';

  @override
  String get lyricsFollowPlayback => 'Följ uppspelningen';

  @override
  String get lyricsTimingEarlier => 'Tidigare';

  @override
  String get lyricsTimingLater => 'Senare';

  @override
  String get lyricsTimingSave => 'Spara tidsförskjutning';

  @override
  String get lyricsSaved => 'Låttexten har sparats.';

  @override
  String get lyricsSaveFailed => 'Kunde inte spara låttexten. Försök igen.';

  @override
  String get lyricsDeleteFailed =>
      'Kunde inte radera den sparade låttexten. Försök igen.';

  @override
  String get artistTopSongs => 'Populäraste låtarna';

  @override
  String get artistLoadFailed => 'Kunde inte läsa in artisten';

  @override
  String get artistNoTopSongs => 'Inga populära låtar tillgängliga';

  @override
  String get artistNoAlbums => 'Inga album tillgängliga';

  @override
  String get snackbarOpeningArtistPage => 'Öppnar artistens ursprungliga sida.';

  @override
  String get snackbarOpeningPlaylistPage =>
      'Öppnar spellistans ursprungliga sida.';

  @override
  String get playlistSaveOrderFailed =>
      'Kunde inte spara spellistans ordning. Försök igen.';

  @override
  String get playlistReorderTracksHint =>
      'Håll i handtaget för att ändra låtarnas ordning';

  @override
  String get playlistTrackCountLabel => 'Antal låtar';

  @override
  String get playlistDescription => 'Beskrivning';

  @override
  String get playlistOriginalUrl => 'Ursprunglig webbadress';

  @override
  String get searchSearching => 'Söker…';

  @override
  String get searchSuggestions => 'Förslag';

  @override
  String get searchTopResults => 'Bästa träffarna';

  @override
  String get changelogEmpty => 'Ingen versionshistorik tillgänglig.';

  @override
  String get changelogTitle => 'Nyheter';

  @override
  String get changelogLatest => 'Senaste';

  @override
  String get changelogNext => 'Nästa version';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Installationen är inte klar';

  @override
  String get pluginBootstrapRetryBody =>
      'Vissa tillägg kunde inte installeras just nu. Försök igen för att slutföra installationen.';

  @override
  String get pluginBootstrapInternetTitle => 'Internetanslutning krävs';

  @override
  String get pluginBootstrapInternetBody =>
      'Bloomee behöver ansluta till internet en gång för att identifiera ditt land och ställa in tilläggsmotorn.';

  @override
  String get buttonExit => 'Avsluta';

  @override
  String get eqSource => 'Val av equalizer';

  @override
  String get eqBuiltin => 'Appens equalizer';

  @override
  String get eqBuiltinSubtitle => '10-bands equalizer';

  @override
  String get eqDevice => 'Enhetens equalizer';

  @override
  String get eqDeviceSubtitle => 'System / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'Appens equalizer är avstängd. Ställ in enhetens equalizer i enhetens ljudinställningar.';

  @override
  String get eqPresets => 'Förinställningar';

  @override
  String get eqCustomCurve => 'Egen kurva';

  @override
  String get shortcutMuted => 'Ljud av';

  @override
  String get shortcutUnmuted => 'Ljud på';

  @override
  String get shortcutShuffleOn => 'Blandning på';

  @override
  String get shortcutShuffleOff => 'Blandning av';

  @override
  String get shortcutRepeatOff => 'Upprepning av';

  @override
  String get shortcutLiked => 'Tillagd i favoriter';

  @override
  String get shortcutUnliked => 'Borttagen från favoriter';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'Kunde inte välja hämtningsmapp: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Versionen är inte tillgänglig';

  @override
  String get backupNewCopyDetails =>
      'Skapar separata spellistor och slår samman favoriter. Befintliga spellistor bevaras. Även vald historik och valda inställningar importeras.';

  @override
  String get changelogCurrent => 'Nuvarande';

  @override
  String get backupLibrary =>
      'Bibliotek (spellistor, favoriter och sparade samlingar)';

  @override
  String get eqPresetFlat => 'Neutral';

  @override
  String get eqPresetAcoustic => 'Akustisk';

  @override
  String get eqPresetBassBoost => 'Basförstärkning';

  @override
  String get eqPresetBassReducer => 'Basdämpning';

  @override
  String get eqPresetClassical => 'Klassiskt';

  @override
  String get eqPresetDance => 'Dans';

  @override
  String get eqPresetDeep => 'Djup';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Elektronisk';

  @override
  String get eqPresetHipHop => 'Hiphop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latin';

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
  String get eqPresetSmallSpeakers => 'Små högtalare';

  @override
  String get eqPresetSpokenWord => 'Tal';

  @override
  String get eqPresetTrebleBoost => 'Diskantförstärkning';

  @override
  String get eqPresetTrebleReducer => 'Diskantdämpning';

  @override
  String get eqPresetVocalBooster => 'Sångförstärkning';

  @override
  String get eqPresetCustom => 'Egen';
}
