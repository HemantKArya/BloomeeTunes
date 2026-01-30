// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get welcome => 'Bloomeeへようこそ';

  @override
  String get onboardingSubtitle => '広告なしの音楽の旅がここから始まります。自分好みにカスタマイズしましょう。';

  @override
  String get country => '国';

  @override
  String get language => '言語';

  @override
  String get getStarted => '始める';

  @override
  String get settings => '設定';

  @override
  String get discover => '発見';

  @override
  String get history => '履歴';

  @override
  String get library => 'ライブラリ';

  @override
  String get explore => '探索';

  @override
  String get search => '検索';

  @override
  String get offline => 'オフライン';

  @override
  String get searchHint => '次のお気に入りの曲を見つけましょう...';

  @override
  String get songs => '曲';

  @override
  String get albums => 'アルバム';

  @override
  String get artists => 'アーティスト';

  @override
  String get playlists => 'プレイリスト';

  @override
  String get recently => '最近';

  @override
  String get lastFmPicks => 'Last.Fmのおすすめ';

  @override
  String get noInternet => 'インターネット接続がありません！';

  @override
  String get enjoyingFrom => '再生中:';

  @override
  String get unknown => '不明';

  @override
  String get availableOffline => 'オフラインで利用可能';

  @override
  String get timer => 'タイマー';

  @override
  String get lyrics => '歌詞';

  @override
  String get loop => 'ループ';

  @override
  String get off => 'オフ';

  @override
  String get loopOne => '1曲リピート';

  @override
  String get loopAll => '全曲リピート';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get openOriginalLink => '元のリンクを開く';

  @override
  String get unableToOpenLink => 'リンクを開けません';

  @override
  String get updates => 'アップデート';

  @override
  String get checkUpdates => '新しいアップデートを確認';

  @override
  String get downloads => 'ダウンロード';

  @override
  String get downloadsSubtitle => '保存先、ダウンロード品質など...';

  @override
  String get playerSettings => 'プレーヤー設定';

  @override
  String get playerSettingsSubtitle => 'ストリーミング品質、自動再生など';

  @override
  String get uiSettings => 'UI要素とサービス';

  @override
  String get uiSettingsSubtitle => '自動スライド、ソースエンジンなど';

  @override
  String get lastFmSettings => 'Last.FM設定';

  @override
  String get lastFmSettingsSubtitle => 'APIキー、シークレット、スクロブル設定。';

  @override
  String get storage => 'ストレージ';

  @override
  String get storageSubtitle => 'バックアップ、キャッシュ、履歴、復元など...';

  @override
  String get languageCountry => '言語と国';

  @override
  String get languageCountrySubtitle => '言語と国を選択してください。';

  @override
  String get about => 'このアプリについて';

  @override
  String get aboutSubtitle => 'アプリについて、バージョン、開発者など';

  @override
  String get searchLibrary => 'ライブラリを検索...';

  @override
  String get emptyLibraryMessage => 'ライブラリが寂しいようです。曲を追加して華やかにしましょう！';

  @override
  String get noMatchesFound => '一致するものが見つかりませんでした';

  @override
  String inPlaylist(String playlistName) {
    return '$playlistName 内';
  }

  @override
  String artistWithEngine(String engine) {
    return 'アーティスト - $engine';
  }

  @override
  String albumWithEngine(String engine) {
    return 'アルバム - $engine';
  }

  @override
  String playlistWithEngine(String engine) {
    return 'プレイリスト - $engine';
  }

  @override
  String get noDownloads => 'ダウンロードはありません';

  @override
  String get searchSongs => '曲を検索...';

  @override
  String get refreshDownloads => 'ダウンロードを更新';

  @override
  String get closeSearch => '検索を閉じる';

  @override
  String get aboutTagline => 'コードでシンフォニーを創る。';

  @override
  String get maintainer => 'メンテナー';

  @override
  String get followGithub => 'GitHubでフォローする';

  @override
  String get contact => '連絡先';

  @override
  String get contactTooltip => 'ビジネスの問い合わせを送る';

  @override
  String get linkedin => 'Linkedin';

  @override
  String get linkedinTooltip => 'アップデートとクリエイティブなハイライト';

  @override
  String get supportMessage => 'Bloomeeを楽しんでいますか？少額のチップがあれば活動を続けられます。🌸';

  @override
  String get supportButton => '支援する';

  @override
  String get supportFooter => 'Bloomeeをもっと良くしたいと思っています。';

  @override
  String get github => 'GitHub';

  @override
  String get versionError => 'バージョンを取得できません';

  @override
  String get home => 'ホーム';

  @override
  String get topSongs => '人気の曲';

  @override
  String get topAlbums => '人気のアルバム';

  @override
  String get viewLyrics => '歌詞を表示';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get startAuth => '認証開始';

  @override
  String get getSessionKey => 'セッションキーを取得して保存';

  @override
  String get removeKeys => 'キーを削除';

  @override
  String get countryLangSettings => '国と言語の設定';

  @override
  String get autoCheckCountry => '国の自動確認';

  @override
  String get autoCheckCountrySubtitle => 'アプリを開いたときに現在地から国を自動的に確認します。';

  @override
  String get countrySubtitle => 'アプリのデフォルトとして設定する国。';

  @override
  String get languageSubtitle => 'アプリのメイン言語。';

  @override
  String get scrobbleTracks => 'トラックをスクロブル';

  @override
  String get scrobbleTracksSubtitle => 'Last.FMにトラックをスクロブルする';

  @override
  String get firstAuthLastFM => '最初にLast.FM APIを認証してください。';

  @override
  String get lastFmInstructions =>
      'Last.FMのAPIキーを設定するには、\n1. Last.FM（https://www.last.fm/）にアクセスしてアカウントを作成してください。\n2. 次に、https://www.last.fm/api/account/create からAPIキーとシークレットを生成してください。\n3. 以下にAPIキーとシークレットを入力し、「認証開始」をクリックしてセッションキーを取得してください。\n4. ブラウザで許可した後、「セッションキーを取得して保存」をクリックしてセッションキーを保存してください。';

  @override
  String lastFmAuthenticated(String username) {
    return 'こんにちは、$usernameさん。\nLast.FM APIが認証されました。';
  }

  @override
  String get onboardingWelcome => '体験をカスタマイズする';

  @override
  String get confirmSettings => '最適なコンテンツで開始するために、国と言語を確認してください。';

  @override
  String get detectedLabel => '検出されました';

  @override
  String lastFmAuthFailed(String message) {
    return 'Last.FMの認証に失敗しました。\n$message\nヒント：まず「認証開始」をクリックしてブラウザでサインインし、次に「セッションキーを取得して保存」ボタンをクリックしてください。';
  }
}
