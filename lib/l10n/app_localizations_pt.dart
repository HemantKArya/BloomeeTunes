// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get onboardingTitle => 'Boas-vindas ao Bloomee';

  @override
  String get onboardingSubtitle => 'Escolha seu idioma e sua região.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get navHome => 'Início';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navLocal => 'No dispositivo';

  @override
  String get navOffline => 'Offline';

  @override
  String get playerEnjoyingFrom => 'Reproduzindo de';

  @override
  String get playerPlayWithMix => 'Reproduzir com mix automático';

  @override
  String get playerPlayNext => 'Reproduzir a seguir';

  @override
  String get playerAddToQueue => 'Adicionar à fila';

  @override
  String get playerAddToFavorites => 'Adicionar aos favoritos';

  @override
  String get playerNoLyricsFound => 'Nenhuma letra encontrada';

  @override
  String get playerLyricsNoPlugin =>
      'Nenhum provedor de letras configurado. Acesse Configurações → Plugins para instalar um.';

  @override
  String get localMusicTitle => 'No dispositivo';

  @override
  String get localMusicGrantPermission => 'Permitir acesso';

  @override
  String get localMusicStorageAccessRequired =>
      'Acesso ao armazenamento necessário';

  @override
  String get localMusicStorageAccessDesc =>
      'Permita o acesso para buscar e reproduzir os arquivos de áudio do seu dispositivo.';

  @override
  String get localMusicAddFolder => 'Adicionar pasta de músicas';

  @override
  String get localMusicScanNow => 'Buscar agora';

  @override
  String localMusicScanFailed(String message) {
    return 'Falha na busca: $message';
  }

  @override
  String get localMusicScanning => 'Buscando arquivos de áudio no dispositivo…';

  @override
  String get localMusicShuffle => 'Aleatório';

  @override
  String get localMusicPlayAll => 'Reproduzir tudo';

  @override
  String get localMusicSearchHint => 'Buscar músicas no dispositivo…';

  @override
  String get localMusicRescanDevice => 'Buscar novamente no dispositivo';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'Atualizar';

  @override
  String get buttonDownload => 'Baixar';

  @override
  String get buttonLater => 'Mais tarde';

  @override
  String get buttonInfo => 'Informações';

  @override
  String get buttonMore => 'Mais';

  @override
  String get dialogDeleteTrack => 'Excluir faixa';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Excluir “$title” do dispositivo? Essa ação não pode ser desfeita.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Essa faixa também será removida de:';

  @override
  String get dialogDontAskAgain => 'Não perguntar novamente';

  @override
  String get dialogUpdateAvailable => 'Atualização disponível';

  @override
  String get dialogUpdateNow => 'Atualizar agora';

  @override
  String get dialogDownloadPlaylist => 'Baixar playlist';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Baixar as músicas de “$title”? Total: $count. Elas serão adicionadas à fila de downloads.';
  }

  @override
  String get dialogDownloadAll => 'Baixar tudo';

  @override
  String get playlistEdit => 'Editar playlist';

  @override
  String get playlistShareFile => 'Compartilhar arquivo';

  @override
  String get playlistExportFile => 'Exportar arquivo';

  @override
  String get playlistPlay => 'Reproduzir';

  @override
  String get playlistAddToQueue => 'Adicionar playlist à fila';

  @override
  String get playlistShare => 'Compartilhar playlist';

  @override
  String get playlistDelete => 'Excluir playlist';

  @override
  String get playlistEmptyState => 'Nenhuma música ainda';

  @override
  String get playlistAvailableOffline => 'Disponível offline';

  @override
  String get playlistShuffle => 'Aleatório';

  @override
  String get playlistNoMatchSearch => 'Nenhuma playlist corresponde à busca';

  @override
  String get playlistCreateNew => 'Criar playlist';

  @override
  String get playlistCreateFirstOne =>
      'Você ainda não tem playlists. Crie uma para começar.';

  @override
  String get addToPlaylistNoSongSelected => 'Nenhuma música selecionada';

  @override
  String get createPlaylistDialogBarrierLabel =>
      'Janela de criação de playlist';

  @override
  String get createPlaylistDialogNameHint => 'Músicas de verão';

  @override
  String get createPlaylistDialogCreate => 'Criar';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '$count música',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title removida de $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Não foi possível carregar a playlist';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsPlugins => 'Plugins';

  @override
  String get settingsPluginsSubtitle => 'Instale, ative e gerencie plugins.';

  @override
  String get settingsUpdates => 'Atualizações';

  @override
  String get settingsUpdatesSubtitle => 'Verifique se há atualizações';

  @override
  String get settingsDownloads => 'Downloads';

  @override
  String get settingsDownloadsSubtitle =>
      'Pasta de downloads, qualidade de áudio e outras opções';

  @override
  String get settingsLocalTracks => 'Faixas do dispositivo';

  @override
  String get settingsLocalTracksSubtitle =>
      'Busca de músicas, pastas e busca automática';

  @override
  String get settingsPlayer => 'Configurações de reprodução';

  @override
  String get settingsPlayerSubtitle =>
      'Qualidade de áudio, reprodução automática e outras opções';

  @override
  String get settingsPluginDefaults => 'Plugins padrão';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Fonte de Descobrir e prioridade dos resolvedores';

  @override
  String get settingsUIElements => 'Interface e serviços';

  @override
  String get settingsUIElementsSubtitle =>
      'Rolagem automática e ajustes da interface';

  @override
  String get settingsLastFM => 'Configurações do Last.fm';

  @override
  String get settingsLastFMSubtitle =>
      'Chaves de API e envio do histórico de reprodução';

  @override
  String get settingsStorage => 'Armazenamento';

  @override
  String get settingsStorageSubtitle =>
      'Backup, cache, histórico e restauração';

  @override
  String get settingsLanguageCountry => 'Idioma e país';

  @override
  String get settingsLanguageCountrySubtitle =>
      'Escolha seu idioma e seu país.';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutSubtitle =>
      'Informações sobre o aplicativo, a versão e o desenvolvedor';

  @override
  String get settingsScanning => 'Busca de arquivos';

  @override
  String get settingsMusicFolders => 'Pastas de músicas';

  @override
  String get settingsQuality => 'Qualidade';

  @override
  String get settingsHistory => 'Histórico';

  @override
  String get settingsBackupRestore => 'Backup e restauração';

  @override
  String get settingsAutomatic => 'Automático';

  @override
  String get settingsDangerZone => 'Redefinição de dados';

  @override
  String get settingsScrobbling => 'Envio do histórico de reprodução';

  @override
  String get settingsAuthentication => 'Autenticação';

  @override
  String get settingsHomeScreen => 'Tela inicial';

  @override
  String get settingsChartVisibility => 'Visibilidade das paradas';

  @override
  String get dialogAddingToDownloadQueue => 'Adicionando à fila de downloads';

  @override
  String get emptyNoInternet => 'Sem conexão com a internet';

  @override
  String get emptyNoContentPlugin =>
      'Nenhum resolvedor de conteúdo ativo. Ative um no gerenciador de plugins.';

  @override
  String get emptyRefreshingSource =>
      'Atualizando a fonte de Descobrir… A fonte anterior não está mais disponível.';

  @override
  String get emptyNoTracks => 'Nenhuma faixa disponível';

  @override
  String get emptyNoResults => 'Nenhuma correspondência encontrada';

  @override
  String snackbarDeletedTrack(String title) {
    return '“$title” excluída';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Não foi possível excluir “$title”';
  }

  @override
  String get snackbarAddedToNextQueue => 'Adicionada para reproduzir a seguir';

  @override
  String get snackbarAddedToQueue => 'Adicionada à fila';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title adicionada aos favoritos';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Reproduzindo $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name adicionada à fila';
  }

  @override
  String get snackbarPlaylistUpdated => 'Playlist atualizada';

  @override
  String get snackbarLinkCopied => 'Link copiado';

  @override
  String get snackbarCouldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Músicas adicionadas à fila de downloads: $count';
  }

  @override
  String get searchHintExplore => 'O que você quer ouvir?';

  @override
  String get searchHintLibrary => 'Buscar na biblioteca…';

  @override
  String get searchHintPlaylists => 'Buscar playlists…';

  @override
  String get searchStartTyping => 'Digite para buscar';

  @override
  String get searchNoSuggestions => 'Nenhuma sugestão encontrada';

  @override
  String get searchNoResults =>
      'Nenhum resultado encontrado.\nTente outro termo ou outra fonte.';

  @override
  String get searchFailed => 'Falha na busca';

  @override
  String get searchDiscover => 'Descubra novas músicas';

  @override
  String get searchSources => 'Fontes';

  @override
  String get searchNoPlugins => 'Nenhum plugin instalado';

  @override
  String get searchTracks => 'Faixas';

  @override
  String get searchAlbums => 'Álbuns';

  @override
  String get searchArtists => 'Artistas';

  @override
  String get searchPlaylists => 'Playlists';

  @override
  String get exploreDiscover => 'Descobrir';

  @override
  String get exploreRecently => 'Ouvidas recentemente';

  @override
  String get exploreLastFmPicks => 'Sugestões do Last.fm';

  @override
  String get exploreFailedToLoad =>
      'Não foi possível carregar as seções da tela inicial.';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmptyState =>
      'Sua biblioteca está vazia. Adicione músicas e playlists para começar.';

  @override
  String libraryIn(String playlistName) {
    return 'em $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Adicionar à playlist';

  @override
  String get menuSmartReplace => 'Substituir por uma faixa equivalente';

  @override
  String get menuShare => 'Compartilhar';

  @override
  String get menuAvailableOffline => 'Disponível offline';

  @override
  String get menuDownload => 'Baixar';

  @override
  String get menuOpenOriginalLink => 'Abrir link original';

  @override
  String get menuDeleteTrack => 'Excluir';

  @override
  String get tooltipRemoveFromLibrary => 'Remover da biblioteca';

  @override
  String get tooltipSaveToLibrary => 'Salvar na biblioteca';

  @override
  String get tooltipOpenOriginalLink => 'Abrir link original';

  @override
  String get tooltipAvailableOffline => 'Disponível offline';

  @override
  String get tooltipMoreOptions => 'Mais opções';

  @override
  String get appuiTitle => 'Interface e serviços';

  @override
  String get appuiAutoSlideCharts => 'Avançar paradas automaticamente';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Avance automaticamente as paradas da tela inicial.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Mostre sugestões do Last.fm. É necessário entrar na conta e reiniciar o aplicativo.';

  @override
  String get appuiNoChartsAvailable =>
      'Nenhuma parada disponível. Ative um plugin provedor de paradas.';

  @override
  String get appuiLoginToLastFm => 'Entre na sua conta do Last.fm primeiro.';

  @override
  String get appuiShowInCarousel => 'Mostrar no carrossel da tela inicial.';

  @override
  String get countrySettingTitle => 'País e idioma';

  @override
  String get countrySettingAutoDetect => 'Detectar país automaticamente';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Detecte seu país automaticamente ao abrir o aplicativo.';

  @override
  String get countrySettingCountryLabel => 'País';

  @override
  String get countrySettingLanguageLabel => 'Idioma';

  @override
  String get countrySettingSystemDefault => 'Padrão do sistema';

  @override
  String get downloadSettingTitle => 'Downloads';

  @override
  String get downloadSettingQuality => 'Qualidade dos downloads';

  @override
  String get downloadSettingQualitySubtitle =>
      'Qualidade de áudio preferida para todas as faixas baixadas.';

  @override
  String get downloadSettingFolder => 'Pasta de downloads';

  @override
  String get downloadSettingResetFolder =>
      'Restaurar pasta de downloads padrão';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Restaure o local padrão dos downloads.';

  @override
  String get lastfmTitle => 'Last.fm';

  @override
  String get lastfmScrobbleTracks => 'Enviar histórico de reprodução';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Envie as faixas reproduzidas para seu perfil do Last.fm.';

  @override
  String get lastfmAuthFirst => 'Autorize o acesso à API do Last.fm primeiro.';

  @override
  String get lastfmAuthenticatedAs => 'Conectado como';

  @override
  String get lastfmAuthFailed => 'Falha na autenticação:';

  @override
  String get lastfmNotAuthenticated => 'Não autenticado';

  @override
  String get lastfmSteps =>
      'Como autenticar:\n1. Crie uma conta ou entre em last.fm.\n2. Gere uma chave de API em last.fm/api/account/create.\n3. Insira a chave de API e a chave secreta abaixo.\n4. Toque em “1. Iniciar autorização” e autorize no navegador.\n5. Toque em “2. Obter e salvar chave de sessão”.';

  @override
  String get lastfmApiKey => 'Chave de API';

  @override
  String get lastfmApiSecret => 'Chave secreta da API';

  @override
  String get lastfmStartAuth => '1. Iniciar autorização';

  @override
  String get lastfmGetSession => '2. Obter e salvar chave de sessão';

  @override
  String get lastfmRemoveKeys => 'Remover chaves';

  @override
  String get lastfmStartAuthFirst =>
      'Inicie a autorização primeiro e confirme no navegador.';

  @override
  String get localSettingTitle => 'Faixas do dispositivo';

  @override
  String get localSettingAutoScan => 'Buscar arquivos ao iniciar';

  @override
  String get localSettingAutoScanSubtitle =>
      'Busque novas faixas no dispositivo ao iniciar o aplicativo.';

  @override
  String get localSettingLastScan => 'Última busca';

  @override
  String get localSettingNeverScanned => 'Nunca';

  @override
  String get localSettingScanInProgress => 'Busca em andamento…';

  @override
  String get localSettingScanNowSubtitle =>
      'Inicie uma busca completa na biblioteca.';

  @override
  String get localSettingNoFolders =>
      'Nenhuma pasta adicionada. Adicione uma para buscar músicas.';

  @override
  String get localSettingAddFolder => 'Adicionar pasta';

  @override
  String get playerSettingTitle => 'Configurações de reprodução';

  @override
  String get playerSettingStreamingHeader => 'Áudio online';

  @override
  String get playerSettingStreamQuality => 'Qualidade do áudio online';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Taxa de bits do áudio para reprodução online.';

  @override
  String get playerSettingQualityLow => 'Baixa';

  @override
  String get playerSettingQualityMedium => 'Média';

  @override
  String get playerSettingQualityHigh => 'Alta';

  @override
  String get playerSettingPlaybackHeader => 'Reprodução';

  @override
  String get playerSettingAutoPlay => 'Reprodução automática';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Adicione músicas semelhantes quando a fila terminar.';

  @override
  String get playerSettingAutoFallback => 'Usar fonte alternativa';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Se um plugin estiver ausente ou não fornecer áudio, tente um resolvedor compatível apenas para reproduzir.';

  @override
  String get playerSettingCrossfade => 'Transição entre faixas';

  @override
  String get playerSettingCrossfadeOff => 'Desativada';

  @override
  String get playerSettingCrossfadeInstant => 'As faixas mudam sem transição';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Transição de $seconds s entre faixas';
  }

  @override
  String get playerSettingEqualizer => 'Equalizador';

  @override
  String get playerSettingEqualizerActive => 'Ativo';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Ativo — $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Equalizador paramétrico de 10 bandas via FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Plugins padrão';

  @override
  String get pluginDefaultsDiscoverHeader => 'Fonte de Descobrir';

  @override
  String get pluginDefaultsNoResolver =>
      'Nenhum resolvedor de conteúdo ativo. Ative um plugin para escolher a fonte de Descobrir.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Use o primeiro resolvedor de conteúdo disponível.';

  @override
  String get pluginDefaultsPriorityHeader => 'Prioridade dos resolvedores';

  @override
  String get pluginDefaultsNoPriority =>
      'Nenhum resolvedor de conteúdo ativo. A ordem de prioridade aparecerá aqui quando houver plugins ativos.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Arraste para reordenar. Os resolvedores com maior prioridade são usados primeiro para encontrar versões reproduzíveis das faixas das paradas ou importadas.';

  @override
  String get pluginDefaultsLyricsHeader => 'Prioridade das letras';

  @override
  String get pluginDefaultsLyricsNone => 'Nenhum provedor de letras ativo.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Arraste para reordenar os provedores de letras. O primeiro da lista é consultado primeiro.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Sugestões de busca';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'Nenhum provedor de sugestões ativo.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Nenhum';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Use apenas o histórico de busca.';

  @override
  String get storageSettingTitle => 'Armazenamento';

  @override
  String get storageClearHistoryEvery => 'Limpar histórico a cada';

  @override
  String get storageClearHistorySubtitle =>
      'Limpe o histórico de reprodução após o período escolhido.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Backup salvo em $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Não foi possível compartilhar o backup: $error';
  }

  @override
  String get storageRestoreBackup => 'Restaurar backup';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restaure suas configurações e seus dados de um arquivo de backup.';

  @override
  String get storageAutoBackup => 'Backup automático';

  @override
  String get storageAutoLyrics => 'Salvar letras automaticamente';

  @override
  String get storageAutoLyricsSubtitle =>
      'Salve as letras automaticamente durante a reprodução.';

  @override
  String get storageResetApp => 'Redefinir Bloomee';

  @override
  String get storageResetConfirmTitle => 'Confirmar redefinição';

  @override
  String get storageResetButton => 'Redefinir';

  @override
  String get storageRestoreOptionsTitle => 'Opções de restauração';

  @override
  String get storageRestoreContinue => 'Continuar';

  @override
  String get storageRestoreConfirmTitle => 'Confirmar restauração';

  @override
  String get storageRestoreYes => 'Sim, restaurar';

  @override
  String get storageRestoring =>
      'Restaurando os dados selecionados…\nAguarde até a conclusão.';

  @override
  String get storageRestoreFailedTitle => 'Falha na restauração';

  @override
  String get updateSettingTitle => 'Atualizações';

  @override
  String get updateCheckForUpdates => 'Verificar atualizações';

  @override
  String get updateCheckSubtitle =>
      'Verifique se há uma nova versão do Bloomee.';

  @override
  String get updateAutoNotify => 'Notificar atualizações';

  @override
  String get updateAutoNotifySubtitle =>
      'Receba avisos sobre novas atualizações ao iniciar o aplicativo.';

  @override
  String get updateCheckTitle => 'Verificar atualizações';

  @override
  String get updateUpToDate => 'O Bloomee está atualizado';

  @override
  String get updateViewPreRelease =>
      'Ver versão de pré-lançamento mais recente';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versão atual: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable =>
      'Uma nova versão do Bloomee está disponível';

  @override
  String updateVersion(String ver, String build) {
    return 'Versão: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Baixar agora';

  @override
  String get updateChecking => 'Verificando atualizações…';

  @override
  String get timerTitle => 'Temporizador de sono';

  @override
  String get timerInterludeMessage => 'A reprodução será interrompida em:';

  @override
  String get timerHours => 'Horas';

  @override
  String get timerMinutes => 'Minutos';

  @override
  String get timerSeconds => 'Segundos';

  @override
  String get timerStop => 'Parar temporizador';

  @override
  String get timerFinishedMessage =>
      'O temporizador de sono interrompeu a reprodução.';

  @override
  String get timerGotIt => 'Entendi';

  @override
  String get timerSetTimeError => 'Defina uma duração';

  @override
  String get timerStart => 'Iniciar temporizador';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsEmpty => 'Nenhuma notificação ainda';

  @override
  String get recentsTitle => 'Histórico';

  @override
  String playlistByCreator(String creator) {
    return 'por $creator';
  }

  @override
  String get playlistYou => 'Você';

  @override
  String get pluginManagerTitle => 'Plugins';

  @override
  String get pluginManagerEmpty =>
      'Nenhum plugin instalado.\nToque em + para adicionar um arquivo .bex.';

  @override
  String get pluginManagerFilterAll => 'Todos';

  @override
  String get pluginManagerFilterContent => 'Resolvedores de conteúdo';

  @override
  String get pluginManagerFilterCharts => 'Provedores de paradas';

  @override
  String get pluginManagerFilterLyrics => 'Provedores de letras';

  @override
  String get pluginManagerFilterSuggestions => 'Provedores de sugestões';

  @override
  String get pluginManagerFilterImporters => 'Importadores de conteúdo';

  @override
  String get pluginManagerTooltipRefresh => 'Atualizar';

  @override
  String get pluginManagerTooltipInstall => 'Instalar plugin';

  @override
  String get pluginManagerNoMatch => 'Nenhum plugin corresponde a este filtro';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Não foi possível selecionar o arquivo: $error';
  }

  @override
  String get pluginManagerInstalling => 'Instalando plugin…';

  @override
  String get pluginManagerTypeContentResolver => 'Resolvedor de conteúdo';

  @override
  String get pluginManagerTypeChartProvider => 'Provedor de paradas';

  @override
  String get pluginManagerTypeLyricsProvider => 'Provedor de letras';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Sugestões de busca';

  @override
  String get pluginManagerTypeContentImporter => 'Importador de conteúdo';

  @override
  String get pluginManagerDeleteTitle => 'Excluir plugin?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Excluir “$name”? Os arquivos do plugin serão removidos permanentemente.';
  }

  @override
  String get pluginManagerDeleteAction => 'Excluir';

  @override
  String get pluginManagerCancel => 'Cancelar';

  @override
  String get pluginManagerEnablePlugin => 'Ativar plugin';

  @override
  String get pluginManagerUnloadPlugin => 'Desativar plugin';

  @override
  String get pluginManagerDeleting => 'Excluindo…';

  @override
  String get pluginManagerApiKeysTitle => 'Chaves de API';

  @override
  String get pluginManagerApiKeysSaved => 'Chaves de API salvas';

  @override
  String get pluginManagerSave => 'Salvar';

  @override
  String get pluginManagerDetailVersion => 'Versão';

  @override
  String get pluginManagerDetailType => 'Tipo';

  @override
  String get pluginManagerDetailPublisher => 'Publicador';

  @override
  String get pluginManagerDetailLastUpdated => 'Última atualização';

  @override
  String get pluginManagerDetailCreated => 'Criação';

  @override
  String get pluginManagerDetailHomepage => 'Site';

  @override
  String get pluginManagerDeleteStorageTitle => 'Excluir dados do plugin?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Remover também as chaves de API e as configurações salvas de “$name”?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Manter dados';

  @override
  String get pluginManagerDeleteStorageRemove => 'Excluir dados';

  @override
  String get segmentsSheetTitle => 'Trechos';

  @override
  String get segmentsSheetEmpty => 'Nenhum trecho disponível';

  @override
  String get segmentsSheetUntitled => 'Trecho sem título';

  @override
  String get smartReplaceTitle => 'Substituir por uma faixa equivalente';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Escolha uma versão reproduzível de “$title” para atualizar as referências nas playlists salvas.';
  }

  @override
  String get smartReplaceClose => 'Fechar';

  @override
  String get smartReplaceNoMatch => 'Nenhuma substituição encontrada';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Os plugins resolvedores ativos não encontraram uma correspondência adequada.';

  @override
  String get smartReplaceBestMatch => 'Melhor correspondência';

  @override
  String get smartReplaceSearchFailed => 'Falha na busca';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Não foi possível substituir a faixa: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Faixa substituída$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' e fila atualizada';

  @override
  String get playerUnknownQueue => 'Desconhecido';

  @override
  String playerLiked(String title) {
    return '$title adicionada aos favoritos';
  }

  @override
  String playerUnliked(String title) {
    return '$title removida dos favoritos';
  }

  @override
  String get offlineNoDownloads => 'Nenhum download';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Buscar nas suas músicas…';

  @override
  String get offlineRefreshTooltip => 'Atualizar downloads';

  @override
  String get offlineCloseSearch => 'Fechar busca';

  @override
  String get offlineSearchTooltip => 'Buscar';

  @override
  String get offlineOpenFailed =>
      'Não foi possível abrir esta faixa offline. Tente atualizar os downloads.';

  @override
  String get offlinePlayFailed =>
      'Não foi possível reproduzir esta música offline. Tente novamente.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas',
      one: '$count faixa',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Não foi possível carregar o álbum';

  @override
  String get aboutCraftingSubtitle => 'Desenvolvido para a música.';

  @override
  String get aboutFollowGitHub => 'Seguir no GitHub';

  @override
  String get aboutSendInquiry => 'Enviar contato comercial';

  @override
  String get aboutCreativeHighlights => 'Atualizações e projetos';

  @override
  String get aboutTipQuote =>
      'Gostou do Bloomee? Você pode apoiar o desenvolvimento.';

  @override
  String get aboutTipButton => 'Apoiar o projeto';

  @override
  String get aboutTipDesc => 'Sua contribuição ajuda a melhorar o Bloomee.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Detalhes da música';

  @override
  String get songInfoSectionTechnical => 'Informações técnicas';

  @override
  String get songInfoSectionActions => 'Ações';

  @override
  String get songInfoLabelTitle => 'Título';

  @override
  String get songInfoLabelArtist => 'Artista';

  @override
  String get songInfoLabelAlbum => 'Álbum';

  @override
  String get songInfoLabelDuration => 'Duração';

  @override
  String get songInfoLabelSource => 'Fonte';

  @override
  String get songInfoLabelMediaId => 'ID da mídia';

  @override
  String get songInfoLabelPluginId => 'ID do plugin';

  @override
  String get songInfoCopyId => 'Copiar ID';

  @override
  String get songInfoCopyLink => 'Copiar link';

  @override
  String get songInfoOpenBrowser => 'Abrir no navegador';

  @override
  String get songInfoIdCopied => 'ID da mídia copiado';

  @override
  String get songInfoLinkCopied => 'Link copiado';

  @override
  String get songInfoNoLink => 'Nenhum link disponível';

  @override
  String get songInfoOpenFailed => 'Não foi possível abrir o link';

  @override
  String get songInfoUpdateMetadata => 'Atualizar metadados';

  @override
  String get songInfoMetadataUpdated => 'Metadados atualizados';

  @override
  String get songInfoMetadataUpdateFailed =>
      'Não foi possível atualizar os metadados';

  @override
  String get songInfoMetadataUnavailable =>
      'A atualização de metadados não está disponível para esta fonte';

  @override
  String get songInfoSearchTitle => 'Buscar esta música no Bloomee';

  @override
  String get songInfoSearchArtist => 'Buscar este artista no Bloomee';

  @override
  String get songInfoSearchAlbum => 'Buscar este álbum no Bloomee';

  @override
  String get eqTitle => 'Equalizador';

  @override
  String get chartNoItems => 'Esta parada está vazia';

  @override
  String get chartLoadFailed => 'Não foi possível carregar a parada';

  @override
  String get chartPlay => 'Reproduzir';

  @override
  String get chartResolving => 'Buscando correspondência';

  @override
  String get chartReady => 'Pronto';

  @override
  String get chartAddToPlaylist => 'Adicionar à playlist';

  @override
  String get chartNoResolver =>
      'Nenhum resolvedor de conteúdo ativo. Instale um plugin para reproduzir.';

  @override
  String get chartResolveFailed =>
      'Não foi possível encontrar uma correspondência. Abrindo a busca…';

  @override
  String get chartNoResolverAdd => 'Nenhum resolvedor de conteúdo ativo.';

  @override
  String get chartNoMatch =>
      'Nenhuma correspondência encontrada. Tente buscar manualmente.';

  @override
  String get chartStatPeak => 'Melhor posição';

  @override
  String get chartStatWeeks => 'Semanas';

  @override
  String get chartStatChange => 'Variação';

  @override
  String menuSharePreparing(String title) {
    return 'Preparando $title para compartilhar.';
  }

  @override
  String get menuOpenLinkFailed => 'Não foi possível abrir o link';

  @override
  String get localMusicFolders => 'Pastas de músicas';

  @override
  String get localMusicRemoveFolder => 'Remover pasta';

  @override
  String get localMusicCloseSearch => 'Fechar busca';

  @override
  String get localMusicOpenSearch => 'Buscar';

  @override
  String get localMusicNoMusicFound =>
      'Nenhuma música encontrada no dispositivo';

  @override
  String get localMusicNoSearchResults => 'Nenhuma faixa corresponde à busca.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas',
      one: '$count faixa',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Importar músicas';

  @override
  String get importNoPluginsLoaded =>
      'Nenhum plugin importador de conteúdo ativo.\nInstale um para importar playlists de outros serviços.';

  @override
  String get importBloomeeFiles => 'Importar arquivos do Bloomee';

  @override
  String get importM3UFiles => 'Importar playlist M3U';

  @override
  String get importM3UNameDialogTitle => 'Nome da playlist';

  @override
  String get importM3UNameHint => 'Digite um nome para esta playlist';

  @override
  String get importM3UNoTracks =>
      'Nenhuma faixa válida encontrada no arquivo M3U.';

  @override
  String get importNoteTitle => 'Observação';

  @override
  String get importNoteMessage =>
      'Só é possível importar arquivos criados pelo Bloomee.\nArquivos de outras fontes não funcionarão. Continuar mesmo assim?';

  @override
  String get importTitle => 'Importar';

  @override
  String get importCheckingUrl => 'Verificando link…';

  @override
  String get importFetchingTracks => 'Buscando faixas…';

  @override
  String get importSavingToLibrary => 'Salvando na biblioteca…';

  @override
  String get importPasteUrlHint =>
      'Cole o link de uma playlist ou de um álbum para importar';

  @override
  String get importAction => 'Importar';

  @override
  String importTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas',
      one: '$count faixa',
    );
    return '$_temp0';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Buscando correspondências: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Salvar faixas ($count)';
  }

  @override
  String importTracksSaved(int count) {
    return 'Faixas salvas: $count';
  }

  @override
  String get importDone => 'Concluído';

  @override
  String get importMore => 'Importar mais';

  @override
  String get importUnknownError => 'Erro desconhecido';

  @override
  String get importTryAgain => 'Tentar novamente';

  @override
  String get importSkipTrack => 'Pular esta faixa';

  @override
  String get importMatchOptions => 'Opções de correspondência';

  @override
  String get importSkipped => 'Ignorada';

  @override
  String get importReorderTip =>
      'Pressione uma playlist por alguns instantes para reordenar';

  @override
  String get importErrorCannotHandleUrl =>
      'Este plugin não é compatível com o link informado.';

  @override
  String get importErrorUnexpectedResponse => 'Resposta inesperada do plugin.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Não foi possível verificar o link: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Não foi possível obter os dados da coleção: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Não foi possível obter as faixas: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Não foi possível salvar a playlist: $error';
  }

  @override
  String get playlistPinToTop => 'Fixar no topo';

  @override
  String get playlistUnpin => 'Desafixar';

  @override
  String get snackbarInvalidFileFormat => 'Formato de arquivo inválido';

  @override
  String get snackbarProcessingFile => 'Processando arquivo…';

  @override
  String get pluginManagerTabInstalled => 'Instalados';

  @override
  String get pluginManagerTabStore => 'Loja de plugins';

  @override
  String get pluginManagerSelectPackage => 'Selecionar pacote de plugin (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'O plugin usa uma versão antiga do manifesto. Alguns recursos podem não funcionar. Considere atualizá-lo.';

  @override
  String get pluginManagerStatusActive => 'Ativo';

  @override
  String get pluginManagerStatusInactive => 'Inativo';

  @override
  String get pluginRepositoryAddTitle => 'Adicionar repositório';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Insira o link de um arquivo JSON de repositório de plugins válido.';

  @override
  String get pluginRepositoryAddAction => 'Adicionar repositório';

  @override
  String get pluginRepositoryTitle => 'Repositórios de plugins';

  @override
  String get pluginRepositorySubtitle =>
      'Adicione uma fonte JSON para explorar plugins disponíveis online.';

  @override
  String get pluginRepositoryEmpty => 'Nenhum repositório adicionado.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Atualização desconhecida';

  @override
  String get pluginRepositoryNoDescription => 'Nenhuma descrição disponível.';

  @override
  String get pluginRepositoryUrlCopied => 'Link do repositório copiado';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugins',
      one: '$count plugin',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Atualizado em $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plugins disponíveis',
      one: '$count plugin disponível',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Manifesto desatualizado. Alguns recursos podem não funcionar.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Publicador desconhecido';

  @override
  String get pluginRepositoryActionRetry => 'Tentar novamente';

  @override
  String get pluginRepositoryActionOutdated => 'Desatualizado';

  @override
  String get pluginRepositoryActionInstalled => 'Instalado';

  @override
  String get pluginRepositoryActionInstall => 'Instalar';

  @override
  String get pluginRepositoryActionUnavailable => 'Indisponível';

  @override
  String get pluginRepositoryInstallFailed => 'Falha na instalação.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Não foi possível baixar $name.';
  }

  @override
  String get pluginRepositoryErrorLoad =>
      'Não foi possível carregar os repositórios.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'Link ou arquivo de repositório inválido.';

  @override
  String get pluginRepositoryErrorRemove =>
      'Não foi possível remover o repositório.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faixa substituída em $count playlists$queue.',
      one: 'Faixa substituída em $count playlist$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Buscar letras…';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Digite o nome de uma música ou de um artista para encontrar letras.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Nenhuma letra encontrada para “$query”';
  }

  @override
  String get lyricsSearchApplied => 'Letra aplicada';

  @override
  String get lyricsSearchFetchFailed => 'Não foi possível obter a letra';

  @override
  String get lyricsSearchPreview => 'Prévia';

  @override
  String get lyricsSearchPreviewTooltip => 'Ver prévia da letra';

  @override
  String get lyricsSearchSynced => 'Sincronizada';

  @override
  String get lyricsSearchPreviewLoadFailed =>
      'Não foi possível carregar a letra.';

  @override
  String get lyricsSearchApplyAction => 'Aplicar letra';

  @override
  String get lyricsSettingsSearchTitle => 'Buscar outra letra';

  @override
  String get lyricsSettingsSearchSubtitle => 'Encontre outras versões online';

  @override
  String get lyricsSettingsSyncTitle => 'Ajustar sincronização';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Ajuste letras que aparecem antes ou depois do áudio';

  @override
  String get lyricsSettingsSaveTitle => 'Salvar offline';

  @override
  String get lyricsSettingsSaveSubtitle => 'Armazene esta letra no dispositivo';

  @override
  String get lyricsSettingsDeleteTitle => 'Excluir letra salva';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Remova a letra armazenada offline';

  @override
  String get lyricsSyncTapToReset => 'Toque para redefinir';

  @override
  String get upNextTitle => 'A seguir';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens na fila',
      one: '$count item na fila',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Copiar';

  @override
  String get snackbarCopiedToClipboard => 'Copiado';

  @override
  String get tooltipSongInfo => 'Informações da música';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'Não é possível excluir a música em reprodução';

  @override
  String get playerLoopOff => 'Desativado';

  @override
  String get playerLoopOne => 'Repetir uma';

  @override
  String get playerLoopAll => 'Repetir tudo';

  @override
  String get snackbarOpeningAlbumPage => 'Abrindo a página original do álbum.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Uma nova versão do Bloomee está disponível.\n\nVersão: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Plugin “$id” instalado';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Plugin “$id” excluído';
  }

  @override
  String get pluginBootstrapTitle => 'Configurando o Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Configurando o novo mecanismo de plugins… $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Isso só precisa ser feito uma vez.';

  @override
  String get backupSave => 'Salvar backup em JSON';

  @override
  String get backupShare => 'Compartilhar backup JSON';

  @override
  String get backupPortableDetails =>
      'Inclui playlists, favoritos, coleções salvas, históricos e preferências transferíveis. Não inclui arquivos de áudio, contas nem pastas do dispositivo.';

  @override
  String get backupHistories => 'Históricos de reprodução e busca';

  @override
  String get backupPreferences => 'Preferências transferíveis';

  @override
  String get backupNewCopy => 'Importar como novas playlists';

  @override
  String get backupMerge => 'Mesclar com os dados existentes';

  @override
  String get backupReplace => 'Substituir seções selecionadas';

  @override
  String get backupMergeDetails =>
      'As faixas, os metadados e as preferências existentes são preservados. As faixas ausentes são adicionadas ao final, na ordem do arquivo. Os favoritos são mesclados.';

  @override
  String get backupReplaceWarning =>
      'As seções selecionadas serão substituídas. Se a biblioteca estiver selecionada, as playlists e os favoritos existentes também serão substituídos. As seções não selecionadas e os arquivos do dispositivo serão preservados. Uma cópia de recuperação privada será criada antes da operação.';

  @override
  String get backupAutoDetails =>
      'Mantém sete cópias de recuperação privadas. A verificação ocorre ao abrir o aplicativo, com no máximo uma cópia a cada 24 horas. Essas cópias são removidas ao desinstalar o aplicativo.';

  @override
  String get backupLocationDetails =>
      'Escolha um destino ao salvar o backup. As cópias de recuperação privadas ficam dentro do aplicativo.';

  @override
  String get backupResetDetails =>
      'Redefine todos os dados do banco de dados na próxima inicialização. Os arquivos de áudio baixados e os arquivos de plugins instalados permanecem no dispositivo. Uma cópia de recuperação privada é criada antes da operação.';

  @override
  String get backupResetPending =>
      'Redefinição agendada. Feche e abra o Bloomee novamente para concluir.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return 'Playlists: $playlists · Faixas: $tracks';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'Importação concluída. Playlists criadas: $playlists; entradas de faixas adicionadas: $tracks; registros de histórico adicionados: $history; preferências aplicadas: $settings.';
  }

  @override
  String get backupRefreshFailed =>
      'Os dados foram importados. Feche e abra o Bloomee novamente para atualizar todas as preferências.';

  @override
  String get backupRecoveryCopies => 'Cópias de recuperação';

  @override
  String get backupNoRecoveryCopies => 'Nenhuma cópia de recuperação ainda.';

  @override
  String get backupRecoveryAutomatic => 'Backup automático';

  @override
  String get backupRecoveryBeforeImport => 'Antes de uma importação';

  @override
  String get backupRecoveryBeforeReset => 'Antes de uma redefinição';

  @override
  String get backupCancelReset => 'Cancelar redefinição';

  @override
  String get libraryRecoveryTitle => 'Recuperar biblioteca ausente';

  @override
  String get libraryRecoverySubtitle =>
      'Busque playlists e registros de downloads preservados de versões anteriores.';

  @override
  String get libraryRecoveryChooseSource =>
      'Escolha um banco de dados preservado para analisar. Sua biblioteca atual e os arquivos originais serão mantidos.';

  @override
  String get libraryRecoveryNoSources =>
      'Nenhum banco de dados preservado foi encontrado. Os arquivos de áudio, por si só, não permitem recuperar as playlists às quais pertenciam.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return 'Foram encontradas $tracks faixas, $playlists playlists e $downloads registros de downloads. Arquivos indisponíveis no momento: $unavailable; seus registros serão preservados.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return 'Referências de playlists danificadas que não puderam ser reconstruídas desta cópia: $broken.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'A recuperação adiciona faixas, entradas de playlists e registros de downloads ausentes. As playlists, as associações de arquivos e as configurações existentes são preservadas. Uma cópia de recuperação é criada primeiro. Repita com outra cópia preservada se ela contiver mais dados da sua biblioteca.';

  @override
  String get libraryRecoveryMerge => 'Mesclar biblioteca recuperada';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Recuperação concluída. Entradas de playlists adicionadas: $entries; registros de downloads adicionados: $downloads.';
  }

  @override
  String get backupStartupFailed => 'Não foi possível iniciar o Bloomee';

  @override
  String get backupStartupFailedDetails =>
      'A inicialização foi interrompida sem reparar ou substituir seu banco de dados automaticamente. Feche o aplicativo e tente novamente. Preserve os dados do aplicativo ao relatar este erro.';

  @override
  String get lyricsTitle => 'Letra';

  @override
  String get lyricsEnterFullscreen => 'Letra em tela cheia';

  @override
  String get lyricsExitFullscreen => 'Sair da tela cheia';

  @override
  String get lyricsFollowPlayback => 'Acompanhar reprodução';

  @override
  String get lyricsTimingEarlier => 'Mostrar antes';

  @override
  String get lyricsTimingLater => 'Mostrar depois';

  @override
  String get lyricsTimingSave => 'Salvar sincronização';

  @override
  String get lyricsSaved => 'Letra salva.';

  @override
  String get lyricsSaveFailed =>
      'Não foi possível salvar a letra. Tente novamente.';

  @override
  String get lyricsDeleteFailed =>
      'Não foi possível excluir a letra salva. Tente novamente.';

  @override
  String get artistTopSongs => 'Músicas populares';

  @override
  String get artistLoadFailed => 'Não foi possível carregar o artista';

  @override
  String get artistNoTopSongs => 'Nenhuma música popular disponível';

  @override
  String get artistNoAlbums => 'Nenhum álbum disponível';

  @override
  String get snackbarOpeningArtistPage =>
      'Abrindo a página original do artista.';

  @override
  String get snackbarOpeningPlaylistPage =>
      'Abrindo a página original da playlist.';

  @override
  String get playlistSaveOrderFailed =>
      'Não foi possível salvar a ordem da playlist. Tente novamente.';

  @override
  String get playlistReorderTracksHint =>
      'Segure e arraste a alça para reordenar as faixas';

  @override
  String get playlistTrackCountLabel => 'Número de faixas';

  @override
  String get playlistDescription => 'Descrição';

  @override
  String get playlistOriginalUrl => 'Link original';

  @override
  String get searchSearching => 'Buscando…';

  @override
  String get searchSuggestions => 'Sugestões';

  @override
  String get searchTopResults => 'Principais resultados';

  @override
  String get changelogEmpty => 'Nenhuma informação de alterações disponível.';

  @override
  String get changelogTitle => 'Novidades';

  @override
  String get changelogLatest => 'Mais recente';

  @override
  String get changelogNext => 'Próxima versão';

  @override
  String changelogVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Configuração incompleta';

  @override
  String get pluginBootstrapRetryBody =>
      'Não foi possível instalar alguns plugins agora. Tente novamente para concluir a configuração.';

  @override
  String get pluginBootstrapInternetTitle =>
      'Conexão com a internet necessária';

  @override
  String get pluginBootstrapInternetBody =>
      'O Bloomee precisa de uma conexão com a internet uma vez para detectar seu país e configurar o mecanismo de plugins.';

  @override
  String get buttonExit => 'Sair';

  @override
  String get eqSource => 'Fonte do equalizador';

  @override
  String get eqBuiltin => 'Equalizador do aplicativo';

  @override
  String get eqBuiltinSubtitle => 'Equalizador de 10 bandas';

  @override
  String get eqDevice => 'Equalizador do dispositivo';

  @override
  String get eqDeviceSubtitle => 'Sistema / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'O equalizador do aplicativo está desativado. Configure o equalizador do dispositivo nas configurações de som do aparelho.';

  @override
  String get eqPresets => 'Predefinições';

  @override
  String get eqCustomCurve => 'Curva personalizada';

  @override
  String get shortcutMuted => 'Sem som';

  @override
  String get shortcutUnmuted => 'Som ativado';

  @override
  String get shortcutShuffleOn => 'Aleatório ativado';

  @override
  String get shortcutShuffleOff => 'Aleatório desativado';

  @override
  String get shortcutRepeatOff => 'Repetição desativada';

  @override
  String get shortcutLiked => 'Adicionada aos favoritos';

  @override
  String get shortcutUnliked => 'Removida dos favoritos';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'Não foi possível selecionar a pasta de downloads: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Versão indisponível';

  @override
  String get backupNewCopyDetails =>
      'Cria playlists separadas e mescla os favoritos. As playlists existentes são preservadas. Os históricos e as preferências selecionados também são importados.';

  @override
  String get changelogCurrent => 'Atual';

  @override
  String get backupLibrary =>
      'Biblioteca (playlists, favoritos e coleções salvas)';

  @override
  String get eqPresetFlat => 'Neutro';

  @override
  String get eqPresetAcoustic => 'Acústico';

  @override
  String get eqPresetBassBoost => 'Reforço de graves';

  @override
  String get eqPresetBassReducer => 'Redução de graves';

  @override
  String get eqPresetClassical => 'Clássica';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetDeep => 'Profundo';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Eletrônica';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latina';

  @override
  String get eqPresetLive => 'Ao vivo';

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
  String get eqPresetSmallSpeakers => 'Caixas de som pequenas';

  @override
  String get eqPresetSpokenWord => 'Voz falada';

  @override
  String get eqPresetTrebleBoost => 'Reforço de agudos';

  @override
  String get eqPresetTrebleReducer => 'Redução de agudos';

  @override
  String get eqPresetVocalBooster => 'Reforço de voz';

  @override
  String get eqPresetCustom => 'Personalizado';
}
