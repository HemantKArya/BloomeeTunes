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
  String get onboardingSubtitle => 'Configuremos tu idioma y región.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navLocal => 'Local';

  @override
  String get navOffline => 'Sin conexión';

  @override
  String get playerEnjoyingFrom => 'Escuchando desde';

  @override
  String get playerQueue => 'Cola de reproducción';

  @override
  String get playerPlayWithMix => 'Reproducción automática';

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
      'No hay un proveedor de letras configurado. Ve a Ajustes → Plugins para instalar uno.';

  @override
  String get playerFullscreenLyrics => 'Letras a pantalla completa';

  @override
  String get localMusicTitle => 'Música local';

  @override
  String get localMusicGrantPermission => 'Conceder permiso';

  @override
  String get localMusicStorageAccessRequired =>
      'Acceso al almacenamiento necesario';

  @override
  String get localMusicStorageAccessDesc =>
      'Por favor, concede permiso para escanear y reproducir los archivos de audio almacenados en tu dispositivo.';

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
      'Escaneando el dispositivo en busca de archivos...';

  @override
  String get localMusicEmpty => 'No se encontró música local';

  @override
  String get localMusicSearchEmpty =>
      'No hay pistas que coincidan con tu búsqueda.';

  @override
  String get localMusicShuffle => 'Modo aleatorio';

  @override
  String get localMusicPlayAll => 'Reproducir todo';

  @override
  String get localMusicSearchHint => 'Buscar música local...';

  @override
  String get localMusicRescanDevice => 'Volver a escanear dispositivo';

  @override
  String get localMusicRemoveFolder => 'Quitar carpeta';

  @override
  String get localMusicMusicFolders => 'Carpetas de música';

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
  String get buttonShare => 'Compartir';

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
    return '¿Estás seguro de que quieres eliminar \"$title\" de tu dispositivo? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Esta pista también se eliminará de:';

  @override
  String get dialogDontAskAgain => 'No volver a preguntar';

  @override
  String get dialogDeletePlugin => '¿Eliminar plugin?';

  @override
  String dialogDeletePluginMessage(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"? Esto borrará sus archivos de forma permanente.';
  }

  @override
  String get dialogUpdateAvailable => 'Actualización disponible';

  @override
  String get dialogUpdateNow => 'Actualizar ahora';

  @override
  String get dialogDownloadPlaylist => 'Descargar lista';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '¿Quieres descargar $count canciones de \"$title\"? Se añadirán a la cola de descarga.';
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
  String get playlistEmptyState => '¡Aún no hay canciones!';

  @override
  String get playlistAvailableOffline => 'Disponible sin conexión';

  @override
  String get playlistShuffle => 'Aleatorio';

  @override
  String get playlistMoreOptions => 'Más opciones';

  @override
  String get playlistNoMatchSearch => 'Ninguna lista coincide con tu búsqueda';

  @override
  String get playlistCreateNew => 'Crear nueva lista';

  @override
  String get playlistCreateFirstOne =>
      'No tienes listas aún. ¡Crea una para empezar!';

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
  String get settingsPlugins => 'Plugins';

  @override
  String get settingsPluginsSubtitle => 'Instala, carga y gestiona plugins.';

  @override
  String get settingsUpdates => 'Actualizaciones';

  @override
  String get settingsUpdatesSubtitle => 'Buscar nuevas versiones';

  @override
  String get settingsDownloads => 'Descargas';

  @override
  String get settingsDownloadsSubtitle => 'Ruta, calidad de descarga y más...';

  @override
  String get settingsLocalTracks => 'Pistas locales';

  @override
  String get settingsLocalTracksSubtitle => 'Escanear y gestionar carpetas.';

  @override
  String get settingsPlayer => 'Ajustes del reproductor';

  @override
  String get settingsPlayerSubtitle =>
      'Calidad de streaming, reproducción automática, etc.';

  @override
  String get settingsPluginDefaults => 'Plugins por defecto';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Fuentes y prioridad de resolución.';

  @override
  String get settingsUIElements => 'Interfaz y servicios';

  @override
  String get settingsUIElementsSubtitle =>
      'Ajustes visuales, carrusel automático, etc.';

  @override
  String get settingsLastFM => 'Ajustes de Last.FM';

  @override
  String get settingsLastFMSubtitle => 'Configuración de cuenta y scrobbling.';

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
  String get settingsScanning => 'Escaneando';

  @override
  String get settingsMusicFolders => 'Carpetas de música';

  @override
  String get settingsQuality => 'Calidad';

  @override
  String get settingsHistory => 'Historial';

  @override
  String get settingsBackupRestore => 'Copia de seguridad';

  @override
  String get settingsAutomatic => 'Automático';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'Autenticación';

  @override
  String get settingsHomeScreen => 'Pantalla de inicio';

  @override
  String get settingsChartVisibility => 'Visibilidad de listas';

  @override
  String get settingsLocation => 'Ubicación';

  @override
  String get pluginRepositoryTitle => 'Repositorios de plugins';

  @override
  String get pluginRepositorySubtitle =>
      'Añade fuentes para explorar nuevos plugins.';

  @override
  String get pluginRepositoryAddAction => 'Añadir repositorio';

  @override
  String get pluginRepositoryAddTitle => 'Añadir repositorio';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Introduce la URL de un JSON válido.';

  @override
  String get pluginRepositoryEmpty => 'No hay repositorios aún.';

  @override
  String get pluginRepositoryUrlCopied => 'URL copiada al portapapeles';

  @override
  String get pluginRepositoryNoDescription => 'Sin descripción.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Sin info de actualización';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugins',
      one: '1 plugin',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Fallo al cargar repositorios.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'URL o archivo de repositorio no válido.';

  @override
  String get pluginRepositoryErrorRemove => 'Fallo al eliminar el repositorio.';

  @override
  String pluginRepositoryError(String message) {
    return 'Error: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => 'Añadiendo a la cola de descarga';

  @override
  String get emptyNoInternet => '¡Sin conexión a internet!';

  @override
  String get emptyNoContentPlugin =>
      'No hay plugins de contenido cargados. Instala uno en el Gestor de Plugins.';

  @override
  String get emptyRefreshingSource =>
      'Actualizando fuente de descubrimiento... La anterior ya no está disponible.';

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
    return '¡Añadido a tus Me gusta: $title!';
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
  String get snackbarPlaylistQueued => 'Lista añadida a la cola de descarga';

  @override
  String get snackbarPlaylistUpdated => '¡Lista actualizada!';

  @override
  String get snackbarNoInternet => 'Sin conexión a internet.';

  @override
  String get snackbarImportFailed => '¡Error al importar!';

  @override
  String get snackbarImportCompleted => 'Importación completada';

  @override
  String get snackbarBackupFailed => '¡Error al crear la copia de seguridad!';

  @override
  String snackbarExportedTo(String path) {
    return 'Exportado a: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'ID de medios copiado';

  @override
  String get snackbarLinkCopied => 'Enlace copiado';

  @override
  String get snackbarNoLinkAvailable => 'No hay enlace disponible';

  @override
  String get snackbarCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Preparando descarga para $title...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title ya está descargado.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title ya está en la cola.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'Descargado: $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Error: El servicio de descarga no está disponible.';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Se añadieron $count canciones a la cola de descarga';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Error al eliminar la pista del almacenamiento del dispositivo.';

  @override
  String get searchHintExplore => '¿Qué quieres escuchar?';

  @override
  String get searchHintLibrary => 'Buscar en la biblioteca...';

  @override
  String get searchHintOfflineMusic => 'Buscar en tus canciones...';

  @override
  String get searchHintPlaylists => 'Buscar listas...';

  @override
  String get searchStartTyping => 'Empieza a escribir para buscar...';

  @override
  String get searchNoSuggestions => '¡No se encontraron sugerencias!';

  @override
  String get searchNoResults =>
      '¡No hay resultados!\nPrueba con otra palabra clave o fuente.';

  @override
  String get searchFailed => '¡Error en la búsqueda!';

  @override
  String get searchDiscover => 'Descubre música increíble...';

  @override
  String get searchSources => 'FUENTES';

  @override
  String get searchNoPlugins => 'No hay plugins instalados';

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
  String get exploreRecently => 'Reciente';

  @override
  String get exploreLastFmPicks => 'Recomendaciones de Last.Fm';

  @override
  String get exploreFailedToLoad => 'Error al cargar las secciones de inicio.';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmptyState =>
      'Tu biblioteca se siente sola. ¡Añade música para alegrarla!';

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
  String get songInfoTitle => 'Título';

  @override
  String get songInfoArtist => 'Artista';

  @override
  String get songInfoAlbum => 'Álbum';

  @override
  String get songInfoMediaId => 'ID de medios';

  @override
  String get songInfoCopyId => 'Copiar ID';

  @override
  String get songInfoCopyLink => 'Copiar enlace';

  @override
  String get songInfoOpenBrowser => 'Abrir en navegador';

  @override
  String get tooltipRemoveFromLibrary => 'Quitar de la biblioteca';

  @override
  String get tooltipSaveToLibrary => 'Guardar en la biblioteca';

  @override
  String get tooltipOpenOriginalLink => 'Abrir enlace original';

  @override
  String get tooltipShuffle => 'Aleatorio';

  @override
  String get tooltipAvailableOffline => 'Disponible sin conexión';

  @override
  String get tooltipDownloadPlaylist => 'Descargar lista';

  @override
  String get tooltipMoreOptions => 'Más opciones';

  @override
  String get tooltipInfo => 'Información';

  @override
  String get appuiTitle => 'Interfaz y servicios';

  @override
  String get appuiAutoSlideCharts => 'Carrusel automático';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Deslizar las listas automáticamente en el inicio.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Sugerencias de Last.FM. Requiere inicio de sesión y reinicio.';

  @override
  String get appuiNoChartsAvailable =>
      'No hay listas disponibles. Instala un plugin de listas.';

  @override
  String get appuiLoginToLastFm => 'Inicia sesión en Last.FM primero.';

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
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Hacer scrobbling';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Enviar pistas escuchadas a tu perfil de Last.FM.';

  @override
  String get lastfmAuthFirst => 'Primero autentica la API de Last.FM.';

  @override
  String get lastfmAuthenticatedAs => 'Autenticado como';

  @override
  String get lastfmAuthFailed => 'Error de autenticación:';

  @override
  String get lastfmNotAuthenticated => 'No autenticado';

  @override
  String get lastfmSteps =>
      'Pasos para autenticar:\n1. Crea/abre una cuenta en last.fm\n2. Genera una API Key en last.fm/api/account/create\n3. Introduce tu API Key y Secret abajo\n4. Toca \"Iniciar Autenticación\" y aprueba en el navegador\n5. Toca \"Guardar Clave de Sesión\" para terminar';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. Iniciar Autenticación';

  @override
  String get lastfmGetSession => '2. Guardar Clave de Sesión';

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
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Calidad de streaming';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Calidad de audio global para reproducción online.';

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
  String get playerSettingAutoFallback => 'Búsqueda de respaldo automática';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Si falla un plugin, intentar con otro compatible automáticamente.';

  @override
  String get playerSettingCrossfade => 'Crossfade (Fundido)';

  @override
  String get playerSettingCrossfadeOff => 'Desactivado';

  @override
  String get playerSettingCrossfadeInstant => 'Cambio instantáneo';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Fundido de ${seconds}s entre canciones';
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
  String get pluginDefaultsTitle => 'Plugins por defecto';

  @override
  String get pluginDefaultsDiscoverHeader => 'Fuente de descubrimiento';

  @override
  String get pluginDefaultsNoResolver =>
      'No hay cargado un plugin de resolución. Instala uno primero.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Usar el primer plugin disponible.';

  @override
  String get pluginDefaultsPriorityHeader => 'Prioridad de resolución';

  @override
  String get pluginDefaultsNoPriority =>
      'No hay plugins cargados. La prioridad aparecerá aquí al instalarlos.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Arrastra para reordenar. Los plugins superiores se intentarán primero.';

  @override
  String get pluginDefaultsLyricsHeader => 'Prioridad de letras';

  @override
  String get pluginDefaultsLyricsNone => 'No hay proveedores de letras.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Arrastra para reordenar los proveedores de letras.';

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
  String get storageBackupLocation => 'Ubicación de copia de seguridad';

  @override
  String get storageBackupLocationAndroid =>
      'Directorio de Descargas / App-data';

  @override
  String get storageBackupLocationDownloads => 'Directorio de Descargas';

  @override
  String get storageCreateBackup => 'Crear copia de seguridad';

  @override
  String get storageCreateBackupSubtitle =>
      'Guarda tus ajustes y datos en un archivo.';

  @override
  String storageBackupCreatedAt(String path) {
    return 'Copia creada en $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Error al compartir copia: $error';
  }

  @override
  String get storageBackupFailed => '¡Error en la copia de seguridad!';

  @override
  String get storageRestoreBackup => 'Restaurar copia';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restaura tus datos desde un archivo de copia de seguridad.';

  @override
  String get storageAutoBackup => 'Copia automática';

  @override
  String get storageAutoBackupSubtitle =>
      'Crear copias de seguridad automáticas periódicamente.';

  @override
  String get storageAutoLyrics => 'Autoguardado de letras';

  @override
  String get storageAutoLyricsSubtitle =>
      'Guardar letras automáticamente al reproducir una canción.';

  @override
  String get storageResetApp => 'Restablecer Bloomee';

  @override
  String get storageResetAppSubtitle =>
      'Elimina todos los datos y devuelve la app a su estado inicial.';

  @override
  String get storageResetConfirmTitle => 'Confirmar restablecimiento';

  @override
  String get storageResetConfirmMessage =>
      '¿Estás seguro de que quieres restablecer Bloomee? Esto borrará todos tus datos y no se puede deshacer.';

  @override
  String get storageResetButton => 'Restablecer';

  @override
  String get storageResetSuccess => 'La aplicación ha sido restablecida.';

  @override
  String get storageLocationDialogTitle => 'Ubicación de copia';

  @override
  String get storageLocationAndroid =>
      'Las copias se guardan en:\n\n1. Directorio de Descargas\n2. Android/data/ls.bloomee.musicplayer/data\n\nCopia el archivo desde cualquiera de esas rutas.';

  @override
  String get storageLocationOther =>
      'Las copias se guardan en la carpeta de Descargas.';

  @override
  String get storageRestoreOptionsTitle => 'Opciones de restauración';

  @override
  String get storageRestoreOptionsDesc =>
      'Elige qué quieres restaurar. Desmarca lo que NO quieras importar.';

  @override
  String get storageRestoreSelectAll => 'Seleccionar todo';

  @override
  String get storageRestoreMediaItems =>
      'Elementos multimedia (biblioteca, canciones)';

  @override
  String get storageRestoreSearchHistory => 'Historial de búsqueda';

  @override
  String get storageRestoreContinue => 'Continuar';

  @override
  String get storageRestoreNoFile => 'No se seleccionó ningún archivo.';

  @override
  String get storageRestoreSaveFailed =>
      'Error al guardar el archivo seleccionado.';

  @override
  String get storageRestoreConfirmTitle => 'Confirmar restauración';

  @override
  String get storageRestoreConfirmPrefix =>
      'Esto sobrescribirá y fusionará tus datos actuales con los del archivo:';

  @override
  String get storageRestoreConfirmSuffix =>
      '¿Estás seguro de que quieres proceder?';

  @override
  String get storageRestoreYes => 'Sí, restaurar';

  @override
  String get storageRestoreNo => 'No';

  @override
  String get storageRestoring =>
      'Restaurando datos seleccionados…\nPor favor, espera.';

  @override
  String get storageRestoreMediaBullet => '• Elementos multimedia';

  @override
  String get storageRestoreHistoryBullet => '• Historial de búsqueda';

  @override
  String get storageUnexpectedError =>
      'Ocurrió un error inesperado durante la restauración.';

  @override
  String get storageRestoreCompleted => 'Restauración completada';

  @override
  String get storageRestoreFailedTitle => 'Fallo en la restauración';

  @override
  String get storageRestoreSuccessMessage =>
      'Datos restaurados con éxito. Se recomienda reiniciar la aplicación.';

  @override
  String get storageRestoreFailedMessage =>
      'La restauración falló con los siguientes errores:';

  @override
  String get storageRestoreUnknownError =>
      'Error desconocido durante la restauración.';

  @override
  String get storageRestoreRestartHint =>
      'Por favor, reinicia la app para asegurar la consistencia.';

  @override
  String get updateSettingTitle => 'Actualizaciones';

  @override
  String get updateAppUpdatesHeader => 'Actualizaciones de la app';

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
  String get updateUpToDate => '¡Bloomee🌸 está al día!';

  @override
  String get updateViewPreRelease => 'Ver última Pre-Release';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versión actual: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      '¡Hay una nueva versión de Bloomee🌸 disponible!';

  @override
  String updateVersion(String ver, String build) {
    return 'Versión: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Descargar ahora';

  @override
  String get updateChecking => 'Comprobando disponibilidad de versiones...';

  @override
  String get timerTitle => 'Temporizador';

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
      'La música se ha detenido. ¡Que descanses! 🥰';

  @override
  String get timerGotIt => 'Entendido';

  @override
  String get timerSetTimeError => 'Por favor, elige un tiempo';

  @override
  String get timerStart => 'Iniciar temporizador';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => '¡No hay notificaciones aún!';

  @override
  String get recentsTitle => 'Historial';

  @override
  String playlistByCreator(String creator) {
    return 'por $creator';
  }

  @override
  String get playlistTypeAlbum => 'Álbum';

  @override
  String get playlistTypePlaylist => 'Lista';

  @override
  String get playlistYou => 'Tú';

  @override
  String get pluginManagerTitle => 'Plugins';

  @override
  String get pluginManagerEmpty =>
      'No hay plugins instalados.\nToca + para añadir un archivo .bex.';

  @override
  String get pluginManagerFilterAll => 'Todos';

  @override
  String get pluginManagerFilterContent => 'Contenido';

  @override
  String get pluginManagerFilterCharts => 'Listas/Éxitos';

  @override
  String get pluginManagerFilterLyrics => 'Letras';

  @override
  String get pluginManagerFilterSuggestions => 'Sugerencias';

  @override
  String get pluginManagerFilterImporters => 'Importadores';

  @override
  String get pluginManagerTooltipRefresh => 'Actualizar';

  @override
  String get pluginManagerTooltipInstall => 'Instalar Plugin';

  @override
  String get pluginManagerNoMatch => 'Ningún plugin coincide con el filtro';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Error al elegir archivo: $error';
  }

  @override
  String get pluginManagerInstalling => 'Instalando plugin...';

  @override
  String get pluginManagerTypeContentResolver => 'Contenido';

  @override
  String get pluginManagerTypeChartProvider => 'Listas/Éxitos';

  @override
  String get pluginManagerTypeLyricsProvider => 'Letras';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Sugerencias';

  @override
  String get pluginManagerTypeContentImporter => 'Importador';

  @override
  String get pluginManagerDeleteTitle => '¿Eliminar plugin?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Se borrarán sus archivos.';
  }

  @override
  String get pluginManagerDeleteAction => 'Eliminar';

  @override
  String get pluginManagerCancel => 'Cancelar';

  @override
  String get pluginManagerEnablePlugin => 'Habilitar Plugin';

  @override
  String get pluginManagerUnloadPlugin => 'Desactivar Plugin';

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
  String get pluginManagerDowngradeTitle => '¿Instalar versión anterior?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'Estás instalando una versión igual o anterior de \"$name\". ¿Continuar?';
  }

  @override
  String get pluginManagerDowngradeAction => 'Instalar de todos modos';

  @override
  String get pluginManagerDeleteStorageTitle => '¿Borrar datos del plugin?';

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
    return 'Elige un reemplazo para \"$title\" y actualiza las referencias en tus listas.';
  }

  @override
  String get smartReplaceClose => 'Cerrar';

  @override
  String get smartReplaceNoMatch => 'No se encontró reemplazo';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Ninguno de los plugins cargados devolvió una coincidencia clara.';

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
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return 'Reemplazado en $count lista$plural$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' y se actualizó la cola';

  @override
  String get playerUnknownQueue => 'Desconocido';

  @override
  String playerLiked(String title) {
    return '¡Añadido a Me gusta!';
  }

  @override
  String playerUnliked(String title) {
    return '¡Quitado de Me gusta!';
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
  String get aboutCraftingSubtitle => 'Creando sinfonías en código.';

  @override
  String get aboutFollowGitHub => 'Síguelo en GitHub';

  @override
  String get aboutSendInquiry => 'Consulta de negocios';

  @override
  String get aboutCreativeHighlights => 'Actualizaciones y contenido creativo';

  @override
  String get aboutTipQuote =>
      '¿Te gusta Bloomee? Tu apoyo ayuda a que siga creciendo. 🌸';

  @override
  String get aboutTipButton => 'Quiero ayudar';

  @override
  String get aboutTipDesc => 'Quiero que Bloomee siga mejorando.';

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
  String get songInfoLabelPluginId => 'ID de plugin';

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
  String get eqResetTooltip => 'Restablecer';

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
      'No hay cargado un plugin de resolución. Instala uno.';

  @override
  String get chartResolveFailed => 'No se encontró fuente directa. Buscando...';

  @override
  String get chartNoResolverAdd => 'No hay plugins cargados.';

  @override
  String get chartNoMatch => 'Sin coincidencias. Prueba a buscar manualmente.';

  @override
  String get chartStatPeak => 'Pico';

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
  String get localMusicCloseSearch => 'Cerrar búsqueda';

  @override
  String get localMusicOpenSearch => 'Buscar';

  @override
  String get localMusicNoMusicFound => 'No se encontró música local';

  @override
  String get localMusicNoSearchResults => 'Sin resultados para tu búsqueda.';

  @override
  String get importSongsTitle => 'Importar canciones';

  @override
  String get importNoPluginsLoaded =>
      'No hay plugins importadores cargados.\nInstala uno para importar desde servicios externos.';

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
    return '$count pistas';
  }

  @override
  String get importResolving => 'Buscando fuentes...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'Resolviendo pistas: $done / $total';
  }

  @override
  String get importReviewTitle => 'Revisión de importación';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved resueltas, $failed fallidas de $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Guardar $count pistas';
  }

  @override
  String importTracksSaved(int count) {
    return '¡$count pistas guardadas!';
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
  String get importAutoMatched => 'Automática';

  @override
  String get importUserSelected => 'Seleccionada';

  @override
  String get importSkipped => 'Omitida';

  @override
  String get importNoMatch => 'Sin coincidencia';

  @override
  String get importReorderTip => 'Mantén presionado para reordenar las listas';

  @override
  String get importErrorCannotHandleUrl =>
      'Este plugin no soporta la URL proporcionada.';

  @override
  String get importErrorUnexpectedResponse =>
      'Respuesta inesperada del plugin.';

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
  String get snackbarImportingMedia => 'Importando elementos multimedia...';

  @override
  String get snackbarPlaylistSaved => '¡Lista guardada en la biblioteca!';

  @override
  String get snackbarInvalidFileFormat => 'Formato de archivo no válido';

  @override
  String get snackbarMediaItemImported => 'Elemento multimedia importado';

  @override
  String get snackbarPlaylistImported => 'Lista importada';

  @override
  String get snackbarOpenImportForUrl =>
      'Abre la pantalla de Importar en la Biblioteca para usar esta URL.';

  @override
  String get snackbarProcessingFile => 'Procesando archivo...';

  @override
  String snackbarPreparingShare(String title) {
    return 'Preparando \"$title\" para compartir';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Preparando \"$title\" para exportar.';
  }

  @override
  String get pluginManagerTabInstalled => 'Instalados';

  @override
  String get pluginManagerTabStore => 'Tienda de plugins';

  @override
  String get pluginManagerSelectPackage => 'Selecciona paquete (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'El plugin usa un manifiesto antiguo. Algunas funciones podrían fallar.';

  @override
  String get pluginManagerStatusActive => 'Activo';

  @override
  String get pluginManagerStatusInactive => 'Inactivo';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Actualizado el $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugins disponibles',
      one: '1 plugin disponible',
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
  String get pluginRepositoryActionOutdated => 'Antiguo';

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
  String get lyricsSearchEmptyPrompt => 'Escribe una canción o artista.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Sin letras para \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'Letras aplicadas con éxito';

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
  String get lyricsSettingsSearchTitle => 'Buscar letras personalizadas';

  @override
  String get lyricsSettingsSearchSubtitle =>
      'Busca versiones alternativas online';

  @override
  String get lyricsSettingsSyncTitle => 'Ajustar sincronización';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Corrige letras adelantadas o atrasadas';

  @override
  String get lyricsSettingsSaveTitle => 'Guardar para offline';

  @override
  String get lyricsSettingsSaveSubtitle =>
      'Almacena las letras en tu dispositivo';

  @override
  String get lyricsSettingsDeleteTitle => 'Borrar letras guardadas';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Elimina los datos de letras offline';

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
  String get upNextAutoPlay => 'Automático';

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
    return '¡Nueva versión de Bloomee🌸 disponible!\n\nVersión: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Plugin \"$id\" instalado con éxito';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'Plugin \"$id\" cargado';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Plugin \"$id\" eliminado con éxito';
  }

  @override
  String get pluginBootstrapTitle => 'Configurando Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Configurando nuevo motor de plugins... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Esto solo sucede una vez.';

  @override
  String get pluginBootstrapErrorTitle => 'Conexión lenta';

  @override
  String get pluginBootstrapErrorBody =>
      'No se instalaron algunos plugins. Puedes usar Bloomee, se reintentará en el próximo inicio.';

  @override
  String get pluginBootstrapContinue => 'Continuar de todos modos';
}
