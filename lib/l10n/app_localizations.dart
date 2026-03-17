import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bloomee'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your language and region.'**
  String get onboardingSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get navLocal;

  /// No description provided for @navOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get navOffline;

  /// No description provided for @playerEnjoyingFrom.
  ///
  /// In en, this message translates to:
  /// **'Enjoying From'**
  String get playerEnjoyingFrom;

  /// No description provided for @playerQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get playerQueue;

  /// No description provided for @playerPlayWithMix.
  ///
  /// In en, this message translates to:
  /// **'Auto-Mix Play'**
  String get playerPlayWithMix;

  /// No description provided for @playerPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get playerPlayNext;

  /// No description provided for @playerAddToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to Queue'**
  String get playerAddToQueue;

  /// No description provided for @playerAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get playerAddToFavorites;

  /// No description provided for @playerNoLyricsFound.
  ///
  /// In en, this message translates to:
  /// **'No Lyrics Found'**
  String get playerNoLyricsFound;

  /// No description provided for @playerLyricsNoPlugin.
  ///
  /// In en, this message translates to:
  /// **'No lyrics provider configured. Go to Settings → Plugins to install one.'**
  String get playerLyricsNoPlugin;

  /// No description provided for @playerFullscreenLyrics.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen Lyrics'**
  String get playerFullscreenLyrics;

  /// No description provided for @localMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get localMusicTitle;

  /// No description provided for @localMusicGrantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get localMusicGrantPermission;

  /// No description provided for @localMusicStorageAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage Access Required'**
  String get localMusicStorageAccessRequired;

  /// No description provided for @localMusicStorageAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Please grant permission to scan and play audio files stored on your device.'**
  String get localMusicStorageAccessDesc;

  /// No description provided for @localMusicAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add Music Folder'**
  String get localMusicAddFolder;

  /// No description provided for @localMusicScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get localMusicScanNow;

  /// No description provided for @localMusicScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {message}'**
  String localMusicScanFailed(String message);

  /// No description provided for @localMusicScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning device for audio files...'**
  String get localMusicScanning;

  /// No description provided for @localMusicEmpty.
  ///
  /// In en, this message translates to:
  /// **'No local music found'**
  String get localMusicEmpty;

  /// No description provided for @localMusicSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tracks found matching your search.'**
  String get localMusicSearchEmpty;

  /// No description provided for @localMusicShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get localMusicShuffle;

  /// No description provided for @localMusicPlayAll.
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get localMusicPlayAll;

  /// No description provided for @localMusicSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search local music...'**
  String get localMusicSearchHint;

  /// No description provided for @localMusicRescanDevice.
  ///
  /// In en, this message translates to:
  /// **'Rescan Device'**
  String get localMusicRescanDevice;

  /// No description provided for @localMusicRemoveFolder.
  ///
  /// In en, this message translates to:
  /// **'Remove folder'**
  String get localMusicRemoveFolder;

  /// No description provided for @localMusicMusicFolders.
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get localMusicMusicFolders;

  /// No description provided for @localMusicTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 track} other{{count} tracks}}'**
  String localMusicTrackCount(int count);

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get buttonUpdate;

  /// No description provided for @buttonDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get buttonDownload;

  /// No description provided for @buttonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get buttonShare;

  /// No description provided for @buttonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get buttonLater;

  /// No description provided for @buttonInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get buttonInfo;

  /// No description provided for @buttonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get buttonMore;

  /// No description provided for @dialogDeleteTrack.
  ///
  /// In en, this message translates to:
  /// **'Delete Track'**
  String get dialogDeleteTrack;

  /// No description provided for @dialogDeleteTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\" from your device? This action cannot be undone.'**
  String dialogDeleteTrackMessage(String title);

  /// No description provided for @dialogDeleteTrackLinkedPlaylists.
  ///
  /// In en, this message translates to:
  /// **'This track will also be removed from:'**
  String get dialogDeleteTrackLinkedPlaylists;

  /// No description provided for @dialogDontAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask me again'**
  String get dialogDontAskAgain;

  /// No description provided for @dialogDeletePlugin.
  ///
  /// In en, this message translates to:
  /// **'Delete Plugin?'**
  String get dialogDeletePlugin;

  /// No description provided for @dialogDeletePluginMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This will permanently remove its files.'**
  String dialogDeletePluginMessage(String name);

  /// No description provided for @dialogUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get dialogUpdateAvailable;

  /// No description provided for @dialogUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get dialogUpdateNow;

  /// No description provided for @dialogDownloadPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Download playlist'**
  String get dialogDownloadPlaylist;

  /// No description provided for @dialogDownloadPlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to download {count} songs from \"{title}\"? This will add them to the download queue.'**
  String dialogDownloadPlaylistMessage(int count, String title);

  /// No description provided for @dialogDownloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download All'**
  String get dialogDownloadAll;

  /// No description provided for @playlistEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get playlistEdit;

  /// No description provided for @playlistShareFile.
  ///
  /// In en, this message translates to:
  /// **'Share file'**
  String get playlistShareFile;

  /// No description provided for @playlistExportFile.
  ///
  /// In en, this message translates to:
  /// **'Export File'**
  String get playlistExportFile;

  /// No description provided for @playlistPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playlistPlay;

  /// No description provided for @playlistAddToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add Playlist to Queue'**
  String get playlistAddToQueue;

  /// No description provided for @playlistShare.
  ///
  /// In en, this message translates to:
  /// **'Share Playlist'**
  String get playlistShare;

  /// No description provided for @playlistDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get playlistDelete;

  /// No description provided for @playlistEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No Songs Yet!'**
  String get playlistEmptyState;

  /// No description provided for @playlistAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available Offline'**
  String get playlistAvailableOffline;

  /// No description provided for @playlistShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playlistShuffle;

  /// No description provided for @playlistMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get playlistMoreOptions;

  /// No description provided for @playlistNoMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No playlists match your search'**
  String get playlistNoMatchSearch;

  /// No description provided for @playlistCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create New Playlist'**
  String get playlistCreateNew;

  /// No description provided for @playlistCreateFirstOne.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet. Create one to get started!'**
  String get playlistCreateFirstOne;

  /// No description provided for @playlistSongCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Song} other{{count} Songs}}'**
  String playlistSongCount(int count);

  /// No description provided for @playlistRemovedTrack.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from {playlist}'**
  String playlistRemovedTrack(String title, String playlist);

  /// No description provided for @playlistFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load playlist'**
  String get playlistFailedToLoad;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPlugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get settingsPlugins;

  /// No description provided for @settingsPluginsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install, load and manage plugins.'**
  String get settingsPluginsSubtitle;

  /// No description provided for @settingsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdates;

  /// No description provided for @settingsUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check for new updates'**
  String get settingsUpdatesSubtitle;

  /// No description provided for @settingsDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settingsDownloads;

  /// No description provided for @settingsDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download Path, Download Quality and more...'**
  String get settingsDownloadsSubtitle;

  /// No description provided for @settingsLocalTracks.
  ///
  /// In en, this message translates to:
  /// **'Local Tracks'**
  String get settingsLocalTracks;

  /// No description provided for @settingsLocalTracksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan, manage folders and auto-scan settings.'**
  String get settingsLocalTracksSubtitle;

  /// No description provided for @settingsPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player Settings'**
  String get settingsPlayer;

  /// No description provided for @settingsPlayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stream quality, Auto Play, etc.'**
  String get settingsPlayerSubtitle;

  /// No description provided for @settingsPluginDefaults.
  ///
  /// In en, this message translates to:
  /// **'Plugin Defaults'**
  String get settingsPluginDefaults;

  /// No description provided for @settingsPluginDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover source, resolver priority.'**
  String get settingsPluginDefaultsSubtitle;

  /// No description provided for @settingsUIElements.
  ///
  /// In en, this message translates to:
  /// **'UI Elements & Services'**
  String get settingsUIElements;

  /// No description provided for @settingsUIElementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto slide, UI tweaks etc.'**
  String get settingsUIElementsSubtitle;

  /// No description provided for @settingsLastFM.
  ///
  /// In en, this message translates to:
  /// **'Last.FM Settings'**
  String get settingsLastFM;

  /// No description provided for @settingsLastFMSubtitle.
  ///
  /// In en, this message translates to:
  /// **'API Key, Secret, and Scrobbling settings.'**
  String get settingsLastFMSubtitle;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorage;

  /// No description provided for @settingsStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup, Cache, History, Restore and more...'**
  String get settingsStorageSubtitle;

  /// No description provided for @settingsLanguageCountry.
  ///
  /// In en, this message translates to:
  /// **'Language & Country'**
  String get settingsLanguageCountry;

  /// No description provided for @settingsLanguageCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your language and country.'**
  String get settingsLanguageCountrySubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About the app, version, developer, etc.'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get settingsScanning;

  /// No description provided for @settingsMusicFolders.
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get settingsMusicFolders;

  /// No description provided for @settingsQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get settingsQuality;

  /// No description provided for @settingsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get settingsHistory;

  /// No description provided for @settingsBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsBackupRestore;

  /// No description provided for @settingsAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsAutomatic;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsScrobbling.
  ///
  /// In en, this message translates to:
  /// **'Scrobbling'**
  String get settingsScrobbling;

  /// No description provided for @settingsAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get settingsAuthentication;

  /// No description provided for @settingsHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get settingsHomeScreen;

  /// No description provided for @settingsChartVisibility.
  ///
  /// In en, this message translates to:
  /// **'Chart Visibility'**
  String get settingsChartVisibility;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @pluginRepositoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugin Repositories'**
  String get pluginRepositoryTitle;

  /// No description provided for @pluginRepositorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a JSON source to browse remote plugins.'**
  String get pluginRepositorySubtitle;

  /// No description provided for @pluginRepositoryAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add Repository'**
  String get pluginRepositoryAddAction;

  /// No description provided for @pluginRepositoryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Repository'**
  String get pluginRepositoryAddTitle;

  /// No description provided for @pluginRepositoryAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of a valid plugin repository JSON file.'**
  String get pluginRepositoryAddSubtitle;

  /// No description provided for @pluginRepositoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No repositories added yet.'**
  String get pluginRepositoryEmpty;

  /// No description provided for @pluginRepositoryUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Repository URL copied to clipboard'**
  String get pluginRepositoryUrlCopied;

  /// No description provided for @pluginRepositoryNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get pluginRepositoryNoDescription;

  /// No description provided for @pluginRepositoryUnknownUpdate.
  ///
  /// In en, this message translates to:
  /// **'Unknown update'**
  String get pluginRepositoryUnknownUpdate;

  /// No description provided for @pluginRepositoryPluginsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plugin} other{{count} plugins}}'**
  String pluginRepositoryPluginsCount(int count);

  /// No description provided for @pluginRepositoryErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load repositories.'**
  String get pluginRepositoryErrorLoad;

  /// No description provided for @pluginRepositoryErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid repository URL or repository file.'**
  String get pluginRepositoryErrorInvalid;

  /// No description provided for @pluginRepositoryErrorRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove repository.'**
  String get pluginRepositoryErrorRemove;

  /// No description provided for @pluginRepositoryError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String pluginRepositoryError(String message);

  /// No description provided for @dialogAddingToDownloadQueue.
  ///
  /// In en, this message translates to:
  /// **'Adding to download queue'**
  String get dialogAddingToDownloadQueue;

  /// No description provided for @emptyNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection!'**
  String get emptyNoInternet;

  /// No description provided for @emptyNoContentPlugin.
  ///
  /// In en, this message translates to:
  /// **'No content plugin loaded. Load a Content Resolver in Plugin Manager.'**
  String get emptyNoContentPlugin;

  /// No description provided for @emptyRefreshingSource.
  ///
  /// In en, this message translates to:
  /// **'Refreshing Discover source... The previous source is no longer available.'**
  String get emptyRefreshingSource;

  /// No description provided for @emptyNoTracks.
  ///
  /// In en, this message translates to:
  /// **'No tracks available'**
  String get emptyNoTracks;

  /// No description provided for @emptyNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get emptyNoResults;

  /// No description provided for @snackbarDeletedTrack.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\"'**
  String snackbarDeletedTrack(String title);

  /// No description provided for @snackbarDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete \"{title}\"'**
  String snackbarDeleteFailed(String title);

  /// No description provided for @snackbarAddedToNextQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to Next in Queue'**
  String get snackbarAddedToNextQueue;

  /// No description provided for @snackbarAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to Queue'**
  String get snackbarAddedToQueue;

  /// No description provided for @snackbarAddedToLiked.
  ///
  /// In en, this message translates to:
  /// **'{title} is added to Liked!!'**
  String snackbarAddedToLiked(String title);

  /// No description provided for @snackbarNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing {name}'**
  String snackbarNowPlaying(String name);

  /// No description provided for @snackbarPlaylistAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to Queue'**
  String snackbarPlaylistAddedToQueue(String name);

  /// No description provided for @snackbarPlaylistQueued.
  ///
  /// In en, this message translates to:
  /// **'Playlist added to download queue'**
  String get snackbarPlaylistQueued;

  /// No description provided for @snackbarPlaylistUpdated.
  ///
  /// In en, this message translates to:
  /// **'Playlist Updated!'**
  String get snackbarPlaylistUpdated;

  /// No description provided for @snackbarNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get snackbarNoInternet;

  /// No description provided for @snackbarImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import Failed!'**
  String get snackbarImportFailed;

  /// No description provided for @snackbarImportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Import Completed'**
  String get snackbarImportCompleted;

  /// No description provided for @snackbarBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed!'**
  String get snackbarBackupFailed;

  /// No description provided for @snackbarExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to: {path}'**
  String snackbarExportedTo(String path);

  /// No description provided for @snackbarMediaIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Media ID copied'**
  String get snackbarMediaIdCopied;

  /// No description provided for @snackbarLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get snackbarLinkCopied;

  /// No description provided for @snackbarNoLinkAvailable.
  ///
  /// In en, this message translates to:
  /// **'No link available'**
  String get snackbarNoLinkAvailable;

  /// No description provided for @snackbarCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get snackbarCouldNotOpenLink;

  /// No description provided for @snackbarPreparingDownload.
  ///
  /// In en, this message translates to:
  /// **'Preparing download for {title}...'**
  String snackbarPreparingDownload(String title);

  /// No description provided for @snackbarAlreadyDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{title} is already downloaded.'**
  String snackbarAlreadyDownloaded(String title);

  /// No description provided for @snackbarAlreadyInQueue.
  ///
  /// In en, this message translates to:
  /// **'{title} is already in the queue.'**
  String snackbarAlreadyInQueue(String title);

  /// No description provided for @snackbarDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {title}'**
  String snackbarDownloaded(String title);

  /// No description provided for @snackbarDownloadServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Error: Download service is unavailable.'**
  String get snackbarDownloadServiceUnavailable;

  /// No description provided for @snackbarSongsAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added {count} songs to download queue'**
  String snackbarSongsAddedToQueue(int count);

  /// No description provided for @snackbarDeleteTrackFailDevice.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete track from device storage.'**
  String get snackbarDeleteTrackFailDevice;

  /// No description provided for @searchHintExplore.
  ///
  /// In en, this message translates to:
  /// **'What do you want to listen to?'**
  String get searchHintExplore;

  /// No description provided for @searchHintLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search library...'**
  String get searchHintLibrary;

  /// No description provided for @searchHintOfflineMusic.
  ///
  /// In en, this message translates to:
  /// **'Search your songs...'**
  String get searchHintOfflineMusic;

  /// No description provided for @searchHintPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Search playlists...'**
  String get searchHintPlaylists;

  /// No description provided for @searchStartTyping.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search...'**
  String get searchStartTyping;

  /// No description provided for @searchNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No Suggestions found!'**
  String get searchNoSuggestions;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found!\nTry another keyword or source.'**
  String get searchNoResults;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed!'**
  String get searchFailed;

  /// No description provided for @searchDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing music...'**
  String get searchDiscover;

  /// No description provided for @searchSources.
  ///
  /// In en, this message translates to:
  /// **'SOURCES'**
  String get searchSources;

  /// No description provided for @searchNoPlugins.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed'**
  String get searchNoPlugins;

  /// No description provided for @searchTracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get searchTracks;

  /// No description provided for @searchAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get searchAlbums;

  /// No description provided for @searchArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get searchArtists;

  /// No description provided for @searchPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get searchPlaylists;

  /// No description provided for @exploreDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get exploreDiscover;

  /// No description provided for @exploreRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get exploreRecently;

  /// No description provided for @exploreLastFmPicks.
  ///
  /// In en, this message translates to:
  /// **'Last.Fm Picks'**
  String get exploreLastFmPicks;

  /// No description provided for @exploreFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home sections.'**
  String get exploreFailedToLoad;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Your library is feeling lonely. Add some tunes to brighten it up!'**
  String get libraryEmptyState;

  /// No description provided for @libraryIn.
  ///
  /// In en, this message translates to:
  /// **'in {playlistName}'**
  String libraryIn(String playlistName);

  /// No description provided for @menuAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get menuAddToPlaylist;

  /// No description provided for @menuSmartReplace.
  ///
  /// In en, this message translates to:
  /// **'Smart Replace'**
  String get menuSmartReplace;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @menuAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available Offline'**
  String get menuAvailableOffline;

  /// No description provided for @menuDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get menuDownload;

  /// No description provided for @menuOpenOriginalLink.
  ///
  /// In en, this message translates to:
  /// **'Open original link'**
  String get menuOpenOriginalLink;

  /// No description provided for @menuDeleteTrack.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDeleteTrack;

  /// No description provided for @songInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get songInfoTitle;

  /// No description provided for @songInfoArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get songInfoArtist;

  /// No description provided for @songInfoAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get songInfoAlbum;

  /// No description provided for @songInfoMediaId.
  ///
  /// In en, this message translates to:
  /// **'Media ID'**
  String get songInfoMediaId;

  /// No description provided for @songInfoCopyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get songInfoCopyId;

  /// No description provided for @songInfoCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get songInfoCopyLink;

  /// No description provided for @songInfoOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get songInfoOpenBrowser;

  /// No description provided for @tooltipRemoveFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from Library'**
  String get tooltipRemoveFromLibrary;

  /// No description provided for @tooltipSaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to Library'**
  String get tooltipSaveToLibrary;

  /// No description provided for @tooltipOpenOriginalLink.
  ///
  /// In en, this message translates to:
  /// **'Open Original Link'**
  String get tooltipOpenOriginalLink;

  /// No description provided for @tooltipShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get tooltipShuffle;

  /// No description provided for @tooltipAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available Offline'**
  String get tooltipAvailableOffline;

  /// No description provided for @tooltipDownloadPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Download playlist'**
  String get tooltipDownloadPlaylist;

  /// No description provided for @tooltipMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get tooltipMoreOptions;

  /// No description provided for @tooltipInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tooltipInfo;

  /// No description provided for @appuiTitle.
  ///
  /// In en, this message translates to:
  /// **'UI & Services'**
  String get appuiTitle;

  /// No description provided for @appuiAutoSlideCharts.
  ///
  /// In en, this message translates to:
  /// **'Auto Slide Charts'**
  String get appuiAutoSlideCharts;

  /// No description provided for @appuiAutoSlideChartsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Slide charts automatically in home screen.'**
  String get appuiAutoSlideChartsSubtitle;

  /// No description provided for @appuiLastFmPicksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show suggestions from Last.FM. Login & restart required.'**
  String get appuiLastFmPicksSubtitle;

  /// No description provided for @appuiNoChartsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No charts available. Load a chart provider plugin.'**
  String get appuiNoChartsAvailable;

  /// No description provided for @appuiLoginToLastFm.
  ///
  /// In en, this message translates to:
  /// **'Please login to Last.FM first.'**
  String get appuiLoginToLastFm;

  /// No description provided for @appuiShowInCarousel.
  ///
  /// In en, this message translates to:
  /// **'Show in home carousel.'**
  String get appuiShowInCarousel;

  /// No description provided for @countrySettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Country & Language'**
  String get countrySettingTitle;

  /// No description provided for @countrySettingAutoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect Country'**
  String get countrySettingAutoDetect;

  /// No description provided for @countrySettingAutoDetectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically detect your country when the app opens.'**
  String get countrySettingAutoDetectSubtitle;

  /// No description provided for @countrySettingCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countrySettingCountryLabel;

  /// No description provided for @countrySettingLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get countrySettingLanguageLabel;

  /// No description provided for @countrySettingSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get countrySettingSystemDefault;

  /// No description provided for @downloadSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadSettingTitle;

  /// No description provided for @downloadSettingQuality.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get downloadSettingQuality;

  /// No description provided for @downloadSettingQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Universal audio quality preference for downloaded tracks.'**
  String get downloadSettingQualitySubtitle;

  /// No description provided for @downloadSettingFolder.
  ///
  /// In en, this message translates to:
  /// **'Download Folder'**
  String get downloadSettingFolder;

  /// No description provided for @downloadSettingResetFolder.
  ///
  /// In en, this message translates to:
  /// **'Reset Download Folder'**
  String get downloadSettingResetFolder;

  /// No description provided for @downloadSettingResetFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore the default download path.'**
  String get downloadSettingResetFolderSubtitle;

  /// No description provided for @lastfmTitle.
  ///
  /// In en, this message translates to:
  /// **'Last.FM'**
  String get lastfmTitle;

  /// No description provided for @lastfmScrobbleTracks.
  ///
  /// In en, this message translates to:
  /// **'Scrobble Tracks'**
  String get lastfmScrobbleTracks;

  /// No description provided for @lastfmScrobbleTracksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send played tracks to your Last.FM profile.'**
  String get lastfmScrobbleTracksSubtitle;

  /// No description provided for @lastfmAuthFirst.
  ///
  /// In en, this message translates to:
  /// **'First Authenticate Last.FM API.'**
  String get lastfmAuthFirst;

  /// No description provided for @lastfmAuthenticatedAs.
  ///
  /// In en, this message translates to:
  /// **'Authenticated as'**
  String get lastfmAuthenticatedAs;

  /// No description provided for @lastfmAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed:'**
  String get lastfmAuthFailed;

  /// No description provided for @lastfmNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get lastfmNotAuthenticated;

  /// No description provided for @lastfmSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps to authenticate:\n1. Create / open a Last.FM account at last.fm\n2. Generate an API Key at last.fm/api/account/create\n3. Enter your API Key & Secret below\n4. Tap \"Start Auth\" and approve in the browser\n5. Tap \"Get & Save Session Key\" to finish'**
  String get lastfmSteps;

  /// No description provided for @lastfmApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get lastfmApiKey;

  /// No description provided for @lastfmApiSecret.
  ///
  /// In en, this message translates to:
  /// **'API Secret'**
  String get lastfmApiSecret;

  /// No description provided for @lastfmStartAuth.
  ///
  /// In en, this message translates to:
  /// **'1. Start Auth'**
  String get lastfmStartAuth;

  /// No description provided for @lastfmGetSession.
  ///
  /// In en, this message translates to:
  /// **'2. Get & Save Session Key'**
  String get lastfmGetSession;

  /// No description provided for @lastfmRemoveKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove Keys'**
  String get lastfmRemoveKeys;

  /// No description provided for @lastfmStartAuthFirst.
  ///
  /// In en, this message translates to:
  /// **'Start Auth first, then approve in browser.'**
  String get lastfmStartAuthFirst;

  /// No description provided for @localSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Tracks'**
  String get localSettingTitle;

  /// No description provided for @localSettingAutoScan.
  ///
  /// In en, this message translates to:
  /// **'Auto Scan on Startup'**
  String get localSettingAutoScan;

  /// No description provided for @localSettingAutoScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically scan for new local tracks when the app starts.'**
  String get localSettingAutoScanSubtitle;

  /// No description provided for @localSettingLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last Scan'**
  String get localSettingLastScan;

  /// No description provided for @localSettingNeverScanned.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get localSettingNeverScanned;

  /// No description provided for @localSettingScanInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning in progress…'**
  String get localSettingScanInProgress;

  /// No description provided for @localSettingScanNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manually trigger a full library scan.'**
  String get localSettingScanNowSubtitle;

  /// No description provided for @localSettingNoFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders added. Add a folder to start scanning.'**
  String get localSettingNoFolders;

  /// No description provided for @localSettingAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add Folder'**
  String get localSettingAddFolder;

  /// No description provided for @playerSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Settings'**
  String get playerSettingTitle;

  /// No description provided for @playerSettingStreamingHeader.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get playerSettingStreamingHeader;

  /// No description provided for @playerSettingStreamQuality.
  ///
  /// In en, this message translates to:
  /// **'Streaming Quality'**
  String get playerSettingStreamQuality;

  /// No description provided for @playerSettingStreamQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Global audio bitrate for online playback.'**
  String get playerSettingStreamQualitySubtitle;

  /// No description provided for @playerSettingQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get playerSettingQualityLow;

  /// No description provided for @playerSettingQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get playerSettingQualityMedium;

  /// No description provided for @playerSettingQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get playerSettingQualityHigh;

  /// No description provided for @playerSettingPlaybackHeader.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playerSettingPlaybackHeader;

  /// No description provided for @playerSettingAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get playerSettingAutoPlay;

  /// No description provided for @playerSettingAutoPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enqueue similar songs when the queue ends.'**
  String get playerSettingAutoPlaySubtitle;

  /// No description provided for @playerSettingAutoFallback.
  ///
  /// In en, this message translates to:
  /// **'Auto Fallback Playback'**
  String get playerSettingAutoFallback;

  /// No description provided for @playerSettingAutoFallbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If a plugin is missing or returns no streams, try a compatible resolver for playback only.'**
  String get playerSettingAutoFallbackSubtitle;

  /// No description provided for @playerSettingCrossfade.
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get playerSettingCrossfade;

  /// No description provided for @playerSettingCrossfadeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playerSettingCrossfadeOff;

  /// No description provided for @playerSettingCrossfadeInstant.
  ///
  /// In en, this message translates to:
  /// **'Tracks switch instantly'**
  String get playerSettingCrossfadeInstant;

  /// No description provided for @playerSettingCrossfadeBlend.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s blend between tracks'**
  String playerSettingCrossfadeBlend(int seconds);

  /// No description provided for @playerSettingEqualizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get playerSettingEqualizer;

  /// No description provided for @playerSettingEqualizerActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get playerSettingEqualizerActive;

  /// No description provided for @playerSettingEqualizerActivePreset.
  ///
  /// In en, this message translates to:
  /// **'Enabled — {preset} preset'**
  String playerSettingEqualizerActivePreset(String preset);

  /// No description provided for @playerSettingEqualizerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10-band parametric EQ via FFmpeg.'**
  String get playerSettingEqualizerSubtitle;

  /// No description provided for @pluginDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugin Defaults'**
  String get pluginDefaultsTitle;

  /// No description provided for @pluginDefaultsDiscoverHeader.
  ///
  /// In en, this message translates to:
  /// **'Discover Source'**
  String get pluginDefaultsDiscoverHeader;

  /// No description provided for @pluginDefaultsNoResolver.
  ///
  /// In en, this message translates to:
  /// **'No content resolver loaded. Load a plugin to choose a Discover source.'**
  String get pluginDefaultsNoResolver;

  /// No description provided for @pluginDefaultsAutomaticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the first available content resolver.'**
  String get pluginDefaultsAutomaticSubtitle;

  /// No description provided for @pluginDefaultsPriorityHeader.
  ///
  /// In en, this message translates to:
  /// **'Resolver Priority'**
  String get pluginDefaultsPriorityHeader;

  /// No description provided for @pluginDefaultsNoPriority.
  ///
  /// In en, this message translates to:
  /// **'No content resolvers loaded. Priority ordering will appear here once plugins are loaded.'**
  String get pluginDefaultsNoPriority;

  /// No description provided for @pluginDefaultsPriorityDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Higher priority resolvers are tried first when resolving chart items or imported tracks to playable tracks.'**
  String get pluginDefaultsPriorityDesc;

  /// No description provided for @pluginDefaultsLyricsHeader.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Priority'**
  String get pluginDefaultsLyricsHeader;

  /// No description provided for @pluginDefaultsLyricsNone.
  ///
  /// In en, this message translates to:
  /// **'No lyrics providers loaded.'**
  String get pluginDefaultsLyricsNone;

  /// No description provided for @pluginDefaultsLyricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder lyrics providers. The first provider is tried first.'**
  String get pluginDefaultsLyricsDesc;

  /// No description provided for @pluginDefaultsSuggestionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Search Suggestions'**
  String get pluginDefaultsSuggestionsHeader;

  /// No description provided for @pluginDefaultsSuggestionsNone.
  ///
  /// In en, this message translates to:
  /// **'No suggestion providers loaded.'**
  String get pluginDefaultsSuggestionsNone;

  /// No description provided for @pluginDefaultsSuggestionsHistoryOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get pluginDefaultsSuggestionsHistoryOnlyTitle;

  /// No description provided for @pluginDefaultsSuggestionsHistoryOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use search history only.'**
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle;

  /// No description provided for @storageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageSettingTitle;

  /// No description provided for @storageClearHistoryEvery.
  ///
  /// In en, this message translates to:
  /// **'Clear History In Every'**
  String get storageClearHistoryEvery;

  /// No description provided for @storageClearHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear listening history after the chosen period.'**
  String get storageClearHistorySubtitle;

  /// No description provided for @storageDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Day} other{{count} Days}}'**
  String storageDays(int count);

  /// No description provided for @storageBackupLocation.
  ///
  /// In en, this message translates to:
  /// **'Backup Location'**
  String get storageBackupLocation;

  /// No description provided for @storageBackupLocationAndroid.
  ///
  /// In en, this message translates to:
  /// **'Downloads / app-data directory'**
  String get storageBackupLocationAndroid;

  /// No description provided for @storageBackupLocationDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads directory'**
  String get storageBackupLocationDownloads;

  /// No description provided for @storageCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get storageCreateBackup;

  /// No description provided for @storageCreateBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your settings and data to a backup file.'**
  String get storageCreateBackupSubtitle;

  /// No description provided for @storageBackupCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Backup created at {path}'**
  String storageBackupCreatedAt(String path);

  /// No description provided for @storageBackupShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share backup: {error}'**
  String storageBackupShareFailed(String error);

  /// No description provided for @storageBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed!'**
  String get storageBackupFailed;

  /// No description provided for @storageRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get storageRestoreBackup;

  /// No description provided for @storageRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your settings and data from a backup file.'**
  String get storageRestoreBackupSubtitle;

  /// No description provided for @storageAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get storageAutoBackup;

  /// No description provided for @storageAutoBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Periodically create a backup of your data automatically.'**
  String get storageAutoBackupSubtitle;

  /// No description provided for @storageAutoLyrics.
  ///
  /// In en, this message translates to:
  /// **'Auto Save Lyrics'**
  String get storageAutoLyrics;

  /// No description provided for @storageAutoLyricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save lyrics automatically when a song plays.'**
  String get storageAutoLyricsSubtitle;

  /// No description provided for @storageResetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset Bloomee App'**
  String get storageResetApp;

  /// No description provided for @storageResetAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data and restore the app to its default state.'**
  String get storageResetAppSubtitle;

  /// No description provided for @storageResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get storageResetConfirmTitle;

  /// No description provided for @storageResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset Bloomee? This will delete all your data and cannot be undone.'**
  String get storageResetConfirmMessage;

  /// No description provided for @storageResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get storageResetButton;

  /// No description provided for @storageResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App has been reset to its default state.'**
  String get storageResetSuccess;

  /// No description provided for @storageLocationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Location'**
  String get storageLocationDialogTitle;

  /// No description provided for @storageLocationAndroid.
  ///
  /// In en, this message translates to:
  /// **'Backups are stored in:\n\n1. Downloads directory\n2. Android/data/ls.bloomee.musicplayer/data\n\nCopy the file from either location.'**
  String get storageLocationAndroid;

  /// No description provided for @storageLocationOther.
  ///
  /// In en, this message translates to:
  /// **'Backups are stored in the Downloads directory. Copy the file from there.'**
  String get storageLocationOther;

  /// No description provided for @storageRestoreOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Options'**
  String get storageRestoreOptionsTitle;

  /// No description provided for @storageRestoreOptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which data you want to restore from the selected backup file. Unselect any items you do NOT want to be imported. By default all are selected.'**
  String get storageRestoreOptionsDesc;

  /// No description provided for @storageRestoreSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get storageRestoreSelectAll;

  /// No description provided for @storageRestoreMediaItems.
  ///
  /// In en, this message translates to:
  /// **'Media items (songs, tracks, library entries)'**
  String get storageRestoreMediaItems;

  /// No description provided for @storageRestoreSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get storageRestoreSearchHistory;

  /// No description provided for @storageRestoreContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get storageRestoreContinue;

  /// No description provided for @storageRestoreNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get storageRestoreNoFile;

  /// No description provided for @storageRestoreSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the selected file.'**
  String get storageRestoreSaveFailed;

  /// No description provided for @storageRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get storageRestoreConfirmTitle;

  /// No description provided for @storageRestoreConfirmPrefix.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite and merge the parts you selected in the app with data from the backup file:'**
  String get storageRestoreConfirmPrefix;

  /// No description provided for @storageRestoreConfirmSuffix.
  ///
  /// In en, this message translates to:
  /// **'Your current data will be modified/merged. Are you sure you want to proceed?'**
  String get storageRestoreConfirmSuffix;

  /// No description provided for @storageRestoreYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, restore'**
  String get storageRestoreYes;

  /// No description provided for @storageRestoreNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get storageRestoreNo;

  /// No description provided for @storageRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring selected data…\nPlease wait until the operation completes.'**
  String get storageRestoring;

  /// No description provided for @storageRestoreMediaBullet.
  ///
  /// In en, this message translates to:
  /// **'• Media items'**
  String get storageRestoreMediaBullet;

  /// No description provided for @storageRestoreHistoryBullet.
  ///
  /// In en, this message translates to:
  /// **'• Search history'**
  String get storageRestoreHistoryBullet;

  /// No description provided for @storageUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while restoring.'**
  String get storageUnexpectedError;

  /// No description provided for @storageRestoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Restore Completed'**
  String get storageRestoreCompleted;

  /// No description provided for @storageRestoreFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get storageRestoreFailedTitle;

  /// No description provided for @storageRestoreSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected data was restored successfully. For best results, please restart the app now.'**
  String get storageRestoreSuccessMessage;

  /// No description provided for @storageRestoreFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The restore process failed with the following errors:'**
  String get storageRestoreFailedMessage;

  /// No description provided for @storageRestoreUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred during restore.'**
  String get storageRestoreUnknownError;

  /// No description provided for @storageRestoreRestartHint.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app for better consistency.'**
  String get storageRestoreRestartHint;

  /// No description provided for @updateSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updateSettingTitle;

  /// No description provided for @updateAppUpdatesHeader.
  ///
  /// In en, this message translates to:
  /// **'App Updates'**
  String get updateAppUpdatesHeader;

  /// No description provided for @updateCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get updateCheckForUpdates;

  /// No description provided for @updateCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See if a newer version of Bloomee is available.'**
  String get updateCheckSubtitle;

  /// No description provided for @updateAutoNotify.
  ///
  /// In en, this message translates to:
  /// **'Auto Update Notify'**
  String get updateAutoNotify;

  /// No description provided for @updateAutoNotifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when new updates are available on app start.'**
  String get updateAutoNotifySubtitle;

  /// No description provided for @updateCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get updateCheckTitle;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Bloomee🌸 is up-to-date!!!'**
  String get updateUpToDate;

  /// No description provided for @updateViewPreRelease.
  ///
  /// In en, this message translates to:
  /// **'View Latest Pre-Release'**
  String get updateViewPreRelease;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version: {curr} + {build}'**
  String updateCurrentVersion(String curr, String build);

  /// No description provided for @updateNewVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Version of Bloomee🌸 is now available!!'**
  String get updateNewVersionAvailable;

  /// No description provided for @updateVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {ver}+{build}'**
  String updateVersion(String ver, String build);

  /// No description provided for @updateDownloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download Now'**
  String get updateDownloadNow;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking if newer version are available or not!'**
  String get updateChecking;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get timerTitle;

  /// No description provided for @timerInterludeMessage.
  ///
  /// In en, this message translates to:
  /// **'Preparing for a peaceful interlude in…'**
  String get timerInterludeMessage;

  /// No description provided for @timerHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get timerHours;

  /// No description provided for @timerMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get timerMinutes;

  /// No description provided for @timerSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get timerSeconds;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop Timer'**
  String get timerStop;

  /// No description provided for @timerFinishedMessage.
  ///
  /// In en, this message translates to:
  /// **'The tunes have rested. Sweet Dreams 🥰.'**
  String get timerFinishedMessage;

  /// No description provided for @timerGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get timerGotIt;

  /// No description provided for @timerSetTimeError.
  ///
  /// In en, this message translates to:
  /// **'Please set a time'**
  String get timerSetTimeError;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get timerStart;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Notifications yet!'**
  String get notificationsEmpty;

  /// No description provided for @recentsTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get recentsTitle;

  /// No description provided for @playlistByCreator.
  ///
  /// In en, this message translates to:
  /// **'by {creator}'**
  String playlistByCreator(String creator);

  /// No description provided for @playlistTypeAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get playlistTypeAlbum;

  /// No description provided for @playlistTypePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistTypePlaylist;

  /// No description provided for @playlistYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get playlistYou;

  /// No description provided for @pluginManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get pluginManagerTitle;

  /// No description provided for @pluginManagerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed.\nTap + to add a .bex file.'**
  String get pluginManagerEmpty;

  /// No description provided for @pluginManagerFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pluginManagerFilterAll;

  /// No description provided for @pluginManagerFilterContent.
  ///
  /// In en, this message translates to:
  /// **'Content Resolvers'**
  String get pluginManagerFilterContent;

  /// No description provided for @pluginManagerFilterCharts.
  ///
  /// In en, this message translates to:
  /// **'Chart Providers'**
  String get pluginManagerFilterCharts;

  /// No description provided for @pluginManagerFilterLyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Providers'**
  String get pluginManagerFilterLyrics;

  /// No description provided for @pluginManagerFilterSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Providers'**
  String get pluginManagerFilterSuggestions;

  /// No description provided for @pluginManagerFilterImporters.
  ///
  /// In en, this message translates to:
  /// **'Content Importers'**
  String get pluginManagerFilterImporters;

  /// No description provided for @pluginManagerTooltipRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get pluginManagerTooltipRefresh;

  /// No description provided for @pluginManagerTooltipInstall.
  ///
  /// In en, this message translates to:
  /// **'Install Plugin'**
  String get pluginManagerTooltipInstall;

  /// No description provided for @pluginManagerNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No plugins match this filter'**
  String get pluginManagerNoMatch;

  /// No description provided for @pluginManagerPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file: {error}'**
  String pluginManagerPickFailed(String error);

  /// No description provided for @pluginManagerInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing plugin...'**
  String get pluginManagerInstalling;

  /// No description provided for @pluginManagerTypeContentResolver.
  ///
  /// In en, this message translates to:
  /// **'Content Resolver'**
  String get pluginManagerTypeContentResolver;

  /// No description provided for @pluginManagerTypeChartProvider.
  ///
  /// In en, this message translates to:
  /// **'Chart Provider'**
  String get pluginManagerTypeChartProvider;

  /// No description provided for @pluginManagerTypeLyricsProvider.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Provider'**
  String get pluginManagerTypeLyricsProvider;

  /// No description provided for @pluginManagerTypeSuggestionProvider.
  ///
  /// In en, this message translates to:
  /// **'Search Suggestions'**
  String get pluginManagerTypeSuggestionProvider;

  /// No description provided for @pluginManagerTypeContentImporter.
  ///
  /// In en, this message translates to:
  /// **'Content Importer'**
  String get pluginManagerTypeContentImporter;

  /// No description provided for @pluginManagerDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plugin?'**
  String get pluginManagerDeleteTitle;

  /// No description provided for @pluginManagerDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This will permanently remove its files.'**
  String pluginManagerDeleteMessage(String name);

  /// No description provided for @pluginManagerDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pluginManagerDeleteAction;

  /// No description provided for @pluginManagerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pluginManagerCancel;

  /// No description provided for @pluginManagerEnablePlugin.
  ///
  /// In en, this message translates to:
  /// **'Enable Plugin'**
  String get pluginManagerEnablePlugin;

  /// No description provided for @pluginManagerUnloadPlugin.
  ///
  /// In en, this message translates to:
  /// **'Unload Plugin'**
  String get pluginManagerUnloadPlugin;

  /// No description provided for @pluginManagerDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get pluginManagerDeleting;

  /// No description provided for @pluginManagerApiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'API Keys'**
  String get pluginManagerApiKeysTitle;

  /// No description provided for @pluginManagerApiKeysSaved.
  ///
  /// In en, this message translates to:
  /// **'API keys saved'**
  String get pluginManagerApiKeysSaved;

  /// No description provided for @pluginManagerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pluginManagerSave;

  /// No description provided for @pluginManagerDetailVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get pluginManagerDetailVersion;

  /// No description provided for @pluginManagerDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pluginManagerDetailType;

  /// No description provided for @pluginManagerDetailPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get pluginManagerDetailPublisher;

  /// No description provided for @pluginManagerDetailLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get pluginManagerDetailLastUpdated;

  /// No description provided for @pluginManagerDetailCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get pluginManagerDetailCreated;

  /// No description provided for @pluginManagerDetailHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get pluginManagerDetailHomepage;

  /// No description provided for @pluginManagerDowngradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Downgrade Plugin?'**
  String get pluginManagerDowngradeTitle;

  /// No description provided for @pluginManagerDowngradeMessage.
  ///
  /// In en, this message translates to:
  /// **'You are installing an older or equal version of \"{name}\". Continue?'**
  String pluginManagerDowngradeMessage(String name);

  /// No description provided for @pluginManagerDowngradeAction.
  ///
  /// In en, this message translates to:
  /// **'Install Anyway'**
  String get pluginManagerDowngradeAction;

  /// No description provided for @pluginManagerDeleteStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plugin Data?'**
  String get pluginManagerDeleteStorageTitle;

  /// No description provided for @pluginManagerDeleteStorageMessage.
  ///
  /// In en, this message translates to:
  /// **'Also remove saved API keys and settings for \"{name}\"?'**
  String pluginManagerDeleteStorageMessage(String name);

  /// No description provided for @pluginManagerDeleteStorageKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep Data'**
  String get pluginManagerDeleteStorageKeep;

  /// No description provided for @pluginManagerDeleteStorageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Data'**
  String get pluginManagerDeleteStorageRemove;

  /// No description provided for @segmentsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Segments'**
  String get segmentsSheetTitle;

  /// No description provided for @segmentsSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No segments available'**
  String get segmentsSheetEmpty;

  /// No description provided for @segmentsSheetUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled Segment'**
  String get segmentsSheetUntitled;

  /// No description provided for @smartReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Replace'**
  String get smartReplaceTitle;

  /// No description provided for @smartReplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a playable replacement for \"{title}\" and update saved playlist references.'**
  String smartReplaceSubtitle(String title);

  /// No description provided for @smartReplaceClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get smartReplaceClose;

  /// No description provided for @smartReplaceNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No replacement found'**
  String get smartReplaceNoMatch;

  /// No description provided for @smartReplaceNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'None of the loaded resolver plugins returned a strong enough match.'**
  String get smartReplaceNoMatchSubtitle;

  /// No description provided for @smartReplaceBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get smartReplaceBestMatch;

  /// No description provided for @smartReplaceSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get smartReplaceSearchFailed;

  /// No description provided for @smartReplaceApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Smart Replace failed: {error}'**
  String smartReplaceApplyFailed(String error);

  /// No description provided for @smartReplaceApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied replacement{queue}.'**
  String smartReplaceApplied(String queue);

  /// No description provided for @smartReplaceAppliedPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Replaced in {count} playlist{plural}{queue}.'**
  String smartReplaceAppliedPlaylists(int count, String plural, String queue);

  /// No description provided for @smartReplaceQueueUpdated.
  ///
  /// In en, this message translates to:
  /// **' and updated the queue'**
  String get smartReplaceQueueUpdated;

  /// No description provided for @playerUnknownQueue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get playerUnknownQueue;

  /// No description provided for @playerLiked.
  ///
  /// In en, this message translates to:
  /// **'{title} Liked!!'**
  String playerLiked(String title);

  /// No description provided for @playerUnliked.
  ///
  /// In en, this message translates to:
  /// **'{title} Unliked!!'**
  String playerUnliked(String title);

  /// No description provided for @offlineNoDownloads.
  ///
  /// In en, this message translates to:
  /// **'No Downloads'**
  String get offlineNoDownloads;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTitle;

  /// No description provided for @offlineSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your songs...'**
  String get offlineSearchHint;

  /// No description provided for @offlineRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Downloads'**
  String get offlineRefreshTooltip;

  /// No description provided for @offlineCloseSearch.
  ///
  /// In en, this message translates to:
  /// **'Close Search'**
  String get offlineCloseSearch;

  /// No description provided for @offlineSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get offlineSearchTooltip;

  /// No description provided for @offlineOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this offline track. Try refreshing downloads.'**
  String get offlineOpenFailed;

  /// No description provided for @offlinePlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play this offline song. Please try again.'**
  String get offlinePlayFailed;

  /// No description provided for @albumViewTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Track} other{{count} Tracks}}'**
  String albumViewTrackCount(int count);

  /// No description provided for @albumViewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load album'**
  String get albumViewLoadFailed;

  /// No description provided for @aboutCraftingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Crafting symphonies in code.'**
  String get aboutCraftingSubtitle;

  /// No description provided for @aboutFollowGitHub.
  ///
  /// In en, this message translates to:
  /// **'Follow him on GitHub'**
  String get aboutFollowGitHub;

  /// No description provided for @aboutSendInquiry.
  ///
  /// In en, this message translates to:
  /// **'Send a business inquiry'**
  String get aboutSendInquiry;

  /// No description provided for @aboutCreativeHighlights.
  ///
  /// In en, this message translates to:
  /// **'Updates and creative highlights'**
  String get aboutCreativeHighlights;

  /// No description provided for @aboutTipQuote.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Bloomee? A small tip keeps it blooming. 🌸'**
  String get aboutTipQuote;

  /// No description provided for @aboutTipButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help'**
  String get aboutTipButton;

  /// No description provided for @aboutTipDesc.
  ///
  /// In en, this message translates to:
  /// **'I want Bloomee to keep improving.'**
  String get aboutTipDesc;

  /// No description provided for @aboutGitHub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get aboutGitHub;

  /// No description provided for @songInfoSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Song Details'**
  String get songInfoSectionDetails;

  /// No description provided for @songInfoSectionTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical Info'**
  String get songInfoSectionTechnical;

  /// No description provided for @songInfoSectionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get songInfoSectionActions;

  /// No description provided for @songInfoLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get songInfoLabelTitle;

  /// No description provided for @songInfoLabelArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get songInfoLabelArtist;

  /// No description provided for @songInfoLabelAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get songInfoLabelAlbum;

  /// No description provided for @songInfoLabelDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get songInfoLabelDuration;

  /// No description provided for @songInfoLabelSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get songInfoLabelSource;

  /// No description provided for @songInfoLabelMediaId.
  ///
  /// In en, this message translates to:
  /// **'Media ID'**
  String get songInfoLabelMediaId;

  /// No description provided for @songInfoLabelPluginId.
  ///
  /// In en, this message translates to:
  /// **'Plugin ID'**
  String get songInfoLabelPluginId;

  /// No description provided for @songInfoIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Media ID copied'**
  String get songInfoIdCopied;

  /// No description provided for @songInfoLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get songInfoLinkCopied;

  /// No description provided for @songInfoNoLink.
  ///
  /// In en, this message translates to:
  /// **'No link available'**
  String get songInfoNoLink;

  /// No description provided for @songInfoOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get songInfoOpenFailed;

  /// No description provided for @songInfoUpdateMetadata.
  ///
  /// In en, this message translates to:
  /// **'Get latest metadata'**
  String get songInfoUpdateMetadata;

  /// No description provided for @songInfoMetadataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Metadata updated'**
  String get songInfoMetadataUpdated;

  /// No description provided for @songInfoMetadataUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update metadata'**
  String get songInfoMetadataUpdateFailed;

  /// No description provided for @songInfoMetadataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Metadata refresh is unavailable for this source'**
  String get songInfoMetadataUnavailable;

  /// No description provided for @songInfoSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for this song in Bloomee'**
  String get songInfoSearchTitle;

  /// No description provided for @songInfoSearchArtist.
  ///
  /// In en, this message translates to:
  /// **'Search for this artist in Bloomee'**
  String get songInfoSearchArtist;

  /// No description provided for @songInfoSearchAlbum.
  ///
  /// In en, this message translates to:
  /// **'Search for this album in Bloomee'**
  String get songInfoSearchAlbum;

  /// No description provided for @eqTitle.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get eqTitle;

  /// No description provided for @eqResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset to Flat'**
  String get eqResetTooltip;

  /// No description provided for @chartNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items in this chart'**
  String get chartNoItems;

  /// No description provided for @chartLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chart'**
  String get chartLoadFailed;

  /// No description provided for @chartPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get chartPlay;

  /// No description provided for @chartResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving'**
  String get chartResolving;

  /// No description provided for @chartReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get chartReady;

  /// No description provided for @chartAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get chartAddToPlaylist;

  /// No description provided for @chartNoResolver.
  ///
  /// In en, this message translates to:
  /// **'No content resolver loaded. Install a plugin to play.'**
  String get chartNoResolver;

  /// No description provided for @chartResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve. Searching instead...'**
  String get chartResolveFailed;

  /// No description provided for @chartNoResolverAdd.
  ///
  /// In en, this message translates to:
  /// **'No content resolver loaded.'**
  String get chartNoResolverAdd;

  /// No description provided for @chartNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Could not find a match. Try searching manually.'**
  String get chartNoMatch;

  /// No description provided for @chartStatPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get chartStatPeak;

  /// No description provided for @chartStatWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get chartStatWeeks;

  /// No description provided for @chartStatChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get chartStatChange;

  /// No description provided for @menuSharePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing {title} for share.'**
  String menuSharePreparing(String title);

  /// No description provided for @menuOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get menuOpenLinkFailed;

  /// No description provided for @localMusicFolders.
  ///
  /// In en, this message translates to:
  /// **'Music Folders'**
  String get localMusicFolders;

  /// No description provided for @localMusicCloseSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get localMusicCloseSearch;

  /// No description provided for @localMusicOpenSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get localMusicOpenSearch;

  /// No description provided for @localMusicNoMusicFound.
  ///
  /// In en, this message translates to:
  /// **'No local music found'**
  String get localMusicNoMusicFound;

  /// No description provided for @localMusicNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No tracks found matching your search.'**
  String get localMusicNoSearchResults;

  /// No description provided for @importSongsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Songs'**
  String get importSongsTitle;

  /// No description provided for @importNoPluginsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No content-importer plugins loaded.\nInstall an importer plugin to import playlists from external services.'**
  String get importNoPluginsLoaded;

  /// No description provided for @importBloomeeFiles.
  ///
  /// In en, this message translates to:
  /// **'Import Bloomee Files'**
  String get importBloomeeFiles;

  /// No description provided for @importM3UFiles.
  ///
  /// In en, this message translates to:
  /// **'Import M3U Playlist'**
  String get importM3UFiles;

  /// No description provided for @importM3UNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Name'**
  String get importM3UNameDialogTitle;

  /// No description provided for @importM3UNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this playlist'**
  String get importM3UNameHint;

  /// No description provided for @importM3UNoTracks.
  ///
  /// In en, this message translates to:
  /// **'No valid tracks found in the M3U file.'**
  String get importM3UNoTracks;

  /// No description provided for @importNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get importNoteTitle;

  /// No description provided for @importNoteMessage.
  ///
  /// In en, this message translates to:
  /// **'You can only import files created by Bloomee.\nIf your file is from another source, it will not work. Continue anyway?'**
  String get importNoteMessage;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importCheckingUrl.
  ///
  /// In en, this message translates to:
  /// **'Checking URL...'**
  String get importCheckingUrl;

  /// No description provided for @importFetchingTracks.
  ///
  /// In en, this message translates to:
  /// **'Fetching tracks...'**
  String get importFetchingTracks;

  /// No description provided for @importSavingToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Saving to library...'**
  String get importSavingToLibrary;

  /// No description provided for @importPasteUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a playlist or album URL to import'**
  String get importPasteUrlHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @importTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks'**
  String importTrackCount(int count);

  /// No description provided for @importResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving...'**
  String get importResolving;

  /// No description provided for @importResolvingProgress.
  ///
  /// In en, this message translates to:
  /// **'Resolving tracks: {done} / {total}'**
  String importResolvingProgress(int done, int total);

  /// No description provided for @importReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Review'**
  String get importReviewTitle;

  /// No description provided for @importReviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{resolved} resolved, {failed} failed out of {total}'**
  String importReviewSummary(int resolved, int failed, int total);

  /// No description provided for @importSaveTracks.
  ///
  /// In en, this message translates to:
  /// **'Save {count} Tracks'**
  String importSaveTracks(int count);

  /// No description provided for @importTracksSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks saved!'**
  String importTracksSaved(int count);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get importDone;

  /// No description provided for @importMore.
  ///
  /// In en, this message translates to:
  /// **'Import More'**
  String get importMore;

  /// No description provided for @importUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get importUnknownError;

  /// No description provided for @importTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get importTryAgain;

  /// No description provided for @importSkipTrack.
  ///
  /// In en, this message translates to:
  /// **'Skip this track'**
  String get importSkipTrack;

  /// No description provided for @importMatchOptions.
  ///
  /// In en, this message translates to:
  /// **'Match options'**
  String get importMatchOptions;

  /// No description provided for @importAutoMatched.
  ///
  /// In en, this message translates to:
  /// **'Auto-matched'**
  String get importAutoMatched;

  /// No description provided for @importUserSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get importUserSelected;

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get importSkipped;

  /// No description provided for @importNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No match found'**
  String get importNoMatch;

  /// No description provided for @importReorderTip.
  ///
  /// In en, this message translates to:
  /// **'Long press a playlist to start reordering'**
  String get importReorderTip;

  /// No description provided for @importErrorCannotHandleUrl.
  ///
  /// In en, this message translates to:
  /// **'This plugin cannot handle the provided URL.'**
  String get importErrorCannotHandleUrl;

  /// No description provided for @importErrorUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from plugin.'**
  String get importErrorUnexpectedResponse;

  /// No description provided for @importErrorFailedToCheck.
  ///
  /// In en, this message translates to:
  /// **'Failed to check URL: {error}'**
  String importErrorFailedToCheck(String error);

  /// No description provided for @importErrorFailedToFetchInfo.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch collection info: {error}'**
  String importErrorFailedToFetchInfo(String error);

  /// No description provided for @importErrorFailedToFetchTracks.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch tracks: {error}'**
  String importErrorFailedToFetchTracks(String error);

  /// No description provided for @importErrorFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save playlist: {error}'**
  String importErrorFailedToSave(String error);

  /// No description provided for @playlistPinToTop.
  ///
  /// In en, this message translates to:
  /// **'Pin to Top'**
  String get playlistPinToTop;

  /// No description provided for @playlistUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get playlistUnpin;

  /// No description provided for @snackbarImportingMedia.
  ///
  /// In en, this message translates to:
  /// **'Importing MediaItems..'**
  String get snackbarImportingMedia;

  /// No description provided for @snackbarPlaylistSaved.
  ///
  /// In en, this message translates to:
  /// **'Playlist saved to library!'**
  String get snackbarPlaylistSaved;

  /// No description provided for @snackbarInvalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid File Format'**
  String get snackbarInvalidFileFormat;

  /// No description provided for @snackbarMediaItemImported.
  ///
  /// In en, this message translates to:
  /// **'Media Item Imported'**
  String get snackbarMediaItemImported;

  /// No description provided for @snackbarPlaylistImported.
  ///
  /// In en, this message translates to:
  /// **'Playlist Imported'**
  String get snackbarPlaylistImported;

  /// No description provided for @snackbarOpenImportForUrl.
  ///
  /// In en, this message translates to:
  /// **'Open the Import screen in Library to import from this URL.'**
  String get snackbarOpenImportForUrl;

  /// No description provided for @snackbarProcessingFile.
  ///
  /// In en, this message translates to:
  /// **'Processing File...'**
  String get snackbarProcessingFile;

  /// No description provided for @snackbarPreparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing {title} for share'**
  String snackbarPreparingShare(String title);

  /// No description provided for @snackbarPreparingExport.
  ///
  /// In en, this message translates to:
  /// **'Preparing {title} for export.'**
  String snackbarPreparingExport(String title);

  /// No description provided for @pluginManagerTabInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get pluginManagerTabInstalled;

  /// No description provided for @pluginManagerTabStore.
  ///
  /// In en, this message translates to:
  /// **'Plugin Store'**
  String get pluginManagerTabStore;

  /// No description provided for @pluginManagerSelectPackage.
  ///
  /// In en, this message translates to:
  /// **'Select Plugin Package (.bex)'**
  String get pluginManagerSelectPackage;

  /// No description provided for @pluginManagerOutdatedManifest.
  ///
  /// In en, this message translates to:
  /// **'Plugin uses an outdated manifest version. Some features might break. Consider updating.'**
  String get pluginManagerOutdatedManifest;

  /// No description provided for @pluginManagerStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get pluginManagerStatusActive;

  /// No description provided for @pluginManagerStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get pluginManagerStatusInactive;

  /// No description provided for @pluginRepositoryUpdatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String pluginRepositoryUpdatedOn(String date);

  /// No description provided for @pluginRepositoryAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plugin available} other{{count} plugins available}}'**
  String pluginRepositoryAvailableCount(int count);

  /// No description provided for @pluginRepositoryOutdatedManifest.
  ///
  /// In en, this message translates to:
  /// **'Outdated manifest. Features may break.'**
  String get pluginRepositoryOutdatedManifest;

  /// No description provided for @pluginRepositoryUnknownPublisher.
  ///
  /// In en, this message translates to:
  /// **'Unknown publisher'**
  String get pluginRepositoryUnknownPublisher;

  /// No description provided for @pluginRepositoryActionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pluginRepositoryActionRetry;

  /// No description provided for @pluginRepositoryActionOutdated.
  ///
  /// In en, this message translates to:
  /// **'Outdated'**
  String get pluginRepositoryActionOutdated;

  /// No description provided for @pluginRepositoryActionInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get pluginRepositoryActionInstalled;

  /// No description provided for @pluginRepositoryActionInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get pluginRepositoryActionInstall;

  /// No description provided for @pluginRepositoryActionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get pluginRepositoryActionUnavailable;

  /// No description provided for @pluginRepositoryInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed.'**
  String get pluginRepositoryInstallFailed;

  /// No description provided for @pluginRepositoryDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download {name}.'**
  String pluginRepositoryDownloadFailed(String name);

  /// No description provided for @smartReplaceAppliedPlaylistsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Replaced in 1 playlist{queue}.} other{Replaced in {count} playlists{queue}.}}'**
  String smartReplaceAppliedPlaylistsSummary(int count, String queue);

  /// No description provided for @lyricsSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search for lyrics...'**
  String get lyricsSearchFieldLabel;

  /// No description provided for @lyricsSearchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a song or artist to find lyrics.'**
  String get lyricsSearchEmptyPrompt;

  /// No description provided for @lyricsSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No lyrics found for \"{query}\"'**
  String lyricsSearchNoResults(String query);

  /// No description provided for @lyricsSearchApplied.
  ///
  /// In en, this message translates to:
  /// **'Lyrics successfully applied'**
  String get lyricsSearchApplied;

  /// No description provided for @lyricsSearchFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch lyrics'**
  String get lyricsSearchFetchFailed;

  /// No description provided for @lyricsSearchPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get lyricsSearchPreview;

  /// No description provided for @lyricsSearchPreviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview lyrics'**
  String get lyricsSearchPreviewTooltip;

  /// No description provided for @lyricsSearchSynced.
  ///
  /// In en, this message translates to:
  /// **'SYNCED'**
  String get lyricsSearchSynced;

  /// No description provided for @lyricsSearchPreviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lyrics.'**
  String get lyricsSearchPreviewLoadFailed;

  /// No description provided for @lyricsSearchApplyAction.
  ///
  /// In en, this message translates to:
  /// **'Apply Lyrics'**
  String get lyricsSearchApplyAction;

  /// No description provided for @lyricsSettingsSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Custom Lyrics'**
  String get lyricsSettingsSearchTitle;

  /// No description provided for @lyricsSettingsSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find alternative versions online'**
  String get lyricsSettingsSearchSubtitle;

  /// No description provided for @lyricsSettingsSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Sync (Delay/Offset)'**
  String get lyricsSettingsSyncTitle;

  /// No description provided for @lyricsSettingsSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fix lyrics that are too fast or slow'**
  String get lyricsSettingsSyncSubtitle;

  /// No description provided for @lyricsSettingsSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Offline'**
  String get lyricsSettingsSaveTitle;

  /// No description provided for @lyricsSettingsSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store these lyrics on your device'**
  String get lyricsSettingsSaveSubtitle;

  /// No description provided for @lyricsSettingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Lyrics'**
  String get lyricsSettingsDeleteTitle;

  /// No description provided for @lyricsSettingsDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove offline lyrics data'**
  String get lyricsSettingsDeleteSubtitle;

  /// No description provided for @lyricsSyncTapToReset.
  ///
  /// In en, this message translates to:
  /// **'Tap to reset'**
  String get lyricsSyncTapToReset;

  /// No description provided for @upNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNextTitle;

  /// No description provided for @upNextItemsInQueue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item in queue} other{{count} items in queue}}'**
  String upNextItemsInQueue(int count);

  /// No description provided for @upNextAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get upNextAutoPlay;

  /// No description provided for @tooltipCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get tooltipCopyToClipboard;

  /// No description provided for @snackbarCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get snackbarCopiedToClipboard;

  /// No description provided for @tooltipSongInfo.
  ///
  /// In en, this message translates to:
  /// **'Song Info'**
  String get tooltipSongInfo;

  /// No description provided for @snackbarCannotDeletePlayingSong.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete currently playing song'**
  String get snackbarCannotDeletePlayingSong;

  /// No description provided for @playerLoopOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playerLoopOff;

  /// No description provided for @playerLoopOne.
  ///
  /// In en, this message translates to:
  /// **'Loop One'**
  String get playerLoopOne;

  /// No description provided for @playerLoopAll.
  ///
  /// In en, this message translates to:
  /// **'Loop All'**
  String get playerLoopAll;

  /// No description provided for @snackbarOpeningAlbumPage.
  ///
  /// In en, this message translates to:
  /// **'Opening original album page.'**
  String get snackbarOpeningAlbumPage;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'New Version of Bloomee🌸 is now available!\n\nVersion: {ver}+{build}'**
  String updateAvailableBody(String ver, String build);

  /// No description provided for @pluginSnackbarInstalled.
  ///
  /// In en, this message translates to:
  /// **'Plugin \"{id}\" installed successfully'**
  String pluginSnackbarInstalled(String id);

  /// No description provided for @pluginSnackbarLoaded.
  ///
  /// In en, this message translates to:
  /// **'Plugin \"{id}\" loaded'**
  String pluginSnackbarLoaded(String id);

  /// No description provided for @pluginSnackbarDeleted.
  ///
  /// In en, this message translates to:
  /// **'Plugin \"{id}\" deleted successfully'**
  String pluginSnackbarDeleted(String id);

  /// No description provided for @pluginBootstrapTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting up Bloomee'**
  String get pluginBootstrapTitle;

  /// No description provided for @pluginBootstrapProgress.
  ///
  /// In en, this message translates to:
  /// **'Setting up new plugin engine... {percent}%'**
  String pluginBootstrapProgress(int percent);

  /// No description provided for @pluginBootstrapHint.
  ///
  /// In en, this message translates to:
  /// **'This only happens once.'**
  String get pluginBootstrapHint;

  /// No description provided for @pluginBootstrapErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection too slow'**
  String get pluginBootstrapErrorTitle;

  /// No description provided for @pluginBootstrapErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Some plugins could not be installed. You can still use Bloomee — plugins will be retried on next launch.'**
  String get pluginBootstrapErrorBody;

  /// No description provided for @pluginBootstrapContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get pluginBootstrapContinue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
