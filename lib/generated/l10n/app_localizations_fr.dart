// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue sur Bloomee';

  @override
  String get onboardingSubtitle =>
      'Votre voyage musical sans publicité commence ici. Personnalisez votre expérience.';

  @override
  String get country => 'Pays';

  @override
  String get language => 'Langue';

  @override
  String get getStarted => 'Commencer';

  @override
  String get settings => 'Paramètres';

  @override
  String get discover => 'Découvrir';

  @override
  String get history => 'Historique';

  @override
  String get library => 'Bibliothèque';

  @override
  String get explore => 'Explorer';

  @override
  String get search => 'Rechercher';

  @override
  String get offline => 'Hors ligne';

  @override
  String get searchHint => 'Trouvez votre prochaine obsession musicale...';

  @override
  String get songs => 'Chansons';

  @override
  String get albums => 'Albums';

  @override
  String get artists => 'Artistes';

  @override
  String get playlists => 'Playlists';

  @override
  String get recently => 'Récemment';

  @override
  String get lastFmPicks => 'Sélections Last.Fm';

  @override
  String get noInternet => 'Pas de connexion Internet !';

  @override
  String get enjoyingFrom => 'Écoute depuis';

  @override
  String get unknown => 'Inconnu';

  @override
  String get availableOffline => 'Disponible hors ligne';

  @override
  String get timer => 'Minuteur';

  @override
  String get lyrics => 'Paroles';

  @override
  String get loop => 'Boucle';

  @override
  String get off => 'Désactivé';

  @override
  String get loopOne => 'Boucle un';

  @override
  String get loopAll => 'Boucle tout';

  @override
  String get shuffle => 'Aléatoire';

  @override
  String get openOriginalLink => 'Ouvrir le lien original';

  @override
  String get unableToOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get updates => 'Mises à jour';

  @override
  String get checkUpdates => 'Vérifier les nouvelles mises à jour';

  @override
  String get downloads => 'Téléchargements';

  @override
  String get downloadsSubtitle =>
      'Chemin, qualité de téléchargement et plus...';

  @override
  String get playerSettings => 'Paramètres du Lecteur';

  @override
  String get playerSettingsSubtitle =>
      'Qualité de streaming, lecture automatique, etc.';

  @override
  String get uiSettings => 'Éléments UI & Services';

  @override
  String get uiSettingsSubtitle => 'Défilement auto, moteurs source, etc.';

  @override
  String get lastFmSettings => 'Paramètres Last.FM';

  @override
  String get lastFmSettingsSubtitle =>
      'Clé API, Secret et paramètres de Scrobbling.';

  @override
  String get storage => 'Stockage';

  @override
  String get storageSubtitle =>
      'Sauvegarde, Cache, Historique, Restauration et plus...';

  @override
  String get languageCountry => 'Langue & Pays';

  @override
  String get languageCountrySubtitle =>
      'Sélectionnez votre langue et votre pays.';

  @override
  String get about => 'À propos';

  @override
  String get aboutSubtitle =>
      'À propos de l\'application, version, développeur, etc.';

  @override
  String get searchLibrary => 'Rechercher dans la bibliothèque...';

  @override
  String get emptyLibraryMessage =>
      'Votre bibliothèque se sent seule. Ajoutez des morceaux pour l\'égayer !';

  @override
  String get noMatchesFound => 'Aucun résultat trouvé';

  @override
  String inPlaylist(String playlistName) {
    return 'dans $playlistName';
  }

  @override
  String artistWithEngine(String engine) {
    return 'Artiste - $engine';
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
  String get noDownloads => 'Aucun téléchargement';

  @override
  String get searchSongs => 'Rechercher vos chansons...';

  @override
  String get refreshDownloads => 'Actualiser les téléchargements';

  @override
  String get closeSearch => 'Fermer la recherche';

  @override
  String get aboutTagline => 'Créer des symphonies en code.';

  @override
  String get maintainer => 'Mainteneur';

  @override
  String get followGithub => 'Le suivre sur GitHub';

  @override
  String get contact => 'Contact';

  @override
  String get contactTooltip => 'Envoyer une demande commerciale';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip => 'Mises à jour et points forts créatifs';

  @override
  String get supportMessage =>
      'Vous aimez Bloomee ? Un petit don l\'aide à s\'épanouir. 🌸';

  @override
  String get supportButton => 'Je vais aider';

  @override
  String get supportFooter => 'Je veux que Bloomee continue de s\'améliorer.';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'Impossible de récupérer la version';

  @override
  String get home => 'Accueil';

  @override
  String get topSongs => 'Meilleures chansons';

  @override
  String get topAlbums => 'Meilleurs albums';

  @override
  String get viewLyrics => 'Voir les paroles';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get startAuth => 'Démarrer l\'Auth';

  @override
  String get getSessionKey => 'Obtenir & Sauvegarder la clé de session';

  @override
  String get removeKeys => 'Supprimer les clés';

  @override
  String get countryLangSettings => 'Paramètres de Pays & Langue';

  @override
  String get autoCheckCountry => 'Vérification auto du pays';

  @override
  String get autoCheckCountrySubtitle =>
      'Vérifier automatiquement le pays selon votre position à l\'ouverture de l\'application.';

  @override
  String get countrySubtitle =>
      'Pays à définir par défaut pour l\'application.';

  @override
  String get languageSubtitle =>
      'Langue principale pour l\'interface de l\'application.';

  @override
  String get scrobbleTracks => 'Scrobbler les morceaux';

  @override
  String get scrobbleTracksSubtitle => 'Scrobbler les morceaux sur Last.FM';

  @override
  String get firstAuthLastFM => 'Authentifiez d\'abord l\'API Last.FM.';

  @override
  String get lastFmInstructions =>
      'Pour configurer la clé API pour Last.FM, \n1. Allez sur Last.FM et créez un compte (https://www.last.fm/).\n2. Générez maintenant une clé API et un Secret depuis : https://www.last.fm/api/account/create\n3. Entrez la clé API et le Secret ci-dessous et cliquez sur \'Démarrer l\'Auth\' pour obtenir la clé de session.\n4. Après avoir autorisé depuis le navigateur, cliquez sur \'Obtenir & Sauvegarder la clé de session\' pour sauvegarder la clé de session.';

  @override
  String lastFmAuthenticated(String username) {
    return 'Bonjour, $username,\nL\'API Last.FM est authentifiée.';
  }

  @override
  String get onboardingWelcome => 'Personnalisez votre expérience';

  @override
  String get confirmSettings =>
      'Veuillez confirmer votre pays et votre langue pour commencer avec le contenu qui vous convient le mieux.';

  @override
  String get detectedLabel => 'Détecté';

  @override
  String lastFmAuthFailed(String message) {
    return 'Échec de l\'authentification Last.FM.\n$message\nConseil : Cliquez d\'abord sur Démarrer l\'Auth et connectez-vous depuis le navigateur, puis cliquez sur le bouton Obtenir & Sauvegarder la clé de session';
  }
}
