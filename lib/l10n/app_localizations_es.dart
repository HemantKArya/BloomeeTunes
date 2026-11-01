// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get onboardingTitle => 'Bienvenido a Bloomee';

  @override
  String get onboardingSubtitle => 'Selecciona tu idioma y región.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navLocal => 'En el dispositivo';

  @override
  String get navOffline => 'Sin conexión';

  @override
  String get playerEnjoyingFrom => 'Escuchando desde';

  @override
  String get playerPlayWithMix => 'Reproducir con mezcla automática';

  @override
  String get playerPlayNext => 'Reproducir a continuación';

  @override
  String get playerAddToQueue => 'Añadir a la cola';

  @override
  String get playerAddToFavorites => 'Añadir a favoritos';

  @override
  String get playerNoLyricsFound => 'No se encontraron letras';

  @override
  String get playerLyricsNoPlugin =>
      'No hay un proveedor de letras configurado. Ve a Ajustes → Complementos para instalar uno.';

  @override
  String get localMusicTitle => 'En el dispositivo';

  @override
  String get localMusicGrantPermission => 'Conceder permiso';

  @override
  String get localMusicStorageAccessRequired =>
      'Acceso al almacenamiento necesario';

  @override
  String get localMusicStorageAccessDesc =>
      'Permite el acceso para buscar y reproducir los archivos de audio de tu dispositivo.';

  @override
  String get localMusicAddFolder => 'Añadir carpeta de música';

  @override
  String get localMusicScanNow => 'Escanear ahora';

  @override
  String localMusicScanFailed(String message) {
    return 'Error al escanear: $message';
  }

  @override
  String get localMusicScanning =>
      'Buscando archivos de audio en el dispositivo…';

  @override
  String get localMusicShuffle => 'Aleatorio';

  @override
  String get localMusicPlayAll => 'Reproducir todo';

  @override
  String get localMusicSearchHint => 'Buscar música local...';

  @override
  String get localMusicRescanDevice => 'Volver a escanear dispositivo';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonOk => 'Aceptar';

  @override
  String get buttonUpdate => 'Actualizar';

  @override
  String get buttonDownload => 'Descargar';

  @override
  String get buttonLater => 'Más tarde';

  @override
  String get buttonInfo => 'Información';

  @override
  String get buttonMore => 'Más';

  @override
  String get dialogDeleteTrack => 'Eliminar pista';

  @override
  String dialogDeleteTrackMessage(String title) {
    return '¿Quieres eliminar «$title» del dispositivo? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Esta pista también se eliminará de:';

  @override
  String get dialogDontAskAgain => 'No volver a preguntar';

  @override
  String get dialogUpdateAvailable => 'Actualización disponible';

  @override
  String get dialogUpdateNow => 'Actualizar ahora';

  @override
  String get dialogDownloadPlaylist => 'Descargar lista';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '¿Quieres descargar las canciones de «$title»? Total: $count. Se añadirán a la cola de descargas.';
  }

  @override
  String get dialogDownloadAll => 'Descargar todo';

  @override
  String get playlistEdit => 'Editar lista';

  @override
  String get playlistShareFile => 'Compartir archivo';

  @override
  String get playlistExportFile => 'Exportar archivo';

  @override
  String get playlistPlay => 'Reproducir';

  @override
  String get playlistAddToQueue => 'Añadir lista a la cola';

  @override
  String get playlistShare => 'Compartir lista';

  @override
  String get playlistDelete => 'Eliminar lista';

  @override
  String get playlistEmptyState => 'Aún no hay canciones';

  @override
  String get playlistAvailableOffline => 'Disponible sin conexión';

  @override
  String get playlistShuffle => 'Aleatorio';

  @override
  String get playlistNoMatchSearch => 'Ninguna lista coincide con tu búsqueda';

  @override
  String get playlistCreateNew => 'Crear lista de reproducción';

  @override
  String get playlistCreateFirstOne =>
      'Aún no tienes listas de reproducción. Crea una para empezar.';

  @override
  String get addToPlaylistNoSongSelected => 'No hay canción seleccionada';

  @override
  String get createPlaylistDialogBarrierLabel =>
      'Ventana para crear una lista de reproducción';

  @override
  String get createPlaylistDialogNameHint => 'Música de verano';

  @override
  String get createPlaylistDialogCreate => 'Crear';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title eliminada de $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Error al cargar la lista';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPlugins => 'Complementos';

  @override
  String get settingsPluginsSubtitle =>
      'Instala, activa y gestiona complementos.';

  @override
  String get settingsUpdates => 'Actualizaciones';

  @override
  String get settingsUpdatesSubtitle => 'Buscar nuevas versiones';

  @override
  String get settingsDownloads => 'Descargas';

  @override
  String get settingsDownloadsSubtitle =>
      'Carpeta de descargas, calidad de audio y otras opciones';

  @override
  String get settingsLocalTracks => 'Pistas locales';

  @override
  String get settingsLocalTracksSubtitle =>
      'Búsqueda de archivos, carpetas y búsqueda automática';

  @override
  String get settingsPlayer => 'Ajustes del reproductor';

  @override
  String get settingsPlayerSubtitle =>
      'Calidad de audio, reproducción automática y otras opciones';

  @override
  String get settingsPluginDefaults => 'Complementos predeterminados';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Fuente de Descubrir y prioridad de las fuentes de contenido';

  @override
  String get settingsUIElements => 'Interfaz y servicios';

  @override
  String get settingsUIElementsSubtitle =>
      'Ajustes visuales, carrusel automático, etc.';

  @override
  String get settingsLastFM => 'Ajustes de Last.fm';

  @override
  String get settingsLastFMSubtitle =>
      'Claves API y envío del historial de reproducción';

  @override
  String get settingsStorage => 'Almacenamiento';

  @override
  String get settingsStorageSubtitle =>
      'Copias de seguridad, caché, historial y restauración.';

  @override
  String get settingsLanguageCountry => 'Idioma y región';

  @override
  String get settingsLanguageCountrySubtitle => 'Selecciona tu idioma y país.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle =>
      'Versión, desarrollador y más información.';

  @override
  String get settingsScanning => 'Búsqueda de archivos';

  @override
  String get settingsMusicFolders => 'Carpetas de música';

  @override
  String get settingsQuality => 'Calidad';

  @override
  String get settingsHistory => 'Historial';

  @override
  String get settingsBackupRestore => 'Copia de seguridad y restauración';

  @override
  String get settingsAutomatic => 'Automático';

  @override
  String get settingsDangerZone => 'Restablecimiento de datos';

  @override
  String get settingsScrobbling => 'Envío del historial de reproducción';

  @override
  String get settingsAuthentication => 'Autenticación';

  @override
  String get settingsHomeScreen => 'Pantalla de inicio';

  @override
  String get settingsChartVisibility => 'Visibilidad de listas de éxitos';

  @override
  String get dialogAddingToDownloadQueue => 'Añadiendo a la cola de descarga';

  @override
  String get emptyNoInternet => 'Sin conexión a internet';

  @override
  String get emptyNoContentPlugin =>
      'No hay fuentes de contenido activas. Activa un complemento en el gestor de complementos.';

  @override
  String get emptyRefreshingSource =>
      'Actualizando la fuente de Descubrir… La fuente anterior ya no está disponible.';

  @override
  String get emptyNoTracks => 'No hay pistas disponibles';

  @override
  String get emptyNoResults => 'No se encontraron coincidencias';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Se eliminó \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Error al eliminar \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue =>
      'Añadido para reproducir a continuación';

  @override
  String get snackbarAddedToQueue => 'Añadido a la cola';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title añadido a favoritos';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Reproduciendo $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Se añadió $name a la cola';
  }

  @override
  String get snackbarPlaylistUpdated => 'Lista de reproducción actualizada';

  @override
  String get snackbarLinkCopied => 'Enlace copiado';

  @override
  String get snackbarCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Se añadieron $count canciones a la cola de descarga';
  }

  @override
  String get searchHintExplore => '¿Qué quieres escuchar?';

  @override
  String get searchHintLibrary => 'Buscar en la biblioteca...';

  @override
  String get searchHintPlaylists => 'Buscar listas...';

  @override
  String get searchStartTyping => 'Empieza a escribir para buscar...';

  @override
  String get searchNoSuggestions => 'No se encontraron sugerencias';

  @override
  String get searchNoResults =>
      'No se encontraron resultados.\nPrueba con otro término u otra fuente.';

  @override
  String get searchFailed => 'Error en la búsqueda';

  @override
  String get searchDiscover => 'Descubre nueva música';

  @override
  String get searchSources => 'Fuentes';

  @override
  String get searchNoPlugins => 'No hay complementos instalados';

  @override
  String get searchTracks => 'Canciones';

  @override
  String get searchAlbums => 'Álbumes';

  @override
  String get searchArtists => 'Artistas';

  @override
  String get searchPlaylists => 'Listas';

  @override
  String get exploreDiscover => 'Descubrir';

  @override
  String get exploreRecently => 'Escuchado recientemente';

  @override
  String get exploreLastFmPicks => 'Recomendaciones de Last.fm';

  @override
  String get exploreFailedToLoad => 'Error al cargar las secciones de inicio.';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmptyState =>
      'Tu biblioteca está vacía. Añade canciones y listas de reproducción para empezar.';

  @override
  String libraryIn(String playlistName) {
    return 'en $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Añadir a lista';

  @override
  String get menuSmartReplace => 'Reemplazo inteligente';

  @override
  String get menuShare => 'Compartir';

  @override
  String get menuAvailableOffline => 'Disponible sin conexión';

  @override
  String get menuDownload => 'Descargar';

  @override
  String get menuOpenOriginalLink => 'Abrir enlace original';

  @override
  String get menuDeleteTrack => 'Eliminar';

  @override
  String get tooltipRemoveFromLibrary => 'Quitar de la biblioteca';

  @override
  String get tooltipSaveToLibrary => 'Guardar en la biblioteca';

  @override
  String get tooltipOpenOriginalLink => 'Abrir enlace original';

  @override
  String get tooltipAvailableOffline => 'Disponible sin conexión';

  @override
  String get tooltipMoreOptions => 'Más opciones';

  @override
  String get appuiTitle => 'Interfaz y servicios';

  @override
  String get appuiAutoSlideCharts => 'Carrusel automático';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Deslizar las listas automáticamente en el inicio.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Muestra recomendaciones de Last.fm. Debes iniciar sesión y reiniciar la aplicación.';

  @override
  String get appuiNoChartsAvailable =>
      'No hay listas de éxitos disponibles. Activa un complemento de listas de éxitos.';

  @override
  String get appuiLoginToLastFm => 'Inicia sesión en Last.fm primero.';

  @override
  String get appuiShowInCarousel => 'Mostrar en el carrusel de inicio.';

  @override
  String get countrySettingTitle => 'País e idioma';

  @override
  String get countrySettingAutoDetect => 'Detectar país automáticamente';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Detectar tu país al abrir la aplicación.';

  @override
  String get countrySettingCountryLabel => 'País';

  @override
  String get countrySettingLanguageLabel => 'Idioma';

  @override
  String get countrySettingSystemDefault => 'Predeterminado del sistema';

  @override
  String get downloadSettingTitle => 'Descargas';

  @override
  String get downloadSettingQuality => 'Calidad de descarga';

  @override
  String get downloadSettingQualitySubtitle =>
      'Calidad de audio preferida para pistas descargadas.';

  @override
  String get downloadSettingFolder => 'Carpeta de descargas';

  @override
  String get downloadSettingResetFolder => 'Restablecer carpeta';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Restaurar la ruta de descarga predeterminada.';

  @override
  String get lastfmTitle => 'Last.fm';

  @override
  String get lastfmScrobbleTracks => 'Enviar historial de reproducción';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Enviar pistas escuchadas a tu perfil de Last.fm.';

  @override
  String get lastfmAuthFirst => 'Primero autentica la API de Last.fm.';

  @override
  String get lastfmAuthenticatedAs => 'Autenticado como';

  @override
  String get lastfmAuthFailed => 'Error de autenticación:';

  @override
  String get lastfmNotAuthenticated => 'No autenticado';

  @override
  String get lastfmSteps =>
      'Pasos para autenticar:\n1. Crea una cuenta o inicia sesión en last.fm.\n2. Genera una clave API en last.fm/api/account/create.\n3. Introduce la clave API y la clave secreta abajo.\n4. Toca «1. Iniciar autorización» y confirma en el navegador.\n5. Toca «2. Obtener y guardar clave de sesión».';

  @override
  String get lastfmApiKey => 'Clave API';

  @override
  String get lastfmApiSecret => 'Clave secreta API';

  @override
  String get lastfmStartAuth => '1. Iniciar autorización';

  @override
  String get lastfmGetSession => '2. Obtener y guardar clave de sesión';

  @override
  String get lastfmRemoveKeys => 'Eliminar claves';

  @override
  String get lastfmStartAuthFirst =>
      'Inicia la autenticación primero, luego aprueba en el navegador.';

  @override
  String get localSettingTitle => 'Pistas locales';

  @override
  String get localSettingAutoScan => 'Escanear al inicio';

  @override
  String get localSettingAutoScanSubtitle =>
      'Escanear música local automáticamente al abrir la app.';

  @override
  String get localSettingLastScan => 'Último escaneo';

  @override
  String get localSettingNeverScanned => 'Nunca';

  @override
  String get localSettingScanInProgress => 'Escaneo en curso…';

  @override
  String get localSettingScanNowSubtitle =>
      'Activar un escaneo manual de la biblioteca.';

  @override
  String get localSettingNoFolders =>
      'No hay carpetas. Añade una para empezar a escanear.';

  @override
  String get localSettingAddFolder => 'Añadir carpeta';

  @override
  String get playerSettingTitle => 'Ajustes del reproductor';

  @override
  String get playerSettingStreamingHeader => 'Audio en línea';

  @override
  String get playerSettingStreamQuality => 'Calidad de audio en línea';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Tasa de bits del audio para la reproducción en línea.';

  @override
  String get playerSettingQualityLow => 'Baja';

  @override
  String get playerSettingQualityMedium => 'Media';

  @override
  String get playerSettingQualityHigh => 'Alta';

  @override
  String get playerSettingPlaybackHeader => 'Reproducción';

  @override
  String get playerSettingAutoPlay => 'Reproducción automática';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Añadir canciones similares cuando termine la cola.';

  @override
  String get playerSettingAutoFallback => 'Usar una fuente alternativa';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Si un complemento no está disponible o no proporciona audio, prueba una fuente compatible solo para reproducir.';

  @override
  String get playerSettingCrossfade => 'Fundido entre canciones';

  @override
  String get playerSettingCrossfadeOff => 'Desactivado';

  @override
  String get playerSettingCrossfadeInstant => 'Cambio instantáneo';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Fundido de $seconds s entre canciones';
  }

  @override
  String get playerSettingEqualizer => 'Ecualizador';

  @override
  String get playerSettingEqualizerActive => 'Activo';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Habilitado — Perfil $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Ecualizador paramétrico de 10 bandas (vía FFmpeg).';

  @override
  String get pluginDefaultsTitle => 'Complementos predeterminados';

  @override
  String get pluginDefaultsDiscoverHeader => 'Fuente de Descubrir';

  @override
  String get pluginDefaultsNoResolver =>
      'No hay fuentes de contenido activas. Activa un complemento para elegir una fuente de Descubrir.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Usa la primera fuente de contenido disponible.';

  @override
  String get pluginDefaultsPriorityHeader =>
      'Prioridad de las fuentes de contenido';

  @override
  String get pluginDefaultsNoPriority =>
      'No hay fuentes de contenido activas. El orden de prioridad aparecerá aquí cuando se activen los complementos.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Arrastra para reordenar. Las fuentes con mayor prioridad se prueban primero para encontrar versiones reproducibles de las canciones importadas o de las listas de éxitos.';

  @override
  String get pluginDefaultsLyricsHeader => 'Prioridad de letras';

  @override
  String get pluginDefaultsLyricsNone => 'No hay proveedores de letras.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Arrastra para reordenar los proveedores de letras. Se prueba primero el que aparece al principio.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Sugerencias de búsqueda';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'No hay proveedores de sugerencias.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Ninguno';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Usar solo el historial de búsqueda.';

  @override
  String get storageSettingTitle => 'Almacenamiento';

  @override
  String get storageClearHistoryEvery => 'Limpiar historial cada';

  @override
  String get storageClearHistorySubtitle =>
      'Borrar el historial tras el periodo elegido.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Copia creada en $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Error al compartir copia: $error';
  }

  @override
  String get storageRestoreBackup => 'Restaurar copia';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restaura tus datos desde un archivo de copia de seguridad.';

  @override
  String get storageAutoBackup => 'Copia automática';

  @override
  String get storageAutoLyrics => 'Autoguardado de letras';

  @override
  String get storageAutoLyricsSubtitle =>
      'Guardar letras automáticamente al reproducir una canción.';

  @override
  String get storageResetApp => 'Restablecer Bloomee';

  @override
  String get storageResetConfirmTitle => 'Confirmar restablecimiento';

  @override
  String get storageResetButton => 'Restablecer';

  @override
  String get storageRestoreOptionsTitle => 'Opciones de restauración';

  @override
  String get storageRestoreContinue => 'Continuar';

  @override
  String get storageRestoreConfirmTitle => 'Confirmar restauración';

  @override
  String get storageRestoreYes => 'Sí, restaurar';

  @override
  String get storageRestoring =>
      'Restaurando datos seleccionados…\nPor favor, espera.';

  @override
  String get storageRestoreFailedTitle => 'Fallo en la restauración';

  @override
  String get updateSettingTitle => 'Actualizaciones';

  @override
  String get updateCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get updateCheckSubtitle =>
      'Comprobar si hay una versión más nueva de Bloomee.';

  @override
  String get updateAutoNotify => 'Notificar actualizaciones';

  @override
  String get updateAutoNotifySubtitle =>
      'Avisar al abrir la app si hay una actualización disponible.';

  @override
  String get updateCheckTitle => 'Búsqueda de actualizaciones';

  @override
  String get updateUpToDate => 'Bloomee está actualizado';

  @override
  String get updateViewPreRelease => 'Ver la última versión preliminar';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versión actual: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Hay una nueva versión de Bloomee disponible';

  @override
  String updateVersion(String ver, String build) {
    return 'Versión: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Descargar ahora';

  @override
  String get updateChecking => 'Comprobando disponibilidad de versiones...';

  @override
  String get timerTitle => 'Temporizador de apagado';

  @override
  String get timerInterludeMessage => 'La música se detendrá en…';

  @override
  String get timerHours => 'Horas';

  @override
  String get timerMinutes => 'Minutos';

  @override
  String get timerSeconds => 'Segundos';

  @override
  String get timerStop => 'Detener temporizador';

  @override
  String get timerFinishedMessage =>
      'El temporizador ha detenido la reproducción.';

  @override
  String get timerGotIt => 'Entendido';

  @override
  String get timerSetTimeError => 'Por favor, elige un tiempo';

  @override
  String get timerStart => 'Iniciar temporizador';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => 'Aún no hay notificaciones';

  @override
  String get recentsTitle => 'Historial';

  @override
  String playlistByCreator(String creator) {
    return 'por $creator';
  }

  @override
  String get playlistYou => 'Tú';

  @override
  String get pluginManagerTitle => 'Complementos';

  @override
  String get pluginManagerEmpty =>
      'No hay complementos instalados.\nToca + para añadir un archivo .bex.';

  @override
  String get pluginManagerFilterAll => 'Todos';

  @override
  String get pluginManagerFilterContent => 'Fuentes de contenido';

  @override
  String get pluginManagerFilterCharts => 'Proveedores de listas de éxitos';

  @override
  String get pluginManagerFilterLyrics => 'Proveedores de letras';

  @override
  String get pluginManagerFilterSuggestions => 'Proveedores de sugerencias';

  @override
  String get pluginManagerFilterImporters => 'Importadores';

  @override
  String get pluginManagerTooltipRefresh => 'Actualizar';

  @override
  String get pluginManagerTooltipInstall => 'Instalar complemento';

  @override
  String get pluginManagerNoMatch =>
      'Ningún complemento coincide con el filtro';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Error al elegir archivo: $error';
  }

  @override
  String get pluginManagerInstalling => 'Instalando complemento...';

  @override
  String get pluginManagerTypeContentResolver => 'Fuente de contenido';

  @override
  String get pluginManagerTypeChartProvider => 'Proveedor de listas de éxitos';

  @override
  String get pluginManagerTypeLyricsProvider => 'Proveedor de letras';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Sugerencias de búsqueda';

  @override
  String get pluginManagerTypeContentImporter => 'Importador';

  @override
  String get pluginManagerDeleteTitle => '¿Eliminar complemento?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Se borrarán sus archivos.';
  }

  @override
  String get pluginManagerDeleteAction => 'Eliminar';

  @override
  String get pluginManagerCancel => 'Cancelar';

  @override
  String get pluginManagerEnablePlugin => 'Activar complemento';

  @override
  String get pluginManagerUnloadPlugin => 'Desactivar complemento';

  @override
  String get pluginManagerDeleting => 'Eliminando...';

  @override
  String get pluginManagerApiKeysTitle => 'Claves API';

  @override
  String get pluginManagerApiKeysSaved => 'Claves API guardadas';

  @override
  String get pluginManagerSave => 'Guardar';

  @override
  String get pluginManagerDetailVersion => 'Versión';

  @override
  String get pluginManagerDetailType => 'Tipo';

  @override
  String get pluginManagerDetailPublisher => 'Editor';

  @override
  String get pluginManagerDetailLastUpdated => 'Última actualización';

  @override
  String get pluginManagerDetailCreated => 'Creado el';

  @override
  String get pluginManagerDetailHomepage => 'Sitio web';

  @override
  String get pluginManagerDeleteStorageTitle =>
      '¿Borrar datos del complemento?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '¿Quieres borrar también las claves API y ajustes de \"$name\"?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Mantener datos';

  @override
  String get pluginManagerDeleteStorageRemove => 'Borrar datos';

  @override
  String get segmentsSheetTitle => 'Segmentos';

  @override
  String get segmentsSheetEmpty => 'No hay segmentos disponibles';

  @override
  String get segmentsSheetUntitled => 'Segmento sin título';

  @override
  String get smartReplaceTitle => 'Reemplazo inteligente';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Elige una versión reproducible de «$title» para actualizar sus referencias en las listas guardadas.';
  }

  @override
  String get smartReplaceClose => 'Cerrar';

  @override
  String get smartReplaceNoMatch => 'No se encontró reemplazo';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Ninguna de las fuentes de contenido activas encontró una coincidencia adecuada.';

  @override
  String get smartReplaceBestMatch => 'Mejor coincidencia';

  @override
  String get smartReplaceSearchFailed => 'Fallo en la búsqueda';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Fallo en el reemplazo: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Reemplazo aplicado$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' y se actualizó la cola';

  @override
  String get playerUnknownQueue => 'Desconocido';

  @override
  String playerLiked(String title) {
    return '$title añadido a favoritos';
  }

  @override
  String playerUnliked(String title) {
    return '$title eliminado de favoritos';
  }

  @override
  String get offlineNoDownloads => 'No hay descargas';

  @override
  String get offlineTitle => 'Sin conexión';

  @override
  String get offlineSearchHint => 'Buscar en tus canciones...';

  @override
  String get offlineRefreshTooltip => 'Actualizar descargas';

  @override
  String get offlineCloseSearch => 'Cerrar búsqueda';

  @override
  String get offlineSearchTooltip => 'Buscar';

  @override
  String get offlineOpenFailed =>
      'No se pudo abrir esta pista. Prueba a actualizar las descargas.';

  @override
  String get offlinePlayFailed => 'No se pudo reproducir. Inténtalo de nuevo.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Fallo al cargar álbum';

  @override
  String get aboutCraftingSubtitle => 'Desarrollado para la música.';

  @override
  String get aboutFollowGitHub => 'Síguelo en GitHub';

  @override
  String get aboutSendInquiry => 'Consulta de negocios';

  @override
  String get aboutCreativeHighlights => 'Actualizaciones y contenido creativo';

  @override
  String get aboutTipQuote => '¿Te gusta Bloomee? Puedes apoyar su desarrollo.';

  @override
  String get aboutTipButton => 'Apoyar el proyecto';

  @override
  String get aboutTipDesc => 'Tu aportación ayuda a mejorar Bloomee.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Detalles de la canción';

  @override
  String get songInfoSectionTechnical => 'Información técnica';

  @override
  String get songInfoSectionActions => 'Acciones';

  @override
  String get songInfoLabelTitle => 'Título';

  @override
  String get songInfoLabelArtist => 'Artista';

  @override
  String get songInfoLabelAlbum => 'Álbum';

  @override
  String get songInfoLabelDuration => 'Duración';

  @override
  String get songInfoLabelSource => 'Fuente';

  @override
  String get songInfoLabelMediaId => 'ID de medios';

  @override
  String get songInfoLabelPluginId => 'ID de complemento';

  @override
  String get songInfoCopyId => 'Copiar ID';

  @override
  String get songInfoCopyLink => 'Copiar enlace';

  @override
  String get songInfoOpenBrowser => 'Abrir en navegador';

  @override
  String get songInfoIdCopied => 'ID de medios copiado';

  @override
  String get songInfoLinkCopied => 'Enlace copiado';

  @override
  String get songInfoNoLink => 'No hay enlace disponible';

  @override
  String get songInfoOpenFailed => 'No se pudo abrir el enlace';

  @override
  String get songInfoUpdateMetadata => 'Obtener metadatos actualizados';

  @override
  String get songInfoMetadataUpdated => 'Metadatos actualizados';

  @override
  String get songInfoMetadataUpdateFailed => 'Fallo al actualizar metadatos';

  @override
  String get songInfoMetadataUnavailable =>
      'Actualización no disponible para esta fuente';

  @override
  String get songInfoSearchTitle => 'Buscar esta canción en Bloomee';

  @override
  String get songInfoSearchArtist => 'Buscar este artista en Bloomee';

  @override
  String get songInfoSearchAlbum => 'Buscar este álbum en Bloomee';

  @override
  String get eqTitle => 'Ecualizador';

  @override
  String get chartNoItems => 'No hay elementos en esta lista';

  @override
  String get chartLoadFailed => 'Fallo al cargar lista de éxitos';

  @override
  String get chartPlay => 'Reproducir';

  @override
  String get chartResolving => 'Buscando fuente';

  @override
  String get chartReady => 'Listo';

  @override
  String get chartAddToPlaylist => 'Añadir a lista';

  @override
  String get chartNoResolver =>
      'No hay fuentes de contenido activas. Instala un complemento para reproducir.';

  @override
  String get chartResolveFailed => 'No se encontró fuente directa. Buscando...';

  @override
  String get chartNoResolverAdd => 'No hay fuentes de contenido activas.';

  @override
  String get chartNoMatch => 'Sin coincidencias. Prueba a buscar manualmente.';

  @override
  String get chartStatPeak => 'Mejor posición';

  @override
  String get chartStatWeeks => 'Semanas';

  @override
  String get chartStatChange => 'Cambio';

  @override
  String menuSharePreparing(String title) {
    return 'Preparando \"$title\" para compartir.';
  }

  @override
  String get menuOpenLinkFailed => 'No se pudo abrir el enlace';

  @override
  String get localMusicFolders => 'Carpetas de música';

  @override
  String get localMusicRemoveFolder => 'Quitar carpeta';

  @override
  String get localMusicCloseSearch => 'Cerrar búsqueda';

  @override
  String get localMusicOpenSearch => 'Buscar';

  @override
  String get localMusicNoMusicFound => 'No se encontró música local';

  @override
  String get localMusicNoSearchResults => 'Sin resultados para tu búsqueda.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Importar canciones';

  @override
  String get importNoPluginsLoaded =>
      'No hay complementos importadores cargados.\nInstala uno para importar desde servicios externos.';

  @override
  String get importBloomeeFiles => 'Importar archivos Bloomee';

  @override
  String get importM3UFiles => 'Importar lista M3U';

  @override
  String get importM3UNameDialogTitle => 'Nombre de la lista';

  @override
  String get importM3UNameHint => 'Ponle un nombre a esta lista';

  @override
  String get importM3UNoTracks =>
      'No se encontraron pistas válidas en el archivo M3U.';

  @override
  String get importNoteTitle => 'Nota';

  @override
  String get importNoteMessage =>
      'Solo puedes importar archivos creados por Bloomee.\nSi es de otra fuente, no funcionará. ¿Continuar?';

  @override
  String get importTitle => 'Importar';

  @override
  String get importCheckingUrl => 'Comprobando URL...';

  @override
  String get importFetchingTracks => 'Obteniendo pistas...';

  @override
  String get importSavingToLibrary => 'Guardando en la biblioteca...';

  @override
  String get importPasteUrlHint => 'Pega la URL de una lista o álbum';

  @override
  String get importAction => 'Importar';

  @override
  String importTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '$count pista',
    );
    return '$_temp0';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Resolviendo pistas: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Guardar $count pistas';
  }

  @override
  String importTracksSaved(int count) {
    return 'Pistas guardadas: $count';
  }

  @override
  String get importDone => 'Hecho';

  @override
  String get importMore => 'Importar más';

  @override
  String get importUnknownError => 'Error desconocido';

  @override
  String get importTryAgain => 'Reintentar';

  @override
  String get importSkipTrack => 'Omitir esta pista';

  @override
  String get importMatchOptions => 'Opciones de coincidencia';

  @override
  String get importSkipped => 'Omitida';

  @override
  String get importReorderTip => 'Mantén presionado para reordenar las listas';

  @override
  String get importErrorCannotHandleUrl =>
      'Este complemento no soporta la URL proporcionada.';

  @override
  String get importErrorUnexpectedResponse =>
      'Respuesta inesperada del complemento.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Error al comprobar URL: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Error al obtener información: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Error al obtener pistas: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Error al guardar lista: $error';
  }

  @override
  String get playlistPinToTop => 'Fijar arriba';

  @override
  String get playlistUnpin => 'Desfijar';

  @override
  String get snackbarInvalidFileFormat => 'Formato de archivo no válido';

  @override
  String get snackbarProcessingFile => 'Procesando archivo...';

  @override
  String get pluginManagerTabInstalled => 'Instalados';

  @override
  String get pluginManagerTabStore => 'Tienda de complementos';

  @override
  String get pluginManagerSelectPackage => 'Selecciona paquete (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'El complemento usa un manifiesto antiguo. Algunas funciones podrían fallar.';

  @override
  String get pluginManagerStatusActive => 'Activo';

  @override
  String get pluginManagerStatusInactive => 'Inactivo';

  @override
  String get pluginRepositoryAddTitle => 'Añadir repositorio';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Introduce el enlace de un archivo JSON válido de un repositorio de complementos.';

  @override
  String get pluginRepositoryAddAction => 'Añadir repositorio';

  @override
  String get pluginRepositoryTitle => 'Repositorios de complementos';

  @override
  String get pluginRepositorySubtitle =>
      'Añade una fuente JSON para explorar complementos disponibles en línea.';

  @override
  String get pluginRepositoryEmpty => 'No hay repositorios aún.';

  @override
  String get pluginRepositoryUnknownUpdate =>
      'Sin información de actualización';

  @override
  String get pluginRepositoryNoDescription => 'Sin descripción.';

  @override
  String get pluginRepositoryUrlCopied => 'URL copiada al portapapeles';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count complementos',
      one: '1 complemento',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Actualizado el $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count complementos disponibles',
      one: '1 complemento disponible',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Manifiesto antiguo. Riesgo de errores.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Editor desconocido';

  @override
  String get pluginRepositoryActionRetry => 'Reintentar';

  @override
  String get pluginRepositoryActionOutdated => 'Desactualizado';

  @override
  String get pluginRepositoryActionInstalled => 'Instalado';

  @override
  String get pluginRepositoryActionInstall => 'Instalar';

  @override
  String get pluginRepositoryActionUnavailable => 'No disponible';

  @override
  String get pluginRepositoryInstallFailed => 'Fallo en la instalación.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Error al descargar $name.';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Fallo al cargar repositorios.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'URL o archivo de repositorio no válido.';

  @override
  String get pluginRepositoryErrorRemove => 'Fallo al eliminar el repositorio.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reemplazado en $count listas$queue.',
      one: 'Reemplazado en 1 lista$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Buscar letras...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Escribe el nombre de una canción o de un artista para encontrar letras.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Sin letras para \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'Letra aplicada';

  @override
  String get lyricsSearchFetchFailed => 'Fallo al obtener letras';

  @override
  String get lyricsSearchPreview => 'Vista previa';

  @override
  String get lyricsSearchPreviewTooltip => 'Ver letras';

  @override
  String get lyricsSearchSynced => 'SINCRONIZADA';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Fallo al cargar letras.';

  @override
  String get lyricsSearchApplyAction => 'Aplicar letras';

  @override
  String get lyricsSettingsSearchTitle => 'Buscar otra letra';

  @override
  String get lyricsSettingsSearchSubtitle =>
      'Encuentra otras versiones en línea';

  @override
  String get lyricsSettingsSyncTitle => 'Ajustar sincronización';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Corrige letras adelantadas o atrasadas';

  @override
  String get lyricsSettingsSaveTitle => 'Guardar sin conexión';

  @override
  String get lyricsSettingsSaveSubtitle =>
      'Almacena las letras en tu dispositivo';

  @override
  String get lyricsSettingsDeleteTitle => 'Borrar letras guardadas';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Elimina la letra guardada sin conexión';

  @override
  String get lyricsSyncTapToReset => 'Toca para restablecer';

  @override
  String get upNextTitle => 'A continuación';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos en cola',
      one: '1 elemento en cola',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get snackbarCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get tooltipSongInfo => 'Info de la canción';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'No se puede borrar la canción que suena';

  @override
  String get playerLoopOff => 'No repetir';

  @override
  String get playerLoopOne => 'Repetir una';

  @override
  String get playerLoopAll => 'Repetir todas';

  @override
  String get snackbarOpeningAlbumPage => 'Abriendo página original del álbum.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Hay una nueva versión de Bloomee disponible.\n\nVersión: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Complemento \"$id\" instalado con éxito';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Complemento \"$id\" eliminado con éxito';
  }

  @override
  String get pluginBootstrapTitle => 'Configurando Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Configurando nuevo motor de complementos... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Esto solo sucede una vez.';

  @override
  String get backupSave => 'Guardar copia de seguridad como JSON';

  @override
  String get backupShare => 'Compartir copia de seguridad JSON';

  @override
  String get backupPortableDetails =>
      'Incluye listas, favoritos, colecciones guardadas, historiales y preferencias transferibles. No incluye archivos de audio, cuentas ni carpetas del dispositivo.';

  @override
  String get backupHistories => 'Historiales de reproducción y búsqueda';

  @override
  String get backupPreferences => 'Preferencias transferibles';

  @override
  String get backupNewCopy => 'Importar como listas nuevas';

  @override
  String get backupMerge => 'Combinar con los datos existentes';

  @override
  String get backupReplace => 'Reemplazar las secciones seleccionadas';

  @override
  String get backupMergeDetails =>
      'Se conservan las pistas, los metadatos y las preferencias existentes. Las pistas que faltan se añaden en el orden del archivo. Los favoritos se combinan.';

  @override
  String get backupReplaceWarning =>
      'Se reemplazarán las secciones seleccionadas, incluidas las listas y los favoritos existentes si seleccionas la biblioteca. Se conservarán las secciones no seleccionadas y los archivos del dispositivo. Primero se creará una copia de recuperación privada.';

  @override
  String get backupAutoDetails =>
      'Conserva siete copias de recuperación privadas. Se comprueba al abrir la aplicación, como máximo una vez cada 24 horas. Estas copias se eliminan al desinstalarla.';

  @override
  String get backupLocationDetails =>
      'Elige un destino con «Guardar copia de seguridad». Las copias de recuperación privadas se guardan dentro de la aplicación.';

  @override
  String get backupResetDetails =>
      'Restablece todos los datos de la base de datos al iniciar de nuevo la aplicación. Los archivos de audio descargados y los archivos de complementos instalados permanecen en el dispositivo. Primero se creará una copia de recuperación privada.';

  @override
  String get backupResetPending =>
      'Restablecimiento programado. Cierra y vuelve a abrir Bloomee para completarlo.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return 'Listas: $playlists · Pistas: $tracks';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'Importación completada. Listas creadas: $playlists; entradas de pistas añadidas: $tracks; registros de historial añadidos: $history; preferencias aplicadas: $settings.';
  }

  @override
  String get backupRefreshFailed =>
      'Los datos se han importado. Cierra y vuelve a abrir Bloomee para actualizar todas las preferencias.';

  @override
  String get backupRecoveryCopies => 'Copias de recuperación';

  @override
  String get backupNoRecoveryCopies => 'Aún no hay copias de recuperación.';

  @override
  String get backupRecoveryAutomatic => 'Copia de seguridad automática';

  @override
  String get backupRecoveryBeforeImport => 'Antes de una importación';

  @override
  String get backupRecoveryBeforeReset => 'Antes de un restablecimiento';

  @override
  String get backupCancelReset => 'Cancelar restablecimiento';

  @override
  String get libraryRecoveryTitle => 'Recuperar biblioteca perdida';

  @override
  String get libraryRecoverySubtitle =>
      'Busca listas y registros de descargas conservados de versiones anteriores.';

  @override
  String get libraryRecoveryChooseSource =>
      'Elige una base de datos conservada para analizarla. Tu biblioteca actual y los archivos originales se conservarán.';

  @override
  String get libraryRecoveryNoSources =>
      'No se encontraron bases de datos conservadas. Los archivos de audio por sí solos no permiten recuperar las listas a las que pertenecían.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return 'Se encontraron $tracks pistas, $playlists listas y $downloads registros de descargas. Archivos no disponibles actualmente: $unavailable; sus registros se conservarán.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return 'Referencias de listas dañadas que no se pudieron reconstruir a partir de esta copia: $broken.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'La recuperación añade las pistas, las entradas de listas y los registros de descargas que faltan. Se conservan las listas, las asociaciones de archivos y los ajustes existentes. Primero se crea una copia de recuperación. Repite el proceso con otra copia conservada si contiene más elementos de tu biblioteca.';

  @override
  String get libraryRecoveryMerge => 'Combinar biblioteca recuperada';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Recuperación completada. Entradas de listas añadidas: $entries; registros de descargas añadidos: $downloads.';
  }

  @override
  String get backupStartupFailed => 'Bloomee no pudo iniciarse';

  @override
  String get backupStartupFailedDetails =>
      'El inicio se detuvo sin reparar ni reemplazar automáticamente tu base de datos. Cierra la aplicación y vuelve a intentarlo. Conserva los datos de la aplicación al informar de este error.';

  @override
  String get lyricsTitle => 'Letra';

  @override
  String get lyricsEnterFullscreen => 'Letra a pantalla completa';

  @override
  String get lyricsExitFullscreen => 'Salir de pantalla completa';

  @override
  String get lyricsFollowPlayback => 'Seguir la reproducción';

  @override
  String get lyricsTimingEarlier => 'Mostrar antes';

  @override
  String get lyricsTimingLater => 'Mostrar después';

  @override
  String get lyricsTimingSave => 'Guardar sincronización';

  @override
  String get lyricsSaved => 'Letra guardada.';

  @override
  String get lyricsSaveFailed =>
      'No se pudo guardar la letra. Inténtalo de nuevo.';

  @override
  String get lyricsDeleteFailed =>
      'No se pudo eliminar la letra guardada. Inténtalo de nuevo.';

  @override
  String get artistTopSongs => 'Canciones populares';

  @override
  String get artistLoadFailed => 'No se pudo cargar el artista';

  @override
  String get artistNoTopSongs => 'No hay canciones populares disponibles';

  @override
  String get artistNoAlbums => 'No hay álbumes disponibles';

  @override
  String get snackbarOpeningArtistPage =>
      'Abriendo la página original del artista.';

  @override
  String get snackbarOpeningPlaylistPage =>
      'Abriendo la página original de la lista.';

  @override
  String get playlistSaveOrderFailed =>
      'No se pudo guardar el orden de la lista. Inténtalo de nuevo.';

  @override
  String get playlistReorderTracksHint =>
      'Mantén pulsado el control para reordenar las pistas';

  @override
  String get playlistTrackCountLabel => 'Número de pistas';

  @override
  String get playlistDescription => 'Descripción';

  @override
  String get playlistOriginalUrl => 'URL original';

  @override
  String get searchSearching => 'Buscando…';

  @override
  String get searchSuggestions => 'Sugerencias';

  @override
  String get searchTopResults => 'Resultados principales';

  @override
  String get changelogEmpty => 'No hay información de cambios disponible.';

  @override
  String get changelogTitle => 'Novedades';

  @override
  String get changelogLatest => 'Última';

  @override
  String get changelogNext => 'Próxima versión';

  @override
  String changelogVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Configuración incompleta';

  @override
  String get pluginBootstrapRetryBody =>
      'No se pudieron instalar algunos complementos. Reinténtalo para completar la configuración.';

  @override
  String get pluginBootstrapInternetTitle => 'Se requiere conexión a internet';

  @override
  String get pluginBootstrapInternetBody =>
      'Bloomee necesita conectarse a internet una vez para detectar tu país y configurar el motor de complementos.';

  @override
  String get buttonExit => 'Salir';

  @override
  String get eqSource => 'Origen del ecualizador';

  @override
  String get eqBuiltin => 'Ecualizador de la aplicación';

  @override
  String get eqBuiltinSubtitle => 'Ecualizador de 10 bandas';

  @override
  String get eqDevice => 'Ecualizador del dispositivo';

  @override
  String get eqDeviceSubtitle => 'Sistema / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'El ecualizador de la aplicación está desactivado. Configura el ecualizador del dispositivo en sus ajustes de sonido.';

  @override
  String get eqPresets => 'Preajustes';

  @override
  String get eqCustomCurve => 'Curva personalizada';

  @override
  String get shortcutMuted => 'Silenciado';

  @override
  String get shortcutUnmuted => 'Sonido activado';

  @override
  String get shortcutShuffleOn => 'Reproducción aleatoria activada';

  @override
  String get shortcutShuffleOff => 'Reproducción aleatoria desactivada';

  @override
  String get shortcutRepeatOff => 'Repetición desactivada';

  @override
  String get shortcutLiked => 'Añadido a favoritos';

  @override
  String get shortcutUnliked => 'Eliminado de favoritos';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'No se pudo seleccionar la carpeta de descargas: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Versión no disponible';

  @override
  String get backupNewCopyDetails =>
      'Crea listas independientes y combina los favoritos. Se conservan las listas existentes. También se importan los historiales y las preferencias seleccionados.';

  @override
  String get changelogCurrent => 'Actual';

  @override
  String get backupLibrary =>
      'Biblioteca (listas, favoritos y colecciones guardadas)';

  @override
  String get eqPresetFlat => 'Plano';

  @override
  String get eqPresetAcoustic => 'Acústico';

  @override
  String get eqPresetBassBoost => 'Refuerzo de graves';

  @override
  String get eqPresetBassReducer => 'Reducción de graves';

  @override
  String get eqPresetClassical => 'Clásica';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetDeep => 'Profundo';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Electrónica';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latina';

  @override
  String get eqPresetLive => 'En directo';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetPiano => 'Piano';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRB => 'R&B';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetSmallSpeakers => 'Altavoces pequeños';

  @override
  String get eqPresetSpokenWord => 'Voz hablada';

  @override
  String get eqPresetTrebleBoost => 'Refuerzo de agudos';

  @override
  String get eqPresetTrebleReducer => 'Reducción de agudos';

  @override
  String get eqPresetVocalBooster => 'Refuerzo de voz';

  @override
  String get eqPresetCustom => 'Personalizado';
}
