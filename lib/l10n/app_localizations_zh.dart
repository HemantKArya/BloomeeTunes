// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get onboardingTitle => '欢迎使用 Bloomee';

  @override
  String get onboardingSubtitle => '让我们开始设置您的语言和地区。';

  @override
  String get continueButton => '继续';

  @override
  String get navHome => '首页';

  @override
  String get navLibrary => '音乐库';

  @override
  String get navSearch => '搜索';

  @override
  String get navLocal => '本地';

  @override
  String get navOffline => '离线';

  @override
  String get playerEnjoyingFrom => '播放自';

  @override
  String get playerQueue => '播放队列';

  @override
  String get playerPlayWithMix => '智能混音播放';

  @override
  String get playerPlayNext => '下一首播放';

  @override
  String get playerAddToQueue => '添加到队列';

  @override
  String get playerAddToFavorites => '添加到我喜欢的音乐';

  @override
  String get playerNoLyricsFound => '未找到歌词';

  @override
  String get playerLyricsNoPlugin => '未配置歌词来源。请前往 设置 → 插件 安装一个。';

  @override
  String get playerFullscreenLyrics => '全屏歌词';

  @override
  String get localMusicTitle => '本地音乐';

  @override
  String get localMusicGrantPermission => '授予权限';

  @override
  String get localMusicStorageAccessRequired => '需要存储访问权限';

  @override
  String get localMusicStorageAccessDesc => '请授予权限以扫描并播放您设备上存储的音频文件。';

  @override
  String get localMusicAddFolder => '添加音乐文件夹';

  @override
  String get localMusicScanNow => '立即扫描';

  @override
  String localMusicScanFailed(String message) {
    return '扫描失败: $message';
  }

  @override
  String get localMusicScanning => '正在扫描设备中的音频文件...';

  @override
  String get localMusicEmpty => '未发现本地音乐';

  @override
  String get localMusicSearchEmpty => '未找到匹配的音轨。';

  @override
  String get localMusicShuffle => '随机播放';

  @override
  String get localMusicPlayAll => '播放全部';

  @override
  String get localMusicSearchHint => '搜索本地音乐...';

  @override
  String get localMusicRescanDevice => '重新扫描设备';

  @override
  String get localMusicRemoveFolder => '移除文件夹';

  @override
  String get localMusicMusicFolders => '音乐文件夹';

  @override
  String localMusicTrackCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonDelete => '删除';

  @override
  String get buttonOk => '确定';

  @override
  String get buttonUpdate => '更新';

  @override
  String get buttonDownload => '下载';

  @override
  String get buttonShare => '分享';

  @override
  String get buttonLater => '稍后';

  @override
  String get buttonInfo => '详情';

  @override
  String get buttonMore => '更多';

  @override
  String get dialogDeleteTrack => '删除音轨';

  @override
  String dialogDeleteTrackMessage(String title) {
    return '确定要从设备中删除 \"$title\" 吗？此操作不可撤销。';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists => '该音轨也将从以下位置移除：';

  @override
  String get dialogDontAskAgain => '不再询问';

  @override
  String get dialogDeletePlugin => '删除插件？';

  @override
  String dialogDeletePluginMessage(String name) {
    return '确定要删除 \"$name\" 吗？这将永久移除其相关文件。';
  }

  @override
  String get dialogUpdateAvailable => '发现新版本';

  @override
  String get dialogUpdateNow => '立即更新';

  @override
  String get dialogDownloadPlaylist => '下载歌单';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '要下载 \"$title\" 中的 $count 首歌曲吗？它们将被添加到下载队列。';
  }

  @override
  String get dialogDownloadAll => '全部下载';

  @override
  String get playlistEdit => '编辑歌单';

  @override
  String get playlistShareFile => '分享文件';

  @override
  String get playlistExportFile => '导出文件';

  @override
  String get playlistPlay => '播放';

  @override
  String get playlistAddToQueue => '将歌单添加到队列';

  @override
  String get playlistShare => '分享歌单';

  @override
  String get playlistDelete => '删除歌单';

  @override
  String get playlistEmptyState => '暂无歌曲';

  @override
  String get playlistAvailableOffline => '离线可用';

  @override
  String get playlistShuffle => '随机播放';

  @override
  String get playlistMoreOptions => '更多选项';

  @override
  String get playlistNoMatchSearch => '没有匹配搜索的歌单';

  @override
  String get playlistCreateNew => '创建新歌单';

  @override
  String get playlistCreateFirstOne => '暂无歌单。创建一个来开始吧！';

  @override
  String playlistSongCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '已从 $playlist 中移除 $title';
  }

  @override
  String get playlistFailedToLoad => '加载歌单失败';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsPlugins => '插件管理';

  @override
  String get settingsPluginsSubtitle => '安装、加载和管理插件。';

  @override
  String get settingsUpdates => '软件更新';

  @override
  String get settingsUpdatesSubtitle => '检查新版本';

  @override
  String get settingsDownloads => '下载设置';

  @override
  String get settingsDownloadsSubtitle => '下载路径、音质等...';

  @override
  String get settingsLocalTracks => '本地音轨';

  @override
  String get settingsLocalTracksSubtitle => '扫描、管理文件夹和自动扫描设置。';

  @override
  String get settingsPlayer => '播放器设置';

  @override
  String get settingsPlayerSubtitle => '串流音质、自动播放等。';

  @override
  String get settingsPluginDefaults => '插件默认项';

  @override
  String get settingsPluginDefaultsSubtitle => '发现源、解析器优先级。';

  @override
  String get settingsUIElements => '界面与服务';

  @override
  String get settingsUIElementsSubtitle => '自动轮播、界面微调等。';

  @override
  String get settingsLastFM => 'Last.FM 设置';

  @override
  String get settingsLastFMSubtitle => 'API 密钥、Secret 和播放记录(Scrobble)设置。';

  @override
  String get settingsStorage => '存储与备份';

  @override
  String get settingsStorageSubtitle => '备份、缓存、历史记录、恢复等...';

  @override
  String get settingsLanguageCountry => '语言与地区';

  @override
  String get settingsLanguageCountrySubtitle => '选择您的语言和国家。';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutSubtitle => '关于应用、版本、开发者等。';

  @override
  String get settingsScanning => '正在扫描';

  @override
  String get settingsMusicFolders => '音乐文件夹';

  @override
  String get settingsQuality => '音质';

  @override
  String get settingsHistory => '历史记录';

  @override
  String get settingsBackupRestore => '备份与恢复';

  @override
  String get settingsAutomatic => '自动';

  @override
  String get settingsDangerZone => '危险区域';

  @override
  String get settingsScrobbling => '播放记录';

  @override
  String get settingsAuthentication => '认证';

  @override
  String get settingsHomeScreen => '主页设置';

  @override
  String get settingsChartVisibility => '排行榜可见性';

  @override
  String get settingsLocation => '位置';

  @override
  String get pluginRepositoryTitle => '插件仓库';

  @override
  String get pluginRepositorySubtitle => '添加 JSON 源以浏览远程插件。';

  @override
  String get pluginRepositoryAddAction => '添加仓库';

  @override
  String get pluginRepositoryAddTitle => '添加仓库';

  @override
  String get pluginRepositoryAddSubtitle => '输入有效的插件仓库 JSON 文件 URL。';

  @override
  String get pluginRepositoryEmpty => '尚未添加任何仓库。';

  @override
  String get pluginRepositoryUrlCopied => '仓库 URL 已复制到剪贴板';

  @override
  String get pluginRepositoryNoDescription => '未提供描述。';

  @override
  String get pluginRepositoryUnknownUpdate => '未知更新';

  @override
  String pluginRepositoryPluginsCount(int count) {
    return '$count 个插件';
  }

  @override
  String get pluginRepositoryErrorLoad => '加载仓库失败。';

  @override
  String get pluginRepositoryErrorInvalid => '无效的仓库 URL 或仓库文件。';

  @override
  String get pluginRepositoryErrorRemove => '移除仓库失败。';

  @override
  String pluginRepositoryError(String message) {
    return '错误: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => '正在添加到下载队列';

  @override
  String get emptyNoInternet => '无网络连接！';

  @override
  String get emptyNoContentPlugin => '未加载内容插件。请在插件管理器中加载一个内容解析器。';

  @override
  String get emptyRefreshingSource => '正在刷新发现源... 之前的来源已不可用。';

  @override
  String get emptyNoTracks => '暂无音轨';

  @override
  String get emptyNoResults => '未找到匹配项';

  @override
  String snackbarDeletedTrack(String title) {
    return '已删除 \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '删除 \"$title\" 失败';
  }

  @override
  String get snackbarAddedToNextQueue => '已添加到下一首播放';

  @override
  String get snackbarAddedToQueue => '已添加到队列';

  @override
  String snackbarAddedToLiked(String title) {
    return '已将 $title 添加到喜欢的音乐！';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '正在播放 $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '已将 $name 添加到队列';
  }

  @override
  String get snackbarPlaylistQueued => '歌单已添加到下载队列';

  @override
  String get snackbarPlaylistUpdated => '歌单已更新！';

  @override
  String get snackbarNoInternet => '无网络连接。';

  @override
  String get snackbarImportFailed => '导入失败！';

  @override
  String get snackbarImportCompleted => '导入完成';

  @override
  String get snackbarBackupFailed => '备份失败！';

  @override
  String snackbarExportedTo(String path) {
    return '已导出至: $path';
  }

  @override
  String get snackbarMediaIdCopied => '媒体 ID 已复制';

  @override
  String get snackbarLinkCopied => '链接已复制';

  @override
  String get snackbarNoLinkAvailable => '无可用链接';

  @override
  String get snackbarCouldNotOpenLink => '无法打开链接';

  @override
  String snackbarPreparingDownload(String title) {
    return '正在为 $title 准备下载...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title 已下载。';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title 已在队列中。';
  }

  @override
  String snackbarDownloaded(String title) {
    return '已下载 $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable => '错误：下载服务不可用。';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '已将 $count 首歌曲添加到下载队列';
  }

  @override
  String get snackbarDeleteTrackFailDevice => '无法从设备存储中删除音轨。';

  @override
  String get searchHintExplore => '想听点什么？';

  @override
  String get searchHintLibrary => '搜索库...';

  @override
  String get searchHintOfflineMusic => '搜索您的歌曲...';

  @override
  String get searchHintPlaylists => '搜索歌单...';

  @override
  String get searchStartTyping => '开始输入以搜索...';

  @override
  String get searchNoSuggestions => '未找到建议！';

  @override
  String get searchNoResults => '未找到结果！\n请尝试其他关键词或来源。';

  @override
  String get searchFailed => '搜索失败！';

  @override
  String get searchDiscover => '发现美妙音乐...';

  @override
  String get searchSources => '来源';

  @override
  String get searchNoPlugins => '未安装插件';

  @override
  String get searchTracks => '音轨';

  @override
  String get searchAlbums => '专辑';

  @override
  String get searchArtists => '艺人';

  @override
  String get searchPlaylists => '歌单';

  @override
  String get exploreDiscover => '发现';

  @override
  String get exploreRecently => '最近播放';

  @override
  String get exploreLastFmPicks => 'Last.Fm 精选';

  @override
  String get exploreFailedToLoad => '加载主页版块失败。';

  @override
  String get libraryTitle => '音乐库';

  @override
  String get libraryEmptyState => '您的音乐库有些冷清。添加一些音乐让它亮起来吧！';

  @override
  String libraryIn(String playlistName) {
    return '位于 $playlistName';
  }

  @override
  String get menuAddToPlaylist => '添加到歌单';

  @override
  String get menuSmartReplace => '智能替换';

  @override
  String get menuShare => '分享';

  @override
  String get menuAvailableOffline => '离线可用';

  @override
  String get menuDownload => '下载';

  @override
  String get menuOpenOriginalLink => '打开原始链接';

  @override
  String get menuDeleteTrack => '删除';

  @override
  String get songInfoTitle => '标题';

  @override
  String get songInfoArtist => '艺人';

  @override
  String get songInfoAlbum => '专辑';

  @override
  String get songInfoMediaId => '媒体 ID';

  @override
  String get songInfoCopyId => '复制 ID';

  @override
  String get songInfoCopyLink => '复制链接';

  @override
  String get songInfoOpenBrowser => '在浏览器中打开';

  @override
  String get tooltipRemoveFromLibrary => '从音乐库移除';

  @override
  String get tooltipSaveToLibrary => '保存到音乐库';

  @override
  String get tooltipOpenOriginalLink => '打开原始链接';

  @override
  String get tooltipShuffle => '随机播放';

  @override
  String get tooltipAvailableOffline => '离线可用';

  @override
  String get tooltipDownloadPlaylist => '下载歌单';

  @override
  String get tooltipMoreOptions => '更多选项';

  @override
  String get tooltipInfo => '详情';

  @override
  String get appuiTitle => '界面与服务';

  @override
  String get appuiAutoSlideCharts => '自动轮播榜单';

  @override
  String get appuiAutoSlideChartsSubtitle => '在首页自动滑动展示榜单。';

  @override
  String get appuiLastFmPicksSubtitle => '显示来自 Last.FM 的建议。需要登录并重启。';

  @override
  String get appuiNoChartsAvailable => '暂无可用榜单。请加载榜单提供程序插件。';

  @override
  String get appuiLoginToLastFm => '请先登录 Last.FM。';

  @override
  String get appuiShowInCarousel => '在主页轮播图中显示。';

  @override
  String get countrySettingTitle => '国家与语言';

  @override
  String get countrySettingAutoDetect => '自动检测国家';

  @override
  String get countrySettingAutoDetectSubtitle => '打开应用时自动检测您所在的国家。';

  @override
  String get countrySettingCountryLabel => '国家';

  @override
  String get countrySettingLanguageLabel => '语言';

  @override
  String get countrySettingSystemDefault => '系统默认';

  @override
  String get downloadSettingTitle => '下载';

  @override
  String get downloadSettingQuality => '下载音质';

  @override
  String get downloadSettingQualitySubtitle => '下载音轨时的通用音质偏好。';

  @override
  String get downloadSettingFolder => '下载文件夹';

  @override
  String get downloadSettingResetFolder => '重置下载文件夹';

  @override
  String get downloadSettingResetFolderSubtitle => '恢复默认下载路径。';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => '记录播放记录(Scrobble)';

  @override
  String get lastfmScrobbleTracksSubtitle => '将播放过的音轨发送到您的 Last.FM 档案。';

  @override
  String get lastfmAuthFirst => '请先认证 Last.FM API。';

  @override
  String get lastfmAuthenticatedAs => '已认证为';

  @override
  String get lastfmAuthFailed => '认证失败：';

  @override
  String get lastfmNotAuthenticated => '未认证';

  @override
  String get lastfmSteps =>
      '认证步骤：\n1. 在 last.fm 创建或登录账号\n2. 在 last.fm/api/account/create 生成 API 密钥\n3. 在下方输入您的 API Key 和 Secret\n4. 点击“开始认证”并在浏览器中批准\n5. 点击“获取并保存会话密钥”以完成';

  @override
  String get lastfmApiKey => 'API 密钥';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. 开始认证';

  @override
  String get lastfmGetSession => '2. 获取并保存会话密钥';

  @override
  String get lastfmRemoveKeys => '移除密钥';

  @override
  String get lastfmStartAuthFirst => '请先开始认证，然后在浏览器中批准。';

  @override
  String get localSettingTitle => '本地音轨';

  @override
  String get localSettingAutoScan => '启动时自动扫描';

  @override
  String get localSettingAutoScanSubtitle => '应用启动时自动扫描新的本地音轨。';

  @override
  String get localSettingLastScan => '上次扫描';

  @override
  String get localSettingNeverScanned => '从未扫描';

  @override
  String get localSettingScanInProgress => '扫描中...';

  @override
  String get localSettingScanNowSubtitle => '手动触发全量音乐库扫描。';

  @override
  String get localSettingNoFolders => '尚未添加文件夹。添加文件夹以开始扫描。';

  @override
  String get localSettingAddFolder => '添加文件夹';

  @override
  String get playerSettingTitle => '播放器设置';

  @override
  String get playerSettingStreamingHeader => '串流';

  @override
  String get playerSettingStreamQuality => '串流音质';

  @override
  String get playerSettingStreamQualitySubtitle => '在线播放时的全局音频比特率。';

  @override
  String get playerSettingQualityLow => '低';

  @override
  String get playerSettingQualityMedium => '中';

  @override
  String get playerSettingQualityHigh => '高';

  @override
  String get playerSettingPlaybackHeader => '播放';

  @override
  String get playerSettingAutoPlay => '自动播放';

  @override
  String get playerSettingAutoPlaySubtitle => '队列结束时自动添加相似歌曲。';

  @override
  String get playerSettingAutoFallback => '自动回退播放';

  @override
  String get playerSettingAutoFallbackSubtitle => '如果插件缺失或无法播放，尝试使用兼容的解析器。';

  @override
  String get playerSettingCrossfade => '淡入淡出';

  @override
  String get playerSettingCrossfadeOff => '关闭';

  @override
  String get playerSettingCrossfadeInstant => '歌曲即时切换';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '曲间 $seconds 秒混音';
  }

  @override
  String get playerSettingEqualizer => '均衡器';

  @override
  String get playerSettingEqualizerActive => '已开启';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return '已开启 — $preset 预设';
  }

  @override
  String get playerSettingEqualizerSubtitle => '通过 FFmpeg 实现的 10 段参数均衡器。';

  @override
  String get pluginDefaultsTitle => '插件默认项';

  @override
  String get pluginDefaultsDiscoverHeader => '发现源';

  @override
  String get pluginDefaultsNoResolver => '未加载内容解析器。加载插件以选择发现源。';

  @override
  String get pluginDefaultsAutomaticSubtitle => '使用第一个可用的内容解析器。';

  @override
  String get pluginDefaultsPriorityHeader => '解析器优先级';

  @override
  String get pluginDefaultsNoPriority => '未加载内容解析器。加载插件后，优先级排序将显示在这里。';

  @override
  String get pluginDefaultsPriorityDesc =>
      '拖动以重新排序。解析榜单项或导入音轨时，将首先尝试优先级较高的解析器。';

  @override
  String get pluginDefaultsLyricsHeader => '歌词优先级';

  @override
  String get pluginDefaultsLyricsNone => '未加载歌词提供程序。';

  @override
  String get pluginDefaultsLyricsDesc => '拖动以重新排序歌词提供程序。将首先尝试第一个提供程序。';

  @override
  String get pluginDefaultsSuggestionsHeader => '搜索建议';

  @override
  String get pluginDefaultsSuggestionsNone => '未加载建议提供程序。';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => '无';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle => '仅使用搜索历史。';

  @override
  String get storageSettingTitle => '存储';

  @override
  String get storageClearHistoryEvery => '定期清除历史记录';

  @override
  String get storageClearHistorySubtitle => '在选定的时间段后清除播放历史。';

  @override
  String storageDays(int count) {
    return '$count 天';
  }

  @override
  String get storageBackupLocation => '备份位置';

  @override
  String get storageBackupLocationAndroid => '下载 / 应用数据目录';

  @override
  String get storageBackupLocationDownloads => '下载目录';

  @override
  String get storageCreateBackup => '创建备份';

  @override
  String get storageCreateBackupSubtitle => '将您的设置和数据保存到备份文件。';

  @override
  String storageBackupCreatedAt(String path) {
    return '备份已创建于 $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return '分享备份失败: $error';
  }

  @override
  String get storageBackupFailed => '备份失败！';

  @override
  String get storageRestoreBackup => '恢复备份';

  @override
  String get storageRestoreBackupSubtitle => '从备份文件恢复您的设置和数据。';

  @override
  String get storageAutoBackup => '自动备份';

  @override
  String get storageAutoBackupSubtitle => '定期自动创建数据备份。';

  @override
  String get storageAutoLyrics => '自动保存歌词';

  @override
  String get storageAutoLyricsSubtitle => '播放歌曲时自动保存歌词。';

  @override
  String get storageResetApp => '重置 Bloomee 应用';

  @override
  String get storageResetAppSubtitle => '删除所有数据并将应用恢复到初始状态。';

  @override
  String get storageResetConfirmTitle => '确认重置';

  @override
  String get storageResetConfirmMessage => '确定要重置 Bloomee 吗？这将删除您的所有数据且无法撤销。';

  @override
  String get storageResetButton => '重置';

  @override
  String get storageResetSuccess => '应用已恢复到默认状态。';

  @override
  String get storageLocationDialogTitle => '备份位置';

  @override
  String get storageLocationAndroid =>
      '备份存储在：\n\n1. 下载目录\n2. Android/data/ls.bloomee.musicplayer/data\n\n请从任一位置复制文件。';

  @override
  String get storageLocationOther => '备份存储在“下载”目录中。请从那里复制文件。';

  @override
  String get storageRestoreOptionsTitle => '恢复选项';

  @override
  String get storageRestoreOptionsDesc => '选择要从备份文件恢复的数据。取消选择不需要导入的项目。默认全选。';

  @override
  String get storageRestoreSelectAll => '全选';

  @override
  String get storageRestoreMediaItems => '媒体项目 (歌曲、音轨、库条目)';

  @override
  String get storageRestoreSearchHistory => '搜索历史';

  @override
  String get storageRestoreContinue => '继续';

  @override
  String get storageRestoreNoFile => '未选择文件。';

  @override
  String get storageRestoreSaveFailed => '保存选定文件失败。';

  @override
  String get storageRestoreConfirmTitle => '确认恢复';

  @override
  String get storageRestoreConfirmPrefix => '这将用备份文件中的数据覆盖并合并应用中选定的部分：';

  @override
  String get storageRestoreConfirmSuffix => '您当前的数据将被修改/合并。确定要继续吗？';

  @override
  String get storageRestoreYes => '是的，恢复';

  @override
  String get storageRestoreNo => '不';

  @override
  String get storageRestoring => '正在恢复选定的数据...\n请等待操作完成。';

  @override
  String get storageRestoreMediaBullet => '• 媒体项目';

  @override
  String get storageRestoreHistoryBullet => '• 搜索历史';

  @override
  String get storageUnexpectedError => '恢复过程中发生意外错误。';

  @override
  String get storageRestoreCompleted => '恢复完成';

  @override
  String get storageRestoreFailedTitle => '恢复失败';

  @override
  String get storageRestoreSuccessMessage => '选定的数据已成功恢复。为了获得最佳效果，请现在重启应用。';

  @override
  String get storageRestoreFailedMessage => '恢复过程失败，错误如下：';

  @override
  String get storageRestoreUnknownError => '恢复期间发生未知错误。';

  @override
  String get storageRestoreRestartHint => '请重启应用以确保一致性。';

  @override
  String get updateSettingTitle => '更新';

  @override
  String get updateAppUpdatesHeader => '应用更新';

  @override
  String get updateCheckForUpdates => '检查更新';

  @override
  String get updateCheckSubtitle => '查看是否有新版本的 Bloomee 可用。';

  @override
  String get updateAutoNotify => '自动更新通知';

  @override
  String get updateAutoNotifySubtitle => '应用启动时如有新版本将收到通知。';

  @override
  String get updateCheckTitle => '检查更新';

  @override
  String get updateUpToDate => 'Bloomee🌸 已经是最新版本！';

  @override
  String get updateViewPreRelease => '查看最新预发布版';

  @override
  String updateCurrentVersion(String curr, String build) {
    return '当前版本: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'Bloomee🌸 新版本现已可用！';

  @override
  String updateVersion(String ver, String build) {
    return '版本: $ver+$build';
  }

  @override
  String get updateDownloadNow => '立即下载';

  @override
  String get updateChecking => '正在检查是否有新版本！';

  @override
  String get timerTitle => '睡眠定时器';

  @override
  String get timerInterludeMessage => '音乐将在以下时间后停止...';

  @override
  String get timerHours => '小时';

  @override
  String get timerMinutes => '分钟';

  @override
  String get timerSeconds => '秒';

  @override
  String get timerStop => '停止定时器';

  @override
  String get timerFinishedMessage => '音乐已停止播放。祝你好梦 🥰。';

  @override
  String get timerGotIt => '知道了！';

  @override
  String get timerSetTimeError => '请设置时间';

  @override
  String get timerStart => '启动定时器';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsEmpty => '暂无通知！';

  @override
  String get recentsTitle => '历史记录';

  @override
  String playlistByCreator(String creator) {
    return '创建者：$creator';
  }

  @override
  String get playlistTypeAlbum => '专辑';

  @override
  String get playlistTypePlaylist => '歌单';

  @override
  String get playlistYou => '您';

  @override
  String get pluginManagerTitle => '插件';

  @override
  String get pluginManagerEmpty => '未安装插件。\n点击 + 添加 .bex 文件。';

  @override
  String get pluginManagerFilterAll => '全部';

  @override
  String get pluginManagerFilterContent => '内容解析器';

  @override
  String get pluginManagerFilterCharts => '榜单程序';

  @override
  String get pluginManagerFilterLyrics => '歌词程序';

  @override
  String get pluginManagerFilterSuggestions => '建议程序';

  @override
  String get pluginManagerFilterImporters => '导入程序';

  @override
  String get pluginManagerTooltipRefresh => '刷新';

  @override
  String get pluginManagerTooltipInstall => '安装插件';

  @override
  String get pluginManagerNoMatch => '没有匹配此过滤器的插件';

  @override
  String pluginManagerPickFailed(String error) {
    return '选择文件失败: $error';
  }

  @override
  String get pluginManagerInstalling => '正在安装插件...';

  @override
  String get pluginManagerTypeContentResolver => '内容解析器';

  @override
  String get pluginManagerTypeChartProvider => '榜单提供程序';

  @override
  String get pluginManagerTypeLyricsProvider => '歌词提供程序';

  @override
  String get pluginManagerTypeSuggestionProvider => '搜索建议';

  @override
  String get pluginManagerTypeContentImporter => '内容导入程序';

  @override
  String get pluginManagerDeleteTitle => '删除插件？';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '确定要删除 \"$name\" 吗？这将永久移除其文件。';
  }

  @override
  String get pluginManagerDeleteAction => '删除';

  @override
  String get pluginManagerCancel => '取消';

  @override
  String get pluginManagerEnablePlugin => '启用插件';

  @override
  String get pluginManagerUnloadPlugin => '卸载插件';

  @override
  String get pluginManagerDeleting => '正在删除...';

  @override
  String get pluginManagerApiKeysTitle => 'API 密钥';

  @override
  String get pluginManagerApiKeysSaved => 'API 密钥已保存';

  @override
  String get pluginManagerSave => '保存';

  @override
  String get pluginManagerDetailVersion => '版本';

  @override
  String get pluginManagerDetailType => '类型';

  @override
  String get pluginManagerDetailPublisher => '发布者';

  @override
  String get pluginManagerDetailLastUpdated => '最后更新';

  @override
  String get pluginManagerDetailCreated => '创建时间';

  @override
  String get pluginManagerDetailHomepage => '主页';

  @override
  String get pluginManagerDowngradeTitle => '降级插件？';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return '您正在安装 \"$name\" 的旧版本或相同版本。确定继续吗？';
  }

  @override
  String get pluginManagerDowngradeAction => '仍然安装';

  @override
  String get pluginManagerDeleteStorageTitle => '删除插件数据？';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '是否同时移除 \"$name\" 保存的 API 密钥和设置？';
  }

  @override
  String get pluginManagerDeleteStorageKeep => '保留数据';

  @override
  String get pluginManagerDeleteStorageRemove => '移除数据';

  @override
  String get segmentsSheetTitle => '片段';

  @override
  String get segmentsSheetEmpty => '暂无可用片段';

  @override
  String get segmentsSheetUntitled => '无标题片段';

  @override
  String get smartReplaceTitle => '智能替换';

  @override
  String smartReplaceSubtitle(String title) {
    return '为 \"$title\" 选择一个可播放的替代源，并更新已保存的歌单引用。';
  }

  @override
  String get smartReplaceClose => '关闭';

  @override
  String get smartReplaceNoMatch => '未找到替代源';

  @override
  String get smartReplaceNoMatchSubtitle => '加载的解析器插件均未返回足够匹配的结果。';

  @override
  String get smartReplaceBestMatch => '最佳匹配';

  @override
  String get smartReplaceSearchFailed => '搜索失败';

  @override
  String smartReplaceApplyFailed(String error) {
    return '智能替换失败: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return '已应用替代源$queue。';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '已在 $count 个歌单中替换$queue。';
  }

  @override
  String get smartReplaceQueueUpdated => '并更新了队列';

  @override
  String get playerUnknownQueue => '未知';

  @override
  String playerLiked(String title) {
    return '已喜欢 $title！！';
  }

  @override
  String playerUnliked(String title) {
    return '已取消喜欢 $title！！';
  }

  @override
  String get offlineNoDownloads => '暂无下载';

  @override
  String get offlineTitle => '离线';

  @override
  String get offlineSearchHint => '搜索您的歌曲...';

  @override
  String get offlineRefreshTooltip => '刷新下载项';

  @override
  String get offlineCloseSearch => '关闭搜索';

  @override
  String get offlineSearchTooltip => '搜索';

  @override
  String get offlineOpenFailed => '无法打开此离线音轨。请尝试刷新下载项。';

  @override
  String get offlinePlayFailed => '无法播放此离线歌曲。请重试。';

  @override
  String albumViewTrackCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String get albumViewLoadFailed => '加载专辑失败';

  @override
  String get aboutCraftingSubtitle => '用代码编织交响乐。';

  @override
  String get aboutFollowGitHub => '在 GitHub 上关注他';

  @override
  String get aboutSendInquiry => '发送商务咨询';

  @override
  String get aboutCreativeHighlights => '更新与创作亮点';

  @override
  String get aboutTipQuote => '喜欢 Bloomee 吗？小小的打赏能让它持续绽放。🌸';

  @override
  String get aboutTipButton => '我要赞赏';

  @override
  String get aboutTipDesc => '我希望 Bloomee 越来越好。';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => '歌曲详情';

  @override
  String get songInfoSectionTechnical => '技术信息';

  @override
  String get songInfoSectionActions => '操作';

  @override
  String get songInfoLabelTitle => '标题';

  @override
  String get songInfoLabelArtist => '艺人';

  @override
  String get songInfoLabelAlbum => '专辑';

  @override
  String get songInfoLabelDuration => '时长';

  @override
  String get songInfoLabelSource => '来源';

  @override
  String get songInfoLabelMediaId => '媒体 ID';

  @override
  String get songInfoLabelPluginId => '插件 ID';

  @override
  String get songInfoIdCopied => '媒体 ID 已复制';

  @override
  String get songInfoLinkCopied => '链接已复制';

  @override
  String get songInfoNoLink => '无可用链接';

  @override
  String get songInfoOpenFailed => '无法打开链接';

  @override
  String get songInfoUpdateMetadata => '获取最新元数据';

  @override
  String get songInfoMetadataUpdated => '元数据已更新';

  @override
  String get songInfoMetadataUpdateFailed => '无法更新元数据';

  @override
  String get songInfoMetadataUnavailable => '此来源不支持刷新元数据';

  @override
  String get songInfoSearchTitle => '在 Bloomee 中搜索此歌曲';

  @override
  String get songInfoSearchArtist => '在 Bloomee 中搜索此艺人';

  @override
  String get songInfoSearchAlbum => '在 Bloomee 中搜索此专辑';

  @override
  String get eqTitle => '均衡器';

  @override
  String get eqResetTooltip => '重置为平直';

  @override
  String get chartNoItems => '此榜单中没有项目';

  @override
  String get chartLoadFailed => '加载榜单失败';

  @override
  String get chartPlay => '播放';

  @override
  String get chartResolving => '正在解析';

  @override
  String get chartReady => '就绪';

  @override
  String get chartAddToPlaylist => '添加到歌单';

  @override
  String get chartNoResolver => '未加载内容解析器。请安装插件以播放。';

  @override
  String get chartResolveFailed => '无法解析。正在转为搜索...';

  @override
  String get chartNoResolverAdd => '未加载内容解析器。';

  @override
  String get chartNoMatch => '未找到匹配项。请尝试手动搜索。';

  @override
  String get chartStatPeak => '最高';

  @override
  String get chartStatWeeks => '周数';

  @override
  String get chartStatChange => '变化';

  @override
  String menuSharePreparing(String title) {
    return '正在准备分享 \"$title\"。';
  }

  @override
  String get menuOpenLinkFailed => '无法打开链接';

  @override
  String get localMusicFolders => '音乐文件夹';

  @override
  String get localMusicCloseSearch => '关闭搜索';

  @override
  String get localMusicOpenSearch => '搜索';

  @override
  String get localMusicNoMusicFound => '未找到本地音乐';

  @override
  String get localMusicNoSearchResults => '未找到匹配搜索的音轨。';

  @override
  String get importSongsTitle => '导入歌曲';

  @override
  String get importNoPluginsLoaded => '未加载内容导入插件。\n请安装导入插件以从外部服务导入歌单。';

  @override
  String get importBloomeeFiles => '导入 Bloomee 文件';

  @override
  String get importM3UFiles => '导入 M3U 歌单';

  @override
  String get importM3UNameDialogTitle => '歌单名称';

  @override
  String get importM3UNameHint => '为此歌单输入名称';

  @override
  String get importM3UNoTracks => 'M3U 文件中未找到有效音轨。';

  @override
  String get importNoteTitle => '注';

  @override
  String get importNoteMessage =>
      '您只能导入由 Bloomee 创建的文件。\n如果文件来自其他来源，将无法工作。是否仍要继续？';

  @override
  String get importTitle => '导入';

  @override
  String get importCheckingUrl => '正在检查 URL...';

  @override
  String get importFetchingTracks => '正在获取音轨...';

  @override
  String get importSavingToLibrary => '正在保存到音乐库...';

  @override
  String get importPasteUrlHint => '粘贴歌单或专辑 URL 以导入';

  @override
  String get importAction => '导入';

  @override
  String importTrackCount(int count) {
    return '$count 首歌曲';
  }

  @override
  String get importResolving => '正在解析...';

  @override
  String importResolvingProgress(int done, int total) {
    return '正在解析音轨：$done / $total';
  }

  @override
  String get importReviewTitle => '导入预览';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$total 首歌曲中，$resolved 首已解析，$failed 首失败';
  }

  @override
  String importSaveTracks(int count) {
    return '保存 $count 首音轨';
  }

  @override
  String importTracksSaved(int count) {
    return '已保存 $count 首音轨！';
  }

  @override
  String get importDone => '完成';

  @override
  String get importMore => '导入更多';

  @override
  String get importUnknownError => '未知错误';

  @override
  String get importTryAgain => '重试';

  @override
  String get importSkipTrack => '跳过此音轨';

  @override
  String get importMatchOptions => '匹配选项';

  @override
  String get importAutoMatched => '自动匹配';

  @override
  String get importUserSelected => '已选定';

  @override
  String get importSkipped => '已跳过';

  @override
  String get importNoMatch => '未找到匹配';

  @override
  String get importReorderTip => '长按歌单以开始重新排序';

  @override
  String get importErrorCannotHandleUrl => '此插件无法处理提供的 URL。';

  @override
  String get importErrorUnexpectedResponse => '插件返回意外响应。';

  @override
  String importErrorFailedToCheck(String error) {
    return '检查 URL 失败: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return '获取集合信息失败: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return '获取音轨失败: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return '保存歌单失败: $error';
  }

  @override
  String get playlistPinToTop => '置顶';

  @override
  String get playlistUnpin => '取消置顶';

  @override
  String get snackbarImportingMedia => '正在导入媒体项目...';

  @override
  String get snackbarPlaylistSaved => '歌单已保存到音乐库！';

  @override
  String get snackbarInvalidFileFormat => '无效的文件格式';

  @override
  String get snackbarMediaItemImported => '媒体项目已导入';

  @override
  String get snackbarPlaylistImported => '歌单已导入';

  @override
  String get snackbarOpenImportForUrl => '请在音乐库中打开“导入”屏幕以从该 URL 导入。';

  @override
  String get snackbarProcessingFile => '正在处理文件...';

  @override
  String snackbarPreparingShare(String title) {
    return '正在准备分享 \"$title\"';
  }

  @override
  String snackbarPreparingExport(String title) {
    return '正在准备导出 \"$title\"。';
  }

  @override
  String get pluginManagerTabInstalled => '已安装';

  @override
  String get pluginManagerTabStore => '插件商店';

  @override
  String get pluginManagerSelectPackage => '选择插件包 (.bex)';

  @override
  String get pluginManagerOutdatedManifest => '此插件使用旧版清单。某些功能可能会失效。请考虑更新。';

  @override
  String get pluginManagerStatusActive => '已启用';

  @override
  String get pluginManagerStatusInactive => '未启用';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return '更新于 $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    return '$count 个可用插件';
  }

  @override
  String get pluginRepositoryOutdatedManifest => '清单版本过旧。功能可能失效。';

  @override
  String get pluginRepositoryUnknownPublisher => '未知发布者';

  @override
  String get pluginRepositoryActionRetry => '重试';

  @override
  String get pluginRepositoryActionOutdated => '旧版本';

  @override
  String get pluginRepositoryActionInstalled => '已安装';

  @override
  String get pluginRepositoryActionInstall => '安装';

  @override
  String get pluginRepositoryActionUnavailable => '不可用';

  @override
  String get pluginRepositoryInstallFailed => '安装失败。';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '下载 $name 失败。';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    return '已在 $count 个歌单中替换$queue。';
  }

  @override
  String get lyricsSearchFieldLabel => '搜索歌词...';

  @override
  String get lyricsSearchEmptyPrompt => '输入歌曲或艺人名以查找歌词。';

  @override
  String lyricsSearchNoResults(String query) {
    return '未找到 \"$query\" 的歌词';
  }

  @override
  String get lyricsSearchApplied => '歌词应用成功';

  @override
  String get lyricsSearchFetchFailed => '获取歌词失败';

  @override
  String get lyricsSearchPreview => '预览';

  @override
  String get lyricsSearchPreviewTooltip => '预览歌词';

  @override
  String get lyricsSearchSynced => '同步';

  @override
  String get lyricsSearchPreviewLoadFailed => '加载歌词失败。';

  @override
  String get lyricsSearchApplyAction => '应用歌词';

  @override
  String get lyricsSettingsSearchTitle => '搜索自定义歌词';

  @override
  String get lyricsSettingsSearchSubtitle => '在线查找其他版本';

  @override
  String get lyricsSettingsSyncTitle => '调整同步 (延迟/偏移)';

  @override
  String get lyricsSettingsSyncSubtitle => '修复过快或过慢的歌词';

  @override
  String get lyricsSettingsSaveTitle => '离线保存';

  @override
  String get lyricsSettingsSaveSubtitle => '将歌词存储在您的设备上';

  @override
  String get lyricsSettingsDeleteTitle => '删除已保存歌词';

  @override
  String get lyricsSettingsDeleteSubtitle => '移除离线歌词数据';

  @override
  String get lyricsSyncTapToReset => '点击以重置';

  @override
  String get upNextTitle => '接下来播放';

  @override
  String upNextItemsInQueue(int count) {
    return '队列中有 $count 个项目';
  }

  @override
  String get upNextAutoPlay => '自动播放';

  @override
  String get tooltipCopyToClipboard => '复制到剪贴板';

  @override
  String get snackbarCopiedToClipboard => '已复制到剪贴板';

  @override
  String get tooltipSongInfo => '歌曲信息';

  @override
  String get snackbarCannotDeletePlayingSong => '无法删除当前播放的歌曲';

  @override
  String get playerLoopOff => '关闭循环';

  @override
  String get playerLoopOne => '单曲循环';

  @override
  String get playerLoopAll => '全部循环';

  @override
  String get snackbarOpeningAlbumPage => '正在打开原始专辑页面。';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Bloomee🌸 新版本现已可用！\n\n版本：$ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return '插件 \"$id\" 安装成功';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return '插件 \"$id\" 已加载';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return '插件 \"$id\" 已删除';
  }

  @override
  String get pluginBootstrapTitle => '正在设置 Bloomee';

  @override
  String pluginBootstrapProgress(int percent) {
    return '正在设置新插件引擎... $percent%';
  }

  @override
  String get pluginBootstrapHint => '此操作仅执行一次。';

  @override
  String get pluginBootstrapErrorTitle => '连接过慢';

  @override
  String get pluginBootstrapErrorBody =>
      '部分插件无法安装。您仍可使用 Bloomee —— 插件将在下次启动时重试。';

  @override
  String get pluginBootstrapContinue => '仍然继续';
}
