// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get onboardingTitle => 'Bloomeeへようこそ';

  @override
  String get onboardingSubtitle => '言語と地域の設定を行いましょう。';

  @override
  String get continueButton => '次へ';

  @override
  String get navHome => 'ホーム';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navSearch => '検索';

  @override
  String get navLocal => 'ローカル';

  @override
  String get navOffline => 'オフライン';

  @override
  String get playerEnjoyingFrom => '再生中:';

  @override
  String get playerQueue => '再生待ちリスト';

  @override
  String get playerPlayWithMix => 'オートミックス再生';

  @override
  String get playerPlayNext => '次に再生';

  @override
  String get playerAddToQueue => 'キューに追加';

  @override
  String get playerAddToFavorites => 'お気に入りに追加';

  @override
  String get playerNoLyricsFound => '歌詞が見つかりませんでした';

  @override
  String get playerLyricsNoPlugin =>
      '歌詞プロバイダーが設定されていません。設定 → プラグイン からインストールしてください。';

  @override
  String get playerFullscreenLyrics => 'フルスクリーン歌詞';

  @override
  String get localMusicTitle => 'ローカル';

  @override
  String get localMusicGrantPermission => '権限を許可';

  @override
  String get localMusicStorageAccessRequired => 'ストレージへのアクセス権限が必要です';

  @override
  String get localMusicStorageAccessDesc =>
      'デバイス内のオーディオファイルをスキャンして再生するために、アクセス権限を許可してください。';

  @override
  String get localMusicAddFolder => '音楽フォルダーを追加';

  @override
  String get localMusicScanNow => '今すぐスキャン';

  @override
  String localMusicScanFailed(String message) {
    return 'スキャン失敗: $message';
  }

  @override
  String get localMusicScanning => 'オーディオファイルをスキャン中...';

  @override
  String get localMusicEmpty => 'ローカル音楽が見つかりません';

  @override
  String get localMusicSearchEmpty => '検索条件に一致する曲が見つかりませんでした。';

  @override
  String get localMusicShuffle => 'シャッフル再生';

  @override
  String get localMusicPlayAll => 'すべて再生';

  @override
  String get localMusicSearchHint => 'ローカル音楽を検索...';

  @override
  String get localMusicRescanDevice => 'デバイスを再スキャン';

  @override
  String get localMusicRemoveFolder => 'フォルダーを削除';

  @override
  String get localMusicMusicFolders => '音楽フォルダー';

  @override
  String localMusicTrackCount(int count) {
    return '$count 曲';
  }

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get buttonDelete => '削除';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonUpdate => 'アップデート';

  @override
  String get buttonDownload => 'ダウンロード';

  @override
  String get buttonShare => '共有';

  @override
  String get buttonLater => '後で';

  @override
  String get buttonInfo => '情報';

  @override
  String get buttonMore => '詳細';

  @override
  String get dialogDeleteTrack => '曲を削除';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'デバイスから \"$title\" を削除してもよろしいですか？この操作は取り消せません。';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists => 'この曲は以下の項目からも削除されます:';

  @override
  String get dialogDontAskAgain => '今後表示しない';

  @override
  String get dialogDeletePlugin => 'プラグインを削除しますか？';

  @override
  String dialogDeletePluginMessage(String name) {
    return '\"$name\" を削除してもよろしいですか？関連するファイルが完全に削除されます。';
  }

  @override
  String get dialogUpdateAvailable => 'アップデートがあります';

  @override
  String get dialogUpdateNow => '今すぐアップデート';

  @override
  String get dialogDownloadPlaylist => 'プレイリストをダウンロード';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '\"$title\" から $count 曲をダウンロードしますか？ダウンロードキューに追加されます。';
  }

  @override
  String get dialogDownloadAll => 'すべてダウンロード';

  @override
  String get playlistEdit => 'プレイリストを編集';

  @override
  String get playlistShareFile => 'ファイルを共有';

  @override
  String get playlistExportFile => 'ファイルを書き出し';

  @override
  String get playlistPlay => '再生';

  @override
  String get playlistAddToQueue => 'プレイリストをキューに追加';

  @override
  String get playlistShare => 'プレイリストを共有';

  @override
  String get playlistDelete => 'プレイリストを削除';

  @override
  String get playlistEmptyState => '曲がまだありません';

  @override
  String get playlistAvailableOffline => 'オフライン再生可能';

  @override
  String get playlistShuffle => 'シャッフル';

  @override
  String get playlistMoreOptions => 'その他のオプション';

  @override
  String get playlistNoMatchSearch => '一致するプレイリストがありません';

  @override
  String get playlistCreateNew => '新しいプレイリストを作成';

  @override
  String get playlistCreateFirstOne => 'プレイリストがありません。お気に入りを作ってみましょう！';

  @override
  String playlistSongCount(int count) {
    return '$count 曲';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$playlist から $title を削除しました';
  }

  @override
  String get playlistFailedToLoad => 'プレイリストの読み込みに失敗しました';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsPlugins => 'プラグイン';

  @override
  String get settingsPluginsSubtitle => 'プラグインのインストールと管理';

  @override
  String get settingsUpdates => 'アップデート';

  @override
  String get settingsUpdatesSubtitle => '新着情報の確認';

  @override
  String get settingsDownloads => 'ダウンロード';

  @override
  String get settingsDownloadsSubtitle => '保存先、音質などの設定';

  @override
  String get settingsLocalTracks => 'ローカル曲';

  @override
  String get settingsLocalTracksSubtitle => 'フォルダーのスキャンと管理';

  @override
  String get settingsPlayer => 'プレイヤー設定';

  @override
  String get settingsPlayerSubtitle => '再生品質、自動再生など';

  @override
  String get settingsPluginDefaults => 'プラグインのデフォルト';

  @override
  String get settingsPluginDefaultsSubtitle => '検索ソース、優先順位の設定';

  @override
  String get settingsUIElements => 'UIとサービス';

  @override
  String get settingsUIElementsSubtitle => 'デザインやUIの微調整';

  @override
  String get settingsLastFM => 'Last.FM 設定';

  @override
  String get settingsLastFMSubtitle => 'APIキーとスクロブルの設定';

  @override
  String get settingsStorage => 'ストレージ';

  @override
  String get settingsStorageSubtitle => 'バックアップ、キャッシュ、履歴の管理';

  @override
  String get settingsLanguageCountry => '言語と地域';

  @override
  String get settingsLanguageCountrySubtitle => '言語と国の選択';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsAboutSubtitle => 'バージョン、開発者情報など';

  @override
  String get settingsScanning => 'スキャン';

  @override
  String get settingsMusicFolders => '音楽フォルダー';

  @override
  String get settingsQuality => '音質';

  @override
  String get settingsHistory => '履歴';

  @override
  String get settingsBackupRestore => 'バックアップと復元';

  @override
  String get settingsAutomatic => '自動';

  @override
  String get settingsDangerZone => '危険地帯';

  @override
  String get settingsScrobbling => 'スクロブル';

  @override
  String get settingsAuthentication => '認証';

  @override
  String get settingsHomeScreen => 'ホーム画面';

  @override
  String get settingsChartVisibility => 'チャートの表示';

  @override
  String get settingsLocation => '場所';

  @override
  String get pluginRepositoryTitle => 'プラグインリポジトリ';

  @override
  String get pluginRepositorySubtitle => '外部ソースを追加してプラグインを検索します。';

  @override
  String get pluginRepositoryAddAction => 'リポジトリを追加';

  @override
  String get pluginRepositoryAddTitle => 'リポジトリを追加';

  @override
  String get pluginRepositoryAddSubtitle => 'プラグインリポジトリ JSON の URL を入力してください。';

  @override
  String get pluginRepositoryEmpty => 'リポジトリがありません。';

  @override
  String get pluginRepositoryUrlCopied => 'クリップボードにコピー済み';

  @override
  String get pluginRepositoryNoDescription => '説明なし。';

  @override
  String get pluginRepositoryUnknownUpdate => '不明な更新';

  @override
  String pluginRepositoryPluginsCount(int count) {
    return '$count 個のプラグイン';
  }

  @override
  String get pluginRepositoryErrorLoad => 'リポジトリを読み込めませんでした。';

  @override
  String get pluginRepositoryErrorInvalid => '無効なリポジトリ形式です。';

  @override
  String get pluginRepositoryErrorRemove => '削除に失敗しました。';

  @override
  String pluginRepositoryError(String message) {
    return 'エラー: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => 'ダウンロードキューに追加中';

  @override
  String get emptyNoInternet => 'インターネット接続がありません';

  @override
  String get emptyNoContentPlugin => 'コンテンツプラグインが読み込まれていません。設定から追加してください。';

  @override
  String get emptyRefreshingSource => 'ソースを更新中... 以前のソースは利用できなくなりました。';

  @override
  String get emptyNoTracks => 'トラックがありません';

  @override
  String get emptyNoResults => '結果が見つかりませんでした';

  @override
  String snackbarDeletedTrack(String title) {
    return '\"$title\" を削除しました';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '\"$title\" の削除に失敗しました';
  }

  @override
  String get snackbarAddedToNextQueue => '次に再生する曲として追加しました';

  @override
  String get snackbarAddedToQueue => '再生待ちリストに追加しました';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title をお気に入りに追加しました！';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '$name を再生中';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name をキューに追加しました';
  }

  @override
  String get snackbarPlaylistQueued => 'プレイリストをダウンロードキューに追加しました';

  @override
  String get snackbarPlaylistUpdated => 'プレイリストを更新しました！';

  @override
  String get snackbarNoInternet => '接続環境を確認してください。';

  @override
  String get snackbarImportFailed => 'インポートに失敗しました';

  @override
  String get snackbarImportCompleted => 'インポートが完了しました';

  @override
  String get snackbarBackupFailed => 'バックアップに失敗しました';

  @override
  String snackbarExportedTo(String path) {
    return '保存先: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'メディアIDをコピーしました';

  @override
  String get snackbarLinkCopied => 'リンクをコピーしました';

  @override
  String get snackbarNoLinkAvailable => '利用可能なリンクがありません';

  @override
  String get snackbarCouldNotOpenLink => 'リンクを開けませんでした';

  @override
  String snackbarPreparingDownload(String title) {
    return '$title のダウンロードを準備中...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title はすでにダウンロード済みです。';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title はすでにキューに入っています。';
  }

  @override
  String snackbarDownloaded(String title) {
    return '$title をダウンロードしました';
  }

  @override
  String get snackbarDownloadServiceUnavailable => 'エラー: ダウンロードサービスを利用できません。';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count 曲をダウンロードキューに追加しました';
  }

  @override
  String get snackbarDeleteTrackFailDevice => 'ストレージからの削除に失敗しました。';

  @override
  String get searchHintExplore => '何を聴きたいですか？';

  @override
  String get searchHintLibrary => 'ライブラリを検索...';

  @override
  String get searchHintOfflineMusic => '曲を検索...';

  @override
  String get searchHintPlaylists => 'プレイリストを検索...';

  @override
  String get searchStartTyping => '検索キーワードを入力してください...';

  @override
  String get searchNoSuggestions => '候補が見つかりませんでした';

  @override
  String get searchNoResults => '結果が見つかりませんでした。\nキーワードやソースを変えてみてください。';

  @override
  String get searchFailed => '検索に失敗しました';

  @override
  String get searchDiscover => '素晴らしい音楽を見つけましょう...';

  @override
  String get searchSources => 'ソース';

  @override
  String get searchNoPlugins => 'プラグインがインストールされていません';

  @override
  String get searchTracks => '曲';

  @override
  String get searchAlbums => 'アルバム';

  @override
  String get searchArtists => 'アーティスト';

  @override
  String get searchPlaylists => 'プレイリスト';

  @override
  String get exploreDiscover => '見つける';

  @override
  String get exploreRecently => '最近の再生';

  @override
  String get exploreLastFmPicks => 'Last.Fm のおすすめ';

  @override
  String get exploreFailedToLoad => 'ホームセクションの読み込みに失敗しました。';

  @override
  String get libraryTitle => 'ライブラリ';

  @override
  String get libraryEmptyState => 'ライブラリが空です。お気に入りの曲を追加しましょう！';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName 内';
  }

  @override
  String get menuAddToPlaylist => 'プレイリストに追加';

  @override
  String get menuSmartReplace => 'スマート置換';

  @override
  String get menuShare => '共有';

  @override
  String get menuAvailableOffline => 'オフライン再生可能';

  @override
  String get menuDownload => 'ダウンロード';

  @override
  String get menuOpenOriginalLink => '元のリンクを開く';

  @override
  String get menuDeleteTrack => '削除';

  @override
  String get songInfoTitle => '曲名';

  @override
  String get songInfoArtist => 'アーティスト';

  @override
  String get songInfoAlbum => 'アルバム';

  @override
  String get songInfoMediaId => 'メディアID';

  @override
  String get songInfoCopyId => 'IDをコピー';

  @override
  String get songInfoCopyLink => 'リンクをコピー';

  @override
  String get songInfoOpenBrowser => 'ブラウザで開く';

  @override
  String get tooltipRemoveFromLibrary => 'ライブラリから削除';

  @override
  String get tooltipSaveToLibrary => 'ライブラリに保存';

  @override
  String get tooltipOpenOriginalLink => '元のリンクを開く';

  @override
  String get tooltipShuffle => 'シャッフル';

  @override
  String get tooltipAvailableOffline => 'オフライン再生可能';

  @override
  String get tooltipDownloadPlaylist => 'プレイリストをダウンロード';

  @override
  String get tooltipMoreOptions => 'その他のオプション';

  @override
  String get tooltipInfo => '曲情報';

  @override
  String get appuiTitle => 'UIとサービス';

  @override
  String get appuiAutoSlideCharts => 'チャートの自動スライド';

  @override
  String get appuiAutoSlideChartsSubtitle => 'ホーム画面のチャートを自動で切り替えます。';

  @override
  String get appuiLastFmPicksSubtitle => 'Last.FM のおすすめを表示（ログインと再起動が必要）。';

  @override
  String get appuiNoChartsAvailable => 'チャートがありません。チャートプロバイダープラグインを追加してください。';

  @override
  String get appuiLoginToLastFm => '先に Last.FM にログインしてください。';

  @override
  String get appuiShowInCarousel => 'ホームカルーセルに表示する';

  @override
  String get countrySettingTitle => '国と言語';

  @override
  String get countrySettingAutoDetect => '国を自動検出';

  @override
  String get countrySettingAutoDetectSubtitle => 'アプリ起動時に国を自動的に判別します。';

  @override
  String get countrySettingCountryLabel => '国';

  @override
  String get countrySettingLanguageLabel => '言語';

  @override
  String get countrySettingSystemDefault => 'システムデフォルト';

  @override
  String get downloadSettingTitle => 'ダウンロード';

  @override
  String get downloadSettingQuality => 'ダウンロード音質';

  @override
  String get downloadSettingQualitySubtitle => '曲をダウンロードする際の優先音質設定。';

  @override
  String get downloadSettingFolder => 'ダウンロードフォルダー';

  @override
  String get downloadSettingResetFolder => 'フォルダーをリセット';

  @override
  String get downloadSettingResetFolderSubtitle => 'デフォルトの保存先に戻します。';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => '曲をスクロブル';

  @override
  String get lastfmScrobbleTracksSubtitle => '再生した曲を Last.FM プロフィールに送信します。';

  @override
  String get lastfmAuthFirst => '先に Last.FM API の認証を行ってください。';

  @override
  String get lastfmAuthenticatedAs => '認証済み:';

  @override
  String get lastfmAuthFailed => '認証に失敗しました:';

  @override
  String get lastfmNotAuthenticated => '未認証';

  @override
  String get lastfmSteps =>
      '認証手順:\n1. last.fm でアカウントを作成/ログイン\n2. last.fm/api/account/create で APIキーを作成\n3. 下記に APIキーとシークレットを入力\n4.「認証開始」を押し、ブラウザで承認\n5.「セッションキーを取得して保存」を押して完了';

  @override
  String get lastfmApiKey => 'APIキー';

  @override
  String get lastfmApiSecret => 'APIシークレット';

  @override
  String get lastfmStartAuth => '1. 認証開始';

  @override
  String get lastfmGetSession => '2. セッションキーを取得して保存';

  @override
  String get lastfmRemoveKeys => 'キーを削除';

  @override
  String get lastfmStartAuthFirst => '先に認証を開始し、ブラウザで承認してください。';

  @override
  String get localSettingTitle => 'ローカル曲';

  @override
  String get localSettingAutoScan => '起動時に自動スキャン';

  @override
  String get localSettingAutoScanSubtitle => 'アプリ起動時に新しいファイルを自動でスキャンします。';

  @override
  String get localSettingLastScan => '最終スキャン';

  @override
  String get localSettingNeverScanned => '未実施';

  @override
  String get localSettingScanInProgress => 'スキャン中…';

  @override
  String get localSettingScanNowSubtitle => '手動でライブラリ全体をスキャンします。';

  @override
  String get localSettingNoFolders => 'フォルダーが追加されていません。スキャンを開始するには追加してください。';

  @override
  String get localSettingAddFolder => 'フォルダーを追加';

  @override
  String get playerSettingTitle => 'プレイヤー設定';

  @override
  String get playerSettingStreamingHeader => 'ストリーミング';

  @override
  String get playerSettingStreamQuality => 'ストリーミング音質';

  @override
  String get playerSettingStreamQualitySubtitle => 'オンライン再生時のビットレート設定。';

  @override
  String get playerSettingQualityLow => '低';

  @override
  String get playerSettingQualityMedium => '中';

  @override
  String get playerSettingQualityHigh => '高';

  @override
  String get playerSettingPlaybackHeader => '再生';

  @override
  String get playerSettingAutoPlay => '自動再生';

  @override
  String get playerSettingAutoPlaySubtitle => 'キュー終了後に似た曲を自動で追加します。';

  @override
  String get playerSettingAutoFallback => '自動フォールバック再生';

  @override
  String get playerSettingAutoFallbackSubtitle => 'エラー時に代替の解決策を試みます。';

  @override
  String get playerSettingCrossfade => 'クロスフェード';

  @override
  String get playerSettingCrossfadeOff => 'オフ';

  @override
  String get playerSettingCrossfadeInstant => '瞬時に切り替え';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '$seconds秒間で曲を重ねる';
  }

  @override
  String get playerSettingEqualizer => 'イコライザー';

  @override
  String get playerSettingEqualizerActive => '有効';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return '有効 — $preset プリセット';
  }

  @override
  String get playerSettingEqualizerSubtitle => 'FFmpeg を使用した10バンド EQ。';

  @override
  String get pluginDefaultsTitle => 'プラグインのデフォルト';

  @override
  String get pluginDefaultsDiscoverHeader => '発見ソース';

  @override
  String get pluginDefaultsNoResolver => 'プラグインがありません。ソースを選択するにはインストールしてください。';

  @override
  String get pluginDefaultsAutomaticSubtitle => '最初に利用可能なソースを使用する';

  @override
  String get pluginDefaultsPriorityHeader => 'ソースの優先順位';

  @override
  String get pluginDefaultsNoPriority => 'プラグインが読み込まれると、ここに順序が表示されます。';

  @override
  String get pluginDefaultsPriorityDesc =>
      'ドラッグして順序を変更します。上にあるものが優先的に再生に使用されます。';

  @override
  String get pluginDefaultsLyricsHeader => '歌詞の優先順位';

  @override
  String get pluginDefaultsLyricsNone => '歌詞プロバイダーがありません。';

  @override
  String get pluginDefaultsLyricsDesc => '歌詞を取得するサービスの順序をドラッグして設定します。';

  @override
  String get pluginDefaultsSuggestionsHeader => '検索候補';

  @override
  String get pluginDefaultsSuggestionsNone => '候補プロバイダーがありません。';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'なし';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle => '検索履歴のみを使用する';

  @override
  String get storageSettingTitle => 'ストレージ';

  @override
  String get storageClearHistoryEvery => '履歴の自動消去';

  @override
  String get storageClearHistorySubtitle => '一定期間を過ぎた再生履歴を自動的に削除します。';

  @override
  String storageDays(int count) {
    return '$count 日';
  }

  @override
  String get storageBackupLocation => 'バックアップ場所';

  @override
  String get storageBackupLocationAndroid => 'ダウンロード / アプリデータディレクトリ';

  @override
  String get storageBackupLocationDownloads => 'ダウンロードディレクトリ';

  @override
  String get storageCreateBackup => 'バックアップを作成';

  @override
  String get storageCreateBackupSubtitle => '設定とデータをバックアップファイルに保存します。';

  @override
  String storageBackupCreatedAt(String path) {
    return 'バックアップ作成先: $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return '共有に失敗しました: $error';
  }

  @override
  String get storageBackupFailed => 'バックアップ失敗！';

  @override
  String get storageRestoreBackup => 'バックアップから復元';

  @override
  String get storageRestoreBackupSubtitle => '保存したファイルからデータと設定を復元します。';

  @override
  String get storageAutoBackup => '自動バックアップ';

  @override
  String get storageAutoBackupSubtitle => '定期的にバックアップを自動生成します。';

  @override
  String get storageAutoLyrics => '歌詞を自動保存';

  @override
  String get storageAutoLyricsSubtitle => '再生時に歌詞を自動的にデバイスへ保存します。';

  @override
  String get storageResetApp => 'アプリをリセット';

  @override
  String get storageResetAppSubtitle => 'すべてのデータを削除し、初期状態に戻します。';

  @override
  String get storageResetConfirmTitle => 'リセットの確認';

  @override
  String get storageResetConfirmMessage =>
      '本当にリセットしますか？この操作は取り消しできず、すべてのデータが消去されます。';

  @override
  String get storageResetButton => 'リセット';

  @override
  String get storageResetSuccess => 'アプリを初期状態に戻しました。';

  @override
  String get storageLocationDialogTitle => 'バックアップ場所';

  @override
  String get storageLocationAndroid =>
      'バックアップは以下に保存されます:\n\n1. ダウンロードフォルダー\n2. Android/data/ls.bloomee.musicplayer/data\n\nここからファイルをコピーしてください。';

  @override
  String get storageLocationOther => 'バックアップはダウンロードフォルダーに保存されます。';

  @override
  String get storageRestoreOptionsTitle => '復元オプション';

  @override
  String get storageRestoreOptionsDesc => '復元するデータを選択してください。不要な項目のチェックを外します。';

  @override
  String get storageRestoreSelectAll => 'すべて選択';

  @override
  String get storageRestoreMediaItems => 'メディア項目（曲、ライブラリなど）';

  @override
  String get storageRestoreSearchHistory => '検索履歴';

  @override
  String get storageRestoreContinue => '続行';

  @override
  String get storageRestoreNoFile => 'ファイルが選択されていません。';

  @override
  String get storageRestoreSaveFailed => 'ファイルの保存に失敗しました。';

  @override
  String get storageRestoreConfirmTitle => '復元の確認';

  @override
  String get storageRestoreConfirmPrefix => '現在のデータはバックアップの内容で統合または上書きされます:';

  @override
  String get storageRestoreConfirmSuffix => '現在のデータが変更されますが、よろしいですか？';

  @override
  String get storageRestoreYes => 'はい、復元します';

  @override
  String get storageRestoreNo => 'いいえ';

  @override
  String get storageRestoring => 'データを復元中…\n完了までしばらくお待ちください。';

  @override
  String get storageRestoreMediaBullet => '• メディア項目';

  @override
  String get storageRestoreHistoryBullet => '• 検索履歴';

  @override
  String get storageUnexpectedError => '復元中に予期しないエラーが発生しました。';

  @override
  String get storageRestoreCompleted => '復元完了';

  @override
  String get storageRestoreFailedTitle => '復元失敗';

  @override
  String get storageRestoreSuccessMessage =>
      'データの復元に成功しました。アプリを再起動して反映させてください。';

  @override
  String get storageRestoreFailedMessage => '復元中に以下のエラーが発生しました:';

  @override
  String get storageRestoreUnknownError => '不明なエラーが発生しました。';

  @override
  String get storageRestoreRestartHint => '安定させるためにアプリを再起動してください。';

  @override
  String get updateSettingTitle => 'アップデート';

  @override
  String get updateAppUpdatesHeader => 'アプリのアップデート';

  @override
  String get updateCheckForUpdates => 'アップデートを確認';

  @override
  String get updateCheckSubtitle => 'Bloomee の新しいバージョンがあるか確認します。';

  @override
  String get updateAutoNotify => 'アップデートの自動通知';

  @override
  String get updateAutoNotifySubtitle => '新しいバージョンがある場合に通知します。';

  @override
  String get updateCheckTitle => '更新の確認';

  @override
  String get updateUpToDate => 'Bloomee🌸 は最新の状態です！';

  @override
  String get updateViewPreRelease => '最新のプレリリースを表示';

  @override
  String updateCurrentVersion(String curr, String build) {
    return '現在のバージョン: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'Bloomee🌸 の新しいバージョンが利用可能です！';

  @override
  String updateVersion(String ver, String build) {
    return 'バージョン: $ver+$build';
  }

  @override
  String get updateDownloadNow => '今すぐダウンロード';

  @override
  String get updateChecking => '最新バージョンの有無を確認中...';

  @override
  String get timerTitle => 'おやすみタイマー';

  @override
  String get timerInterludeMessage => 'まもなく音楽を停止します…';

  @override
  String get timerHours => '時間';

  @override
  String get timerMinutes => '分';

  @override
  String get timerSeconds => '秒';

  @override
  String get timerStop => 'タイマーを停止';

  @override
  String get timerFinishedMessage => '音楽を停止しました。おやすみなさい 🥰。';

  @override
  String get timerGotIt => '了解';

  @override
  String get timerSetTimeError => '時間を設定してください';

  @override
  String get timerStart => 'タイマーを開始';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsEmpty => '通知はありません';

  @override
  String get recentsTitle => '最近の履歴';

  @override
  String playlistByCreator(String creator) {
    return '作成者: $creator';
  }

  @override
  String get playlistTypeAlbum => 'アルバム';

  @override
  String get playlistTypePlaylist => 'プレイリスト';

  @override
  String get playlistYou => 'あなた';

  @override
  String get pluginManagerTitle => 'プラグイン';

  @override
  String get pluginManagerEmpty => 'プラグインがありません。\n＋ を押して .bex ファイルを追加してください。';

  @override
  String get pluginManagerFilterAll => 'すべて';

  @override
  String get pluginManagerFilterContent => 'コンテンツ解決';

  @override
  String get pluginManagerFilterCharts => 'チャート提供';

  @override
  String get pluginManagerFilterLyrics => '歌詞提供';

  @override
  String get pluginManagerFilterSuggestions => '検索候補提供';

  @override
  String get pluginManagerFilterImporters => 'インポーター';

  @override
  String get pluginManagerTooltipRefresh => '更新';

  @override
  String get pluginManagerTooltipInstall => 'プラグインをインストール';

  @override
  String get pluginManagerNoMatch => '条件に合うプラグインが見つかりません';

  @override
  String pluginManagerPickFailed(String error) {
    return 'ファイルの選択に失敗しました: $error';
  }

  @override
  String get pluginManagerInstalling => 'プラグインをインストール中...';

  @override
  String get pluginManagerTypeContentResolver => 'コンテンツ解決';

  @override
  String get pluginManagerTypeChartProvider => 'チャート提供';

  @override
  String get pluginManagerTypeLyricsProvider => '歌詞提供';

  @override
  String get pluginManagerTypeSuggestionProvider => '検索候補提供';

  @override
  String get pluginManagerTypeContentImporter => 'インポーター';

  @override
  String get pluginManagerDeleteTitle => 'プラグインを削除しますか？';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '\"$name\" を削除してもよろしいですか？';
  }

  @override
  String get pluginManagerDeleteAction => '削除';

  @override
  String get pluginManagerCancel => 'キャンセル';

  @override
  String get pluginManagerEnablePlugin => 'プラグインを有効化';

  @override
  String get pluginManagerUnloadPlugin => 'プラグインを解除';

  @override
  String get pluginManagerDeleting => '削除中...';

  @override
  String get pluginManagerApiKeysTitle => 'APIキー';

  @override
  String get pluginManagerApiKeysSaved => 'APIキーを保存しました';

  @override
  String get pluginManagerSave => '保存';

  @override
  String get pluginManagerDetailVersion => 'バージョン';

  @override
  String get pluginManagerDetailType => 'タイプ';

  @override
  String get pluginManagerDetailPublisher => 'パブリッシャー';

  @override
  String get pluginManagerDetailLastUpdated => '最終更新日';

  @override
  String get pluginManagerDetailCreated => '作成日';

  @override
  String get pluginManagerDetailHomepage => 'ホームページ';

  @override
  String get pluginManagerDowngradeTitle => 'ダウングレードしますか？';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return '現在より古い（または同じ）バージョンをインストールしようとしています。続行しますか？';
  }

  @override
  String get pluginManagerDowngradeAction => 'そのままインストール';

  @override
  String get pluginManagerDeleteStorageTitle => 'データを削除しますか？';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '\"$name\" に保存された APIキーや設定も削除しますか？';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'データを残す';

  @override
  String get pluginManagerDeleteStorageRemove => 'データを削除';

  @override
  String get segmentsSheetTitle => 'セグメント';

  @override
  String get segmentsSheetEmpty => '利用可能なセグメントがありません';

  @override
  String get segmentsSheetUntitled => '無題のセグメント';

  @override
  String get smartReplaceTitle => 'スマート置換';

  @override
  String smartReplaceSubtitle(String title) {
    return '\"$title\" を再生可能な別の曲に置き換え、プレイリストの情報を更新します。';
  }

  @override
  String get smartReplaceClose => '閉じる';

  @override
  String get smartReplaceNoMatch => '代替曲が見つかりませんでした';

  @override
  String get smartReplaceNoMatchSubtitle => '読み込まれたプラグインの中に、一致する曲が見つかりません。';

  @override
  String get smartReplaceBestMatch => '最も一致する曲';

  @override
  String get smartReplaceSearchFailed => '検索に失敗しました';

  @override
  String smartReplaceApplyFailed(String error) {
    return '置換に失敗しました: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return '代替曲を適用しました$queue。';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '$count 個のプレイリストで曲を置換しました$queue。';
  }

  @override
  String get smartReplaceQueueUpdated => '（キューを含む）';

  @override
  String get playerUnknownQueue => '不明';

  @override
  String playerLiked(String title) {
    return '$title をお気に入りに追加しました！';
  }

  @override
  String playerUnliked(String title) {
    return '$title をお気に入りから解除しました！';
  }

  @override
  String get offlineNoDownloads => 'ダウンロード済みの曲はありません';

  @override
  String get offlineTitle => 'オフライン';

  @override
  String get offlineSearchHint => '曲を検索...';

  @override
  String get offlineRefreshTooltip => 'リストを更新';

  @override
  String get offlineCloseSearch => '検索を閉じる';

  @override
  String get offlineSearchTooltip => '検索';

  @override
  String get offlineOpenFailed => 'オフライン曲を開けませんでした。更新を試してください。';

  @override
  String get offlinePlayFailed => '再生に失敗しました。もう一度お試しください。';

  @override
  String albumViewTrackCount(int count) {
    return '$count 曲';
  }

  @override
  String get albumViewLoadFailed => 'アルバムの読み込みに失敗しました';

  @override
  String get aboutCraftingSubtitle => 'コードで音楽を奏でる。';

  @override
  String get aboutFollowGitHub => 'GitHub でフォロー';

  @override
  String get aboutSendInquiry => 'ビジネスに関するお問い合わせ';

  @override
  String get aboutCreativeHighlights => 'アップデートとクリエイティブな活動';

  @override
  String get aboutTipQuote => 'Bloomee を気に入っていただけましたか？応援が活動の励みになります。 🌸';

  @override
  String get aboutTipButton => '応援する';

  @override
  String get aboutTipDesc => 'アプリのさらなる改善をサポートします。';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => '曲の詳細';

  @override
  String get songInfoSectionTechnical => '技術情報';

  @override
  String get songInfoSectionActions => 'アクション';

  @override
  String get songInfoLabelTitle => '曲名';

  @override
  String get songInfoLabelArtist => 'アーティスト';

  @override
  String get songInfoLabelAlbum => 'アルバム';

  @override
  String get songInfoLabelDuration => '再生時間';

  @override
  String get songInfoLabelSource => 'ソース';

  @override
  String get songInfoLabelMediaId => 'メディアID';

  @override
  String get songInfoLabelPluginId => 'プラグインID';

  @override
  String get songInfoIdCopied => 'メディアIDをコピーしました';

  @override
  String get songInfoLinkCopied => 'リンクをコピーしました';

  @override
  String get songInfoNoLink => '利用可能なリンクがありません';

  @override
  String get songInfoOpenFailed => 'リンクを開けませんでした';

  @override
  String get songInfoUpdateMetadata => '最新の情報を取得';

  @override
  String get songInfoMetadataUpdated => '情報を更新しました';

  @override
  String get songInfoMetadataUpdateFailed => '情報の更新に失敗しました';

  @override
  String get songInfoMetadataUnavailable => 'このソースは情報の更新に対応していません';

  @override
  String get songInfoSearchTitle => 'Bloomee でこの曲を検索';

  @override
  String get songInfoSearchArtist => 'Bloomee でこのアーティストを検索';

  @override
  String get songInfoSearchAlbum => 'Bloomee でこのアルバムを検索';

  @override
  String get eqTitle => 'イコライザー';

  @override
  String get eqResetTooltip => 'フラットにリセット';

  @override
  String get chartNoItems => 'チャートに項目がありません';

  @override
  String get chartLoadFailed => 'チャートの読み込みに失敗しました';

  @override
  String get chartPlay => '再生';

  @override
  String get chartResolving => '曲を特定中';

  @override
  String get chartReady => '準備完了';

  @override
  String get chartAddToPlaylist => 'プレイリストに追加';

  @override
  String get chartNoResolver => '再生用のプラグインがありません。インストールしてください。';

  @override
  String get chartResolveFailed => '曲が見つかりませんでした。代わりに検索します...';

  @override
  String get chartNoResolverAdd => 'プラグインが読み込まれていません。';

  @override
  String get chartNoMatch => '一致する曲が見つかりませんでした。手動で検索してください。';

  @override
  String get chartStatPeak => '最高順位';

  @override
  String get chartStatWeeks => 'チャートイン期間';

  @override
  String get chartStatChange => '順位変動';

  @override
  String menuSharePreparing(String title) {
    return '$title の共有を準備中...';
  }

  @override
  String get menuOpenLinkFailed => 'リンクを開けませんでした';

  @override
  String get localMusicFolders => '音楽フォルダー';

  @override
  String get localMusicCloseSearch => '検索を閉じる';

  @override
  String get localMusicOpenSearch => '検索';

  @override
  String get localMusicNoMusicFound => 'ローカル音楽が見つかりません';

  @override
  String get localMusicNoSearchResults => '一致するトラックが見つかりませんでした。';

  @override
  String get importSongsTitle => '曲をインポート';

  @override
  String get importNoPluginsLoaded =>
      'インポータープラグインがありません。外部サービスから取り込むにはインストールしてください。';

  @override
  String get importBloomeeFiles => 'Bloomee ファイルをインポート';

  @override
  String get importM3UFiles => 'M3U プレイリストをインポート';

  @override
  String get importM3UNameDialogTitle => 'プレイリスト名';

  @override
  String get importM3UNameHint => '名前を入力してください';

  @override
  String get importM3UNoTracks => 'M3U ファイルに有効なトラックがありませんでした。';

  @override
  String get importNoteTitle => '注記';

  @override
  String get importNoteMessage => 'Bloomee で作成されたファイルのみが対象です。続行しますか？';

  @override
  String get importTitle => 'インポート';

  @override
  String get importCheckingUrl => 'URLを確認中...';

  @override
  String get importFetchingTracks => '曲を取得中...';

  @override
  String get importSavingToLibrary => 'ライブラリに保存中...';

  @override
  String get importPasteUrlHint => 'インポートするプレイリストやアルバムのURLを貼り付け';

  @override
  String get importAction => 'インポート';

  @override
  String importTrackCount(int count) {
    return '$count 曲';
  }

  @override
  String get importResolving => '曲を特定中...';

  @override
  String importResolvingProgress(int done, int total) {
    return '処理中: $done / $total';
  }

  @override
  String get importReviewTitle => 'インポート結果';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$total 曲中 $resolved 曲成功、$failed 曲失敗';
  }

  @override
  String importSaveTracks(int count) {
    return '$count 曲を保存';
  }

  @override
  String importTracksSaved(int count) {
    return '$count 曲を保存しました！';
  }

  @override
  String get importDone => '完了';

  @override
  String get importMore => 'さらに対象を追加';

  @override
  String get importUnknownError => '不明なエラー';

  @override
  String get importTryAgain => '再試行';

  @override
  String get importSkipTrack => 'この曲をスキップ';

  @override
  String get importMatchOptions => '一致設定';

  @override
  String get importAutoMatched => '自動一致';

  @override
  String get importUserSelected => '選択済み';

  @override
  String get importSkipped => 'スキップ済み';

  @override
  String get importNoMatch => '一致なし';

  @override
  String get importReorderTip => '長押ししてプレイリストの順序を入れ替え';

  @override
  String get importErrorCannotHandleUrl => 'このプラグインはこのURLを処理できません。';

  @override
  String get importErrorUnexpectedResponse => 'プラグインから予期しない応答がありました。';

  @override
  String importErrorFailedToCheck(String error) {
    return 'URL確認失敗: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return '情報の取得に失敗しました: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return '曲の取得に失敗しました: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'プレイリストの保存に失敗しました: $error';
  }

  @override
  String get playlistPinToTop => 'トップに固定';

  @override
  String get playlistUnpin => '固定を解除';

  @override
  String get snackbarImportingMedia => 'メディアをインポート中...';

  @override
  String get snackbarPlaylistSaved => 'プレイリストをライブラリに保存しました！';

  @override
  String get snackbarInvalidFileFormat => 'ファイル形式が正しくありません';

  @override
  String get snackbarMediaItemImported => 'メディアをインポートしました';

  @override
  String get snackbarPlaylistImported => 'プレイリストをインポートしました';

  @override
  String get snackbarOpenImportForUrl => 'ライブラリの「インポート」からURLを指定して取り込んでください。';

  @override
  String get snackbarProcessingFile => 'ファイルを処理中...';

  @override
  String snackbarPreparingShare(String title) {
    return '$title の共有を準備中';
  }

  @override
  String snackbarPreparingExport(String title) {
    return '$title の書き出しを準備中...';
  }

  @override
  String get pluginManagerTabInstalled => 'インストール済み';

  @override
  String get pluginManagerTabStore => 'プラグインストア';

  @override
  String get pluginManagerSelectPackage => 'プラグイン（.bex）を選択';

  @override
  String get pluginManagerOutdatedManifest =>
      'このプラグインは古いマニフェストを使用しています。正常に動作しない可能性があります。';

  @override
  String get pluginManagerStatusActive => '有効';

  @override
  String get pluginManagerStatusInactive => '無効';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return '$date 更新';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    return '$count 個のプラグインが利用可能';
  }

  @override
  String get pluginRepositoryOutdatedManifest => 'マニフェストが古いため動作しない場合があります。';

  @override
  String get pluginRepositoryUnknownPublisher => '不明なパブリッシャー';

  @override
  String get pluginRepositoryActionRetry => '再試行';

  @override
  String get pluginRepositoryActionOutdated => '更新あり';

  @override
  String get pluginRepositoryActionInstalled => 'インストール済み';

  @override
  String get pluginRepositoryActionInstall => 'インストール';

  @override
  String get pluginRepositoryActionUnavailable => '利用不可';

  @override
  String get pluginRepositoryInstallFailed => 'インストールに失敗しました。';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name のダウンロードに失敗しました。';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    return '$count 個のプレイリストで置換が完了しました$queue。';
  }

  @override
  String get lyricsSearchFieldLabel => '歌詞を検索...';

  @override
  String get lyricsSearchEmptyPrompt => '曲名やアーティスト名で歌詞を検索してください。';

  @override
  String lyricsSearchNoResults(String query) {
    return '\"$query\" の歌詞は見つかりませんでした';
  }

  @override
  String get lyricsSearchApplied => '歌詞を適用しました';

  @override
  String get lyricsSearchFetchFailed => '歌詞の取得に失敗しました';

  @override
  String get lyricsSearchPreview => 'プレビュー';

  @override
  String get lyricsSearchPreviewTooltip => '歌詞のプレビュー';

  @override
  String get lyricsSearchSynced => '同期済み';

  @override
  String get lyricsSearchPreviewLoadFailed => '歌詞を読み込めませんでした。';

  @override
  String get lyricsSearchApplyAction => '歌詞を適用';

  @override
  String get lyricsSettingsSearchTitle => '別の歌詞を検索';

  @override
  String get lyricsSettingsSearchSubtitle => 'オンラインで他のバージョンを探す';

  @override
  String get lyricsSettingsSyncTitle => '同期の調整（遅延/オフセット）';

  @override
  String get lyricsSettingsSyncSubtitle => '歌詞のズレを修正します';

  @override
  String get lyricsSettingsSaveTitle => 'オフライン保存';

  @override
  String get lyricsSettingsSaveSubtitle => 'この歌詞をデバイスに保存します';

  @override
  String get lyricsSettingsDeleteTitle => '保存した歌詞を削除';

  @override
  String get lyricsSettingsDeleteSubtitle => 'オフラインの歌詞データを消去します';

  @override
  String get lyricsSyncTapToReset => 'タップしてリセット';

  @override
  String get upNextTitle => '次に再生';

  @override
  String upNextItemsInQueue(int count) {
    return '$count 曲が待機中';
  }

  @override
  String get upNextAutoPlay => '自動再生';

  @override
  String get tooltipCopyToClipboard => 'コピーする';

  @override
  String get snackbarCopiedToClipboard => 'コピーしました';

  @override
  String get tooltipSongInfo => '曲の詳細';

  @override
  String get snackbarCannotDeletePlayingSong => '再生中の曲は削除できません';

  @override
  String get playerLoopOff => 'リピートなし';

  @override
  String get playerLoopOne => '1曲リピート';

  @override
  String get playerLoopAll => '全曲リピート';

  @override
  String get snackbarOpeningAlbumPage => '元のアルバムページを開きます。';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Bloomee🌸 の新しいバージョンが利用可能です！\n\nバージョン: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'プラグイン \"$id\" をインストールしました';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'プラグイン \"$id\" を読み込みました';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'プラグイン \"$id\" を削除しました';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee をセットアップ中';

  @override
  String pluginBootstrapProgress(int percent) {
    return '新しいプラグインエンジンを準備中... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'この処理は最初の1回のみです。';

  @override
  String get pluginBootstrapErrorTitle => '接続に時間がかかっています';

  @override
  String get pluginBootstrapErrorBody =>
      '一部のプラグインをインストールできませんでした。アプリ自体は使用可能です。次回の起動時に再試行します。';

  @override
  String get pluginBootstrapContinue => 'そのまま続行';
}
