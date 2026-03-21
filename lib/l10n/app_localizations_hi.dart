// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get onboardingTitle => 'Bloomee में आपका स्वागत है';

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
  String get playerEnjoyingFrom => 'यहाँ से सुन रहे हैं';

  @override
  String get playerQueue => 'कतार';

  @override
  String get playerPlayWithMix => 'ऑटो-मिक्स प्ले';

  @override
  String get playerPlayNext => 'अगला चलाएँ';

  @override
  String get playerAddToQueue => 'कतार में जोड़ें';

  @override
  String get playerAddToFavorites => 'पसंदीदा में जोड़ें';

  @override
  String get playerNoLyricsFound => 'कोई लिरिक्स नहीं मिले';

  @override
  String get playerLyricsNoPlugin =>
      'लिरिक्स दिखाने वाला कोई प्लगइन सेट नहीं है। इसे इंस्टॉल करने के लिए सेटिंग्स → प्लगइन्स में जाएँ।';

  @override
  String get playerFullscreenLyrics => 'फ़ुलस्क्रीन लिरिक्स';

  @override
  String get localMusicTitle => 'लोकल';

  @override
  String get localMusicGrantPermission => 'अनुमति दें';

  @override
  String get localMusicStorageAccessRequired => 'स्टोरेज की अनुमति चाहिए';

  @override
  String get localMusicStorageAccessDesc =>
      'कृपया अपने डिवाइस पर मौजूद ऑडियो फ़ाइलों को स्कैन करने और चलाने की अनुमति दें।';

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
      'ऑडियो फ़ाइलों के लिए डिवाइस को स्कैन किया जा रहा है...';

  @override
  String get localMusicEmpty => 'कोई लोकल म्यूज़िक नहीं मिला';

  @override
  String get localMusicSearchEmpty =>
      'आपकी खोज से मेल खाने वाला कोई ट्रैक नहीं मिला।';

  @override
  String get localMusicShuffle => 'शफ़ल';

  @override
  String get localMusicPlayAll => 'सभी चलाएँ';

  @override
  String get localMusicSearchHint => 'लोकल म्यूज़िक खोजें...';

  @override
  String get localMusicRescanDevice => 'डिवाइस को फिर से स्कैन करें';

  @override
  String get localMusicRemoveFolder => 'फ़ोल्डर हटाएँ';

  @override
  String get localMusicMusicFolders => 'म्यूज़िक फ़ोल्डर्स';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक्स',
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
  String get buttonUpdate => 'अपडेट करें';

  @override
  String get buttonDownload => 'डाउनलोड करें';

  @override
  String get buttonShare => 'शेयर करें';

  @override
  String get buttonLater => 'बाद में';

  @override
  String get buttonInfo => 'जानकारी';

  @override
  String get buttonMore => 'और विकल्प';

  @override
  String get dialogDeleteTrack => 'ट्रैक हटाएँ';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'क्या आप वाकई \"$title\" को अपने डिवाइस से हटाना चाहते हैं? यह कार्रवाई वापस नहीं ली जा सकेगी।';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'यह ट्रैक यहाँ से भी हटा दिया जाएगा:';

  @override
  String get dialogDontAskAgain => 'मुझसे दोबारा न पूछें';

  @override
  String get dialogDeletePlugin => 'प्लगइन हटाएँ?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं? यह इसकी फ़ाइलों को हमेशा के लिए हटा देगा।';
  }

  @override
  String get dialogUpdateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get dialogUpdateNow => 'अभी अपडेट करें';

  @override
  String get dialogDownloadPlaylist => 'प्लेलिस्ट डाउनलोड करें';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'क्या आप \"$title\" से $count गाने डाउनलोड करना चाहते हैं? इससे वे डाउनलोड कतार में जुड़ जाएँगे।';
  }

  @override
  String get dialogDownloadAll => 'सभी डाउनलोड करें';

  @override
  String get playlistEdit => 'प्लेलिस्ट संपादित करें';

  @override
  String get playlistShareFile => 'फ़ाइल शेयर करें';

  @override
  String get playlistExportFile => 'फ़ाइल एक्सपोर्ट करें';

  @override
  String get playlistPlay => 'चलाएँ';

  @override
  String get playlistAddToQueue => 'कतार में प्लेलिस्ट जोड़ें';

  @override
  String get playlistShare => 'प्लेलिस्ट शेयर करें';

  @override
  String get playlistDelete => 'प्लेलिस्ट हटाएँ';

  @override
  String get playlistEmptyState => 'अभी कोई गाने नहीं हैं!';

  @override
  String get playlistAvailableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get playlistShuffle => 'शफ़ल';

  @override
  String get playlistMoreOptions => 'अधिक विकल्प';

  @override
  String get playlistNoMatchSearch =>
      'आपकी खोज से मेल खाने वाली कोई प्लेलिस्ट नहीं है';

  @override
  String get playlistCreateNew => 'नई प्लेलिस्ट बनाएँ';

  @override
  String get playlistCreateFirstOne =>
      'अभी तक कोई प्लेलिस्ट नहीं है। शुरुआत करने के लिए अपनी पहली प्लेलिस्ट बनाएँ!';

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
    return '$playlist से $title हटा दिया गया';
  }

  @override
  String get playlistFailedToLoad => 'प्लेलिस्ट लोड करने में विफल';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsPlugins => 'प्लगइन्स';

  @override
  String get settingsPluginsSubtitle => 'प्लगइन्स इंस्टॉल, लोड और मैनेज करें।';

  @override
  String get settingsUpdates => 'अपडेट्स';

  @override
  String get settingsUpdatesSubtitle => 'नए अपडेट्स की जाँच करें।';

  @override
  String get settingsDownloads => 'डाउनलोड्स';

  @override
  String get settingsDownloadsSubtitle =>
      'डाउनलोड पाथ, ऑडियो क्वालिटी और बहुत कुछ...';

  @override
  String get settingsLocalTracks => 'लोकल ट्रैक्स';

  @override
  String get settingsLocalTracksSubtitle =>
      'स्कैन, फ़ोल्डर मैनेजमेंट और ऑटो-स्कैन सेटिंग्स।';

  @override
  String get settingsPlayer => 'प्लेयर सेटिंग्स';

  @override
  String get settingsPlayerSubtitle => 'स्ट्रीमिंग क्वालिटी, ऑटो प्ले आदि।';

  @override
  String get settingsPluginDefaults => 'प्लगइन डिफ़ॉल्ट्स';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'डिस्कवर सोर्स और रिज़ॉल्वर की प्राथमिकता सेट करें।';

  @override
  String get settingsUIElements => 'UI एलिमेंट्स और सेवाएँ';

  @override
  String get settingsUIElementsSubtitle =>
      'ऑटो स्लाइड, ऐप के डिज़ाइन में बदलाव आदि।';

  @override
  String get settingsLastFM => 'Last.FM सेटिंग्स';

  @override
  String get settingsLastFMSubtitle =>
      'API Key, Secret, और स्क्रॉब्लिंग सेटिंग्स।';

  @override
  String get settingsStorage => 'स्टोरेज';

  @override
  String get settingsStorageSubtitle =>
      'बैकअप, कैश, हिस्ट्री, रीस्टोर और बहुत कुछ...';

  @override
  String get settingsLanguageCountry => 'भाषा और देश';

  @override
  String get settingsLanguageCountrySubtitle => 'अपनी भाषा और देश का चयन करें।';

  @override
  String get settingsAbout => 'ऐप के बारे में';

  @override
  String get settingsAboutSubtitle => 'ऐप का वर्शन, डेवलपर की जानकारी आदि।';

  @override
  String get settingsScanning => 'स्कैनिंग';

  @override
  String get settingsMusicFolders => 'म्यूज़िक फ़ोल्डर्स';

  @override
  String get settingsQuality => 'क्वालिटी';

  @override
  String get settingsHistory => 'हिस्ट्री';

  @override
  String get settingsBackupRestore => 'बैकअप और रीस्टोर';

  @override
  String get settingsAutomatic => 'ऑटोमैटिक';

  @override
  String get settingsDangerZone => 'डेंजर ज़ोन';

  @override
  String get settingsScrobbling => 'स्क्रॉब्लिंग';

  @override
  String get settingsAuthentication => 'प्रमाणीकरण';

  @override
  String get settingsHomeScreen => 'होम स्क्रीन';

  @override
  String get settingsChartVisibility => 'चार्ट दिखाएँ';

  @override
  String get settingsLocation => 'लोकेशन';

  @override
  String get pluginRepositoryTitle => 'प्लगइन रिपॉज़िटरीज़';

  @override
  String get pluginRepositorySubtitle =>
      'रिमोट प्लगइन्स ब्राउज़ करने के लिए एक JSON सोर्स जोड़ें।';

  @override
  String get pluginRepositoryAddAction => 'रिपॉज़िटरी जोड़ें';

  @override
  String get pluginRepositoryAddTitle => 'रिपॉज़िटरी जोड़ें';

  @override
  String get pluginRepositoryAddSubtitle =>
      'किसी सही प्लगइन रिपॉज़िटरी JSON फ़ाइल का URL डालें।';

  @override
  String get pluginRepositoryEmpty => 'अभी तक कोई रिपॉज़िटरी नहीं जोड़ी गई है।';

  @override
  String get pluginRepositoryUrlCopied =>
      'रिपॉज़िटरी URL क्लिपबोर्ड पर कॉपी हो गया।';

  @override
  String get pluginRepositoryNoDescription => 'कोई विवरण नहीं दिया गया है।';

  @override
  String get pluginRepositoryUnknownUpdate => 'अपडेट की जानकारी नहीं है';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लगइन्स',
      one: '1 प्लगइन',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad => 'रिपॉज़िटरीज़ लोड करने में विफल।';

  @override
  String get pluginRepositoryErrorInvalid =>
      'रिपॉज़िटरी URL या फ़ाइल सही नहीं है।';

  @override
  String get pluginRepositoryErrorRemove => 'रिपॉज़िटरी नहीं हटाई जा सकी।';

  @override
  String pluginRepositoryError(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get dialogAddingToDownloadQueue =>
      'डाउनलोड कतार में जोड़ा जा रहा है...';

  @override
  String get emptyNoInternet => 'कोई इंटरनेट कनेक्शन नहीं!';

  @override
  String get emptyNoContentPlugin =>
      'कोई कंटेंट प्लगइन मौजूद नहीं है। प्लगइन मैनेजर से एक कंटेंट रिज़ॉल्वर इंस्टॉल करें।';

  @override
  String get emptyRefreshingSource =>
      'डिस्कवर सोर्स को रीफ्रेश किया जा रहा है... पुराना सोर्स अब उपलब्ध नहीं है।';

  @override
  String get emptyNoTracks => 'कोई गाना मौजूद नहीं है';

  @override
  String get emptyNoResults => 'कोई परिणाम नहीं मिला';

  @override
  String snackbarDeletedTrack(String title) {
    return '\"$title\" हटा दिया गया';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '\"$title\" हटाने में विफल';
  }

  @override
  String get snackbarAddedToNextQueue => 'कतार में आगे जोड़ा गया';

  @override
  String get snackbarAddedToQueue => 'कतार में जोड़ा गया';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title को पसंदीदा में जोड़ा गया!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '$name चल रहा है';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name को कतार में जोड़ा गया';
  }

  @override
  String get snackbarPlaylistQueued => 'प्लेलिस्ट डाउनलोड कतार में जुड़ गई है';

  @override
  String get snackbarPlaylistUpdated => 'प्लेलिस्ट अपडेट हो गई!';

  @override
  String get snackbarNoInternet => 'कोई इंटरनेट कनेक्शन नहीं।';

  @override
  String get snackbarImportFailed => 'इम्पोर्ट विफल!';

  @override
  String get snackbarImportCompleted => 'इम्पोर्ट पूरा हुआ';

  @override
  String get snackbarBackupFailed => 'बैकअप विफल!';

  @override
  String snackbarExportedTo(String path) {
    return 'यहाँ एक्सपोर्ट किया गया: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'मीडिया ID कॉपी की गई';

  @override
  String get snackbarLinkCopied => 'लिंक कॉपी किया गया';

  @override
  String get snackbarNoLinkAvailable => 'कोई लिंक उपलब्ध नहीं है';

  @override
  String get snackbarCouldNotOpenLink => 'लिंक नहीं खोला जा सका';

  @override
  String snackbarPreparingDownload(String title) {
    return '$title को डाउनलोड के लिए तैयार किया जा रहा है...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title पहले से ही डाउनलोड है।';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title पहले से ही कतार में है।';
  }

  @override
  String snackbarDownloaded(String title) {
    return '$title डाउनलोड हो गया';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'त्रुटि: डाउनलोड सेवा अनुपलब्ध है।';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count गानों को डाउनलोड कतार में जोड़ा गया';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'डिवाइस स्टोरेज से ट्रैक हटाने में विफल।';

  @override
  String get searchHintExplore => 'आप क्या सुनना चाहते हैं?';

  @override
  String get searchHintLibrary => 'लाइब्रेरी में खोजें...';

  @override
  String get searchHintOfflineMusic => 'अपने गाने खोजें...';

  @override
  String get searchHintPlaylists => 'प्लेलिस्ट्स खोजें...';

  @override
  String get searchStartTyping => 'खोजने के लिए टाइप करना शुरू करें...';

  @override
  String get searchNoSuggestions => 'कोई सुझाव नहीं मिला!';

  @override
  String get searchNoResults =>
      'कोई परिणाम नहीं मिला!\nकुछ और खोज कर देखें या स्रोत बदलें।';

  @override
  String get searchFailed => 'खोज विफल रही!';

  @override
  String get searchDiscover => 'बेहतरीन संगीत खोजें...';

  @override
  String get searchSources => 'सोर्स';

  @override
  String get searchNoPlugins => 'कोई प्लगइन इंस्टॉल नहीं है';

  @override
  String get searchTracks => 'गाने';

  @override
  String get searchAlbums => 'एल्बम्स';

  @override
  String get searchArtists => 'कलाकार';

  @override
  String get searchPlaylists => 'प्लेलिस्ट्स';

  @override
  String get exploreDiscover => 'डिस्कवर';

  @override
  String get exploreRecently => 'हाल ही में बजाए गए';

  @override
  String get exploreLastFmPicks => 'Last.Fm पिक्स';

  @override
  String get exploreFailedToLoad => 'होम सेक्शन लोड नहीं हो पाया।';

  @override
  String get libraryTitle => 'लाइब्रेरी';

  @override
  String get libraryEmptyState =>
      'आपकी लाइब्रेरी एकदम सूनी है। अपनी पसंद के कुछ बेहतरीन गाने जोड़ें!';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName में';
  }

  @override
  String get menuAddToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get menuSmartReplace => 'स्मार्ट रिप्लेस';

  @override
  String get menuShare => 'शेयर करें';

  @override
  String get menuAvailableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get menuDownload => 'डाउनलोड करें';

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
  String get songInfoCopyId => 'ID कॉपी करें';

  @override
  String get songInfoCopyLink => 'लिंक कॉपी करें';

  @override
  String get songInfoOpenBrowser => 'ब्राउज़र में खोलें';

  @override
  String get tooltipRemoveFromLibrary => 'लाइब्रेरी से हटाएँ';

  @override
  String get tooltipSaveToLibrary => 'लाइब्रेरी में सेव करें';

  @override
  String get tooltipOpenOriginalLink => 'मूल लिंक खोलें';

  @override
  String get tooltipShuffle => 'शफ़ल';

  @override
  String get tooltipAvailableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get tooltipDownloadPlaylist => 'प्लेलिस्ट डाउनलोड करें';

  @override
  String get tooltipMoreOptions => 'और विकल्प';

  @override
  String get tooltipInfo => 'जानकारी';

  @override
  String get appuiTitle => 'UI और सेवाएँ';

  @override
  String get appuiAutoSlideCharts => 'चार्ट्स ऑटो-स्लाइड करें';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'होम स्क्रीन पर चार्ट्स अपने आप स्लाइड होंगे।';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Last.FM से गानों के सुझाव दिखाएँ। इसके लिए लॉगिन और ऐप को रीस्टार्ट करना ज़रूरी है।';

  @override
  String get appuiNoChartsAvailable =>
      'कोई चार्ट उपलब्ध नहीं है। कृपया कोई चार्ट प्रोवाइडर प्लगइन इंस्टॉल करें।';

  @override
  String get appuiLoginToLastFm => 'कृपया पहले Last.FM में लॉगिन करें।';

  @override
  String get appuiShowInCarousel => 'होम कैरोसेल में दिखाएँ।';

  @override
  String get countrySettingTitle => 'देश और भाषा';

  @override
  String get countrySettingAutoDetect => 'देश का स्वतः पता लगाएँ';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'ऐप खुलने पर स्वचालित रूप से आपके देश की पहचान करेगा।';

  @override
  String get countrySettingCountryLabel => 'देश';

  @override
  String get countrySettingLanguageLabel => 'भाषा';

  @override
  String get countrySettingSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get downloadSettingTitle => 'डाउनलोड्स';

  @override
  String get downloadSettingQuality => 'डाउनलोड क्वालिटी';

  @override
  String get downloadSettingQualitySubtitle =>
      'डाउनलोड होने वाले सभी गानों की डिफ़ॉल्ट ऑडियो क्वालिटी।';

  @override
  String get downloadSettingFolder => 'डाउनलोड फ़ोल्डर';

  @override
  String get downloadSettingResetFolder => 'डाउनलोड फ़ोल्डर रीसेट करें';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'डिफ़ॉल्ट डाउनलोड पाथ को वापस सेट करें।';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'ट्रैक्स स्क्रॉबल करें';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'बजाए गए गानों को अपनी Last.FM प्रोफ़ाइल पर सिंक करें।';

  @override
  String get lastfmAuthFirst =>
      'पहले Last.FM API को प्रमाणित (Authenticate) करें।';

  @override
  String get lastfmAuthenticatedAs => 'इसके रूप में प्रमाणित:';

  @override
  String get lastfmAuthFailed => 'प्रमाणीकरण विफल:';

  @override
  String get lastfmNotAuthenticated => 'प्रमाणित नहीं है';

  @override
  String get lastfmSteps =>
      'प्रमाणित करने के चरण:\n1. last.fm पर अपना खाता बनाएँ या खोलें\n2. last.fm/api/account/create पर जाकर API Key बनाएँ\n3. नीचे API Key और Secret दर्ज करें\n4. \"प्रमाणीकरण शुरू करें\" पर टैप करके ब्राउज़र में अनुमति दें\n5. पूरा करने के लिए \"सेशन Key प्राप्त करें और सहेजें\" पर टैप करें';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. प्रमाणीकरण शुरू करें';

  @override
  String get lastfmGetSession => '2. सेशन Key प्राप्त करें और सहेजें';

  @override
  String get lastfmRemoveKeys => 'Keys हटाएँ';

  @override
  String get lastfmStartAuthFirst =>
      'पहले प्रमाणीकरण शुरू करें, फिर ब्राउज़र में स्वीकृति दें।';

  @override
  String get localSettingTitle => 'लोकल ट्रैक्स';

  @override
  String get localSettingAutoScan => 'ऐप शुरू होने पर स्वतः स्कैन करें';

  @override
  String get localSettingAutoScanSubtitle =>
      'ऐप खुलने पर नए लोकल गानों के लिए अपने-आप स्कैन करेगा।';

  @override
  String get localSettingLastScan => 'अंतिम स्कैन';

  @override
  String get localSettingNeverScanned => 'कभी नहीं';

  @override
  String get localSettingScanInProgress => 'स्कैनिंग जारी है…';

  @override
  String get localSettingScanNowSubtitle =>
      'पूरी लाइब्रेरी को मैन्युअल रूप से स्कैन करें।';

  @override
  String get localSettingNoFolders =>
      'कोई फ़ोल्डर नहीं जुड़ा है। स्कैनिंग शुरू करने के लिए एक फ़ोल्डर जोड़ें।';

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
      'ऑनलाइन गाने बजाने के लिए डिफ़ॉल्ट ऑडियो बिटरेट।';

  @override
  String get playerSettingQualityLow => 'कम (Low)';

  @override
  String get playerSettingQualityMedium => 'मध्यम (Medium)';

  @override
  String get playerSettingQualityHigh => 'उच्च (High)';

  @override
  String get playerSettingPlaybackHeader => 'प्लेबैक';

  @override
  String get playerSettingAutoPlay => 'ऑटो प्ले';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'कतार खत्म होने पर उसी तरह के अन्य गाने अपने-आप बजने लगें।';

  @override
  String get playerSettingAutoFallback => 'ऑटो फ़ॉलबैक प्लेबैक';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'यदि कोई प्लगइन काम न करे, तो गाना चलाने के लिए किसी अन्य संगत रिज़ॉल्वर का इस्तेमाल करें।';

  @override
  String get playerSettingCrossfade => 'क्रॉसफ़ेड (Crossfade)';

  @override
  String get playerSettingCrossfadeOff => 'बंद';

  @override
  String get playerSettingCrossfadeInstant => 'गाने तुरंत बदलेंगे';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'गानों के बीच $seconds सेकंड का ब्लेंड';
  }

  @override
  String get playerSettingEqualizer => 'इक्वलाइज़र';

  @override
  String get playerSettingEqualizerActive => 'चालू';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'चालू — $preset प्रीसेट';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'FFmpeg के ज़रिए 10-बैंड पैरामेट्रिक EQ।';

  @override
  String get pluginDefaultsTitle => 'प्लगइन डिफ़ॉल्ट्स';

  @override
  String get pluginDefaultsDiscoverHeader => 'डिस्कवर सोर्स';

  @override
  String get pluginDefaultsNoResolver =>
      'कोई कंटेंट रिज़ॉल्वर इंस्टॉल नहीं है। डिस्कवर सोर्स चुनने के लिए प्लगइन लोड करें।';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'जो भी पहला कंटेंट रिज़ॉल्वर उपलब्ध हो, उसका उपयोग करें।';

  @override
  String get pluginDefaultsPriorityHeader => 'रिज़ॉल्वर की प्राथमिकता';

  @override
  String get pluginDefaultsNoPriority =>
      'कोई कंटेंट रिज़ॉल्वर नहीं मिला। प्लगइन्स इंस्टॉल होने के बाद आप यहाँ उनकी प्राथमिकता तय कर सकेंगे।';

  @override
  String get pluginDefaultsPriorityDesc =>
      'क्रम बदलने के लिए ऊपर-नीचे खींचें। गाने खोजते समय सबसे ऊपर वाले रिज़ॉल्वर को पहले आज़माया जाएगा।';

  @override
  String get pluginDefaultsLyricsHeader => 'लिरिक्स की प्राथमिकता';

  @override
  String get pluginDefaultsLyricsNone => 'लिरिक्स वाला कोई प्लगइन लोड नहीं है।';

  @override
  String get pluginDefaultsLyricsDesc =>
      'लिरिक्स प्रदाताओं का क्रम बदलने के लिए उन्हें खींचें।';

  @override
  String get pluginDefaultsSuggestionsHeader => 'खोज के सुझाव';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'खोज सुझाव वाला कोई प्लगइन मौजूद नहीं है।';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'कोई नहीं';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'केवल मेरी पुरानी खोज (History) का इस्तेमाल करें।';

  @override
  String get storageSettingTitle => 'स्टोरेज';

  @override
  String get storageClearHistoryEvery => 'हिस्ट्री कितने दिनों में साफ करें';

  @override
  String get storageClearHistorySubtitle =>
      'चुने गए समय के बाद सुनने की हिस्ट्री अपने-आप मिटा दी जाएगी।';

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
  String get storageBackupLocation => 'बैकअप की जगह';

  @override
  String get storageBackupLocationAndroid => 'Downloads / App-Data फ़ोल्डर';

  @override
  String get storageBackupLocationDownloads => 'Downloads फ़ोल्डर';

  @override
  String get storageCreateBackup => 'बैकअप बनाएँ';

  @override
  String get storageCreateBackupSubtitle =>
      'अपनी सेटिंग्स और डेटा को एक बैकअप फ़ाइल में सुरक्षित करें।';

  @override
  String storageBackupCreatedAt(String path) {
    return 'बैकअप $path में बन गया है';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'बैकअप शेयर करने में विफल: $error';
  }

  @override
  String get storageBackupFailed => 'बैकअप विफल रहा!';

  @override
  String get storageRestoreBackup => 'बैकअप रीस्टोर करें';

  @override
  String get storageRestoreBackupSubtitle =>
      'किसी बैकअप फ़ाइल से अपनी सेटिंग्स और डेटा वापस लाएँ।';

  @override
  String get storageAutoBackup => 'ऑटो बैकअप';

  @override
  String get storageAutoBackupSubtitle =>
      'समय-समय पर अपने डेटा का बैकअप अपने-आप तैयार करें।';

  @override
  String get storageAutoLyrics => 'लिरिक्स अपने-आप सेव करें';

  @override
  String get storageAutoLyricsSubtitle =>
      'गाना बजते समय उसके लिरिक्स अपने-आप डिवाइस में सेव कर लें।';

  @override
  String get storageResetApp => 'Bloomee ऐप को रीसेट करें';

  @override
  String get storageResetAppSubtitle =>
      'सारा डेटा मिटाकर ऐप को उसकी शुरुआती स्थिति में वापस लाएँ।';

  @override
  String get storageResetConfirmTitle => 'रीसेट की पुष्टि करें';

  @override
  String get storageResetConfirmMessage =>
      'क्या आप वाकई Bloomee को रीसेट करना चाहते हैं? इससे आपका सारा डेटा डिलीट हो जाएगा और इसे वापस नहीं पाया जा सकेगा।';

  @override
  String get storageResetButton => 'रीसेट करें';

  @override
  String get storageResetSuccess => 'ऐप को पूरी तरह से रीसेट कर दिया गया है।';

  @override
  String get storageLocationDialogTitle => 'बैकअप की लोकेशन';

  @override
  String get storageLocationAndroid =>
      'बैकअप यहाँ सेव किए जाते हैं:\n\n1. Downloads फ़ोल्डर\n2. Android/data/ls.bloomee.musicplayer/data\n\nदोनों में से किसी भी जगह से आप फ़ाइल कॉपी कर सकते हैं।';

  @override
  String get storageLocationOther =>
      'बैकअप आपके Downloads फ़ोल्डर में मौजूद हैं।';

  @override
  String get storageRestoreOptionsTitle => 'रीस्टोर विकल्प';

  @override
  String get storageRestoreOptionsDesc =>
      'चुनें कि बैकअप फ़ाइल में से आप कौन-सा डेटा वापस लाना चाहते हैं। जिन्हें आप इम्पोर्ट नहीं करना चाहते, उनसे टिक हटा दें।';

  @override
  String get storageRestoreSelectAll => 'सभी चुनें';

  @override
  String get storageRestoreMediaItems =>
      'मीडिया डेटा (गाने, ट्रैक्स, लाइब्रेरी)';

  @override
  String get storageRestoreSearchHistory => 'खोज की हिस्ट्री (Search History)';

  @override
  String get storageRestoreContinue => 'जारी रखें';

  @override
  String get storageRestoreNoFile => 'कोई फ़ाइल नहीं चुनी गई।';

  @override
  String get storageRestoreSaveFailed => 'चुनी गई फ़ाइल सेव नहीं हो पाई।';

  @override
  String get storageRestoreConfirmTitle => 'रीस्टोर की पुष्टि करें';

  @override
  String get storageRestoreConfirmPrefix =>
      'यह आपके चुने हुए ऐप के मौजूदा डेटा को बैकअप फ़ाइल के डेटा के साथ बदल या मिला देगा:';

  @override
  String get storageRestoreConfirmSuffix =>
      'आपका मौजूदा डेटा बदल जाएगा। क्या आप सचमुच आगे बढ़ना चाहते हैं?';

  @override
  String get storageRestoreYes => 'हाँ, रीस्टोर करें';

  @override
  String get storageRestoreNo => 'नहीं';

  @override
  String get storageRestoring =>
      'चुना हुआ डेटा रीस्टोर किया जा रहा है…\nकृपया प्रक्रिया पूरी होने तक इंतज़ार करें।';

  @override
  String get storageRestoreMediaBullet => '• मीडिया डेटा';

  @override
  String get storageRestoreHistoryBullet => '• खोज की हिस्ट्री';

  @override
  String get storageUnexpectedError =>
      'रीस्टोर करते समय कुछ अज्ञात त्रुटि आ गई।';

  @override
  String get storageRestoreCompleted => 'रीस्टोर पूरा हुआ';

  @override
  String get storageRestoreFailedTitle => 'रीस्टोर विफल';

  @override
  String get storageRestoreSuccessMessage =>
      'डेटा सफलतापूर्वक रीस्टोर कर लिया गया है। बेहतर अनुभव के लिए, कृपया ऐप को एक बार बंद करके दोबारा खोलें।';

  @override
  String get storageRestoreFailedMessage =>
      'रीस्टोर प्रक्रिया इन वजहों से पूरी नहीं हो पाई:';

  @override
  String get storageRestoreUnknownError =>
      'रीस्टोर के दौरान अज्ञात समस्या आ गई।';

  @override
  String get storageRestoreRestartHint =>
      'ऐप को सुचारू रूप से चलाने के लिए कृपया इसे रीस्टार्ट करें।';

  @override
  String get updateSettingTitle => 'अपडेट्स';

  @override
  String get updateAppUpdatesHeader => 'ऐप अपडेट्स';

  @override
  String get updateCheckForUpdates => 'अपडेट्स चेक करें';

  @override
  String get updateCheckSubtitle =>
      'देखें कि Bloomee का कोई नया वर्शन मौजूद है या नहीं।';

  @override
  String get updateAutoNotify => 'ऑटो अपडेट सूचना';

  @override
  String get updateAutoNotifySubtitle =>
      'ऐप खोलते ही नया अपडेट उपलब्ध होने पर जानकारी पाएँ।';

  @override
  String get updateCheckTitle => 'अपडेट्स चेक करें';

  @override
  String get updateUpToDate => 'Bloomee🌸 पूरी तरह से अपडेटेड है!';

  @override
  String get updateViewPreRelease => 'नया प्री-रिलीज़ वर्शन देखें';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'वर्तमान वर्शन: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Bloomee🌸 का एक नया वर्शन उपलब्ध है!';

  @override
  String updateVersion(String ver, String build) {
    return 'वर्शन: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'अभी डाउनलोड करें';

  @override
  String get updateChecking => 'नए वर्शन की जाँच की जा रही है!';

  @override
  String get timerTitle => 'स्लीप टाइमर';

  @override
  String get timerInterludeMessage => 'कुछ ही देर में संगीत रुक जाएगा…';

  @override
  String get timerHours => 'घंटे';

  @override
  String get timerMinutes => 'मिनट';

  @override
  String get timerSeconds => 'सेकंड';

  @override
  String get timerStop => 'टाइमर रोकें';

  @override
  String get timerFinishedMessage => 'संगीत बंद हो गया है। शुभ रात्रि 🥰।';

  @override
  String get timerGotIt => 'समझ गया!';

  @override
  String get timerSetTimeError => 'कृपया एक समय सेट करें';

  @override
  String get timerStart => 'टाइमर शुरू करें';

  @override
  String get notificationsTitle => 'नोटिफ़िकेशन्स';

  @override
  String get notificationsEmpty => 'अभी तक कोई नया नोटिफ़िकेशन नहीं है!';

  @override
  String get recentsTitle => 'हिस्ट्री';

  @override
  String playlistByCreator(String creator) {
    return '$creator के द्वारा';
  }

  @override
  String get playlistTypeAlbum => 'एल्बम';

  @override
  String get playlistTypePlaylist => 'प्लेलिस्ट';

  @override
  String get playlistYou => 'आप';

  @override
  String get pluginManagerTitle => 'प्लगइन्स';

  @override
  String get pluginManagerEmpty =>
      'कोई प्लगइन इंस्टॉल नहीं है।\n.bex फ़ाइल जोड़ने के लिए + पर टैप करें।';

  @override
  String get pluginManagerFilterAll => 'सभी';

  @override
  String get pluginManagerFilterContent => 'कंटेंट रिज़ॉल्वर्स';

  @override
  String get pluginManagerFilterCharts => 'चार्ट प्रदाता';

  @override
  String get pluginManagerFilterLyrics => 'लिरिक्स प्रदाता';

  @override
  String get pluginManagerFilterSuggestions => 'सुझाव प्रदाता';

  @override
  String get pluginManagerFilterImporters => 'कंटेंट इम्पोर्टर्स';

  @override
  String get pluginManagerTooltipRefresh => 'रीफ्रेश करें';

  @override
  String get pluginManagerTooltipInstall => 'प्लगइन इंस्टॉल करें';

  @override
  String get pluginManagerNoMatch => 'इस फ़िल्टर से कोई प्लगइन मैच नहीं हुआ।';

  @override
  String pluginManagerPickFailed(String error) {
    return 'फ़ाइल चुनने में दिक्कत आई: $error';
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
  String get pluginManagerTypeSuggestionProvider => 'खोज के सुझाव';

  @override
  String get pluginManagerTypeContentImporter => 'कंटेंट इम्पोर्टर';

  @override
  String get pluginManagerDeleteTitle => 'प्लगइन हटाएँ?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं? यह इसकी फ़ाइलों को हमेशा के लिए मिटा देगा।';
  }

  @override
  String get pluginManagerDeleteAction => 'हटाएँ';

  @override
  String get pluginManagerCancel => 'रद्द करें';

  @override
  String get pluginManagerEnablePlugin => 'प्लगइन चालू करें';

  @override
  String get pluginManagerUnloadPlugin => 'प्लगइन बंद करें';

  @override
  String get pluginManagerDeleting => 'हटाया जा रहा है...';

  @override
  String get pluginManagerApiKeysTitle => 'API Keys';

  @override
  String get pluginManagerApiKeysSaved => 'API keys सेव कर ली गई हैं';

  @override
  String get pluginManagerSave => 'सेव करें';

  @override
  String get pluginManagerDetailVersion => 'वर्शन';

  @override
  String get pluginManagerDetailType => 'प्रकार';

  @override
  String get pluginManagerDetailPublisher => 'प्रकाशक';

  @override
  String get pluginManagerDetailLastUpdated => 'अंतिम अपडेट';

  @override
  String get pluginManagerDetailCreated => 'बनाया गया';

  @override
  String get pluginManagerDetailHomepage => 'होमपेज';

  @override
  String get pluginManagerDowngradeTitle => 'प्लगइन को डाउनग्रेड करें?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'आप \"$name\" का कोई पुराना या समान वर्शन इंस्टॉल कर रहे हैं। क्या आप ऐसा करना चाहते हैं?';
  }

  @override
  String get pluginManagerDowngradeAction => 'हाँ, इंस्टॉल करें';

  @override
  String get pluginManagerDeleteStorageTitle => 'प्लगइन डेटा भी हटाएँ?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'क्या \"$name\" के लिए सेव की गई API कुंजियाँ और सेटिंग्स भी हटा दी जाएँ?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'डेटा रखें';

  @override
  String get pluginManagerDeleteStorageRemove => 'डेटा हटाएँ';

  @override
  String get segmentsSheetTitle => 'सेगमेंट्स';

  @override
  String get segmentsSheetEmpty => 'कोई सेगमेंट उपलब्ध नहीं है';

  @override
  String get segmentsSheetUntitled => 'बिना नाम का सेगमेंट';

  @override
  String get smartReplaceTitle => 'स्मार्ट रिप्लेस';

  @override
  String smartReplaceSubtitle(String title) {
    return '\"$title\" की जगह चलने वाला कोई दूसरा ट्रैक चुनें और सेव की गई प्लेलिस्ट को अपडेट करें।';
  }

  @override
  String get smartReplaceClose => 'बंद करें';

  @override
  String get smartReplaceNoMatch => 'कोई विकल्प नहीं मिला';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'किसी भी रिज़ॉल्वर प्लगइन को सही मैच नहीं मिला।';

  @override
  String get smartReplaceBestMatch => 'सर्वश्रेष्ठ मैच';

  @override
  String get smartReplaceSearchFailed => 'खोज विफल रही';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'स्मार्ट रिप्लेस विफल: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'नया गाना लागू किया गया$queue।';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '$count प्लेलिस्ट$plural में गाना बदल दिया गया$queue।';
  }

  @override
  String get smartReplaceQueueUpdated => ' और कतार अपडेट की गई';

  @override
  String get playerUnknownQueue => 'अज्ञात';

  @override
  String playerLiked(String title) {
    return '$title को पसंद किया गया!!';
  }

  @override
  String playerUnliked(String title) {
    return '$title से पसंद हटाई गई!!';
  }

  @override
  String get offlineNoDownloads => 'कोई गाना डाउनलोड नहीं है';

  @override
  String get offlineTitle => 'ऑफ़लाइन';

  @override
  String get offlineSearchHint => 'अपने गाने खोजें...';

  @override
  String get offlineRefreshTooltip => 'डाउनलोड्स रीफ्रेश करें';

  @override
  String get offlineCloseSearch => 'खोज बंद करें';

  @override
  String get offlineSearchTooltip => 'खोजें';

  @override
  String get offlineOpenFailed =>
      'इस ऑफ़लाइन ट्रैक को नहीं खोला जा सका। कृपया डाउनलोड्स को रीफ्रेश करके देखें।';

  @override
  String get offlinePlayFailed =>
      'यह ऑफ़लाइन गाना नहीं चल पाया। कृपया दोबारा कोशिश करें।';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रैक्स',
      one: '1 ट्रैक',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'एल्बम लोड नहीं हो पाया';

  @override
  String get aboutCraftingSubtitle => 'कोड के ज़रिए संगीत पिरोना।';

  @override
  String get aboutFollowGitHub => 'GitHub पर फ़ॉलो करें';

  @override
  String get aboutSendInquiry => 'बिज़नेस के लिए संपर्क करें';

  @override
  String get aboutCreativeHighlights => 'अपडेट्स और रचनात्मक बातें';

  @override
  String get aboutTipQuote =>
      'Bloomee पसंद आ रहा है? आपका छोटा-सा सहयोग इसे और बेहतर बनाने में मदद करेगा। 🌸';

  @override
  String get aboutTipButton => 'मैं सहायता करना चाहता/चाहती हूँ';

  @override
  String get aboutTipDesc => 'Bloomee को और बेहतर बनाने में अपना योगदान दें।';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'गाने का विवरण';

  @override
  String get songInfoSectionTechnical => 'तकनीकी जानकारी';

  @override
  String get songInfoSectionActions => 'कार्रवाइयाँ';

  @override
  String get songInfoLabelTitle => 'शीर्षक';

  @override
  String get songInfoLabelArtist => 'कलाकार';

  @override
  String get songInfoLabelAlbum => 'एल्बम';

  @override
  String get songInfoLabelDuration => 'अवधि';

  @override
  String get songInfoLabelSource => 'सोर्स';

  @override
  String get songInfoLabelMediaId => 'मीडिया ID';

  @override
  String get songInfoLabelPluginId => 'प्लगइन ID';

  @override
  String get songInfoIdCopied => 'मीडिया ID कॉपी हो गई है';

  @override
  String get songInfoLinkCopied => 'लिंक कॉपी हो गया है';

  @override
  String get songInfoNoLink => 'कोई लिंक मौजूद नहीं है';

  @override
  String get songInfoOpenFailed => 'लिंक नहीं खुल पाया';

  @override
  String get songInfoUpdateMetadata => 'मेटाडेटा अपडेट करें';

  @override
  String get songInfoMetadataUpdated => 'मेटाडेटा अपडेट कर दिया गया है';

  @override
  String get songInfoMetadataUpdateFailed => 'मेटाडेटा अपडेट नहीं हो सका';

  @override
  String get songInfoMetadataUnavailable =>
      'इस सोर्स के लिए नया डेटा लाना उपलब्ध नहीं है';

  @override
  String get songInfoSearchTitle => 'Bloomee में यह गाना खोजें';

  @override
  String get songInfoSearchArtist => 'Bloomee में इस कलाकार को खोजें';

  @override
  String get songInfoSearchAlbum => 'Bloomee में इस एल्बम को खोजें';

  @override
  String get eqTitle => 'इक्वलाइज़र';

  @override
  String get eqResetTooltip => 'रीसेट करें (Flat)';

  @override
  String get chartNoItems => 'इस चार्ट में कोई गाना नहीं है';

  @override
  String get chartLoadFailed => 'चार्ट लोड करने में समस्या आई';

  @override
  String get chartPlay => 'चलाएँ';

  @override
  String get chartResolving => 'खोजा जा रहा है';

  @override
  String get chartReady => 'तैयार';

  @override
  String get chartAddToPlaylist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get chartNoResolver =>
      'कोई कंटेंट रिज़ॉल्वर लोड नहीं है। चलाने के लिए एक प्लगइन इंस्टॉल करें।';

  @override
  String get chartResolveFailed =>
      'गाना नहीं मिल पाया। इसके बजाय सर्च किया जा रहा है...';

  @override
  String get chartNoResolverAdd => 'कोई कंटेंट रिज़ॉल्वर इंस्टॉल नहीं है।';

  @override
  String get chartNoMatch => 'कोई मैच नहीं मिला। कृपया ख़ुद सर्च करके देखें।';

  @override
  String get chartStatPeak => 'शिखर (Peak)';

  @override
  String get chartStatWeeks => 'सप्ताह';

  @override
  String get chartStatChange => 'बदलाव';

  @override
  String menuSharePreparing(String title) {
    return '$title को शेयर करने के लिए तैयार किया जा रहा है।';
  }

  @override
  String get menuOpenLinkFailed => 'लिंक नहीं खुल पाया';

  @override
  String get localMusicFolders => 'म्यूज़िक फ़ोल्डर्स';

  @override
  String get localMusicCloseSearch => 'खोज बंद करें';

  @override
  String get localMusicOpenSearch => 'खोजें';

  @override
  String get localMusicNoMusicFound => 'कोई लोकल गाना नहीं मिला';

  @override
  String get localMusicNoSearchResults =>
      'आपकी खोज से मिलता-जुलता कोई ट्रैक नहीं मिला।';

  @override
  String get importSongsTitle => 'गाने इम्पोर्ट करें';

  @override
  String get importNoPluginsLoaded =>
      'कोई इम्पोर्टर प्लगइन मौजूद नहीं है।\nबाहरी जगहों से प्लेलिस्ट लाने के लिए पहले कोई इम्पोर्टर प्लगइन इंस्टॉल करें।';

  @override
  String get importBloomeeFiles => 'Bloomee फ़ाइलें इम्पोर्ट करें';

  @override
  String get importM3UFiles => 'M3U प्लेलिस्ट इम्पोर्ट करें';

  @override
  String get importM3UNameDialogTitle => 'प्लेलिस्ट का नाम';

  @override
  String get importM3UNameHint => 'इस प्लेलिस्ट का कोई नाम रखें';

  @override
  String get importM3UNoTracks =>
      'इस M3U फ़ाइल में कोई भी सही ट्रैक नहीं मिला।';

  @override
  String get importNoteTitle => 'नोट';

  @override
  String get importNoteMessage =>
      'आप केवल Bloomee द्वारा बनाई गई फ़ाइलें ही इम्पोर्ट कर सकते हैं।\nयदि आपकी फ़ाइल किसी और जगह की है, तो वह काम नहीं करेगी। क्या आप फिर भी आगे बढ़ना चाहते हैं?';

  @override
  String get importTitle => 'इम्पोर्ट करें';

  @override
  String get importCheckingUrl => 'URL की जाँच हो रही है...';

  @override
  String get importFetchingTracks => 'गाने लाए जा रहे हैं...';

  @override
  String get importSavingToLibrary => 'लाइब्रेरी में सेव किया जा रहा है...';

  @override
  String get importPasteUrlHint =>
      'इम्पोर्ट करने के लिए किसी प्लेलिस्ट या एल्बम का URL यहाँ पेस्ट करें';

  @override
  String get importAction => 'इम्पोर्ट करें';

  @override
  String importTrackCount(int count) {
    return '$count गाने';
  }

  @override
  String get importResolving => 'सर्च किया जा रहा है...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'गानों को ढूँढा जा रहा है: $done / $total';
  }

  @override
  String get importReviewTitle => 'इम्पोर्ट की समीक्षा';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$total में से $resolved मिल गए, $failed नहीं मिले';
  }

  @override
  String importSaveTracks(int count) {
    return '$count गाने सेव करें';
  }

  @override
  String importTracksSaved(int count) {
    return '$count गाने सेव हो गए!';
  }

  @override
  String get importDone => 'हो गया';

  @override
  String get importMore => 'और इम्पोर्ट करें';

  @override
  String get importUnknownError => 'कुछ अज्ञात समस्या आ गई';

  @override
  String get importTryAgain => 'दोबारा कोशिश करें';

  @override
  String get importSkipTrack => 'इस गाने को छोड़ दें';

  @override
  String get importMatchOptions => 'मैच के विकल्प';

  @override
  String get importAutoMatched => 'अपने-आप मैच हुआ';

  @override
  String get importUserSelected => 'आपके द्वारा चुना गया';

  @override
  String get importSkipped => 'छोड़ दिया गया';

  @override
  String get importNoMatch => 'कोई मैच नहीं मिला';

  @override
  String get importReorderTip =>
      'प्लेलिस्ट का क्रम बदलने के लिए उसे देर तक दबाकर रखें';

  @override
  String get importErrorCannotHandleUrl =>
      'यह प्लगइन इस URL को सपोर्ट नहीं करता।';

  @override
  String get importErrorUnexpectedResponse => 'प्लगइन से सही जवाब नहीं मिला।';

  @override
  String importErrorFailedToCheck(String error) {
    return 'URL जाँचने में विफल: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'कलेक्शन की जानकारी नहीं मिल पाई: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'गाने नहीं मिल पाए: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'प्लेलिस्ट सेव करने में विफल: $error';
  }

  @override
  String get playlistPinToTop => 'सबसे ऊपर पिन करें';

  @override
  String get playlistUnpin => 'अनपिन करें';

  @override
  String get snackbarImportingMedia => 'मीडिया आइटम्स लाये जा रहे हैं...';

  @override
  String get snackbarPlaylistSaved =>
      'प्लेलिस्ट आपकी लाइब्रेरी में सेव हो गई है!';

  @override
  String get snackbarInvalidFileFormat => 'फ़ाइल का फ़ॉर्मैट सही नहीं है';

  @override
  String get snackbarMediaItemImported => 'मीडिया आइटम इम्पोर्ट कर लिया गया';

  @override
  String get snackbarPlaylistImported => 'प्लेलिस्ट इम्पोर्ट कर ली गई';

  @override
  String get snackbarOpenImportForUrl =>
      'इस URL से गानें लाने के लिए लाइब्रेरी में \'इम्पोर्ट\' स्क्रीन खोलें।';

  @override
  String get snackbarProcessingFile => 'फ़ाइल को प्रोसेस किया जा रहा है...';

  @override
  String snackbarPreparingShare(String title) {
    return '$title को शेयर करने के लिए तैयार किया जा रहा है';
  }

  @override
  String snackbarPreparingExport(String title) {
    return '$title को एक्सपोर्ट करने के लिए तैयार किया जा रहा है।';
  }

  @override
  String get pluginManagerTabInstalled => 'इंस्टॉल किए गए';

  @override
  String get pluginManagerTabStore => 'प्लगइन स्टोर';

  @override
  String get pluginManagerSelectPackage => 'प्लगइन पैकेज (.bex) चुनें';

  @override
  String get pluginManagerOutdatedManifest =>
      'यह प्लगइन बहुत पुराना है। कुछ फ़ीचर्स काम करना बंद कर सकते हैं। इसे अपडेट करने पर विचार करें।';

  @override
  String get pluginManagerStatusActive => 'चालू';

  @override
  String get pluginManagerStatusInactive => 'बंद';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return '$date को अपडेट हुआ';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लगइन्स मौजूद',
      one: '1 प्लगइन मौजूद',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'पुराना मैनिफेस्ट। फ़ीचर्स ठीक से काम नहीं कर सकते।';

  @override
  String get pluginRepositoryUnknownPublisher => 'प्रकाशक अज्ञात है';

  @override
  String get pluginRepositoryActionRetry => 'दोबारा कोशिश करें';

  @override
  String get pluginRepositoryActionOutdated => 'पुराना वर्शन';

  @override
  String get pluginRepositoryActionInstalled => 'इंस्टॉल्ड';

  @override
  String get pluginRepositoryActionInstall => 'इंस्टॉल करें';

  @override
  String get pluginRepositoryActionUnavailable => 'उपलब्ध नहीं';

  @override
  String get pluginRepositoryInstallFailed => 'इंस्टॉलेशन पूरा नहीं हो सका।';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name को डाउनलोड करने में समस्या आई।';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्लेलिस्ट्स में गाना बदल दिया गया$queue।',
      one: '1 प्लेलिस्ट में गाना बदल दिया गया$queue।',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'लिरिक्स खोजें...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'लिरिक्स खोजने के लिए गाने या कलाकार का नाम टाइप करें।';

  @override
  String lyricsSearchNoResults(String query) {
    return '\"$query\" के लिए कोई लिरिक्स नहीं मिले';
  }

  @override
  String get lyricsSearchApplied => 'लिरिक्स सफलतापूर्वक सेट कर दिए गए हैं';

  @override
  String get lyricsSearchFetchFailed => 'लिरिक्स नहीं मिल पाए';

  @override
  String get lyricsSearchPreview => 'पूर्वावलोकन (Preview)';

  @override
  String get lyricsSearchPreviewTooltip => 'लिरिक्स का पूर्वावलोकन देखें';

  @override
  String get lyricsSearchSynced => 'सिंक किए हुए';

  @override
  String get lyricsSearchPreviewLoadFailed => 'लिरिक्स लोड नहीं हो सके।';

  @override
  String get lyricsSearchApplyAction => 'लिरिक्स लगाएँ';

  @override
  String get lyricsSettingsSearchTitle => 'कस्टम लिरिक्स खोजें';

  @override
  String get lyricsSettingsSearchSubtitle =>
      'लिरिक्स के दूसरे वर्शन ऑनलाइन खोजें';

  @override
  String get lyricsSettingsSyncTitle => 'लिरिक्स की टाइमिंग सेट करें';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'अगर लिरिक्स गाने से आगे या पीछे चल रहे हों, तो उन्हें ठीक करें';

  @override
  String get lyricsSettingsSaveTitle => 'ऑफ़लाइन सेव करें';

  @override
  String get lyricsSettingsSaveSubtitle =>
      'इन लिरिक्स को अपने डिवाइस में हमेशा के लिए सेव करें';

  @override
  String get lyricsSettingsDeleteTitle => 'सेव किए गए लिरिक्स हटाएँ';

  @override
  String get lyricsSettingsDeleteSubtitle => 'ऑफ़लाइन लिरिक्स का डेटा हटा दें';

  @override
  String get lyricsSyncTapToReset => 'रीसेट करने के लिए टैप करें';

  @override
  String get upNextTitle => 'आगे क्या बजेगा';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कतार में $count गाने हैं',
      one: 'कतार में 1 गाना है',
    );
    return '$_temp0';
  }

  @override
  String get upNextAutoPlay => 'ऑटो प्ले';

  @override
  String get tooltipCopyToClipboard => 'क्लिपबोर्ड पर कॉपी करें';

  @override
  String get snackbarCopiedToClipboard => 'क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get tooltipSongInfo => 'गाने की जानकारी';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'जो गाना अभी बज रहा है, उसे हटाया नहीं जा सकता';

  @override
  String get playerLoopOff => 'रिपीट बंद';

  @override
  String get playerLoopOne => 'यही गाना दोहराएँ';

  @override
  String get playerLoopAll => 'सभी दोहराएँ';

  @override
  String get snackbarOpeningAlbumPage => 'मूल एल्बम का पेज खोला जा रहा है।';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Bloomee🌸 का नया वर्शन आ गया है!\n\nवर्शन: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'प्लगइन \"$id\" सफलतापूर्वक इंस्टॉल हो गया';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'प्लगइन \"$id\" लोड हो गया';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'प्लगइन \"$id\" सफलतापूर्वक हटा दिया गया';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee को तैयार किया जा रहा है';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'नया प्लगइन इंजन सेट हो रहा है... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'ऐसा सिर्फ़ पहली बार होता है।';

  @override
  String get pluginBootstrapErrorTitle => 'इंटरनेट कनेक्शन धीमा है';

  @override
  String get pluginBootstrapErrorBody =>
      'कुछ प्लगइन्स इंस्टॉल नहीं हो सके। आप फिर भी Bloomee का उपयोग कर सकते हैं — ऐप दोबारा खुलने पर इन्हें इंस्टॉल करने की कोशिश की जाएगी।';

  @override
  String get pluginBootstrapContinue => 'फिर भी आगे बढ़ें';
}
