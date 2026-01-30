// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to Bloomee';

  @override
  String get onboardingSubtitle =>
      'Your ad-free music journey begins here. Customize your experience.';

  @override
  String get country => 'Country';

  @override
  String get language => 'Language';

  @override
  String get getStarted => 'Get Started';

  @override
  String get settings => 'Settings';

  @override
  String get discover => 'Discover';

  @override
  String get history => 'History';

  @override
  String get library => 'Library';

  @override
  String get explore => 'Explore';

  @override
  String get search => 'Search';

  @override
  String get offline => 'Offline';

  @override
  String get searchHint => 'Find your next song obsession...';

  @override
  String get songs => 'Songs';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artists';

  @override
  String get playlists => 'Playlists';

  @override
  String get recently => 'Recently';

  @override
  String get lastFmPicks => 'Last.Fm Picks';

  @override
  String get noInternet => 'No Internet Connection!';

  @override
  String get enjoyingFrom => 'Enjoying From';

  @override
  String get unknown => 'Unknown';

  @override
  String get availableOffline => 'Available Offline';

  @override
  String get timer => 'Timer';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get loop => 'Loop';

  @override
  String get off => 'Off';

  @override
  String get loopOne => 'Loop One';

  @override
  String get loopAll => 'Loop All';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get openOriginalLink => 'Open Original Link';

  @override
  String get unableToOpenLink => 'Unable to open the link';

  @override
  String get updates => 'Updates';

  @override
  String get checkUpdates => 'Check for new updates';

  @override
  String get downloads => 'Downloads';

  @override
  String get downloadsSubtitle => 'Download Path, Download Quality and more...';

  @override
  String get playerSettings => 'Player Settings';

  @override
  String get playerSettingsSubtitle => 'Stream quality, Auto Play, etc.';

  @override
  String get uiSettings => 'UI Elements & Services';

  @override
  String get uiSettingsSubtitle => 'Auto slide, Source Engines etc.';

  @override
  String get lastFmSettings => 'Last.FM Settings';

  @override
  String get lastFmSettingsSubtitle =>
      'API Key, Secret, and Scrobbling settings.';

  @override
  String get storage => 'Storage';

  @override
  String get storageSubtitle => 'Backup, Cache, History, Restore and more...';

  @override
  String get languageCountry => 'Language & Country';

  @override
  String get languageCountrySubtitle => 'Select your language and country.';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'About the app, version, developer, etc.';

  @override
  String get searchLibrary => 'Search library...';

  @override
  String get emptyLibraryMessage =>
      'Your library is feeling lonely. Add some tunes to brighten it up!';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String inPlaylist(String playlistName) {
    return 'in $playlistName';
  }

  @override
  String artistWithEngine(String engine) {
    return 'Artist - $engine';
  }

  @override
  String albumWithEngine(String engine) {
    return 'Album - $engine';
  }

  @override
  String playlistWithEngine(String engine) {
    return 'Playlist - $engine';
  }

  @override
  String get noDownloads => 'No Downloads';

  @override
  String get searchSongs => 'Search your songs...';

  @override
  String get refreshDownloads => 'Refresh Downloads';

  @override
  String get closeSearch => 'Close Search';

  @override
  String get aboutTagline => 'Crafting symphonies in code.';

  @override
  String get maintainer => 'Maintainer';

  @override
  String get followGithub => 'Follow him on GitHub';

  @override
  String get contact => 'Contact';

  @override
  String get contactTooltip => 'Send a business inquiry';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip => 'Updates and creative highlights';

  @override
  String get supportMessage =>
      '\"Enjoying Bloomee? A small tip keeps it blooming.\" 🌸';

  @override
  String get supportButton => 'I\'ll help';

  @override
  String get supportFooter => 'I want Bloomee to keep improving.';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'Not able to retrieve version';

  @override
  String get home => 'Home';

  @override
  String get topSongs => 'Top Songs';

  @override
  String get topAlbums => 'Top Albums';

  @override
  String get viewLyrics => 'View Lyrics';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get startAuth => 'Start Auth';

  @override
  String get getSessionKey => 'Get & Save Session Key';

  @override
  String get removeKeys => 'Remove Keys';

  @override
  String get countryLangSettings => 'Country & Language Settings';

  @override
  String get autoCheckCountry => 'Auto check country';

  @override
  String get autoCheckCountrySubtitle =>
      'Automatically check the country to your location when you open the app.';

  @override
  String get countrySubtitle => 'Country to set as default for the app.';

  @override
  String get languageSubtitle => 'Primary language for the app UI.';

  @override
  String get scrobbleTracks => 'Scrobble Tracks';

  @override
  String get scrobbleTracksSubtitle => 'Scrobble tracks to Last.FM';

  @override
  String get firstAuthLastFM => 'First Authenticate Last.FM API.';

  @override
  String get lastFmInstructions =>
      'To set API Key for Last.FM, \n1. Go to Last.FM create an account there (https://www.last.fm/).\n2. Now generate an API Key and Secret from: https://www.last.fm/api/account/create\n3. Enter the API Key and Secret below and click on \'Start Auth\' to get the session key.\n4. After allowing from browser, click on \'Get and Save Session Key\' to save the session key.';

  @override
  String lastFmAuthenticated(String username) {
    return 'Hi, $username,\nLast.FM API is Authenticated.';
  }

  @override
  String get onboardingWelcome => 'Tailor your experience';

  @override
  String get confirmSettings =>
      'Please confirm your country and language to get started with content that fits you best.';

  @override
  String get detectedLabel => 'Detected';

  @override
  String lastFmAuthFailed(String message) {
    return 'Last.FM Authentication Failed.\n$message\nHint: First click Start Auth and Sign-In from browser then click Get & Save Session Key button';
  }
}
