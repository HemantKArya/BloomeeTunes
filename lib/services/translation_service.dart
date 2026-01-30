import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'dart:developer' as dev;
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';

class BloomeeTranslationService {
  static final BloomeeTranslationService _instance =
      BloomeeTranslationService._internal();
  factory BloomeeTranslationService() => _instance;
  BloomeeTranslationService._internal();

  OnDeviceTranslator? _translator;
  TranslateLanguage _currentLanguage = TranslateLanguage.english;
  String _lastLanguageCode = "en";
  final Map<String, String> _cache = {};
  Completer<void>? _initCompleter;
  final _unescape = HtmlUnescape();
  
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  // Maps ISO codes to ML Kit TranslateLanguage
  static final Map<String, TranslateLanguage> _languageMap = {
    'en': TranslateLanguage.english,
    'hi': TranslateLanguage.hindi,
    'es': TranslateLanguage.spanish,
    'fr': TranslateLanguage.french,
    'de': TranslateLanguage.german,
    'ru': TranslateLanguage.russian,
    'ja': TranslateLanguage.japanese,
    'ko': TranslateLanguage.korean,
    'zh': TranslateLanguage.chinese,
    'pt': TranslateLanguage.portuguese,
  };

  // Static fallback for common UI labels to support all platforms (Windows/Linux)
  // and provide instant translation for common terms.
  static final Map<String, Map<String, String>> _staticTranslations = {
    'hi': {
      'Settings': 'सेटिंग्स',
      'Discover': 'खोजें',
      'History': 'इतिहास',
      'Library': 'लाइब्रेरी',
      'Play': 'बजाएं',
      'Pause': 'रोकें',
      'Skip': 'छोड़ें',
      'Next': 'अगला',
      'Previous': 'पिछला',
      'Enjoying From': 'यहाँ से आनंद ले रहे हैं',
      'Up Next': 'अगला गाना',
      'Items in Queue': 'कतार में गाने',
      'Auto Play': 'ऑटो प्ले',
      'Country': 'देश',
      'Language': 'भाषा',
      'Download': 'डाउनलोड',
      'Offline': 'ऑफ़लाइन',
      'Search': 'खोजें',
      'Create new Playlist': 'नई प्लेलिस्ट बनाएं',
      'Top Songs': 'शीर्ष गाने',
      'Top Albums': 'शीर्ष एल्बम',
      'Song Info': 'गाने की जानकारी',
      'Details': 'विवरण',
      'Title': 'शीर्षक',
      'Artist': 'कलाकार',
      'Album': 'एल्बम',
      'Genre': 'शैली',
      'Technical Info': 'तकनीकी जानकारी',
      'Actions': 'क्रियाएं',
      'Copy ID': 'आईडी कॉपी करें',
      'Copy Link': 'लिंक कॉपी करें',
      'Open in': 'में खोलें',
    },
    'es': {
      'Settings': 'Ajustes',
      'Discover': 'Descubrir',
      'History': 'Historial',
      'Library': 'Biblioteca',
      'Play': 'Reproducir',
      'Pause': 'Pausa',
      'Enjoying From': 'Disfrutando de',
      'Up Next': 'A continuación',
    },
    'fr': {
      'Settings': 'Paramètres',
      'Discover': 'Découvrir',
      'History': 'Historique',
      'Library': 'Bibliothèque',
      'Play': 'Jouer',
      'Pause': 'Pause',
      'Enjoying From': 'Écoute depuis',
      'Up Next': 'À suivre',
    },
    // Add more as needed
  };

  Future<void> init(String languageCode) async {
    if (!isSupported) {
      dev.log("Translation skipped: Platform not supported", name: "Translation");
      return;
    }

    final targetLang = _languageMap[languageCode] ?? TranslateLanguage.english;
    if (_translator != null && _currentLanguage == targetLang) return;

    // Use a completer to handle concurrent init calls
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      if (_currentLanguage == targetLang) {
        return await _initCompleter!.future;
      }
    }

    _initCompleter = Completer<void>();
    _currentLanguage = targetLang;
    _lastLanguageCode = languageCode;
    _cache.clear();

    try {
      if (_translator != null) {
        await _translator!.close();
      }

      if (targetLang == TranslateLanguage.english) {
        _translator = null;
        _initCompleter!.complete();
        return;
      }

      _translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: targetLang,
      );

      final modelManager = OnDeviceTranslatorModelManager();
      final bool isDownloaded = await modelManager.isModelDownloaded(targetLang.bcpCode);
      
      if (!isDownloaded) {
        dev.log("Downloading translation model for ${targetLang.bcpCode}...", name: "Translation");
        await modelManager.downloadModel(targetLang.bcpCode);
      }
      
      dev.log("Translation initialized for ${targetLang.bcpCode}", name: "Translation");
      _initCompleter!.complete();
    } catch (e) {
      dev.log("Translation init error: $e", name: "Translation");
      _translator = null;
      _initCompleter!.complete();
    }
  }

  Future<String> translate(String text) async {
    if (text.trim().isEmpty) return text;
    
    // 1. Check static fallback first (instant, works on all platforms)
    final langCode = _currentLanguage.bcpCode; // Note: this might need mapping back from TranslateLanguage
    // Simpler: use the code passed to init if we store it.
    // For now, let's use a specialized check.
    
    String? localMatch;
    // We can't easily get the original languageCode here unless we store it.
    // Let's store _lastLanguageCode.
    
    final staticMap = _staticTranslations[_lastLanguageCode];
    if (staticMap != null) {
      // Check for exact match or substring for common UI patterns
      for (var entry in staticMap.entries) {
        if (text.contains(entry.key)) {
          return text.replaceAll(entry.key, entry.value);
        }
      }
    }

    if (!isSupported) return text;
    
    // 2. Wait for initialization if in progress
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      await _initCompleter!.future;
    }

    if (_translator == null && !isSupported) {
      // 3. Web fallback for non-supported platforms or when ML Kit is not ready
      return await _translateWeb(text);
    }

    if (_cache.containsKey(text)) return _cache[text]!;

    try {
      if (_translator != null) {
        final translatedText = await _translator!.translateText(text);
        _cache[text] = translatedText;
        return translatedText;
      } else {
        return await _translateWeb(text);
      }
    } catch (e) {
      dev.log("ML Kit translation error, falling back to Web: $e", name: "Translation");
      return await _translateWeb(text);
    }
  }

  Future<String> _translateWeb(String text) async {
    if (_lastLanguageCode == "en") return text;
    if (_cache.containsKey(text)) return _cache[text]!;

    try {
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$_lastLanguageCode&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0].isNotEmpty) {
          final translated = data[0][0][0].toString();
          final decoded = _unescape.convert(translated);
          _cache[text] = decoded;
          return decoded;
        }
      }
    } catch (e) {
      dev.log("Web translation error: $e", name: "Translation");
    }
    return text;
  }

  void dispose() {
    _translator?.close();
  }
}
