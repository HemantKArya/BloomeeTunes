// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Willkommen bei Bloomee';

  @override
  String get onboardingSubtitle =>
      'Deine werbefreie Musikreise beginnt hier. Personalisiere dein Erlebnis.';

  @override
  String get country => 'Land';

  @override
  String get language => 'Sprache';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get discover => 'Entdecken';

  @override
  String get history => 'Verlauf';

  @override
  String get library => 'Bibliothek';

  @override
  String get explore => 'Erkunden';

  @override
  String get search => 'Suche';

  @override
  String get offline => 'Offline';

  @override
  String get searchHint => 'Finde deine nächste Musikbesessenheit...';

  @override
  String get songs => 'Lieder';

  @override
  String get albums => 'Alben';

  @override
  String get artists => 'Künstler';

  @override
  String get playlists => 'Playlists';

  @override
  String get recently => 'Kürzlich';

  @override
  String get lastFmPicks => 'Last.Fm Auswahl';

  @override
  String get noInternet => 'Keine Internetverbindung!';

  @override
  String get enjoyingFrom => 'Genießen von';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get availableOffline => 'Offline verfügbar';

  @override
  String get timer => 'Timer';

  @override
  String get lyrics => 'Songtexte';

  @override
  String get loop => 'Wiederholung';

  @override
  String get off => 'Aus';

  @override
  String get loopOne => 'Eins wiederholen';

  @override
  String get loopAll => 'Alle wiederholen';

  @override
  String get shuffle => 'Zufallswiedergabe';

  @override
  String get openOriginalLink => 'Original-Link öffnen';

  @override
  String get unableToOpenLink => 'Link kann nicht geöffnet werden';

  @override
  String get updates => 'Updates';

  @override
  String get checkUpdates => 'Nach neuen Updates suchen';

  @override
  String get downloads => 'Downloads';

  @override
  String get downloadsSubtitle =>
      'Download-Pfad, Download-Qualität und mehr...';

  @override
  String get playerSettings => 'Player-Einstellungen';

  @override
  String get playerSettingsSubtitle => 'Streaming-Qualität, Autoplay, etc.';

  @override
  String get uiSettings => 'UI-Elemente & Dienste';

  @override
  String get uiSettingsSubtitle => 'Automatisches Gleiten, Quell-Engines etc.';

  @override
  String get lastFmSettings => 'Last.FM Einstellungen';

  @override
  String get lastFmSettingsSubtitle =>
      'API-Schlüssel, Secret und Scrobbling-Einstellungen.';

  @override
  String get storage => 'Speicher';

  @override
  String get storageSubtitle =>
      'Backup, Cache, Verlauf, Wiederherstellung und mehr...';

  @override
  String get languageCountry => 'Sprache & Land';

  @override
  String get languageCountrySubtitle => 'Wähle deine Sprache und dein Land.';

  @override
  String get about => 'Über';

  @override
  String get aboutSubtitle => 'Über die App, Version, Entwickler, etc.';

  @override
  String get searchLibrary => 'Bibliothek durchsuchen...';

  @override
  String get emptyLibraryMessage =>
      'Deine Bibliothek fühlt sich einsam an. Füge ein paar Melodien hinzu, um sie aufzuheitern!';

  @override
  String get noMatchesFound => 'Keine Treffer gefunden';

  @override
  String inPlaylist(String playlistName) {
    return 'in $playlistName';
  }

  @override
  String artistWithEngine(String engine) {
    return 'Künstler - $engine';
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
  String get noDownloads => 'Keine Downloads';

  @override
  String get searchSongs => 'Suche nach deinen Liedern...';

  @override
  String get refreshDownloads => 'Downloads aktualisieren';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get aboutTagline => 'Sinfonien in Code erschaffen.';

  @override
  String get maintainer => 'Maintainer';

  @override
  String get followGithub => 'Folge ihm auf GitHub';

  @override
  String get contact => 'Kontakt';

  @override
  String get contactTooltip => 'Eine geschäftliche Anfrage senden';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip => 'Updates und kreative Highlights';

  @override
  String get supportMessage =>
      'Gefällt dir Bloomee? Ein kleines Trinkgeld lässt es weiter blühen. 🌸';

  @override
  String get supportButton => 'Ich helfe';

  @override
  String get supportFooter => 'Ich möchte, dass Bloomee immer besser wird.';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'Version konnte nicht abgerufen werden';

  @override
  String get home => 'Startseite';

  @override
  String get topSongs => 'Top-Lieder';

  @override
  String get topAlbums => 'Top-Alben';

  @override
  String get viewLyrics => 'Songtexte anzeigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get startAuth => 'Auth starten';

  @override
  String get getSessionKey => 'Session-Key holen & speichern';

  @override
  String get removeKeys => 'Schlüssel entfernen';

  @override
  String get countryLangSettings => 'Land & Sprache Einstellungen';

  @override
  String get autoCheckCountry => 'Automatische Landesprüfung';

  @override
  String get autoCheckCountrySubtitle =>
      'Überprüfe das Land automatisch anhand deines Standorts, wenn du die App öffnest.';

  @override
  String get countrySubtitle =>
      'Land, das als Standard für die App festgelegt werden soll.';

  @override
  String get languageSubtitle => 'Hauptsprache für die App-Benutzeroberfläche.';

  @override
  String get scrobbleTracks => 'Titel scrobbeln';

  @override
  String get scrobbleTracksSubtitle => 'Titel nach Last.FM scrobbeln';

  @override
  String get firstAuthLastFM => 'Authentifiziere zuerst die Last.FM API.';

  @override
  String get lastFmInstructions =>
      'Um den API-Schlüssel für Last.FM festzulegen, \n1. Gehe zu Last.FM und erstelle dort ein Konto (https://www.last.fm/).\n2. Erstelle nun einen API-Schlüssel und ein Secret unter: https://www.last.fm/api/account/create\n3. Gib den API-Schlüssel und das Secret unten ein und klicke auf \'Auth starten\', um den Session-Key zu erhalten.\n4. Nachdem du dies im Browser erlaubt hast, klicke auf \'Session-Key holen & speichern\', um den Session-Key zu speichern.';

  @override
  String lastFmAuthenticated(String username) {
    return 'Hallo, $username,\nLast.FM API ist authentifiziert.';
  }

  @override
  String get onboardingWelcome => 'Personalisiere dein Erlebnis';

  @override
  String get confirmSettings =>
      'Bitte bestätige dein Land und deine Sprache, um mit Inhalten zu beginnen, die am besten zu dir passen.';

  @override
  String get detectedLabel => 'Erkannt';

  @override
  String lastFmAuthFailed(String message) {
    return 'Last.FM Authentifizierung fehlgeschlagen.\n$message\nHinweis: Klicke zuerst auf Auth starten und melde dich im Browser an, dann klicke auf die Schaltfläche Session-Key holen & speichern';
  }
}
