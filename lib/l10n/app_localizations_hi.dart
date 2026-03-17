// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get onboardingTitle => 'ब्लूमी में आपका स्वागत है';

  @override
  String get onboardingSubtitle => 'आइए आपकी भाषा और क्षेत्र सेट करें।';

  @override
  String get continueButton => 'आगे बढ़ें';

  @override
  String get navHome => 'होम';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navSearch => 'खोजें';

  @override
  String get navLocal => 'लोकल';

  @override
  String get navOffline => 'ऑफ़लाइन';

  @override
  String get playerEnjoyingFrom => 'सुन रहे हैं';

  @override
  String get playerQueue => 'कतार';

  @override
  String get playerPlayWithMix => 'स्वचालित-मिक्स संगीत';

  @override
  String get playerPlayNext => 'अगला चलाएँ';

  @override
  String get playerAddToQueue => 'कतार में जोड़ें';

  @override
  String get playerAddToFavorites => 'पसंदीदा में जोड़ें';

  @override
  String get playerNoLyricsFound => 'गीत के बोल नहीं मिले';

  @override
  String get playerLyricsNoPlugin =>
      'कोई गीत प्रदाता सेट नहीं है। एक इंस्टॉल करने के लिए Settings → Plugins पर जाएं।';

  @override
  String get playerFullscreenLyrics => 'पूर्ण स्क्रीन बोल';

  @override
  String get localMusicTitle => 'लोकल';

  @override
  String get localMusicGrantPermission => 'अनुमति दें';

  @override
  String get localMusicStorageAccessRequired => 'स्टोरेज अनुमति चाहिए';

  @override
  String get localMusicStorageAccessDesc =>
      'अपने डिवाइस पर ऑडियो फ़ाइलें स्कैन और चलाने के लिए अनुमति दें।';

  @override
  String get localMusicAddFolder => 'म्यूज़िक फ़ोल्डर जोड़ें';

  @override
  String get localMusicScanNow => 'अभी स्कैन करें';

  @override
  String localMusicScanFailed(String message) {
    return 'स्कैन विफल: $message';
  }

  @override
  String get localMusicScanning =>
      'ऑडियो फ़ाइलों के लिए डिवाइस स्कैन हो रहा है...';

  @override
  String get localMusicEmpty => 'कोई लोकल म्यूज़िक नहीं मिला';

  @override
  String get localMusicSearchEmpty =>
      'आपकी खोज से मेल खाते कोई ट्रैक नहीं मिले।';

  @override
  String get localMusicShuffle => 'शफ़ल';

  @override
  String get localMusicPlayAll => 'सभी चलाएँ';

  @override
  String get localMusicSearchHint => 'लोकल म्यूज़िक खोजें...';

  @override
  String get localMusicRescanDevice => 'फिर से स्कैन करें';

  @override
  String get localMusicRemoveFolder => 'फ़ोल्डर हटाएं';

  @override
  String get localMusicMusicFolders => 'म्यूज़िक फ़ोल्डर';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक',
      one: '1 ट्रैक',
    );
    return '$_temp0';
  }

  @override
  String get buttonCancel => 'रद्द करें';

  @override
  String get buttonDelete => 'हटाएँ';

  @override
  String get buttonOk => 'ठीक है';

  @override
  String get buttonUpdate => 'अपडेट';

  @override
  String get buttonDownload => 'डाउनलोड';

  @override
  String get buttonShare => 'शेयर';

  @override
  String get buttonLater => 'बाद में';

  @override
  String get buttonInfo => 'Info';

  @override
  String get buttonMore => 'More';

  @override
  String get dialogDeleteTrack => 'ट्रैक हटाएँ';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'क्या आप \"$title\" को अपने डिवाइस से हटाना चाहते हैं? यह पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'यह ट्रैक इनसे भी हटाया जाएगा:';

  @override
  String get dialogDontAskAgain => 'दोबारा न पूछें';

  @override
  String get dialogDeletePlugin => 'प्लगइन हटाएँ?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'क्या आप \"$name\" को हटाना चाहते हैं? इसकी फ़ाइलें स्थायी रूप से हटा दी जाएँगी।';
  }

  @override
  String get dialogUpdateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get dialogUpdateNow => 'अभी अपडेट करें';

  @override
  String get dialogDownloadPlaylist => 'प्लेलिस्ट डाउनलोड करें';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'क्या आप \"$title\" से $count गाने डाउनलोड करना चाहते हैं?';
  }

  @override
  String get dialogDownloadAll => 'सभी डाउनलोड करें';

  @override
  String get playlistEdit => 'प्लेलिस्ट संपादित करें';

  @override
  String get playlistShareFile => 'फ़ाइल शेयर करें';

  @override
  String get playlistExportFile => 'फ़ाइल निर्यात करें';

  @override
  String get playlistPlay => 'चलाएँ';

  @override
  String get playlistAddToQueue => 'कतार में प्लेलिस्ट जोड़ें';

  @override
  String get playlistShare => 'प्लेलिस्ट शेयर करें';

  @override
  String get playlistDelete => 'प्लेलिस्ट हटाएँ';

  @override
  String get playlistEmptyState => 'अभी कोई गाने नहीं!';

  @override
  String get playlistAvailableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get playlistShuffle => 'शफ़ल';

  @override
  String get playlistMoreOptions => 'और विकल्प';

  @override
  String get playlistNoMatchSearch => 'कोई प्लेलिस्ट नहीं मिली';

  @override
  String get playlistCreateNew => 'नई प्लेलिस्ट बनाएँ';

  @override
  String get playlistCreateFirstOne =>
      'कोई प्लेलिस्ट नहीं। शुरू करने के लिए एक बनाएँ!';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गाने',
      one: '1 गाना',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title removed from $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Failed to load playlist';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsPlugins => 'प्लगइन';

  @override
  String get settingsPluginsSubtitle => 'प्लगइन इंस्टॉल, लोड और प्रबंधित करें।';

  @override
  String get settingsUpdates => 'अपडेट';

  @override
  String get settingsUpdatesSubtitle => 'नए अपडेट की जाँच करें';

  @override
  String get settingsDownloads => 'डाउनलोड';

  @override
  String get settingsDownloadsSubtitle =>
      'डाउनलोड पाथ, डाउनलोड क्वालिटी और अन्य...';

  @override
  String get settingsLocalTracks => 'लोकल ट्रैक';

  @override
  String get settingsLocalTracksSubtitle =>
      'स्कैन, फ़ोल्डर प्रबंधित और ऑटो-स्कैन सेटिंग्स।';

  @override
  String get settingsPlayer => 'प्लेयर सेटिंग्स';

  @override
  String get settingsPlayerSubtitle => 'स्ट्रीम क्वालिटी, ऑटो प्ले, आदि।';

  @override
  String get settingsPluginDefaults => 'प्लगइन डिफ़ॉल्ट';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'डिस्कवर स्रोत, रिज़ॉल्वर प्राथमिकता।';

  @override
  String get settingsUIElements => 'UI एलिमेंट और सेवाएँ';

  @override
  String get settingsUIElementsSubtitle => 'ऑटो स्लाइड, UI ट्वीक्स आदि।';

  @override
  String get settingsLastFM => 'Last.FM सेटिंग्स';

  @override
  String get settingsLastFMSubtitle =>
      'API Key, Secret, और स्क्रोबलिंग सेटिंग्स।';

  @override
  String get settingsStorage => 'स्टोरेज';

  @override
  String get settingsStorageSubtitle =>
      'बैकअप, कैश, इतिहास, रीस्टोर और अन्य...';

  @override
  String get settingsLanguageCountry => 'भाषा और देश';

  @override
  String get settingsLanguageCountrySubtitle => 'अपनी भाषा और देश चुनें।';

  @override
  String get settingsAbout => 'ऐप के बारे में';

  @override
  String get settingsAboutSubtitle => 'ऐप, वर्शन, डेवलपर आदि के बारे में।';

  @override
  String get settingsScanning => 'स्कैनिंग';

  @override
  String get settingsMusicFolders => 'म्यूज़िक फ़ोल्डर';

  @override
  String get settingsQuality => 'गुणवत्ता';

  @override
  String get settingsHistory => 'इतिहास';

  @override
  String get settingsBackupRestore => 'बैकअप और रीस्टोर';

  @override
  String get settingsAutomatic => 'स्वचालित';

  @override
  String get settingsDangerZone => 'खतरा क्षेत्र';

  @override
  String get settingsScrobbling => 'स्क्रोबलिंग';

  @override
  String get settingsAuthentication => 'प्रमाणीकरण';

  @override
  String get settingsHomeScreen => 'होम स्क्रीन';

  @override
  String get settingsChartVisibility => 'चार्ट दृश्यता';

  @override
  String get settingsLocation => 'स्थान';

  @override
  String get pluginRepositoryTitle => 'प्लगइन रिपॉज़िटरी';

  @override
  String get pluginRepositorySubtitle =>
      'रिमोट प्लगइन देखने के लिए JSON स्रोत जोड़ें।';

  @override
  String get pluginRepositoryAddAction => 'रिपॉज़िटरी जोड़ें';

  @override
  String get pluginRepositoryAddTitle => 'रिपॉज़िटरी जोड़ें';

  @override
  String get pluginRepositoryAddSubtitle =>
      'मान्य प्लगइन रिपॉज़िटरी JSON फ़ाइल का URL दर्ज करें।';

  @override
  String get pluginRepositoryEmpty => 'अभी तक कोई रिपॉज़िटरी नहीं जोड़ी गई है।';

  @override
  String get pluginRepositoryUrlCopied =>
      'रिपॉज़िटरी URL क्लिपबोर्ड पर कॉपी कर दिया गया';

  @override
  String get pluginRepositoryNoDescription => 'कोई विवरण उपलब्ध नहीं है।';

  @override
  String get pluginRepositoryUnknownUpdate => 'अपडेट जानकारी उपलब्ध नहीं';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लगइन',
      one: '1 प्लगइन',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad => 'रिपॉज़िटरी लोड नहीं हो सकीं।';

  @override
  String get pluginRepositoryErrorInvalid =>
      'रिपॉज़िटरी URL या रिपॉज़िटरी फ़ाइल अमान्य है।';

  @override
  String get pluginRepositoryErrorRemove => 'रिपॉज़िटरी हटाई नहीं जा सकी।';

  @override
  String pluginRepositoryError(String message) {
    return 'Error: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => 'Adding to download queue';

  @override
  String get emptyNoInternet => 'इंटरनेट कनेक्शन नहीं!';

  @override
  String get emptyNoContentPlugin =>
      'कोई कंटेंट प्लगइन लोड नहीं। प्लगइन मैनेजर में Content Resolver लोड करें।';

  @override
  String get emptyRefreshingSource =>
      'डिस्कवर स्रोत रिफ़्रेश हो रहा है... पिछला स्रोत अब उपलब्ध नहीं है।';

  @override
  String get emptyNoTracks => 'कोई ट्रैक उपलब्ध नहीं';

  @override
  String get emptyNoResults => 'कोई परिणाम नहीं मिला';

  @override
  String snackbarDeletedTrack(String title) {
    return '\"$title\" हटाया गया';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '\"$title\" हटाने में विफल';
  }

  @override
  String get snackbarAddedToNextQueue => 'कतार में अगला जोड़ा गया';

  @override
  String get snackbarAddedToQueue => 'कतार में जोड़ा गया';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title पसंदीदा में जोड़ा गया!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '$name चल रहा है';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name कतार में जोड़ा गया';
  }

  @override
  String get snackbarPlaylistQueued => 'प्लेलिस्ट डाउनलोड कतार में जोड़ी गई';

  @override
  String get snackbarPlaylistUpdated => 'प्लेलिस्ट अपडेट हुई!';

  @override
  String get snackbarNoInternet => 'इंटरनेट कनेक्शन नहीं।';

  @override
  String get snackbarImportFailed => 'आयात विफल!';

  @override
  String get snackbarImportCompleted => 'आयात पूर्ण';

  @override
  String get snackbarBackupFailed => 'बैकअप विफल!';

  @override
  String snackbarExportedTo(String path) {
    return 'निर्यात: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'मीडिया ID कॉपी हुई';

  @override
  String get snackbarLinkCopied => 'लिंक कॉपी हुई';

  @override
  String get snackbarNoLinkAvailable => 'कोई लिंक उपलब्ध नहीं';

  @override
  String get snackbarCouldNotOpenLink => 'लिंक नहीं खोल सका';

  @override
  String snackbarPreparingDownload(String title) {
    return '$title डाउनलोड तैयार हो रहा है...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title पहले से डाउनलोड है।';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title पहले से कतार में है।';
  }

  @override
  String snackbarDownloaded(String title) {
    return '$title डाउनलोड हो गया';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'त्रुटि: डाउनलोड सेवा उपलब्ध नहीं है।';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Added $count songs to download queue';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Failed to delete track from device storage.';

  @override
  String get searchHintExplore => 'आप क्या सुनना चाहते हैं?';

  @override
  String get searchHintLibrary => 'लाइब्रेरी में खोजें...';

  @override
  String get searchHintOfflineMusic => 'अपने गाने खोजें...';

  @override
  String get searchHintPlaylists => 'प्लेलिस्ट खोजें...';

  @override
  String get searchStartTyping => 'खोजने के लिए टाइप करें...';

  @override
  String get searchNoSuggestions => 'कोई सुझाव नहीं मिला!';

  @override
  String get searchNoResults =>
      'कोई परिणाम नहीं मिला!\nकोई अन्य कीवर्ड या स्रोत आज़माएँ।';

  @override
  String get searchFailed => 'खोज विफल!';

  @override
  String get searchDiscover => 'अद्भुत संगीत खोजें...';

  @override
  String get searchSources => 'स्रोत';

  @override
  String get searchNoPlugins => 'कोई प्लगइन इंस्टॉल नहीं';

  @override
  String get searchTracks => 'ट्रैक';

  @override
  String get searchAlbums => 'एल्बम';

  @override
  String get searchArtists => 'कलाकार';

  @override
  String get searchPlaylists => 'प्लेलिस्ट';

  @override
  String get exploreDiscover => 'डिस्कवर';

  @override
  String get exploreRecently => 'हाल ही में';

  @override
  String get exploreLastFmPicks => 'Last.Fm पिक्स';

  @override
  String get exploreFailedToLoad => 'होम सेक्शन लोड करने में विफल।';

  @override
  String get libraryTitle => 'लाइब्रेरी';

  @override
  String get libraryEmptyState => 'आपकी लाइब्रेरी खाली है। कुछ धुनें जोड़ें!';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName में';
  }

  @override
  String get menuAddToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get menuSmartReplace => 'स्मार्ट रिप्लेस';

  @override
  String get menuShare => 'शेयर';

  @override
  String get menuAvailableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get menuDownload => 'डाउनलोड';

  @override
  String get menuOpenOriginalLink => 'मूल लिंक खोलें';

  @override
  String get menuDeleteTrack => 'हटाएँ';

  @override
  String get songInfoTitle => 'शीर्षक';

  @override
  String get songInfoArtist => 'कलाकार';

  @override
  String get songInfoAlbum => 'एल्बम';

  @override
  String get songInfoMediaId => 'मीडिया ID';

  @override
  String get songInfoCopyId => 'आईडी कॉपी करें';

  @override
  String get songInfoCopyLink => 'लिंक कॉपी करें';

  @override
  String get songInfoOpenBrowser => 'ब्राउज़र में खोलें';

  @override
  String get tooltipRemoveFromLibrary => 'लाइब्रेरी से हटाएँ';

  @override
  String get tooltipSaveToLibrary => 'लाइब्रेरी में सहेजें';

  @override
  String get tooltipOpenOriginalLink => 'मूल लिंक खोलें';

  @override
  String get tooltipShuffle => 'Shuffle';

  @override
  String get tooltipAvailableOffline => 'Available Offline';

  @override
  String get tooltipDownloadPlaylist => 'Download playlist';

  @override
  String get tooltipMoreOptions => 'More Options';

  @override
  String get tooltipInfo => 'Info';

  @override
  String get appuiTitle => 'UI और सेवाएँ';

  @override
  String get appuiAutoSlideCharts => 'चार्ट स्वतः स्लाइड';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'होम स्क्रीन में चार्ट स्वचालित रूप से स्लाइड करें।';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Last.FM से सुझाव दिखाएँ। लॉगिन और पुनः आरंभ करना आवश्यक है।';

  @override
  String get appuiNoChartsAvailable =>
      'कोई चार्ट उपलब्ध नहीं। चार्ट प्रदाता प्लगइन लोड करें।';

  @override
  String get appuiLoginToLastFm => 'कृपया पहले Last.FM में लॉगिन करें।';

  @override
  String get appuiShowInCarousel => 'होम कैरोसेल में दिखाएँ।';

  @override
  String get countrySettingTitle => 'देश और भाषा';

  @override
  String get countrySettingAutoDetect => 'देश स्वतः पहचानें';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'ऐप खुलने पर स्वचालित रूप से आपका देश पहचानें।';

  @override
  String get countrySettingCountryLabel => 'देश';

  @override
  String get countrySettingLanguageLabel => 'भाषा';

  @override
  String get countrySettingSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get downloadSettingTitle => 'डाउनलोड';

  @override
  String get downloadSettingQuality => 'डाउनलोड क्वालिटी';

  @override
  String get downloadSettingQualitySubtitle =>
      'डाउनलोड किए गए ट्रैक के लिए सार्वभौमिक ऑडियो क्वालिटी।';

  @override
  String get downloadSettingFolder => 'डाउनलोड फ़ोल्डर';

  @override
  String get downloadSettingResetFolder => 'डाउनलोड फ़ोल्डर रीसेट करें';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'डिफ़ॉल्ट डाउनलोड पाथ पुनः स्थापित करें।';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'ट्रैक स्क्रोबल करें';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'चलाए गए ट्रैक आपकी Last.FM प्रोफ़ाइल पर भेजें।';

  @override
  String get lastfmAuthFirst => 'पहले Last.FM API प्रमाणित करें।';

  @override
  String get lastfmAuthenticatedAs => 'प्रमाणित: ';

  @override
  String get lastfmAuthFailed => 'प्रमाणीकरण विफल:';

  @override
  String get lastfmNotAuthenticated => 'प्रमाणित नहीं';

  @override
  String get lastfmSteps =>
      'प्रमाणित करने के चरण:\n1. last.fm पर खाता बनाएँ / खोलें\n2. last.fm/api/account/create पर API Key बनाएँ\n3. नीचे API Key और Secret दर्ज करें\n4. \"Start Auth\" दबाएँ और ब्राउज़र में स्वीकृति दें\n5. \"Get & Save Session Key\" दबाएँ';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. प्रमाणीकरण शुरू करें';

  @override
  String get lastfmGetSession => '2. सेशन Key प्राप्त करें';

  @override
  String get lastfmRemoveKeys => 'Keys हटाएँ';

  @override
  String get lastfmStartAuthFirst =>
      'पहले प्रमाणीकरण शुरू करें, फिर ब्राउज़र में स्वीकृति दें।';

  @override
  String get localSettingTitle => 'लोकल ट्रैक';

  @override
  String get localSettingAutoScan => 'स्टार्टअप पर स्वतः स्कैन';

  @override
  String get localSettingAutoScanSubtitle =>
      'ऐप शुरू होने पर स्वचालित रूप से नए लोकल ट्रैक स्कैन करें।';

  @override
  String get localSettingLastScan => 'अंतिम स्कैन';

  @override
  String get localSettingNeverScanned => 'कभी नहीं';

  @override
  String get localSettingScanInProgress => 'स्कैनिंग प्रगति में है…';

  @override
  String get localSettingScanNowSubtitle =>
      'पूरी लाइब्रेरी स्कैन मैन्युअली शुरू करें।';

  @override
  String get localSettingNoFolders =>
      'कोई फ़ोल्डर नहीं जोड़ा गया। स्कैनिंग शुरू करने के लिए फ़ोल्डर जोड़ें।';

  @override
  String get localSettingAddFolder => 'फ़ोल्डर जोड़ें';

  @override
  String get playerSettingTitle => 'प्लेयर सेटिंग्स';

  @override
  String get playerSettingStreamingHeader => 'स्ट्रीमिंग';

  @override
  String get playerSettingStreamQuality => 'स्ट्रीमिंग क्वालिटी';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'ऑनलाइन प्लेबैक के लिए वैश्विक ऑडियो बिटरेट।';

  @override
  String get playerSettingQualityLow => 'कम';

  @override
  String get playerSettingQualityMedium => 'मध्यम';

  @override
  String get playerSettingQualityHigh => 'अधिक';

  @override
  String get playerSettingPlaybackHeader => 'प्लेबैक';

  @override
  String get playerSettingAutoPlay => 'ऑटो प्ले';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'कतार समाप्त होने पर समान गाने जोड़ें।';

  @override
  String get playerSettingAutoFallback => 'ऑटो फ़ॉलबैक प्लेबैक';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'यदि प्लगइन अनुपलब्ध है या कोई स्ट्रीम नहीं है, तो केवल प्लेबैक के लिए संगत रिज़ॉल्वर प्रयास करें।';

  @override
  String get playerSettingCrossfade => 'क्रॉसफ़ेड';

  @override
  String get playerSettingCrossfadeOff => 'बंद';

  @override
  String get playerSettingCrossfadeInstant => 'ट्रैक तुरंत बदलते हैं';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '${seconds}s ट्रैक के बीच मिश्रण';
  }

  @override
  String get playerSettingEqualizer => 'इक्वलाइज़र';

  @override
  String get playerSettingEqualizerActive => 'सक्रिय';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'चालू — $preset प्रीसेट';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'FFmpeg के माध्यम से 10-बैंड पैरामेट्रिक EQ।';

  @override
  String get pluginDefaultsTitle => 'प्लगइन डिफ़ॉल्ट';

  @override
  String get pluginDefaultsDiscoverHeader => 'डिस्कवर स्रोत';

  @override
  String get pluginDefaultsNoResolver =>
      'कोई कंटेंट रिज़ॉल्वर लोड नहीं। डिस्कवर स्रोत चुनने के लिए प्लगइन लोड करें।';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'पहला उपलब्ध कंटेंट रिज़ॉल्वर उपयोग करें।';

  @override
  String get pluginDefaultsPriorityHeader => 'रिज़ॉल्वर प्राथमिकता';

  @override
  String get pluginDefaultsNoPriority =>
      'कोई कंटेंट रिज़ॉल्वर लोड नहीं। प्लगइन लोड होने पर प्राथमिकता क्रम यहाँ दिखेगा।';

  @override
  String get pluginDefaultsPriorityDesc =>
      'क्रमबद्ध करने के लिए खींचें। उच्च प्राथमिकता के रिज़ॉल्वर पहले प्रयास किए जाते हैं।';

  @override
  String get pluginDefaultsLyricsHeader => 'लिरिक्स प्राथमिकता';

  @override
  String get pluginDefaultsLyricsNone => 'कोई लिरिक्स प्रदाता लोड नहीं है।';

  @override
  String get pluginDefaultsLyricsDesc =>
      'लिरिक्स प्रदाताओं को पुनः क्रमित करने के लिए खींचें। पहला प्रदाता पहले आज़माया जाता है।';

  @override
  String get pluginDefaultsSuggestionsHeader => 'खोज सुझाव';

  @override
  String get pluginDefaultsSuggestionsNone => 'कोई सुझाव प्रदाता लोड नहीं है।';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'कोई नहीं';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'केवल खोज इतिहास का उपयोग करें।';

  @override
  String get storageSettingTitle => 'स्टोरेज';

  @override
  String get storageClearHistoryEvery => 'इतिहास हर बार साफ़ करें';

  @override
  String get storageClearHistorySubtitle =>
      'चुनी अवधि के बाद सुनने का इतिहास साफ़ करें।';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String get storageBackupLocation => 'बैकअप स्थान';

  @override
  String get storageBackupLocationAndroid => 'डाउनलोड / ऐप-डेटा डायरेक्टरी';

  @override
  String get storageBackupLocationDownloads => 'डाउनलोड डायरेक्टरी';

  @override
  String get storageCreateBackup => 'बैकअप बनाएँ';

  @override
  String get storageCreateBackupSubtitle =>
      'अपनी सेटिंग्स और डेटा एक बैकअप फ़ाइल में सहेजें।';

  @override
  String storageBackupCreatedAt(String path) {
    return 'बैकअप बनाया गया: $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'बैकअप शेयर करने में विफल: $error';
  }

  @override
  String get storageBackupFailed => 'बैकअप विफल!';

  @override
  String get storageRestoreBackup => 'बैकअप पुनः स्थापित करें';

  @override
  String get storageRestoreBackupSubtitle =>
      'बैकअप फ़ाइल से अपनी सेटिंग्स और डेटा पुनः स्थापित करें।';

  @override
  String get storageAutoBackup => 'स्वतः बैकअप';

  @override
  String get storageAutoBackupSubtitle =>
      'अपने डेटा का समय-समय पर स्वचालित बैकअप बनाएँ।';

  @override
  String get storageAutoLyrics => 'गीत के बोल स्वतः सहेजें';

  @override
  String get storageAutoLyricsSubtitle =>
      'गाना चलने पर गीत के बोल स्वचालित रूप से सहेजें।';

  @override
  String get storageResetApp => 'Bloomee ऐप रीसेट करें';

  @override
  String get storageResetAppSubtitle =>
      'सभी डेटा हटाएँ और ऐप को डिफ़ॉल्ट स्थिति में पुनः स्थापित करें।';

  @override
  String get storageResetConfirmTitle => 'रीसेट की पुष्टि';

  @override
  String get storageResetConfirmMessage =>
      'क्या आप Bloomee को रीसेट करना चाहते हैं? यह आपका सभी डेटा हटा देगा और यह पूर्ववत नहीं किया जा सकता।';

  @override
  String get storageResetButton => 'रीसेट';

  @override
  String get storageResetSuccess =>
      'ऐप को डिफ़ॉल्ट स्थिति में पुनः स्थापित किया गया।';

  @override
  String get storageLocationDialogTitle => 'बैकअप स्थान';

  @override
  String get storageLocationAndroid =>
      'बैकअप यहाँ संग्रहीत हैं:\n\n1. डाउनलोड डायरेक्टरी\n2. Android/data/ls.bloomee.musicplayer/data\n\nकिसी भी स्थान से फ़ाइल कॉपी करें।';

  @override
  String get storageLocationOther =>
      'बैकअप डाउनलोड डायरेक्टरी में संग्रहीत हैं। वहाँ से फ़ाइल कॉपी करें।';

  @override
  String get storageRestoreOptionsTitle => 'पुनः स्थापना विकल्प';

  @override
  String get storageRestoreOptionsDesc =>
      'चुनें कि आप बैकअप फ़ाइल से कौन सा डेटा पुनः स्थापित करना चाहते हैं। जो आइटम आयात नहीं करना चाहते उन्हें अनचेक करें।';

  @override
  String get storageRestoreSelectAll => 'सभी चुनें';

  @override
  String get storageRestoreMediaItems =>
      'मीडिया आइटम (गाने, ट्रैक, लाइब्रेरी प्रविष्टियाँ)';

  @override
  String get storageRestoreSearchHistory => 'खोज इतिहास';

  @override
  String get storageRestoreContinue => 'जारी रखें';

  @override
  String get storageRestoreNoFile => 'कोई फ़ाइल नहीं चुनी गई।';

  @override
  String get storageRestoreSaveFailed => 'चुनी गई फ़ाइल सहेजने में विफल।';

  @override
  String get storageRestoreConfirmTitle => 'पुनः स्थापना की पुष्टि';

  @override
  String get storageRestoreConfirmPrefix =>
      'यह बैकअप फ़ाइल से चुने गए भागों के डेटा को मर्ज/अधिलेखित कर देगा:';

  @override
  String get storageRestoreConfirmSuffix =>
      'आपका वर्तमान डेटा बदल जाएगा। क्या आप आगे बढ़ना चाहते हैं?';

  @override
  String get storageRestoreYes => 'हाँ, पुनः स्थापित करें';

  @override
  String get storageRestoreNo => 'नहीं';

  @override
  String get storageRestoring =>
      'चुना डेटा पुनः स्थापित हो रहा है…\nकृपया ऑपरेशन पूरा होने तक प्रतीक्षा करें।';

  @override
  String get storageRestoreMediaBullet => '• मीडिया आइटम';

  @override
  String get storageRestoreHistoryBullet => '• खोज इतिहास';

  @override
  String get storageUnexpectedError =>
      'पुनः स्थापना के दौरान अप्रत्याशित त्रुटि हुई।';

  @override
  String get storageRestoreCompleted => 'पुनः स्थापना पूर्ण';

  @override
  String get storageRestoreFailedTitle => 'पुनः स्थापना विफल';

  @override
  String get storageRestoreSuccessMessage =>
      'चुना डेटा सफलतापूर्वक पुनः स्थापित हो गया। सर्वोत्तम परिणामों के लिए, अब ऐप पुनः शुरू करें।';

  @override
  String get storageRestoreFailedMessage =>
      'पुनः स्थापना की प्रक्रिया निम्न त्रुटियों के साथ विफल हुई:';

  @override
  String get storageRestoreUnknownError =>
      'पुनः स्थापना के दौरान अज्ञात त्रुटि हुई।';

  @override
  String get storageRestoreRestartHint =>
      'बेहतर स्थिरता के लिए कृपया ऐप पुनः शुरू करें।';

  @override
  String get updateSettingTitle => 'अपडेट';

  @override
  String get updateAppUpdatesHeader => 'ऐप अपडेट';

  @override
  String get updateCheckForUpdates => 'अपडेट जाँचें';

  @override
  String get updateCheckSubtitle =>
      'देखें कि Bloomee का नया संस्करण उपलब्ध है या नहीं।';

  @override
  String get updateAutoNotify => 'स्वतः अपडेट सूचना';

  @override
  String get updateAutoNotifySubtitle =>
      'ऐप शुरू होने पर नए अपडेट की सूचना पाएँ।';

  @override
  String get updateCheckTitle => 'अपडेट जाँचें';

  @override
  String get updateUpToDate => 'Bloomee🌸 अप-टू-डेट है!!!';

  @override
  String get updateViewPreRelease => 'नवीनतम Pre-Release देखें';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'वर्तमान संस्करण: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Bloomee🌸 का नया संस्करण अब उपलब्ध है!!';

  @override
  String updateVersion(String ver, String build) {
    return 'संस्करण: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'अभी डाउनलोड करें';

  @override
  String get updateChecking =>
      'जाँच हो रही है कि नया संस्करण उपलब्ध है या नहीं!';

  @override
  String get timerTitle => 'स्लीप टाइमर';

  @override
  String get timerInterludeMessage =>
      'एक शांतिपूर्ण विराम की तैयारी हो रही है…';

  @override
  String get timerHours => 'घंटे';

  @override
  String get timerMinutes => 'मिनट';

  @override
  String get timerSeconds => 'सेकंड';

  @override
  String get timerStop => 'टाइमर रोकें';

  @override
  String get timerFinishedMessage => 'धुनें आराम कर रही हैं। शुभ स्वप्न 🥰।';

  @override
  String get timerGotIt => 'समझ गया!';

  @override
  String get timerSetTimeError => 'कृपया समय सेट करें';

  @override
  String get timerStart => 'टाइमर शुरू करें';

  @override
  String get notificationsTitle => 'सूचनाएँ';

  @override
  String get notificationsEmpty => 'अभी कोई सूचना नहीं!';

  @override
  String get recentsTitle => 'इतिहास';

  @override
  String playlistByCreator(String creator) {
    return '$creator द्वारा';
  }

  @override
  String get playlistTypeAlbum => 'एल्बम';

  @override
  String get playlistTypePlaylist => 'प्लेलिस्ट';

  @override
  String get playlistYou => 'आप';

  @override
  String get pluginManagerTitle => 'प्लगइन';

  @override
  String get pluginManagerEmpty =>
      'कोई प्लगइन इंस्टॉल नहीं।\n+ दबाएँ और .bex फ़ाइल जोड़ें।';

  @override
  String get pluginManagerFilterAll => 'सभी';

  @override
  String get pluginManagerFilterContent => 'कंटेंट रिज़ॉल्वर';

  @override
  String get pluginManagerFilterCharts => 'चार्ट प्रदाता';

  @override
  String get pluginManagerFilterLyrics => 'लिरिक्स प्रदाता';

  @override
  String get pluginManagerFilterSuggestions => 'सुझाव प्रदाता';

  @override
  String get pluginManagerFilterImporters => 'Content Importers';

  @override
  String get pluginManagerTooltipRefresh => 'रिफ़्रेश';

  @override
  String get pluginManagerTooltipInstall => 'प्लगइन इंस्टॉल करें';

  @override
  String get pluginManagerNoMatch => 'इस फ़िल्टर से कोई प्लगइन नहीं मिला';

  @override
  String pluginManagerPickFailed(String error) {
    return 'फ़ाइल चुनने में विफल: $error';
  }

  @override
  String get pluginManagerInstalling => 'प्लगइन इंस्टॉल हो रहा है...';

  @override
  String get pluginManagerTypeContentResolver => 'कंटेंट रिज़ॉल्वर';

  @override
  String get pluginManagerTypeChartProvider => 'चार्ट प्रदाता';

  @override
  String get pluginManagerTypeLyricsProvider => 'लिरिक्स प्रदाता';

  @override
  String get pluginManagerTypeSuggestionProvider => 'खोज सुझाव';

  @override
  String get pluginManagerTypeContentImporter => 'Content Importer';

  @override
  String get pluginManagerDeleteTitle => 'प्लगइन हटाएँ?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'क्या आप \"$name\" को हटाना चाहते हैं? इससे इसकी फ़ाइलें स्थायी रूप से हट जाएँगी।';
  }

  @override
  String get pluginManagerDeleteAction => 'हटाएँ';

  @override
  String get pluginManagerCancel => 'रद्द करें';

  @override
  String get pluginManagerEnablePlugin => 'प्लगइन सक्षम करें';

  @override
  String get pluginManagerUnloadPlugin => 'प्लगइन अनलोड करें';

  @override
  String get pluginManagerDeleting => 'हटाया जा रहा है...';

  @override
  String get pluginManagerApiKeysTitle => 'API कुंजियाँ';

  @override
  String get pluginManagerApiKeysSaved => 'API कुंजियाँ सहेजी गईं';

  @override
  String get pluginManagerSave => 'सहेजें';

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
  String get segmentsSheetTitle => 'सेगमेंट';

  @override
  String get segmentsSheetEmpty => 'कोई सेगमेंट उपलब्ध नहीं है';

  @override
  String get segmentsSheetUntitled => 'बिना शीर्षक का सेगमेंट';

  @override
  String get smartReplaceTitle => 'स्मार्ट रिप्लेस';

  @override
  String smartReplaceSubtitle(String title) {
    return '\"$title\" के लिए चलाने योग्य विकल्प चुनें और सहेजी प्लेलिस्ट संदर्भ अपडेट करें।';
  }

  @override
  String get smartReplaceClose => 'बंद करें';

  @override
  String get smartReplaceNoMatch => 'कोई विकल्प नहीं मिला';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'किसी भी लोड किए गए रिज़ॉल्वर प्लगइन ने पर्याप्त मिलान नहीं लौटाया।';

  @override
  String get smartReplaceBestMatch => 'सबसे अच्छा मिलान';

  @override
  String get smartReplaceSearchFailed => 'खोज विफल';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'स्मार्ट रिप्लेस विफल: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'विकल्प लागू किया$queue।';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '$count प्लेलिस्ट$plural में बदला$queue।';
  }

  @override
  String get smartReplaceQueueUpdated => ' और कतार अपडेट हुई';

  @override
  String get playerUnknownQueue => 'अज्ञात';

  @override
  String playerLiked(String title) {
    return '$title पसंदीदा में जोड़ा!!';
  }

  @override
  String playerUnliked(String title) {
    return '$title पसंदीदा से हटाया!!';
  }

  @override
  String get offlineNoDownloads => 'कोई डाउनलोड नहीं';

  @override
  String get offlineTitle => 'ऑफ़लाइन';

  @override
  String get offlineSearchHint => 'अपने गाने खोजें...';

  @override
  String get offlineRefreshTooltip => 'डाउनलोड रिफ़्रेश करें';

  @override
  String get offlineCloseSearch => 'खोज बंद करें';

  @override
  String get offlineSearchTooltip => 'खोजें';

  @override
  String get offlineOpenFailed =>
      'यह ऑफ़लाइन ट्रैक नहीं खुल सका। डाउनलोड रिफ़्रेश करें।';

  @override
  String get offlinePlayFailed =>
      'यह ऑफ़लाइन गाना नहीं चला। कृपया पुनः प्रयास करें।';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक',
      one: '1 ट्रैक',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'एल्बम लोड करने में विफल';

  @override
  String get aboutCraftingSubtitle => 'कोड में सिम्फनी बना रहे हैं।';

  @override
  String get aboutFollowGitHub => 'GitHub पर फ़ॉलो करें';

  @override
  String get aboutSendInquiry => 'व्यावसायिक पूछताछ भेजें';

  @override
  String get aboutCreativeHighlights => 'अपडेट और रचनात्मक झलक';

  @override
  String get aboutTipQuote =>
      'Bloomee पसंद है? एक छोटी सी सहायता इसे खिलाए रखती है। 🌸';

  @override
  String get aboutTipButton => 'मैं मदद करूँगा';

  @override
  String get aboutTipDesc => 'मैं चाहता हूँ कि Bloomee बेहतर होता रहे।';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'गाने की जानकारी';

  @override
  String get songInfoSectionTechnical => 'तकनीकी जानकारी';

  @override
  String get songInfoSectionActions => 'क्रियाएँ';

  @override
  String get songInfoLabelTitle => 'शीर्षक';

  @override
  String get songInfoLabelArtist => 'कलाकार';

  @override
  String get songInfoLabelAlbum => 'एल्बम';

  @override
  String get songInfoLabelDuration => 'अवधि';

  @override
  String get songInfoLabelSource => 'स्रोत';

  @override
  String get songInfoLabelMediaId => 'मीडिया आईडी';

  @override
  String get songInfoLabelPluginId => 'प्लगइन आईडी';

  @override
  String get songInfoIdCopied => 'मीडिया आईडी कॉपी हो गई';

  @override
  String get songInfoLinkCopied => 'लिंक कॉपी हो गया';

  @override
  String get songInfoNoLink => 'कोई लिंक उपलब्ध नहीं';

  @override
  String get songInfoOpenFailed => 'लिंक नहीं खोल सका';

  @override
  String get songInfoUpdateMetadata => 'नवीनतम मेटाडेटा प्राप्त करें';

  @override
  String get songInfoMetadataUpdated => 'मेटाडेटा अपडेट हो गया';

  @override
  String get songInfoMetadataUpdateFailed => 'मेटाडेटा अपडेट नहीं हो सका';

  @override
  String get songInfoMetadataUnavailable =>
      'इस स्रोत के लिए मेटाडेटा रीफ्रेश उपलब्ध नहीं है';

  @override
  String get songInfoSearchTitle => 'इस गाने को Bloomee में खोजें';

  @override
  String get songInfoSearchArtist => 'इस कलाकार को Bloomee में खोजें';

  @override
  String get songInfoSearchAlbum => 'इस एल्बम को Bloomee में खोजें';

  @override
  String get eqTitle => 'इक्वलाइज़र';

  @override
  String get eqResetTooltip => 'फ्लैट पर रीसेट करें';

  @override
  String get chartNoItems => 'इस चार्ट में कोई आइटम नहीं';

  @override
  String get chartLoadFailed => 'चार्ट लोड करने में विफल';

  @override
  String get chartPlay => 'चलाएं';

  @override
  String get chartResolving => 'खोज रहे हैं';

  @override
  String get chartReady => 'तैयार';

  @override
  String get chartAddToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get chartNoResolver =>
      'कोई कंटेंट रिज़ॉल्वर लोड नहीं है। चलाने के लिए प्लगइन इंस्टॉल करें।';

  @override
  String get chartResolveFailed =>
      'रिज़ॉल्व नहीं हो सका। इसके बजाय खोज रहे हैं...';

  @override
  String get chartNoResolverAdd => 'कोई कंटेंट रिज़ॉल्वर लोड नहीं है।';

  @override
  String get chartNoMatch =>
      'कोई मिलान नहीं मिला। मैन्युअल रूप से खोजने का प्रयास करें।';

  @override
  String get chartStatPeak => 'चरम';

  @override
  String get chartStatWeeks => 'सप्ताह';

  @override
  String get chartStatChange => 'बदलाव';

  @override
  String menuSharePreparing(String title) {
    return '$title शेयर करने की तैयारी हो रही है।';
  }

  @override
  String get menuOpenLinkFailed => 'लिंक नहीं खोल सका';

  @override
  String get localMusicFolders => 'संगीत फ़ोल्डर';

  @override
  String get localMusicCloseSearch => 'खोज बंद करें';

  @override
  String get localMusicOpenSearch => 'खोजें';

  @override
  String get localMusicNoMusicFound => 'कोई स्थानीय संगीत नहीं मिला';

  @override
  String get localMusicNoSearchResults =>
      'आपकी खोज से मेल खाने वाले कोई ट्रैक नहीं मिले।';

  @override
  String get importSongsTitle => 'Import Songs';

  @override
  String get importNoPluginsLoaded =>
      'No content-importer plugins loaded.\nInstall an importer plugin to import playlists from external services.';

  @override
  String get importBloomeeFiles => 'Import Bloomee Files';

  @override
  String get importM3UFiles => 'M3U प्लेलिस्ट आयात करें';

  @override
  String get importM3UNameDialogTitle => 'प्लेलिस्ट का नाम';

  @override
  String get importM3UNameHint => 'इस प्लेलिस्ट का नाम दर्ज करें';

  @override
  String get importM3UNoTracks => 'M3U फ़ाइल में कोई मान्य ट्रैक नहीं मिले।';

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

  @override
  String get pluginManagerTabInstalled => 'इंस्टॉल किए गए';

  @override
  String get pluginManagerTabStore => 'प्लगइन स्टोर';

  @override
  String get pluginManagerSelectPackage => 'प्लगइन पैकेज चुनें (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'यह प्लगइन पुराने मैनिफेस्ट संस्करण का उपयोग करता है। कुछ फीचर सही से काम नहीं कर सकते। अपडेट करने पर विचार करें।';

  @override
  String get pluginManagerStatusActive => 'सक्रिय';

  @override
  String get pluginManagerStatusInactive => 'निष्क्रिय';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'अपडेट: $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लगइन उपलब्ध',
      one: '1 प्लगइन उपलब्ध',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'पुराना मैनिफेस्ट। कुछ फीचर ठीक से काम नहीं कर सकते।';

  @override
  String get pluginRepositoryUnknownPublisher => 'अज्ञात प्रकाशक';

  @override
  String get pluginRepositoryActionRetry => 'फिर से प्रयास करें';

  @override
  String get pluginRepositoryActionOutdated => 'पुराना';

  @override
  String get pluginRepositoryActionInstalled => 'इंस्टॉल किया गया';

  @override
  String get pluginRepositoryActionInstall => 'इंस्टॉल करें';

  @override
  String get pluginRepositoryActionUnavailable => 'उपलब्ध नहीं';

  @override
  String get pluginRepositoryInstallFailed => 'इंस्टॉलेशन विफल हुआ।';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name डाउनलोड नहीं हो सका।';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लेलिस्ट में बदल दिया गया$queue.',
      one: '1 प्लेलिस्ट में बदल दिया गया$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'गीत के बोल खोजें...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'बोल खोजने के लिए गीत या कलाकार का नाम लिखें।';

  @override
  String lyricsSearchNoResults(String query) {
    return '\"$query\" के लिए कोई बोल नहीं मिले';
  }

  @override
  String get lyricsSearchApplied => 'बोल सफलतापूर्वक लागू किए गए';

  @override
  String get lyricsSearchFetchFailed => 'बोल प्राप्त नहीं किए जा सके';

  @override
  String get lyricsSearchPreview => 'पूर्वावलोकन';

  @override
  String get lyricsSearchPreviewTooltip => 'बोल का पूर्वावलोकन देखें';

  @override
  String get lyricsSearchSynced => 'सिंक';

  @override
  String get lyricsSearchPreviewLoadFailed => 'बोल लोड नहीं हो सके।';

  @override
  String get lyricsSearchApplyAction => 'बोल लागू करें';

  @override
  String get lyricsSettingsSearchTitle => 'कस्टम बोल खोजें';

  @override
  String get lyricsSettingsSearchSubtitle => 'ऑनलाइन वैकल्पिक संस्करण खोजें';

  @override
  String get lyricsSettingsSyncTitle => 'सिंक समायोजित करें (डिले/ऑफसेट)';

  @override
  String get lyricsSettingsSyncSubtitle => 'बहुत तेज़ या धीमे बोल ठीक करें';

  @override
  String get lyricsSettingsSaveTitle => 'ऑफ़लाइन सहेजें';

  @override
  String get lyricsSettingsSaveSubtitle => 'इन बोलों को अपने डिवाइस पर सहेजें';

  @override
  String get lyricsSettingsDeleteTitle => 'सहेजे गए बोल हटाएँ';

  @override
  String get lyricsSettingsDeleteSubtitle => 'ऑफ़लाइन बोल डेटा हटाएँ';

  @override
  String get lyricsSyncTapToReset => 'रीसेट करने के लिए टैप करें';

  @override
  String get upNextTitle => 'अगला';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कतार में $count आइटम',
      one: 'कतार में 1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get upNextAutoPlay => 'ऑटो प्ले';

  @override
  String get tooltipCopyToClipboard => 'क्लिपबोर्ड में कॉपी करें';

  @override
  String get snackbarCopiedToClipboard => 'क्लिपबोर्ड में कॉपी किया';

  @override
  String get tooltipSongInfo => 'गाने की जानकारी';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'अभी चल रहे गाने को नहीं हटा सकते';

  @override
  String get playerLoopOff => 'बंद';

  @override
  String get playerLoopOne => 'एक बार दोहराएं';

  @override
  String get playerLoopAll => 'सब दोहराएं';

  @override
  String get snackbarOpeningAlbumPage => 'मूल एल्बम पेज खोल रहे हैं।';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Bloomee🌸 का नया संस्करण अब उपलब्ध है!\n\nसंस्करण: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'प्लगइन \"$id\" सफलतापूर्वक इंस्टॉल हुआ';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'प्लगइन \"$id\" लोड हुआ';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'प्लगइन \"$id\" हटाया गया';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee सेट हो रहा है';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'नया प्लगइन इंजन सेट किया जा रहा है... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'यह केवल एक बार होता है।';

  @override
  String get pluginBootstrapErrorTitle => 'कनेक्शन बहुत धीमा है';

  @override
  String get pluginBootstrapErrorBody =>
      'कुछ प्लगइन इंस्टॉल नहीं हो सके। आप अभी भी Bloomee का उपयोग कर सकते हैं — प्लगइन अगली बार पुनः प्रयास करेंगे।';

  @override
  String get pluginBootstrapContinue => 'फिर भी जारी रखें';
}
