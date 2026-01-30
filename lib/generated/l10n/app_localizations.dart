import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ru')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bloomee'**
  String get welcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ad-free music journey begins here. Customize your experience.'**
  String get onboardingSubtitle;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Find your next song obsession...'**
  String get searchHint;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @lastFmPicks.
  ///
  /// In en, this message translates to:
  /// **'Last.Fm Picks'**
  String get lastFmPicks;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection!'**
  String get noInternet;

  /// No description provided for @enjoyingFrom.
  ///
  /// In en, this message translates to:
  /// **'Enjoying From'**
  String get enjoyingFrom;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @availableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available Offline'**
  String get availableOffline;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loop;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @loopOne.
  ///
  /// In en, this message translates to:
  /// **'Loop One'**
  String get loopOne;

  /// No description provided for @loopAll.
  ///
  /// In en, this message translates to:
  /// **'Loop All'**
  String get loopAll;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @openOriginalLink.
  ///
  /// In en, this message translates to:
  /// **'Open Original Link'**
  String get openOriginalLink;

  /// No description provided for @unableToOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the link'**
  String get unableToOpenLink;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for new updates'**
  String get checkUpdates;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @downloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download Path, Download Quality and more...'**
  String get downloadsSubtitle;

  /// No description provided for @playerSettings.
  ///
  /// In en, this message translates to:
  /// **'Player Settings'**
  String get playerSettings;

  /// No description provided for @playerSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stream quality, Auto Play, etc.'**
  String get playerSettingsSubtitle;

  /// No description provided for @uiSettings.
  ///
  /// In en, this message translates to:
  /// **'UI Elements & Services'**
  String get uiSettings;

  /// No description provided for @uiSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto slide, Source Engines etc.'**
  String get uiSettingsSubtitle;

  /// No description provided for @lastFmSettings.
  ///
  /// In en, this message translates to:
  /// **'Last.FM Settings'**
  String get lastFmSettings;

  /// No description provided for @lastFmSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'API Key, Secret, and Scrobbling settings.'**
  String get lastFmSettingsSubtitle;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup, Cache, History, Restore and more...'**
  String get storageSubtitle;

  /// No description provided for @languageCountry.
  ///
  /// In en, this message translates to:
  /// **'Language & Country'**
  String get languageCountry;

  /// No description provided for @languageCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your language and country.'**
  String get languageCountrySubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About the app, version, developer, etc.'**
  String get aboutSubtitle;

  /// No description provided for @searchLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search library...'**
  String get searchLibrary;

  /// No description provided for @emptyLibraryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your library is feeling lonely. Add some tunes to brighten it up!'**
  String get emptyLibraryMessage;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// No description provided for @inPlaylist.
  ///
  /// In en, this message translates to:
  /// **'in {playlistName}'**
  String inPlaylist(String playlistName);

  /// No description provided for @artistWithEngine.
  ///
  /// In en, this message translates to:
  /// **'Artist - {engine}'**
  String artistWithEngine(String engine);

  /// No description provided for @albumWithEngine.
  ///
  /// In en, this message translates to:
  /// **'Album - {engine}'**
  String albumWithEngine(String engine);

  /// No description provided for @playlistWithEngine.
  ///
  /// In en, this message translates to:
  /// **'Playlist - {engine}'**
  String playlistWithEngine(String engine);

  /// No description provided for @noDownloads.
  ///
  /// In en, this message translates to:
  /// **'No Downloads'**
  String get noDownloads;

  /// No description provided for @searchSongs.
  ///
  /// In en, this message translates to:
  /// **'Search your songs...'**
  String get searchSongs;

  /// No description provided for @refreshDownloads.
  ///
  /// In en, this message translates to:
  /// **'Refresh Downloads'**
  String get refreshDownloads;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close Search'**
  String get closeSearch;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Crafting symphonies in code.'**
  String get aboutTagline;

  /// No description provided for @maintainer.
  ///
  /// In en, this message translates to:
  /// **'Maintainer'**
  String get maintainer;

  /// No description provided for @followGithub.
  ///
  /// In en, this message translates to:
  /// **'Follow him on GitHub'**
  String get followGithub;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send a business inquiry'**
  String get contactTooltip;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'Linkedin'**
  String get linkedin;

  /// No description provided for @linkedinTooltip.
  ///
  /// In en, this message translates to:
  /// **'Updates and creative highlights'**
  String get linkedinTooltip;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'\"Enjoying Bloomee? A small tip keeps it blooming.\" 🌸'**
  String get supportMessage;

  /// No description provided for @supportButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help'**
  String get supportButton;

  /// No description provided for @supportFooter.
  ///
  /// In en, this message translates to:
  /// **'I want Bloomee to keep improving.'**
  String get supportFooter;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @versionError.
  ///
  /// In en, this message translates to:
  /// **'Not able to retrieve version'**
  String get versionError;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @topSongs.
  ///
  /// In en, this message translates to:
  /// **'Top Songs'**
  String get topSongs;

  /// No description provided for @topAlbums.
  ///
  /// In en, this message translates to:
  /// **'Top Albums'**
  String get topAlbums;

  /// No description provided for @viewLyrics.
  ///
  /// In en, this message translates to:
  /// **'View Lyrics'**
  String get viewLyrics;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @startAuth.
  ///
  /// In en, this message translates to:
  /// **'Start Auth'**
  String get startAuth;

  /// No description provided for @getSessionKey.
  ///
  /// In en, this message translates to:
  /// **'Get & Save Session Key'**
  String get getSessionKey;

  /// No description provided for @removeKeys.
  ///
  /// In en, this message translates to:
  /// **'Remove Keys'**
  String get removeKeys;

  /// No description provided for @countryLangSettings.
  ///
  /// In en, this message translates to:
  /// **'Country & Language Settings'**
  String get countryLangSettings;

  /// No description provided for @autoCheckCountry.
  ///
  /// In en, this message translates to:
  /// **'Auto check country'**
  String get autoCheckCountry;

  /// No description provided for @autoCheckCountrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically check the country to your location when you open the app.'**
  String get autoCheckCountrySubtitle;

  /// No description provided for @countrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Country to set as default for the app.'**
  String get countrySubtitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Primary language for the app UI.'**
  String get languageSubtitle;

  /// No description provided for @scrobbleTracks.
  ///
  /// In en, this message translates to:
  /// **'Scrobble Tracks'**
  String get scrobbleTracks;

  /// No description provided for @scrobbleTracksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scrobble tracks to Last.FM'**
  String get scrobbleTracksSubtitle;

  /// No description provided for @firstAuthLastFM.
  ///
  /// In en, this message translates to:
  /// **'First Authenticate Last.FM API.'**
  String get firstAuthLastFM;

  /// No description provided for @lastFmInstructions.
  ///
  /// In en, this message translates to:
  /// **'To set API Key for Last.FM, \n1. Go to Last.FM create an account there (https://www.last.fm/).\n2. Now generate an API Key and Secret from: https://www.last.fm/api/account/create\n3. Enter the API Key and Secret below and click on \'Start Auth\' to get the session key.\n4. After allowing from browser, click on \'Get and Save Session Key\' to save the session key.'**
  String get lastFmInstructions;

  /// No description provided for @lastFmAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Hi, {username},\nLast.FM API is Authenticated.'**
  String lastFmAuthenticated(String username);

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Tailor your experience'**
  String get onboardingWelcome;

  /// No description provided for @confirmSettings.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your country and language to get started with content that fits you best.'**
  String get confirmSettings;

  /// No description provided for @detectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detectedLabel;

  /// No description provided for @lastFmAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Last.FM Authentication Failed.\n{message}\nHint: First click Start Auth and Sign-In from browser then click Get & Save Session Key button'**
  String lastFmAuthFailed(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'ja',
        'ru'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
