// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcome => 'Bienvenido a Bloomee';

  @override
  String get onboardingSubtitle =>
      'Tu viaje musical sin anuncios comienza aquí. Personaliza tu experiencia.';

  @override
  String get country => 'País';

  @override
  String get language => 'Idioma';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get settings => 'Ajustes';

  @override
  String get discover => 'Descubrir';

  @override
  String get history => 'Historial';

  @override
  String get library => 'Biblioteca';

  @override
  String get explore => 'Explorar';

  @override
  String get search => 'Buscar';

  @override
  String get offline => 'Sin conexión';

  @override
  String get searchHint => 'Encuentra tu próxima obsesión musical...';

  @override
  String get songs => 'Canciones';

  @override
  String get albums => 'Álbumes';

  @override
  String get artists => 'Artistas';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get recently => 'Reciente';

  @override
  String get lastFmPicks => 'Selecciones de Last.Fm';

  @override
  String get noInternet => '¡Sin conexión a Internet!';

  @override
  String get enjoyingFrom => 'Disfrutando desde';

  @override
  String get unknown => 'Desconocido';

  @override
  String get availableOffline => 'Disponible sin conexión';

  @override
  String get timer => 'Temporizador';

  @override
  String get lyrics => 'Letras';

  @override
  String get loop => 'Bucle';

  @override
  String get off => 'Apagado';

  @override
  String get loopOne => 'Repetir una';

  @override
  String get loopAll => 'Repetir todas';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get openOriginalLink => 'Abrir enlace original';

  @override
  String get unableToOpenLink => 'No se puede abrir el enlace';

  @override
  String get updates => 'Actualizaciones';

  @override
  String get checkUpdates => 'Buscar nuevas actualizaciones';

  @override
  String get downloads => 'Descargas';

  @override
  String get downloadsSubtitle =>
      'Ruta de descarga, calidad de descarga y más...';

  @override
  String get playerSettings => 'Ajustes del Reproductor';

  @override
  String get playerSettingsSubtitle =>
      'Calidad de transmisión, reproducción automática, etc.';

  @override
  String get uiSettings => 'Elementos de la Interfaz y Servicios';

  @override
  String get uiSettingsSubtitle =>
      'Deslizamiento automático, motores de origen, etc.';

  @override
  String get lastFmSettings => 'Ajustes de Last.FM';

  @override
  String get lastFmSettingsSubtitle =>
      'Clave API, secreto y ajustes de scrobbling.';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get storageSubtitle =>
      'Copia de seguridad, caché, historial, restauración y más...';

  @override
  String get languageCountry => 'Idioma y País';

  @override
  String get languageCountrySubtitle => 'Selecciona tu idioma y país.';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutSubtitle =>
      'Acerca de la aplicación, versión, desarrollador, etc.';

  @override
  String get searchLibrary => 'Buscar en la biblioteca...';

  @override
  String get emptyLibraryMessage =>
      'Tu biblioteca se siente sola. ¡Añade algunas canciones para alegrarla!';

  @override
  String get noMatchesFound => 'No se encontraron coincidencias';

  @override
  String inPlaylist(String playlistName) {
    return 'en $playlistName';
  }

  @override
  String artistWithEngine(String engine) {
    return 'Artista - $engine';
  }

  @override
  String albumWithEngine(String engine) {
    return 'Álbum - $engine';
  }

  @override
  String playlistWithEngine(String engine) {
    return 'Lista de reproducción - $engine';
  }

  @override
  String get noDownloads => 'No hay descargas';

  @override
  String get searchSongs => 'Busca tus canciones...';

  @override
  String get refreshDownloads => 'Actualizar descargas';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get aboutTagline => 'Creando sinfonías en código.';

  @override
  String get maintainer => 'Mantenedor';

  @override
  String get followGithub => 'Síguelo en GitHub';

  @override
  String get contact => 'Contacto';

  @override
  String get contactTooltip => 'Enviar una consulta comercial';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip =>
      'Actualizaciones y aspectos destacados creativos';

  @override
  String get supportMessage =>
      '¿Disfrutando con Bloomee? Una pequeña propina lo mantiene floreciendo. 🌸';

  @override
  String get supportButton => 'Ayudaré';

  @override
  String get supportFooter => 'Quiero que Bloomee siga mejorando.';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'No se pudo recuperar la versión';

  @override
  String get home => 'Inicio';

  @override
  String get topSongs => 'Canciones principales';

  @override
  String get topAlbums => 'Álbumes principales';

  @override
  String get viewLyrics => 'Ver letras';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'Aceptar';

  @override
  String get startAuth => 'Iniciar autenticación';

  @override
  String get getSessionKey => 'Obtener y guardar clave de sesión';

  @override
  String get removeKeys => 'Eliminar claves';

  @override
  String get countryLangSettings => 'Ajustes de País e Idioma';

  @override
  String get autoCheckCountry => 'Comprobar país automáticamente';

  @override
  String get autoCheckCountrySubtitle =>
      'Comprobar automáticamente el país según tu ubicación al abrir la aplicación.';

  @override
  String get countrySubtitle =>
      'País para establecer por defecto en la aplicación.';

  @override
  String get languageSubtitle =>
      'Idioma principal de la interfaz de la aplicación.';

  @override
  String get scrobbleTracks => 'Scrobble Tracks';

  @override
  String get scrobbleTracksSubtitle => 'Hacer scrobble de pistas en Last.FM';

  @override
  String get firstAuthLastFM => 'Primero autentica la API de Last.FM.';

  @override
  String get lastFmInstructions =>
      'Para configurar la clave API de Last.FM, \n1. Ve a Last.FM y crea una cuenta allí (https://www.last.fm/).\n2. Ahora genera una clave API y un secreto desde: https://www.last.fm/api/account/create\n3. Introduce la clave API y el secreto a continuación y haz clic en \'Iniciar autenticación\' para obtener la clave de sesión.\n4. Después de permitirlo desde el navegador, haz clic en \'Obtener y guardar clave de sesión\' para guardar la clave de sesión.';

  @override
  String lastFmAuthenticated(String username) {
    return 'Hola, $username,\nLa API de Last.FM está autenticada.';
  }

  @override
  String get onboardingWelcome => 'Personaliza tu experiencia';

  @override
  String get confirmSettings =>
      'Por favor, confirma tu país e idioma para empezar con el contenido que mejor se adapte a ti.';

  @override
  String get detectedLabel => 'Detectado';

  @override
  String lastFmAuthFailed(String message) {
    return 'Fallo en la autenticación de Last.FM.\n$message\nSugerencia: Primero haz clic en Iniciar autenticación e inicia sesión desde el navegador, luego haz clic en el botón Obtener y guardar clave de sesión';
  }
}
