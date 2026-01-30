// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcome => 'ब्लूमी में आपका स्वागत है';

  @override
  String get onboardingSubtitle =>
      'आपकी विज्ञापन-मुक्त संगीत यात्रा यहाँ से शुरू होती है। अपने अनुभव को अपनी पसंद के अनुसार ढालें।';

  @override
  String get country => 'देश';

  @override
  String get language => 'भाषा';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get discover => 'खोजें';

  @override
  String get history => 'इतिहास';

  @override
  String get library => 'लाइब्रेरी';

  @override
  String get explore => 'एक्सप्लोर';

  @override
  String get search => 'सर्च';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get searchHint => 'अपना पसंदीदा गीत ढूंढें...';

  @override
  String get songs => 'गाने';

  @override
  String get albums => 'एल्बम';

  @override
  String get artists => 'कलाकार';

  @override
  String get playlists => 'प्लेलिस्ट';

  @override
  String get recently => 'हाल ही में';

  @override
  String get lastFmPicks => 'Last.Fm की पसंद';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं है!';

  @override
  String get enjoyingFrom => 'सुन रहे हैं';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get availableOffline => 'ऑफ़लाइन उपलब्ध';

  @override
  String get timer => 'टाइमर';

  @override
  String get lyrics => 'लिरिक्स';

  @override
  String get loop => 'लूप';

  @override
  String get off => 'बंद';

  @override
  String get loopOne => 'एक दोहराएं';

  @override
  String get loopAll => 'सभी दोहराएं';

  @override
  String get shuffle => 'शफल';

  @override
  String get openOriginalLink => 'मूल लिंक खोलें';

  @override
  String get unableToOpenLink => 'लिंक खोलने में असमर्थ';

  @override
  String get updates => 'अपडेट';

  @override
  String get checkUpdates => 'नए अपडेट की जांच करें';

  @override
  String get downloads => 'डाउनलोड';

  @override
  String get downloadsSubtitle => 'डाउनलोड पाथ, गुणवत्ता और बहुत कुछ...';

  @override
  String get playerSettings => 'प्लेयर सेटिंग्स';

  @override
  String get playerSettingsSubtitle => 'स्ट्रीम गुणवत्ता, ऑटो प्ले, आदि।';

  @override
  String get uiSettings => 'UI तत्व और सेवाएँ';

  @override
  String get uiSettingsSubtitle => 'ऑटो स्लाइड, सोर्स इंजन आदि।';

  @override
  String get lastFmSettings => 'Last.FM सेटिंग्स';

  @override
  String get lastFmSettingsSubtitle =>
      'API की, सीक्रेट और स्क्रॉबलिंग सेटिंग्स।';

  @override
  String get storage => 'स्टोरेज';

  @override
  String get storageSubtitle => 'बैकअप, कैश, इतिहास, रिस्टोर और बहुत कुछ...';

  @override
  String get languageCountry => 'भाषा और देश';

  @override
  String get languageCountrySubtitle => 'अपनी भाषा और देश चुनें।';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get aboutSubtitle => 'ऐप, वर्शन, डेवलपर आदि के बारे में।';

  @override
  String get searchLibrary => 'लाइब्रेरी में खोजें...';

  @override
  String get emptyLibraryMessage =>
      'आपकी लाइब्रेरी खाली लग रही है। इसे सजाने के लिए कुछ गाने जोड़ें!';

  @override
  String get noMatchesFound => 'कोई मिलान नहीं मिला';

  @override
  String inPlaylist(String playlistName) {
    return '$playlistName में';
  }

  @override
  String artistWithEngine(String engine) {
    return 'कलाकार - $engine';
  }

  @override
  String albumWithEngine(String engine) {
    return 'एल्बम - $engine';
  }

  @override
  String playlistWithEngine(String engine) {
    return 'प्लेलिस्ट - $engine';
  }

  @override
  String get noDownloads => 'कोई डाउनलोड नहीं';

  @override
  String get searchSongs => 'अपने गाने खोजें...';

  @override
  String get refreshDownloads => 'डाउनलोड रिफ्रेश करें';

  @override
  String get closeSearch => 'खोज बंद करें';

  @override
  String get aboutTagline => 'कोड में संगीत रचना।';

  @override
  String get maintainer => 'मेंटेनर';

  @override
  String get followGithub => 'उन्हें गिटहब पर फॉलो करें';

  @override
  String get contact => 'संपर्क';

  @override
  String get contactTooltip => 'व्यापारिक पूछताछ भेजें';

  @override
  String get linkedin => 'लिंक्डइन';

  @override
  String get linkedinTooltip => 'अपडेट और क्रिएटिव हाइलाइट्स';

  @override
  String get supportMessage =>
      '\"ब्लूमी पसंद आ रहा है? एक छोटी सी मदद इसे खिलाए रखेगी।\" 🌸';

  @override
  String get supportButton => 'मैं मदद करूँगा';

  @override
  String get supportFooter => 'मैं चाहता हूँ कि ब्लूमी में सुधार होता रहे।';

  @override
  String get github => 'गिटहब';

  @override
  String get versionError => 'वर्शन प्राप्त करने में असमर्थ';

  @override
  String get home => 'होम';

  @override
  String get topSongs => 'टॉप गाने';

  @override
  String get topAlbums => 'टॉप एल्बम';

  @override
  String get viewLyrics => 'लिरिक्स देखें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get startAuth => 'प्रमाणीकरण शुरू करें';

  @override
  String get getSessionKey => 'सेशन की प्राप्त करें';

  @override
  String get removeKeys => 'की हटाएँ';

  @override
  String get countryLangSettings => 'देश और भाषा सेटिंग्स';

  @override
  String get autoCheckCountry => 'ऑटो देश चेक';

  @override
  String get autoCheckCountrySubtitle =>
      'जब आप ऐप खोलते हैं तो स्वचालित रूप से आपके स्थान के अनुसार देश की जांच करें।';

  @override
  String get countrySubtitle =>
      'ऐप के लिए डिफ़ॉल्ट रूप से सेट करने के लिए देश।';

  @override
  String get languageSubtitle => 'ऐप UI के लिए प्राथमिक भाषा।';

  @override
  String get scrobbleTracks => 'ट्रैक स्क्रॉबल करें';

  @override
  String get scrobbleTracksSubtitle => 'Last.FM पर ट्रैक स्क्रॉबल करें';

  @override
  String get firstAuthLastFM => 'पहले Last.FM API को प्रमाणित करें।';

  @override
  String get lastFmInstructions =>
      'Last.FM के लिए API की सेट करने के लिए, \n1. Last.FM पर जाएं और वहां एक अकाउंट बनाएं (https://www.last.fm/)।\n2. अब यहां से API की और सीक्रेट जेनरेट करें: https://www.last.fm/api/account/create\n3. नीचे API की और सीक्रेट दर्ज करें और सेशन की प्राप्त करने के लिए \'प्रमाणीकरण शुरू करें\' पर क्लिक करें।\n4. ब्राउज़र से अनुमति देने के बाद, सेशन की सहेजने के लिए \'सेशन की प्राप्त करें\' पर क्लिक करें।';

  @override
  String lastFmAuthenticated(String username) {
    return 'नमस्ते, $username,\nLast.FM API प्रमाणित है।';
  }

  @override
  String get onboardingWelcome => 'अपने अनुभव को अनुकूलित करें';

  @override
  String get confirmSettings =>
      'कृपया देश और भाषा की पुष्टि करें ताकि आप अपने लिए उपयुक्त सामग्री के साथ शुरुआत कर सकें।';

  @override
  String get detectedLabel => 'पता चला';

  @override
  String lastFmAuthFailed(String message) {
    return 'Last.FM प्रमाणीकरण विफल रहा।\n$message\nसंकेत: पहले ब्राउज़र से प्रमाणीकरण शुरू करें और साइन-इन करें, फिर सेशन की प्राप्त करें बटन पर क्लिक करें';
  }
}
