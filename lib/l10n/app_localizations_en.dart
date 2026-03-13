// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navLocal => 'Local';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Enjoying From';

  @override
  String get playerQueue => 'Queue';

  @override
  String get playerPlayWithMix => 'Auto-Mix Play';

  @override
  String get playerPlayNext => 'Play Next';

  @override
  String get playerAddToQueue => 'Add to Queue';

  @override
  String get playerAddToFavorites => 'Add to Favorites';

  @override
  String get playerNoLyricsFound => 'No Lyrics Found';

  @override
  String get playerLyricsNoPlugin =>
      'No lyrics provider configured. Go to Settings → Plugins to install one.';

  @override
  String get playerFullscreenLyrics => 'Fullscreen Lyrics';

  @override
  String get localMusicTitle => 'Local';

  @override
  String get localMusicGrantPermission => 'Grant Permission';

  @override
  String get localMusicStorageAccessRequired => 'Storage Access Required';

  @override
  String get localMusicStorageAccessDesc =>
      'Please grant permission to scan and play audio files stored on your device.';

  @override
  String get localMusicAddFolder => 'Add Music Folder';

  @override
  String get localMusicScanNow => 'Scan Now';

  @override
  String localMusicScanFailed(String message) {
    return 'Scan failed: $message';
  }

  @override
  String get localMusicScanning => 'Scanning device for audio files...';

  @override
  String get localMusicEmpty => 'No local music found';

  @override
  String get localMusicSearchEmpty => 'No tracks found matching your search.';

  @override
  String get localMusicShuffle => 'Shuffle';

  @override
  String get localMusicPlayAll => 'Play All';

  @override
  String get localMusicSearchHint => 'Search local music...';

  @override
  String get localMusicRescanDevice => 'Rescan Device';

  @override
  String get localMusicRemoveFolder => 'Remove folder';

  @override
  String get localMusicMusicFolders => 'Music Folders';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Update';

  @override
  String get buttonDownload => 'Download';

  @override
  String get buttonShare => 'Share';

  @override
  String get buttonLater => 'Later';

  @override
  String get dialogDeleteTrack => 'Delete Track';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Are you sure you want to delete \"$title\" from your device? This action cannot be undone.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'This track will also be removed from:';

  @override
  String get dialogDontAskAgain => 'Don\'t ask me again';

  @override
  String get dialogDeletePlugin => 'Delete Plugin?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This will permanently remove its files.';
  }

  @override
  String get dialogUpdateAvailable => 'Update Available';

  @override
  String get dialogUpdateNow => 'Update Now';

  @override
  String get dialogDownloadPlaylist => 'Download playlist';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Do you want to download $count songs from \"$title\"? This will add them to the download queue.';
  }

  @override
  String get dialogDownloadAll => 'Download All';

  @override
  String get playlistEdit => 'Edit Playlist';

  @override
  String get playlistShareFile => 'Share file';

  @override
  String get playlistExportFile => 'Export File';

  @override
  String get playlistPlay => 'Play';

  @override
  String get playlistAddToQueue => 'Add Playlist to Queue';

  @override
  String get playlistShare => 'Share Playlist';

  @override
  String get playlistDelete => 'Delete Playlist';

  @override
  String get playlistEmptyState => 'No Songs Yet!';

  @override
  String get playlistAvailableOffline => 'Available Offline';

  @override
  String get playlistShuffle => 'Shuffle';

  @override
  String get playlistMoreOptions => 'More Options';

  @override
  String get playlistNoMatchSearch => 'No playlists match your search';

  @override
  String get playlistCreateNew => 'Create New Playlist';

  @override
  String get playlistCreateFirstOne =>
      'No playlists yet. Create one to get started!';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlugins => 'Plugins';

  @override
  String get settingsPluginsSubtitle => 'Install, load and manage plugins.';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsUpdatesSubtitle => 'Check for new updates';

  @override
  String get settingsDownloads => 'Downloads';

  @override
  String get settingsDownloadsSubtitle =>
      'Download Path, Download Quality and more...';

  @override
  String get settingsLocalTracks => 'Local Tracks';

  @override
  String get settingsLocalTracksSubtitle =>
      'Scan, manage folders and auto-scan settings.';

  @override
  String get settingsPlayer => 'Player Settings';

  @override
  String get settingsPlayerSubtitle => 'Stream quality, Auto Play, etc.';

  @override
  String get settingsPluginDefaults => 'Plugin Defaults';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Discover source, resolver priority.';

  @override
  String get settingsUIElements => 'UI Elements & Services';

  @override
  String get settingsUIElementsSubtitle => 'Auto slide, UI tweaks etc.';

  @override
  String get settingsLastFM => 'Last.FM Settings';

  @override
  String get settingsLastFMSubtitle =>
      'API Key, Secret, and Scrobbling settings.';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsStorageSubtitle =>
      'Backup, Cache, History, Restore and more...';

  @override
  String get settingsLanguageCountry => 'Language & Country';

  @override
  String get settingsLanguageCountrySubtitle =>
      'Select your language and country.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'About the app, version, developer, etc.';

  @override
  String get settingsScanning => 'Scanning';

  @override
  String get settingsMusicFolders => 'Music Folders';

  @override
  String get settingsQuality => 'Quality';

  @override
  String get settingsHistory => 'History';

  @override
  String get settingsBackupRestore => 'Backup & Restore';

  @override
  String get settingsAutomatic => 'Automatic';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'Authentication';

  @override
  String get settingsHomeScreen => 'Home Screen';

  @override
  String get settingsChartVisibility => 'Chart Visibility';

  @override
  String get settingsLocation => 'Location';

  @override
  String get emptyNoInternet => 'No Internet Connection!';

  @override
  String get emptyNoContentPlugin =>
      'No content plugin loaded. Load a Content Resolver in Plugin Manager.';

  @override
  String get emptyRefreshingSource =>
      'Refreshing Discover source... The previous source is no longer available.';

  @override
  String get emptyNoTracks => 'No tracks available';

  @override
  String get emptyNoResults => 'No matches found';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Failed to delete \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue => 'Added to Next in Queue';

  @override
  String get snackbarAddedToQueue => 'Added to Queue';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title is added to Liked!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Playing $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Added $name to Queue';
  }

  @override
  String get snackbarPlaylistQueued => 'Playlist added to download queue';

  @override
  String get snackbarPlaylistUpdated => 'Playlist Updated!';

  @override
  String get snackbarNoInternet => 'No internet connection.';

  @override
  String get snackbarImportFailed => 'Import Failed!';

  @override
  String get snackbarImportCompleted => 'Import Completed';

  @override
  String get snackbarBackupFailed => 'Backup Failed!';

  @override
  String snackbarExportedTo(String path) {
    return 'Exported to: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'Media ID copied';

  @override
  String get snackbarLinkCopied => 'Link copied';

  @override
  String get snackbarNoLinkAvailable => 'No link available';

  @override
  String get snackbarCouldNotOpenLink => 'Could not open link';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Preparing download for $title...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title is already downloaded.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title is already in the queue.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'Downloaded $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Error: Download service is unavailable.';

  @override
  String get searchHintExplore => 'What do you want to listen to?';

  @override
  String get searchHintLibrary => 'Search library...';

  @override
  String get searchHintOfflineMusic => 'Search your songs...';

  @override
  String get searchHintPlaylists => 'Search playlists...';

  @override
  String get searchStartTyping => 'Start typing to search...';

  @override
  String get searchNoSuggestions => 'No Suggestions found!';

  @override
  String get searchNoResults =>
      'No results found!\nTry another keyword or source.';

  @override
  String get searchFailed => 'Search failed!';

  @override
  String get searchDiscover => 'Discover amazing music...';

  @override
  String get searchSources => 'SOURCES';

  @override
  String get searchNoPlugins => 'No plugins installed';

  @override
  String get searchTracks => 'Tracks';

  @override
  String get searchAlbums => 'Albums';

  @override
  String get searchArtists => 'Artists';

  @override
  String get searchPlaylists => 'Playlists';

  @override
  String get exploreDiscover => 'Discover';

  @override
  String get exploreRecently => 'Recently';

  @override
  String get exploreLastFmPicks => 'Last.Fm Picks';

  @override
  String get exploreFailedToLoad => 'Failed to load home sections.';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryEmptyState =>
      'Your library is feeling lonely. Add some tunes to brighten it up!';

  @override
  String libraryIn(String playlistName) {
    return 'in $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Add to Playlist';

  @override
  String get menuSmartReplace => 'Smart Replace';

  @override
  String get menuShare => 'Share';

  @override
  String get menuAvailableOffline => 'Available Offline';

  @override
  String get menuDownload => 'Download';

  @override
  String get menuOpenOriginalLink => 'Open original link';

  @override
  String get menuDeleteTrack => 'Delete';

  @override
  String get songInfoTitle => 'Title';

  @override
  String get songInfoArtist => 'Artist';

  @override
  String get songInfoAlbum => 'Album';

  @override
  String get songInfoMediaId => 'Media ID';

  @override
  String get songInfoCopyId => 'Copy ID';

  @override
  String get songInfoCopyLink => 'Copy Link';

  @override
  String get songInfoOpenBrowser => 'Open in browser';

  @override
  String get tooltipRemoveFromLibrary => 'Remove from Library';

  @override
  String get tooltipSaveToLibrary => 'Save to Library';

  @override
  String get tooltipOpenOriginalLink => 'Open Original Link';

  @override
  String get appuiTitle => 'UI & Services';

  @override
  String get appuiAutoSlideCharts => 'Auto Slide Charts';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Slide charts automatically in home screen.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Show suggestions from Last.FM. Login & restart required.';

  @override
  String get appuiNoChartsAvailable =>
      'No charts available. Load a chart provider plugin.';

  @override
  String get appuiLoginToLastFm => 'Please login to Last.FM first.';

  @override
  String get appuiShowInCarousel => 'Show in home carousel.';

  @override
  String get countrySettingTitle => 'Country & Language';

  @override
  String get countrySettingAutoDetect => 'Auto Detect Country';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Automatically detect your country when the app opens.';

  @override
  String get countrySettingCountryLabel => 'Country';

  @override
  String get countrySettingLanguageLabel => 'Language';

  @override
  String get countrySettingSystemDefault => 'System Default';

  @override
  String get downloadSettingTitle => 'Downloads';

  @override
  String get downloadSettingQuality => 'Download Quality';

  @override
  String get downloadSettingQualitySubtitle =>
      'Universal audio quality preference for downloaded tracks.';

  @override
  String get downloadSettingFolder => 'Download Folder';

  @override
  String get downloadSettingResetFolder => 'Reset Download Folder';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Restore the default download path.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Scrobble Tracks';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Send played tracks to your Last.FM profile.';

  @override
  String get lastfmAuthFirst => 'First Authenticate Last.FM API.';

  @override
  String get lastfmAuthenticatedAs => 'Authenticated as';

  @override
  String get lastfmAuthFailed => 'Authentication failed:';

  @override
  String get lastfmNotAuthenticated => 'Not authenticated';

  @override
  String get lastfmSteps =>
      'Steps to authenticate:\n1. Create / open a Last.FM account at last.fm\n2. Generate an API Key at last.fm/api/account/create\n3. Enter your API Key & Secret below\n4. Tap \"Start Auth\" and approve in the browser\n5. Tap \"Get & Save Session Key\" to finish';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. Start Auth';

  @override
  String get lastfmGetSession => '2. Get & Save Session Key';

  @override
  String get lastfmRemoveKeys => 'Remove Keys';

  @override
  String get lastfmStartAuthFirst =>
      'Start Auth first, then approve in browser.';

  @override
  String get localSettingTitle => 'Local Tracks';

  @override
  String get localSettingAutoScan => 'Auto Scan on Startup';

  @override
  String get localSettingAutoScanSubtitle =>
      'Automatically scan for new local tracks when the app starts.';

  @override
  String get localSettingLastScan => 'Last Scan';

  @override
  String get localSettingNeverScanned => 'Never';

  @override
  String get localSettingScanInProgress => 'Scanning in progress…';

  @override
  String get localSettingScanNowSubtitle =>
      'Manually trigger a full library scan.';

  @override
  String get localSettingNoFolders =>
      'No folders added. Add a folder to start scanning.';

  @override
  String get localSettingAddFolder => 'Add Folder';

  @override
  String get playerSettingTitle => 'Audio Player';

  @override
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Streaming Quality';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Global audio bitrate for online playback.';

  @override
  String get playerSettingQualityLow => 'Low';

  @override
  String get playerSettingQualityMedium => 'Medium';

  @override
  String get playerSettingQualityHigh => 'High';

  @override
  String get playerSettingPlaybackHeader => 'Playback';

  @override
  String get playerSettingAutoPlay => 'Auto Play';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Enqueue similar songs when the queue ends.';

  @override
  String get playerSettingAutoFallback => 'Auto Fallback Playback';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'If a plugin is missing or returns no streams, try a compatible resolver for playback only.';

  @override
  String get playerSettingCrossfade => 'Crossfade';

  @override
  String get playerSettingCrossfadeOff => 'Off';

  @override
  String get playerSettingCrossfadeInstant => 'Tracks switch instantly';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '${seconds}s blend between tracks';
  }

  @override
  String get playerSettingEqualizer => 'Equalizer';

  @override
  String get playerSettingEqualizerActive => 'Active';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Enabled — $preset preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      '10-band parametric EQ via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Plugin Defaults';

  @override
  String get pluginDefaultsDiscoverHeader => 'Discover Source';

  @override
  String get pluginDefaultsNoResolver =>
      'No content resolver loaded. Load a plugin to choose a Discover source.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Use the first available content resolver.';

  @override
  String get pluginDefaultsPriorityHeader => 'Resolver Priority';

  @override
  String get pluginDefaultsNoPriority =>
      'No content resolvers loaded. Priority ordering will appear here once plugins are loaded.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Drag to reorder. Higher priority resolvers are tried first when resolving chart items or imported tracks to playable tracks.';

  @override
  String get pluginDefaultsLyricsHeader => 'Lyrics Priority';

  @override
  String get pluginDefaultsLyricsNone => 'No lyrics providers loaded.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Drag to reorder lyrics providers. The first provider is tried first.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Search Suggestions';

  @override
  String get pluginDefaultsSuggestionsNone => 'No suggestion providers loaded.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'None';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Use search history only.';

  @override
  String get storageSettingTitle => 'Storage';

  @override
  String get storageClearHistoryEvery => 'Clear History In Every';

  @override
  String get storageClearHistorySubtitle =>
      'Clear listening history after the chosen period.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Days',
      one: '1 Day',
    );
    return '$_temp0';
  }

  @override
  String get storageBackupLocation => 'Backup Location';

  @override
  String get storageBackupLocationAndroid => 'Downloads / app-data directory';

  @override
  String get storageBackupLocationDownloads => 'Downloads directory';

  @override
  String get storageCreateBackup => 'Create Backup';

  @override
  String get storageCreateBackupSubtitle =>
      'Save your settings and data to a backup file.';

  @override
  String storageBackupCreatedAt(String path) {
    return 'Backup created at $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Failed to share backup: $error';
  }

  @override
  String get storageBackupFailed => 'Backup Failed!';

  @override
  String get storageRestoreBackup => 'Restore Backup';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restore your settings and data from a backup file.';

  @override
  String get storageAutoBackup => 'Auto Backup';

  @override
  String get storageAutoBackupSubtitle =>
      'Periodically create a backup of your data automatically.';

  @override
  String get storageAutoLyrics => 'Auto Save Lyrics';

  @override
  String get storageAutoLyricsSubtitle =>
      'Save lyrics automatically when a song plays.';

  @override
  String get storageResetApp => 'Reset Bloomee App';

  @override
  String get storageResetAppSubtitle =>
      'Delete all data and restore the app to its default state.';

  @override
  String get storageResetConfirmTitle => 'Confirm Reset';

  @override
  String get storageResetConfirmMessage =>
      'Are you sure you want to reset Bloomee? This will delete all your data and cannot be undone.';

  @override
  String get storageResetButton => 'Reset';

  @override
  String get storageResetSuccess => 'App has been reset to its default state.';

  @override
  String get storageLocationDialogTitle => 'Backup Location';

  @override
  String get storageLocationAndroid =>
      'Backups are stored in:\n\n1. Downloads directory\n2. Android/data/ls.bloomee.musicplayer/data\n\nCopy the file from either location.';

  @override
  String get storageLocationOther =>
      'Backups are stored in the Downloads directory. Copy the file from there.';

  @override
  String get storageRestoreOptionsTitle => 'Restore Options';

  @override
  String get storageRestoreOptionsDesc =>
      'Choose which data you want to restore from the selected backup file. Unselect any items you do NOT want to be imported. By default all are selected.';

  @override
  String get storageRestoreSelectAll => 'Select All';

  @override
  String get storageRestoreMediaItems =>
      'Media items (songs, tracks, library entries)';

  @override
  String get storageRestoreSearchHistory => 'Search history';

  @override
  String get storageRestoreContinue => 'Continue';

  @override
  String get storageRestoreNoFile => 'No file selected.';

  @override
  String get storageRestoreSaveFailed => 'Failed to save the selected file.';

  @override
  String get storageRestoreConfirmTitle => 'Confirm Restore';

  @override
  String get storageRestoreConfirmPrefix =>
      'This will overwrite and merge the parts you selected in the app with data from the backup file:';

  @override
  String get storageRestoreConfirmSuffix =>
      'Your current data will be modified/merged. Are you sure you want to proceed?';

  @override
  String get storageRestoreYes => 'Yes, restore';

  @override
  String get storageRestoreNo => 'No';

  @override
  String get storageRestoring =>
      'Restoring selected data…\nPlease wait until the operation completes.';

  @override
  String get storageRestoreMediaBullet => '• Media items';

  @override
  String get storageRestoreHistoryBullet => '• Search history';

  @override
  String get storageUnexpectedError =>
      'An unexpected error occurred while restoring.';

  @override
  String get storageRestoreCompleted => 'Restore Completed';

  @override
  String get storageRestoreFailedTitle => 'Restore Failed';

  @override
  String get storageRestoreSuccessMessage =>
      'The selected data was restored successfully. For best results, please restart the app now.';

  @override
  String get storageRestoreFailedMessage =>
      'The restore process failed with the following errors:';

  @override
  String get storageRestoreUnknownError =>
      'Unknown error occurred during restore.';

  @override
  String get storageRestoreRestartHint =>
      'Please restart the app for better consistency.';

  @override
  String get updateSettingTitle => 'Updates';

  @override
  String get updateAppUpdatesHeader => 'App Updates';

  @override
  String get updateCheckForUpdates => 'Check for Updates';

  @override
  String get updateCheckSubtitle =>
      'See if a newer version of Bloomee is available.';

  @override
  String get updateAutoNotify => 'Auto Update Notify';

  @override
  String get updateAutoNotifySubtitle =>
      'Get notified when new updates are available on app start.';

  @override
  String get updateCheckTitle => 'Check for Updates';

  @override
  String get updateUpToDate => 'Bloomee🌸 is up-to-date!!!';

  @override
  String get updateViewPreRelease => 'View Latest Pre-Release';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Current Version: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'New Version of Bloomee🌸 is now available!!';

  @override
  String updateVersion(String ver, String build) {
    return 'Version: $ver+ $build';
  }

  @override
  String get updateDownloadNow => 'Download Now';

  @override
  String get updateChecking =>
      'Checking if newer version are available or not!';

  @override
  String get timerTitle => 'Sleep Timer';

  @override
  String get timerInterludeMessage => 'Preparing for a peaceful interlude in…';

  @override
  String get timerHours => 'Hours';

  @override
  String get timerMinutes => 'Minutes';

  @override
  String get timerSeconds => 'Seconds';

  @override
  String get timerStop => 'Stop Timer';

  @override
  String get timerFinishedMessage => 'The tunes have rested. Sweet Dreams 🥰.';

  @override
  String get timerGotIt => 'Got it!';

  @override
  String get timerSetTimeError => 'Please set a time';

  @override
  String get timerStart => 'Start Timer';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No Notifications yet!';

  @override
  String get recentsTitle => 'History';

  @override
  String playlistByCreator(String creator) {
    return 'by $creator';
  }

  @override
  String get playlistTypeAlbum => 'Album';

  @override
  String get playlistTypePlaylist => 'Playlist';

  @override
  String get playlistYou => 'You';

  @override
  String get pluginManagerTitle => 'Plugins';

  @override
  String get pluginManagerEmpty =>
      'No plugins installed.\nTap + to add a .bex file.';

  @override
  String get pluginManagerFilterAll => 'All';

  @override
  String get pluginManagerFilterContent => 'Content Resolvers';

  @override
  String get pluginManagerFilterCharts => 'Chart Providers';

  @override
  String get pluginManagerFilterLyrics => 'Lyrics Providers';

  @override
  String get pluginManagerFilterSuggestions => 'Suggestion Providers';

  @override
  String get pluginManagerFilterImporters => 'Content Importers';

  @override
  String get pluginManagerTooltipRefresh => 'Refresh';

  @override
  String get pluginManagerTooltipInstall => 'Install Plugin';

  @override
  String get pluginManagerNoMatch => 'No plugins match this filter';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Failed to pick file: $error';
  }

  @override
  String get pluginManagerInstalling => 'Installing plugin...';

  @override
  String get pluginManagerTypeContentResolver => 'Content Resolver';

  @override
  String get pluginManagerTypeChartProvider => 'Chart Provider';

  @override
  String get pluginManagerTypeLyricsProvider => 'Lyrics Provider';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Search Suggestions';

  @override
  String get pluginManagerTypeContentImporter => 'Content Importer';

  @override
  String get pluginManagerDeleteTitle => 'Delete Plugin?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This will permanently remove its files.';
  }

  @override
  String get pluginManagerDeleteAction => 'Delete';

  @override
  String get pluginManagerCancel => 'Cancel';

  @override
  String get pluginManagerEnablePlugin => 'Enable Plugin';

  @override
  String get pluginManagerUnloadPlugin => 'Unload Plugin';

  @override
  String get pluginManagerDeleting => 'Deleting...';

  @override
  String get pluginManagerApiKeysTitle => 'API Keys';

  @override
  String get pluginManagerApiKeysSaved => 'API keys saved';

  @override
  String get pluginManagerSave => 'Save';

  @override
  String get pluginManagerDetailVersion => 'Version';

  @override
  String get pluginManagerDetailType => 'Type';

  @override
  String get pluginManagerDetailPublisher => 'Publisher';

  @override
  String get pluginManagerDetailLastUpdated => 'Last Updated';

  @override
  String get pluginManagerDetailCreated => 'Created';

  @override
  String get pluginManagerDetailHomepage => 'Homepage';

  @override
  String get pluginManagerDowngradeTitle => 'Downgrade Plugin?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'You are installing an older or equal version of \"$name\". Continue?';
  }

  @override
  String get pluginManagerDowngradeAction => 'Install Anyway';

  @override
  String get pluginManagerDeleteStorageTitle => 'Delete Plugin Data?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Also remove saved API keys and settings for \"$name\"?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Keep Data';

  @override
  String get pluginManagerDeleteStorageRemove => 'Remove Data';

  @override
  String get segmentsSheetTitle => 'Segments';

  @override
  String get segmentsSheetEmpty => 'No segments available';

  @override
  String get segmentsSheetUntitled => 'Untitled Segment';

  @override
  String get smartReplaceTitle => 'Smart Replace';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Choose a playable replacement for \"$title\" and update saved playlist references.';
  }

  @override
  String get smartReplaceClose => 'Close';

  @override
  String get smartReplaceNoMatch => 'No replacement found';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'None of the loaded resolver plugins returned a strong enough match.';

  @override
  String get smartReplaceBestMatch => 'Best match';

  @override
  String get smartReplaceSearchFailed => 'Search failed';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Smart Replace failed: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Applied replacement$queue.';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return 'Replaced in $count playlist$plural$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' and updated the queue';

  @override
  String get playerUnknownQueue => 'Unknown';

  @override
  String playerLiked(String title) {
    return '$title Liked!!';
  }

  @override
  String playerUnliked(String title) {
    return '$title Unliked!!';
  }

  @override
  String get offlineNoDownloads => 'No Downloads';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Search your songs...';

  @override
  String get offlineRefreshTooltip => 'Refresh Downloads';

  @override
  String get offlineCloseSearch => 'Close Search';

  @override
  String get offlineSearchTooltip => 'Search';

  @override
  String get offlineOpenFailed =>
      'Unable to open this offline track. Try refreshing downloads.';

  @override
  String get offlinePlayFailed =>
      'Could not play this offline song. Please try again.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tracks',
      one: '1 Track',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Failed to load album';

  @override
  String get aboutCraftingSubtitle => 'Crafting symphonies in code.';

  @override
  String get aboutFollowGitHub => 'Follow him on GitHub';

  @override
  String get aboutSendInquiry => 'Send a business inquiry';

  @override
  String get aboutCreativeHighlights => 'Updates and creative highlights';

  @override
  String get aboutTipQuote =>
      'Enjoying Bloomee? A small tip keeps it blooming. 🌸';

  @override
  String get aboutTipButton => 'I\'ll help';

  @override
  String get aboutTipDesc => 'I want Bloomee to keep improving.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Song Details';

  @override
  String get songInfoSectionTechnical => 'Technical Info';

  @override
  String get songInfoSectionActions => 'Actions';

  @override
  String get songInfoLabelTitle => 'Title';

  @override
  String get songInfoLabelArtist => 'Artist';

  @override
  String get songInfoLabelAlbum => 'Album';

  @override
  String get songInfoLabelDuration => 'Duration';

  @override
  String get songInfoLabelSource => 'Source';

  @override
  String get songInfoLabelMediaId => 'Media ID';

  @override
  String get songInfoLabelPluginId => 'Plugin ID';

  @override
  String get songInfoIdCopied => 'Media ID copied';

  @override
  String get songInfoLinkCopied => 'Link copied';

  @override
  String get songInfoNoLink => 'No link available';

  @override
  String get songInfoOpenFailed => 'Could not open link';

  @override
  String get songInfoSearchTitle => 'Search for this song in Bloomee';

  @override
  String get songInfoSearchArtist => 'Search for this artist in Bloomee';

  @override
  String get songInfoSearchAlbum => 'Search for this album in Bloomee';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get eqResetTooltip => 'Reset to Flat';

  @override
  String get chartNoItems => 'No items in this chart';

  @override
  String get chartLoadFailed => 'Failed to load chart';

  @override
  String get chartPlay => 'Play';

  @override
  String get chartResolving => 'Resolving';

  @override
  String get chartReady => 'Ready';

  @override
  String get chartAddToPlaylist => 'Add to Playlist';

  @override
  String get chartNoResolver =>
      'No content resolver loaded. Install a plugin to play.';

  @override
  String get chartResolveFailed => 'Could not resolve. Searching instead...';

  @override
  String get chartNoResolverAdd => 'No content resolver loaded.';

  @override
  String get chartNoMatch => 'Could not find a match. Try searching manually.';

  @override
  String get chartStatPeak => 'Peak';

  @override
  String get chartStatWeeks => 'Weeks';

  @override
  String get chartStatChange => 'Change';

  @override
  String menuSharePreparing(String title) {
    return 'Preparing $title for share.';
  }

  @override
  String get menuOpenLinkFailed => 'Could not open link';

  @override
  String get localMusicFolders => 'Music Folders';

  @override
  String get localMusicCloseSearch => 'Close search';

  @override
  String get localMusicOpenSearch => 'Search';

  @override
  String get localMusicNoMusicFound => 'No local music found';

  @override
  String get localMusicNoSearchResults =>
      'No tracks found matching your search.';

  @override
  String get importSongsTitle => 'Import Songs';

  @override
  String get importNoPluginsLoaded =>
      'No content-importer plugins loaded.\nInstall an importer plugin to import playlists from external services.';

  @override
  String get importBloomeeFiles => 'Import Bloomee Files';

  @override
  String get importNoteTitle => 'Note';

  @override
  String get importNoteMessage =>
      'You can only import files created by Bloomee.\nIf your file is from another source, it will not work. Continue anyway?';

  @override
  String get importTitle => 'Import';

  @override
  String get importCheckingUrl => 'Checking URL...';

  @override
  String get importFetchingTracks => 'Fetching tracks...';

  @override
  String get importSavingToLibrary => 'Saving to library...';

  @override
  String get importPasteUrlHint => 'Paste a playlist or album URL to import';

  @override
  String get importAction => 'Import';

  @override
  String importTrackCount(int count) {
    return '$count tracks';
  }

  @override
  String get importResolving => 'Resolving...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'Resolving tracks: $done / $total';
  }

  @override
  String get importReviewTitle => 'Import Review';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved resolved, $failed failed out of $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Save $count Tracks';
  }

  @override
  String importTracksSaved(int count) {
    return '$count tracks saved!';
  }

  @override
  String get importDone => 'Done';

  @override
  String get importMore => 'Import More';

  @override
  String get importUnknownError => 'Unknown error';

  @override
  String get importTryAgain => 'Try Again';

  @override
  String get importSkipTrack => 'Skip this track';

  @override
  String get importMatchOptions => 'Match options';

  @override
  String get importAutoMatched => 'Auto-matched';

  @override
  String get importUserSelected => 'Selected';

  @override
  String get importSkipped => 'Skipped';

  @override
  String get importNoMatch => 'No match found';

  @override
  String get importReorderTip => 'Long press a playlist to start reordering';

  @override
  String get importErrorCannotHandleUrl =>
      'This plugin cannot handle the provided URL.';

  @override
  String get importErrorUnexpectedResponse =>
      'Unexpected response from plugin.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Failed to check URL: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Failed to fetch collection info: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Failed to fetch tracks: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Failed to save playlist: $error';
  }

  @override
  String get playlistPinToTop => 'Pin to Top';

  @override
  String get playlistUnpin => 'Unpin';

  @override
  String get snackbarImportingMedia => 'Importing MediaItems..';

  @override
  String get snackbarPlaylistSaved => 'Playlist saved to library!';

  @override
  String get snackbarInvalidFileFormat => 'Invalid File Format';

  @override
  String get snackbarMediaItemImported => 'Media Item Imported';

  @override
  String get snackbarPlaylistImported => 'Playlist Imported';

  @override
  String get snackbarOpenImportForUrl =>
      'Open the Import screen in Library to import from this URL.';

  @override
  String get snackbarProcessingFile => 'Processing File...';

  @override
  String snackbarPreparingShare(String title) {
    return 'Preparing $title for share';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Preparing $title for export.';
  }
}
