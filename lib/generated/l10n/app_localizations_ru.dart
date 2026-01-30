// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcome => 'Добро пожаловать в Bloomee';

  @override
  String get onboardingSubtitle =>
      'Ваше музыкальное путешествие без рекламы начинается здесь. Настройте свое приложение.';

  @override
  String get country => 'Страна';

  @override
  String get language => 'Язык';

  @override
  String get getStarted => 'Начать';

  @override
  String get settings => 'Настройки';

  @override
  String get discover => 'Найти';

  @override
  String get history => 'История';

  @override
  String get library => 'Библиотека';

  @override
  String get explore => 'Обзор';

  @override
  String get search => 'Поиск';

  @override
  String get offline => 'Оффлайн';

  @override
  String get searchHint => 'Найдите свою следующую любимую песню...';

  @override
  String get songs => 'Песни';

  @override
  String get albums => 'Альбомы';

  @override
  String get artists => 'Исполнители';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get recently => 'Недавние';

  @override
  String get lastFmPicks => 'Выбор Last.Fm';

  @override
  String get noInternet => 'Нет подключения к интернету!';

  @override
  String get enjoyingFrom => 'Слушаю из';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get availableOffline => 'Доступно оффлайн';

  @override
  String get timer => 'Таймер';

  @override
  String get lyrics => 'Тексты';

  @override
  String get loop => 'Повтор';

  @override
  String get off => 'Выкл';

  @override
  String get loopOne => 'Повтор одной';

  @override
  String get loopAll => 'Повтор всех';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get openOriginalLink => 'Открыть оригинал';

  @override
  String get unableToOpenLink => 'Не удалось открыть ссылку';

  @override
  String get updates => 'Обновления';

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get downloads => 'Загрузки';

  @override
  String get downloadsSubtitle => 'Путь загрузки, качество и другое...';

  @override
  String get playerSettings => 'Настройки плеера';

  @override
  String get playerSettingsSubtitle =>
      'Качество стриминга, автовоспроизведение и т.д.';

  @override
  String get uiSettings => 'Элементы интерфейса и сервисы';

  @override
  String get uiSettingsSubtitle => 'Авто-слайд, движки поиска и т.д.';

  @override
  String get lastFmSettings => 'Настройки Last.FM';

  @override
  String get lastFmSettingsSubtitle =>
      'API Key, Secret и настройки скробблинга.';

  @override
  String get storage => 'Хранилище';

  @override
  String get storageSubtitle =>
      'Резервное копирование, кэш, история, восстановление и т.д.';

  @override
  String get languageCountry => 'Язык и страна';

  @override
  String get languageCountrySubtitle => 'Выберите ваш язык и страну.';

  @override
  String get about => 'О приложении';

  @override
  String get aboutSubtitle => 'О приложении, версия, разработчик и т.д.';

  @override
  String get searchLibrary => 'Поиск по библиотеке...';

  @override
  String get emptyLibraryMessage =>
      'Ваша библиотека пуста. Добавьте немного музыки, чтобы оживить ее!';

  @override
  String get noMatchesFound => 'Совпадений не найдено';

  @override
  String inPlaylist(String playlistName) {
    return 'в плейлисте $playlistName';
  }

  @override
  String artistWithEngine(String engine) {
    return 'Исполнитель - $engine';
  }

  @override
  String albumWithEngine(String engine) {
    return 'Альбом - $engine';
  }

  @override
  String playlistWithEngine(String engine) {
    return 'Плейлист - $engine';
  }

  @override
  String get noDownloads => 'Нет загрузок';

  @override
  String get searchSongs => 'Поиск ваших песен...';

  @override
  String get refreshDownloads => 'Обновить загрузки';

  @override
  String get closeSearch => 'Закрыть поиск';

  @override
  String get aboutTagline => 'Создание симфоний в коде.';

  @override
  String get maintainer => 'Сопровождающий';

  @override
  String get followGithub => 'Подписаться на GitHub';

  @override
  String get contact => 'Контакты';

  @override
  String get contactTooltip => 'Отправить деловой запрос';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip => 'Обновления и творческие моменты';

  @override
  String get supportMessage =>
      'Нравится Bloomee? Небольшая поддержка поможет проекту развиваться. 🌸';

  @override
  String get supportButton => 'Я помогу';

  @override
  String get supportFooter => 'Я хочу, чтобы Bloomee становился лучше.';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'Не удалось получить версию';

  @override
  String get home => 'Главная';

  @override
  String get topSongs => 'Топ песен';

  @override
  String get topAlbums => 'Топ альбомов';

  @override
  String get viewLyrics => 'Посмотреть текст';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'ОК';

  @override
  String get startAuth => 'Начать авторизацию';

  @override
  String get getSessionKey => 'Получить и сохранить ключ сессии';

  @override
  String get removeKeys => 'Удалить ключи';

  @override
  String get countryLangSettings => 'Настройки страны и языка';

  @override
  String get autoCheckCountry => 'Автоопределение страны';

  @override
  String get autoCheckCountrySubtitle =>
      'Автоматически определять страну по местоположению при запуске приложения.';

  @override
  String get countrySubtitle =>
      'Страна, установленная по умолчанию в приложении.';

  @override
  String get languageSubtitle => 'Основной язык интерфейса приложения.';

  @override
  String get scrobbleTracks => 'Скробблинг треков';

  @override
  String get scrobbleTracksSubtitle => 'Скробблинг треков в Last.FM';

  @override
  String get firstAuthLastFM => 'Сначала авторизуйте Last.FM API.';

  @override
  String get lastFmInstructions =>
      'Чтобы установить API Key для Last.FM, \n1. Перейдите на Last.FM и создайте аккаунт (https://www.last.fm/).\n2. Сгенерируйте API Key и Secret здесь: https://www.last.fm/api/account/create\n3. Введите API Key и Secret ниже и нажмите \'Начать авторизацию\', чтобы получить ключ сессии.\n4. После подтверждения в браузере нажмите \'Получить и сохранить ключ сессии\', чтобы сохранить его.';

  @override
  String lastFmAuthenticated(String username) {
    return 'Привет, $username,\nLast.FM API авторизован.';
  }

  @override
  String get onboardingWelcome => 'Настройте свое приложение';

  @override
  String get confirmSettings =>
      'Пожалуйста, подтвердите вашу страну и язык, чтобы начать работу с наиболее подходящим вам контентом.';

  @override
  String get detectedLabel => 'Обнаружено';

  @override
  String lastFmAuthFailed(String message) {
    return 'Ошибка авторизации Last.FM.\n$message\nПодсказка: сначала нажмите \'Начать авторизацию\' и войдите в систему в браузере, затем нажмите кнопку \'Получить и сохранить ключ сессии\'';
  }
}
