// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get onboardingTitle => 'Bloomee에 오신 것을 환영합니다';

  @override
  String get onboardingSubtitle => '언어와 지역 설정을 시작합니다.';

  @override
  String get continueButton => '계속하기';

  @override
  String get navHome => '홈';

  @override
  String get navLibrary => '보관함';

  @override
  String get navSearch => '검색';

  @override
  String get navLocal => '로컬';

  @override
  String get navOffline => '오프라인';

  @override
  String get playerEnjoyingFrom => '재생 중인 소스';

  @override
  String get playerQueue => '재생 대기열';

  @override
  String get playerPlayWithMix => '자동 믹스 재생';

  @override
  String get playerPlayNext => '다음에 재생';

  @override
  String get playerAddToQueue => '대기열에 추가';

  @override
  String get playerAddToFavorites => '즐겨찾기에 추가';

  @override
  String get playerNoLyricsFound => '가사를 찾을 수 없습니다';

  @override
  String get playerLyricsNoPlugin => '설정된 가사 제공자가 없습니다. 설정 → 플러그인에서 설치해 주세요.';

  @override
  String get playerFullscreenLyrics => '가사 전체 화면';

  @override
  String get localMusicTitle => '로컬 음악';

  @override
  String get localMusicGrantPermission => '권한 허용';

  @override
  String get localMusicStorageAccessRequired => '저장공간 액세스 권한 필요';

  @override
  String get localMusicStorageAccessDesc =>
      '기기에 저장된 오디오 파일을 스캔하고 재생하려면 권한 허용이 필요합니다.';

  @override
  String get localMusicAddFolder => '음악 폴더 추가';

  @override
  String get localMusicScanNow => '지금 스캔';

  @override
  String localMusicScanFailed(String message) {
    return '스캔 실패: $message';
  }

  @override
  String get localMusicScanning => '오디오 파일을 찾는 중...';

  @override
  String get localMusicEmpty => '로컬 음악이 없습니다';

  @override
  String get localMusicSearchEmpty => '검색 결과와 일치하는 트랙이 없습니다.';

  @override
  String get localMusicShuffle => '셔플 재생';

  @override
  String get localMusicPlayAll => '전체 재생';

  @override
  String get localMusicSearchHint => '로컬 음악 검색...';

  @override
  String get localMusicRescanDevice => '기기 다시 스캔';

  @override
  String get localMusicRemoveFolder => '폴더 제거';

  @override
  String get localMusicMusicFolders => '음악 폴더';

  @override
  String localMusicTrackCount(int count) {
    return '곡 $count개';
  }

  @override
  String get buttonCancel => '취소';

  @override
  String get buttonDelete => '삭제';

  @override
  String get buttonOk => '확인';

  @override
  String get buttonUpdate => '업데이트';

  @override
  String get buttonDownload => '다운로드';

  @override
  String get buttonShare => '공유';

  @override
  String get buttonLater => '나중에';

  @override
  String get buttonInfo => '정보';

  @override
  String get buttonMore => '더보기';

  @override
  String get dialogDeleteTrack => '트랙 삭제';

  @override
  String dialogDeleteTrackMessage(String title) {
    return '기기에서 \"$title\" 트랙을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists => '이 트랙은 다음 항목에서도 삭제됩니다:';

  @override
  String get dialogDontAskAgain => '다시 묻지 않음';

  @override
  String get dialogDeletePlugin => '플러그인 삭제';

  @override
  String dialogDeletePluginMessage(String name) {
    return '\"$name\" 플러그인을 삭제하시겠습니까? 관련 파일이 영구적으로 제거됩니다.';
  }

  @override
  String get dialogUpdateAvailable => '업데이트 가능';

  @override
  String get dialogUpdateNow => '지금 업데이트';

  @override
  String get dialogDownloadPlaylist => '플레이리스트 다운로드';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '\"$title\"에서 $count곡을 다운로드하시겠습니까? 다운로드 대기열에 추가됩니다.';
  }

  @override
  String get dialogDownloadAll => '모두 다운로드';

  @override
  String get playlistEdit => '플레이리스트 수정';

  @override
  String get playlistShareFile => '파일 공유';

  @override
  String get playlistExportFile => '파일 내보내기';

  @override
  String get playlistPlay => '재생';

  @override
  String get playlistAddToQueue => '플레이리스트를 대기열에 추가';

  @override
  String get playlistShare => '플레이리스트 공유';

  @override
  String get playlistDelete => '플레이리스트 삭제';

  @override
  String get playlistEmptyState => '곡이 아직 없습니다';

  @override
  String get playlistAvailableOffline => '오프라인 사용 가능';

  @override
  String get playlistShuffle => '셔플 재생';

  @override
  String get playlistMoreOptions => '추가 옵션';

  @override
  String get playlistNoMatchSearch => '일치하는 플레이리스트가 없습니다';

  @override
  String get playlistCreateNew => '새 플레이리스트 만들기';

  @override
  String get playlistCreateFirstOne => '플레이리스트가 없습니다. 첫 번째 리스트를 만들어 보세요!';

  @override
  String playlistSongCount(int count) {
    return '곡 $count개';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$playlist에서 $title 삭제됨';
  }

  @override
  String get playlistFailedToLoad => '플레이리스트를 불러오지 못했습니다';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsPlugins => '플러그인';

  @override
  String get settingsPluginsSubtitle => '플러그인 설치 및 관리';

  @override
  String get settingsUpdates => '업데이트';

  @override
  String get settingsUpdatesSubtitle => '새 버전 확인';

  @override
  String get settingsDownloads => '다운로드';

  @override
  String get settingsDownloadsSubtitle => '경로, 품질 및 기타 설정';

  @override
  String get settingsLocalTracks => '로컬 트랙';

  @override
  String get settingsLocalTracksSubtitle => '폴더 관리 및 자동 스캔';

  @override
  String get settingsPlayer => '플레이어 설정';

  @override
  String get settingsPlayerSubtitle => '스트리밍 품질, 자동 재생 등';

  @override
  String get settingsPluginDefaults => '기본 플러그인';

  @override
  String get settingsPluginDefaultsSubtitle => '검색 소스 및 우선순위 설정';

  @override
  String get settingsUIElements => 'UI 및 서비스';

  @override
  String get settingsUIElementsSubtitle => '디자인 및 UI 트윅 설정';

  @override
  String get settingsLastFM => 'Last.FM 설정';

  @override
  String get settingsLastFMSubtitle => '계정 연동 및 스크로블링 설정';

  @override
  String get settingsStorage => '저장공간';

  @override
  String get settingsStorageSubtitle => '백업, 캐시 및 데이터 복구';

  @override
  String get settingsLanguageCountry => '언어 및 지역';

  @override
  String get settingsLanguageCountrySubtitle => '사용할 언어와 지역 선택';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsAboutSubtitle => '앱 버전, 개발자 정보 등';

  @override
  String get settingsScanning => '스캔 중';

  @override
  String get settingsMusicFolders => '음악 폴더';

  @override
  String get settingsQuality => '음질';

  @override
  String get settingsHistory => '기록';

  @override
  String get settingsBackupRestore => '백업 및 복구';

  @override
  String get settingsAutomatic => '자동';

  @override
  String get settingsDangerZone => '데이터 주의';

  @override
  String get settingsScrobbling => '스크로블링';

  @override
  String get settingsAuthentication => '인증';

  @override
  String get settingsHomeScreen => '홈 화면';

  @override
  String get settingsChartVisibility => '차트 표시 설정';

  @override
  String get settingsLocation => '위치';

  @override
  String get pluginRepositoryTitle => '플러-그인 저장소';

  @override
  String get pluginRepositorySubtitle => '원격 저장소를 추가하여 탐색하세요.';

  @override
  String get pluginRepositoryAddAction => '저장소 추가';

  @override
  String get pluginRepositoryAddTitle => '저장소 추가';

  @override
  String get pluginRepositoryAddSubtitle => '플러그인 저장소 JSON URL을 입력하세요.';

  @override
  String get pluginRepositoryEmpty => '추가된 저장소가 없습니다.';

  @override
  String get pluginRepositoryUrlCopied => '클립보드에 복사됨';

  @override
  String get pluginRepositoryNoDescription => '설명이 없습니다.';

  @override
  String get pluginRepositoryUnknownUpdate => '업데이트 정보 없음';

  @override
  String pluginRepositoryPluginsCount(int count) {
    return '플러그인 $count개';
  }

  @override
  String get pluginRepositoryErrorLoad => '저장소를 불러올 수 없습니다.';

  @override
  String get pluginRepositoryErrorInvalid => '잘못된 저장소 파일 형식입니다.';

  @override
  String get pluginRepositoryErrorRemove => '저장소 제거에 실패했습니다.';

  @override
  String pluginRepositoryError(String message) {
    return '오류: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => '다운로드 대기열에 추가 중';

  @override
  String get emptyNoInternet => '인터넷 연결 없음';

  @override
  String get emptyNoContentPlugin => '로드된 콘텐츠 플러그인이 없습니다. 설정에서 추가해 주세요.';

  @override
  String get emptyRefreshingSource => '소스를 새로고침하는 중...';

  @override
  String get emptyNoTracks => '곡이 없습니다';

  @override
  String get emptyNoResults => '결과가 없습니다';

  @override
  String snackbarDeletedTrack(String title) {
    return '\"$title\" 삭제됨';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '\"$title\" 삭제 실패';
  }

  @override
  String get snackbarAddedToNextQueue => '다음에 재생될 대기열에 추가됨';

  @override
  String get snackbarAddedToQueue => '대기열에 추가됨';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title 곡을 좋아함에 추가했습니다!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '$name 재생 중';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name 플레이리스트를 대기열에 추가함';
  }

  @override
  String get snackbarPlaylistQueued => '다운로드 대기열에 플레이리스트 추가됨';

  @override
  String get snackbarPlaylistUpdated => '플레이리스트 업데이트 완료!';

  @override
  String get snackbarNoInternet => '인터넷 연결이 원활하지 않습니다.';

  @override
  String get snackbarImportFailed => '가져오기 실패!';

  @override
  String get snackbarImportCompleted => '가져오기 완료';

  @override
  String get snackbarBackupFailed => '백업 실패!';

  @override
  String snackbarExportedTo(String path) {
    return '내보낸 경로: $path';
  }

  @override
  String get snackbarMediaIdCopied => '미디어 ID 복사됨';

  @override
  String get snackbarLinkCopied => '링크 복사됨';

  @override
  String get snackbarNoLinkAvailable => '사용 가능한 링크 없음';

  @override
  String get snackbarCouldNotOpenLink => '링크를 열 수 없습니다';

  @override
  String snackbarPreparingDownload(String title) {
    return '$title 다운로드 준비 중...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title 곡은 이미 다운로드되었습니다.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title 곡은 이미 대기열에 있습니다.';
  }

  @override
  String snackbarDownloaded(String title) {
    return '$title 다운로드 완료';
  }

  @override
  String get snackbarDownloadServiceUnavailable => '오류: 다운로드 서비스를 사용할 수 없습니다.';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count곡을 다운로드 대기열에 추가함';
  }

  @override
  String get snackbarDeleteTrackFailDevice => '기기 저장공간에서 삭제하지 못했습니다.';

  @override
  String get searchHintExplore => '어떤 음악을 듣고 싶으신가요?';

  @override
  String get searchHintLibrary => '보관함 검색...';

  @override
  String get searchHintOfflineMusic => '내 곡 검색...';

  @override
  String get searchHintPlaylists => '플레이리스트 검색...';

  @override
  String get searchStartTyping => '검색어를 입력하세요...';

  @override
  String get searchNoSuggestions => '추천 검색어가 없습니다';

  @override
  String get searchNoResults => '검색 결과가 없습니다.\n다른 키워드나 소스를 시도해 보세요.';

  @override
  String get searchFailed => '검색 실패';

  @override
  String get searchDiscover => '새로운 음악을 찾아보세요...';

  @override
  String get searchSources => '소스';

  @override
  String get searchNoPlugins => '설치된 플러그인이 없습니다';

  @override
  String get searchTracks => '곡';

  @override
  String get searchAlbums => '앨범';

  @override
  String get searchArtists => '아티스트';

  @override
  String get searchPlaylists => '플레이리스트';

  @override
  String get exploreDiscover => '둘러보기';

  @override
  String get exploreRecently => '최근 감상';

  @override
  String get exploreLastFmPicks => 'Last.Fm 추천';

  @override
  String get exploreFailedToLoad => '섹션을 불러오지 못했습니다.';

  @override
  String get libraryTitle => '보관함';

  @override
  String get libraryEmptyState => '보관함이 비어 있습니다. 좋아하는 음악을 채워보세요!';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName 수록';
  }

  @override
  String get menuAddToPlaylist => '플레이리스트에 추가';

  @override
  String get menuSmartReplace => '스마트 교체';

  @override
  String get menuShare => '공유';

  @override
  String get menuAvailableOffline => '오프라인 사용 가능';

  @override
  String get menuDownload => '다운로드';

  @override
  String get menuOpenOriginalLink => '원본 링크 열기';

  @override
  String get menuDeleteTrack => '삭제';

  @override
  String get songInfoTitle => '제목';

  @override
  String get songInfoArtist => '아티스트';

  @override
  String get songInfoAlbum => '앨범';

  @override
  String get songInfoMediaId => '미디어 ID';

  @override
  String get songInfoCopyId => 'ID 복사';

  @override
  String get songInfoCopyLink => '링크 복사';

  @override
  String get songInfoOpenBrowser => '브라우저에서 열기';

  @override
  String get tooltipRemoveFromLibrary => '보관함에서 제거';

  @override
  String get tooltipSaveToLibrary => '보관함에 저장';

  @override
  String get tooltipOpenOriginalLink => '원본 링크 열기';

  @override
  String get tooltipShuffle => '셔플';

  @override
  String get tooltipAvailableOffline => '오프라인 사용 가능';

  @override
  String get tooltipDownloadPlaylist => '플레이리스트 다운로드';

  @override
  String get tooltipMoreOptions => '추가 옵션';

  @override
  String get tooltipInfo => '정보';

  @override
  String get appuiTitle => 'UI 및 서비스';

  @override
  String get appuiAutoSlideCharts => '차트 자동 슬라이드';

  @override
  String get appuiAutoSlideChartsSubtitle => '홈 화면에서 차트를 자동으로 넘깁니다.';

  @override
  String get appuiLastFmPicksSubtitle => 'Last.FM 추천 곡을 표시합니다. (로그인 및 재시작 필요)';

  @override
  String get appuiNoChartsAvailable => '표시할 차트가 없습니다. 차트 제공 플러그인을 설치하세요.';

  @override
  String get appuiLoginToLastFm => '먼저 Last.FM에 로그인해 주세요.';

  @override
  String get appuiShowInCarousel => '홈 캐러셀에 표시';

  @override
  String get countrySettingTitle => '국가 및 언어';

  @override
  String get countrySettingAutoDetect => '국가 자동 감지';

  @override
  String get countrySettingAutoDetectSubtitle => '앱 실행 시 국가를 자동으로 감지합니다.';

  @override
  String get countrySettingCountryLabel => '국가';

  @override
  String get countrySettingLanguageLabel => '언어';

  @override
  String get countrySettingSystemDefault => '시스템 기본값';

  @override
  String get downloadSettingTitle => '다운로드';

  @override
  String get downloadSettingQuality => '다운로드 음질';

  @override
  String get downloadSettingQualitySubtitle => '다운로드 시 적용할 기본 음질 설정입니다.';

  @override
  String get downloadSettingFolder => '다운로드 폴더';

  @override
  String get downloadSettingResetFolder => '다운로드 폴더 재설정';

  @override
  String get downloadSettingResetFolderSubtitle => '기본 다운로드 경로로 복원합니다.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => '트랙 스크로블';

  @override
  String get lastfmScrobbleTracksSubtitle => '재생한 곡을 Last.FM 프로필에 기록합니다.';

  @override
  String get lastfmAuthFirst => '먼저 Last.FM API 인증을 진행하세요.';

  @override
  String get lastfmAuthenticatedAs => '인증된 계정:';

  @override
  String get lastfmAuthFailed => '인증 실패:';

  @override
  String get lastfmNotAuthenticated => '인증되지 않음';

  @override
  String get lastfmSteps =>
      '인증 단계:\n1. last.fm 계정 생성/로그인\n2. last.fm/api/account/create에서 API Key 생성\n3. API Key와 Secret 입력\n4. \'인증 시작\' 클릭 후 브라우저에서 승인\n5. \'세션 키 저장\' 클릭하여 완료';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. 인증 시작';

  @override
  String get lastfmGetSession => '2. 세션 키 저장';

  @override
  String get lastfmRemoveKeys => '키 삭제';

  @override
  String get lastfmStartAuthFirst => '먼저 인증을 시작하고 브라우저에서 승인해 주세요.';

  @override
  String get localSettingTitle => '로컬 트랙';

  @override
  String get localSettingAutoScan => '시작 시 자동 스캔';

  @override
  String get localSettingAutoScanSubtitle => '앱을 열 때마다 새로운 로컬 파일을 스캔합니다.';

  @override
  String get localSettingLastScan => '최근 스캔';

  @override
  String get localSettingNeverScanned => '기록 없음';

  @override
  String get localSettingScanInProgress => '스캔 중…';

  @override
  String get localSettingScanNowSubtitle => '전체 라이브러리를 수동으로 스캔합니다.';

  @override
  String get localSettingNoFolders => '추가된 폴더가 없습니다. 폴더를 추가하여 스캔을 시작하세요.';

  @override
  String get localSettingAddFolder => '폴더 추가';

  @override
  String get playerSettingTitle => '플레이어 설정';

  @override
  String get playerSettingStreamingHeader => '스트리밍';

  @override
  String get playerSettingStreamQuality => '스트리밍 음질';

  @override
  String get playerSettingStreamQualitySubtitle => '온라인 재생 시 적용할 기본 비트레이트입니다.';

  @override
  String get playerSettingQualityLow => '낮음';

  @override
  String get playerSettingQualityMedium => '중간';

  @override
  String get playerSettingQualityHigh => '높음';

  @override
  String get playerSettingPlaybackHeader => '재생';

  @override
  String get playerSettingAutoPlay => '자동 재생';

  @override
  String get playerSettingAutoPlaySubtitle => '대기열이 끝나면 유사한 곡을 자동으로 추가합니다.';

  @override
  String get playerSettingAutoFallback => '자동 폴백 재생';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      '사용 중인 플러그인에 오류가 있을 시 다른 호환 소스를 찾습니다.';

  @override
  String get playerSettingCrossfade => '크로스페이드';

  @override
  String get playerSettingCrossfadeOff => '꺼짐';

  @override
  String get playerSettingCrossfadeInstant => '곡 전환 즉시';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return '트랙 간 $seconds초 페이드 적용';
  }

  @override
  String get playerSettingEqualizer => '이퀄라이저';

  @override
  String get playerSettingEqualizerActive => '활성화됨';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return '활성화됨 — $preset 프리셋';
  }

  @override
  String get playerSettingEqualizerSubtitle => 'FFmpeg 기반 10밴드 파라메트릭 EQ입니다.';

  @override
  String get pluginDefaultsTitle => '플러그인 기본 설정';

  @override
  String get pluginDefaultsDiscoverHeader => '검색 소스';

  @override
  String get pluginDefaultsNoResolver =>
      '콘텐츠 플러그인이 없습니다. 소스를 선택하려면 플러그인을 설치하세요.';

  @override
  String get pluginDefaultsAutomaticSubtitle => '사용 가능한 첫 번째 소스를 사용합니다.';

  @override
  String get pluginDefaultsPriorityHeader => '소스 우선순위';

  @override
  String get pluginDefaultsNoPriority => '플러그인을 로드하면 드래그하여 우선순위를 정할 수 있습니다.';

  @override
  String get pluginDefaultsPriorityDesc =>
      '드래그하여 순서를 변경하세요. 상단에 있을수록 재생 시 먼저 사용됩니다.';

  @override
  String get pluginDefaultsLyricsHeader => '가사 우선순위';

  @override
  String get pluginDefaultsLyricsNone => '설치된 가사 소스가 없습니다.';

  @override
  String get pluginDefaultsLyricsDesc => '가사를 가져올 서비스의 순서를 정하세요.';

  @override
  String get pluginDefaultsSuggestionsHeader => '검색어 추천';

  @override
  String get pluginDefaultsSuggestionsNone => '설치된 추천 검색어 소스가 없습니다.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => '없음';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle => '검색 기록만 사용합니다.';

  @override
  String get storageSettingTitle => '저장공간';

  @override
  String get storageClearHistoryEvery => '기록 삭제 주기';

  @override
  String get storageClearHistorySubtitle => '일정 기간이 지난 청취 기록을 자동으로 삭제합니다.';

  @override
  String storageDays(int count) {
    return '$count일';
  }

  @override
  String get storageBackupLocation => '백업 위치';

  @override
  String get storageBackupLocationAndroid => '다운로드 / 앱 데이터 디렉토리';

  @override
  String get storageBackupLocationDownloads => '다운로드 디렉토리';

  @override
  String get storageCreateBackup => '백업 생성';

  @override
  String get storageCreateBackupSubtitle => '설정 및 데이터를 백업 파일로 저장합니다.';

  @override
  String storageBackupCreatedAt(String path) {
    return '백업 생성 위치: $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return '백업 공유 실패: $error';
  }

  @override
  String get storageBackupFailed => '백업 실패!';

  @override
  String get storageRestoreBackup => '백업 복구';

  @override
  String get storageRestoreBackupSubtitle => '백업 파일로부터 데이터와 설정을 복원합니다.';

  @override
  String get storageAutoBackup => '자동 백업';

  @override
  String get storageAutoBackupSubtitle => '정기적으로 데이터 백업을 자동 생성합니다.';

  @override
  String get storageAutoLyrics => '가사 자동 저장';

  @override
  String get storageAutoLyricsSubtitle => '재생 시 가사를 자동으로 기기에 저장합니다.';

  @override
  String get storageResetApp => '앱 초기화';

  @override
  String get storageResetAppSubtitle => '모든 데이터를 삭제하고 초기 상태로 되돌립니다.';

  @override
  String get storageResetConfirmTitle => '초기화 확인';

  @override
  String get storageResetConfirmMessage =>
      '정말로 초기화하시겠습니까? 모든 데이터가 삭제되며 복구할 수 없습니다.';

  @override
  String get storageResetButton => '초기화';

  @override
  String get storageResetSuccess => '앱이 초기 상태로 재설정되었습니다.';

  @override
  String get storageLocationDialogTitle => '백업 위치';

  @override
  String get storageLocationAndroid =>
      '백업 파일은 다음 위치에 저장됩니다:\n\n1. 다운로드 폴더\n2. Android/data/ls.bloomee.musicplayer/data\n\n해당 위치에서 파일을 확인하세요.';

  @override
  String get storageLocationOther => '백업은 다운로드 폴더에 저장됩니다.';

  @override
  String get storageRestoreOptionsTitle => '복구 옵션';

  @override
  String get storageRestoreOptionsDesc =>
      '백업 파일에서 복원할 항목을 선택하세요. 제외할 항목은 선택을 해제해 주세요.';

  @override
  String get storageRestoreSelectAll => '모두 선택';

  @override
  String get storageRestoreMediaItems => '미디어 항목 (곡, 트랙, 보관함 데이터)';

  @override
  String get storageRestoreSearchHistory => '검색 기록';

  @override
  String get storageRestoreContinue => '계속';

  @override
  String get storageRestoreNoFile => '선택된 파일이 없습니다.';

  @override
  String get storageRestoreSaveFailed => '선택한 파일을 저장하지 못했습니다.';

  @override
  String get storageRestoreConfirmTitle => '복구 진행 확인';

  @override
  String get storageRestoreConfirmPrefix => '다음 선택 항목들이 백업 데이터로 병합 또는 교체됩니다:';

  @override
  String get storageRestoreConfirmSuffix => '현재 데이터가 수정됩니다. 계속하시겠습니까?';

  @override
  String get storageRestoreYes => '네, 복구합니다';

  @override
  String get storageRestoreNo => '아니요';

  @override
  String get storageRestoring => '데이터를 복구하는 중…\n잠시만 기다려 주세요.';

  @override
  String get storageRestoreMediaBullet => '• 미디어 항목';

  @override
  String get storageRestoreHistoryBullet => '• 검색 기록';

  @override
  String get storageUnexpectedError => '복구 중 예상치 못한 오류가 발생했습니다.';

  @override
  String get storageRestoreCompleted => '복구 완료';

  @override
  String get storageRestoreFailedTitle => '복구 실패';

  @override
  String get storageRestoreSuccessMessage =>
      '데이터가 성공적으로 복구되었습니다. 변경 사항을 적용하려면 앱을 재시작해 주세요.';

  @override
  String get storageRestoreFailedMessage => '복구 과정에서 다음 오류가 발생했습니다:';

  @override
  String get storageRestoreUnknownError => '알 수 없는 복구 오류 발생.';

  @override
  String get storageRestoreRestartHint => '안정적인 적용을 위해 앱을 재시작해 주세요.';

  @override
  String get updateSettingTitle => '업데이트';

  @override
  String get updateAppUpdatesHeader => '앱 업데이트';

  @override
  String get updateCheckForUpdates => '업데이트 확인';

  @override
  String get updateCheckSubtitle => '최신 버전이 있는지 확인합니다.';

  @override
  String get updateAutoNotify => '업데이트 자동 알림';

  @override
  String get updateAutoNotifySubtitle => '새 버전이 있을 시 앱 시작 시 알려줍니다.';

  @override
  String get updateCheckTitle => '버전 확인';

  @override
  String get updateUpToDate => '최신 버전입니다!';

  @override
  String get updateViewPreRelease => '최신 프리릴리즈 확인';

  @override
  String updateCurrentVersion(String curr, String build) {
    return '현재 버전: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => '새로운 버전의 Bloomee🌸가 출시되었습니다!';

  @override
  String updateVersion(String ver, String build) {
    return '버전: $ver+$build';
  }

  @override
  String get updateDownloadNow => '지금 다운로드';

  @override
  String get updateChecking => '업데이트 확인 중...';

  @override
  String get timerTitle => '취침 예약';

  @override
  String get timerInterludeMessage => '잠시 후 음악이 멈춥니다…';

  @override
  String get timerHours => '시간';

  @override
  String get timerMinutes => '분';

  @override
  String get timerSeconds => '초';

  @override
  String get timerStop => '타이머 중지';

  @override
  String get timerFinishedMessage => '음악이 멈췄습니다. 좋은 꿈 꾸세요 🥰.';

  @override
  String get timerGotIt => '확인';

  @override
  String get timerSetTimeError => '시간을 설정해 주세요';

  @override
  String get timerStart => '타이머 시작';

  @override
  String get notificationsTitle => '알림';

  @override
  String get notificationsEmpty => '새로운 알림이 없습니다';

  @override
  String get recentsTitle => '감상 기록';

  @override
  String playlistByCreator(String creator) {
    return '$creator 작성';
  }

  @override
  String get playlistTypeAlbum => '앨범';

  @override
  String get playlistTypePlaylist => '플레이리스트';

  @override
  String get playlistYou => '사용자';

  @override
  String get pluginManagerTitle => '플러그인';

  @override
  String get pluginManagerEmpty => '설치된 플러그인이 없습니다.\n+ 아이콘을 눌러 .bex 파일을 추가하세요.';

  @override
  String get pluginManagerFilterAll => '전체';

  @override
  String get pluginManagerFilterContent => '콘텐츠 소스';

  @override
  String get pluginManagerFilterCharts => '차트 제공';

  @override
  String get pluginManagerFilterLyrics => '가사 제공';

  @override
  String get pluginManagerFilterSuggestions => '검색어 추천';

  @override
  String get pluginManagerFilterImporters => '데이터 가져오기';

  @override
  String get pluginManagerTooltipRefresh => '새로고침';

  @override
  String get pluginManagerTooltipInstall => '플러그인 설치';

  @override
  String get pluginManagerNoMatch => '일치하는 플러그인이 없습니다';

  @override
  String pluginManagerPickFailed(String error) {
    return '파일 선택 실패: $error';
  }

  @override
  String get pluginManagerInstalling => '플러그인 설치 중...';

  @override
  String get pluginManagerTypeContentResolver => '콘텐츠 리졸버';

  @override
  String get pluginManagerTypeChartProvider => '차트 제공자';

  @override
  String get pluginManagerTypeLyricsProvider => '가사 제공자';

  @override
  String get pluginManagerTypeSuggestionProvider => '검색어 추천';

  @override
  String get pluginManagerTypeContentImporter => '콘텐츠 임포터';

  @override
  String get pluginManagerDeleteTitle => '플러그인 삭제';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '\"$name\"을(를) 정말 삭제하시겠습니까?';
  }

  @override
  String get pluginManagerDeleteAction => '삭제';

  @override
  String get pluginManagerCancel => '취소';

  @override
  String get pluginManagerEnablePlugin => '플러그인 활성화';

  @override
  String get pluginManagerUnloadPlugin => '플러그인 해제';

  @override
  String get pluginManagerDeleting => '삭제 중...';

  @override
  String get pluginManagerApiKeysTitle => 'API 키';

  @override
  String get pluginManagerApiKeysSaved => 'API 키 저장됨';

  @override
  String get pluginManagerSave => '저장';

  @override
  String get pluginManagerDetailVersion => '버전';

  @override
  String get pluginManagerDetailType => '유형';

  @override
  String get pluginManagerDetailPublisher => '게시자';

  @override
  String get pluginManagerDetailLastUpdated => '최근 업데이트';

  @override
  String get pluginManagerDetailCreated => '생성일';

  @override
  String get pluginManagerDetailHomepage => '홈페이지';

  @override
  String get pluginManagerDowngradeTitle => '다운그레이드하시겠습니까?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return '이미 설치된 버전보다 낮거나 같은 버전을 설치하려고 합니다. 계속하시겠습니까?';
  }

  @override
  String get pluginManagerDowngradeAction => '무시하고 설치';

  @override
  String get pluginManagerDeleteStorageTitle => '데이터도 삭제하시겠습니까?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '\"$name\"에 저장된 API 키와 설정 데이터도 삭제할까요?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => '데이터 유지';

  @override
  String get pluginManagerDeleteStorageRemove => '데이터 삭제';

  @override
  String get segmentsSheetTitle => '구간 정보';

  @override
  String get segmentsSheetEmpty => '사용 가능한 구간이 없습니다';

  @override
  String get segmentsSheetUntitled => '제목 없는 구간';

  @override
  String get smartReplaceTitle => '스마트 교체';

  @override
  String smartReplaceSubtitle(String title) {
    return '\"$title\" 트랙을 대체할 재생 가능한 곡을 찾아 플레이리스트 정보를 업데이트합니다.';
  }

  @override
  String get smartReplaceClose => '닫기';

  @override
  String get smartReplaceNoMatch => '대체 항목을 찾지 못함';

  @override
  String get smartReplaceNoMatchSubtitle => '로드된 플러그인 중 충분히 일치하는 곡이 없습니다.';

  @override
  String get smartReplaceBestMatch => '가장 유사한 곡';

  @override
  String get smartReplaceSearchFailed => '검색 실패';

  @override
  String smartReplaceApplyFailed(String error) {
    return '교체 실패: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return '대체 곡이 적용되었습니다$queue.';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '$count개의 플레이리스트에서 교체됨$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' (대기열 포함)';

  @override
  String get playerUnknownQueue => '알 수 없음';

  @override
  String playerLiked(String title) {
    return '$title 곡을 좋아함에 추가했습니다!';
  }

  @override
  String playerUnliked(String title) {
    return '$title 곡을 좋아함에서 해제했습니다!';
  }

  @override
  String get offlineNoDownloads => '다운로드한 곡 없음';

  @override
  String get offlineTitle => '오프라인';

  @override
  String get offlineSearchHint => '내 곡 검색...';

  @override
  String get offlineRefreshTooltip => '목록 새로고침';

  @override
  String get offlineCloseSearch => '검색 닫기';

  @override
  String get offlineSearchTooltip => '검색';

  @override
  String get offlineOpenFailed => '오프라인 트랙을 열 수 없습니다. 새로고침 후 다시 시도해 주세요.';

  @override
  String get offlinePlayFailed => '재생할 수 없습니다.';

  @override
  String albumViewTrackCount(int count) {
    return '곡 $count개';
  }

  @override
  String get albumViewLoadFailed => '앨범 정보를 불러오지 못했습니다';

  @override
  String get aboutCraftingSubtitle => '코드로 음악적 감성을 만듭니다.';

  @override
  String get aboutFollowGitHub => 'GitHub 팔로우';

  @override
  String get aboutSendInquiry => '비즈니스 문의';

  @override
  String get aboutCreativeHighlights => '업데이트 및 주요 소식';

  @override
  String get aboutTipQuote => 'Bloomee가 마음에 드시나요? 소중한 후원이 더 멋진 발전을 만듭니다. 🌸';

  @override
  String get aboutTipButton => '후원하기';

  @override
  String get aboutTipDesc => '지속적인 앱 개선에 힘을 보태주세요.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => '곡 정보';

  @override
  String get songInfoSectionTechnical => '기술적 정보';

  @override
  String get songInfoSectionActions => '작업';

  @override
  String get songInfoLabelTitle => '제목';

  @override
  String get songInfoLabelArtist => '아티스트';

  @override
  String get songInfoLabelAlbum => '앨범';

  @override
  String get songInfoLabelDuration => '길이';

  @override
  String get songInfoLabelSource => '소스';

  @override
  String get songInfoLabelMediaId => '미디어 ID';

  @override
  String get songInfoLabelPluginId => '플러그인 ID';

  @override
  String get songInfoIdCopied => '미디어 ID 복사됨';

  @override
  String get songInfoLinkCopied => '링크 복사됨';

  @override
  String get songInfoNoLink => '사용 가능한 링크 없음';

  @override
  String get songInfoOpenFailed => '링크를 열지 못했습니다';

  @override
  String get songInfoUpdateMetadata => '최신 메타데이터 가져오기';

  @override
  String get songInfoMetadataUpdated => '정보 업데이트 완료';

  @override
  String get songInfoMetadataUpdateFailed => '정보 업데이트 실패';

  @override
  String get songInfoMetadataUnavailable => '이 소스는 정보 새로고침을 지원하지 않습니다';

  @override
  String get songInfoSearchTitle => '이 노래로 검색';

  @override
  String get songInfoSearchArtist => '이 아티스트로 검색';

  @override
  String get songInfoSearchAlbum => '이 앨범으로 검색';

  @override
  String get eqTitle => '이퀄라이저';

  @override
  String get eqResetTooltip => '플랫(기본값)으로 초기화';

  @override
  String get chartNoItems => '차트 데이터가 없습니다';

  @override
  String get chartLoadFailed => '차트를 불러오지 못했습니다';

  @override
  String get chartPlay => '재생';

  @override
  String get chartResolving => '곡 매칭 중';

  @override
  String get chartReady => '준비 완료';

  @override
  String get chartAddToPlaylist => '플레이리스트에 추가';

  @override
  String get chartNoResolver => '재생을 위한 콘텐츠 플러그인이 없습니다.';

  @override
  String get chartResolveFailed => '곡을 찾지 못해 직접 검색으로 전환합니다...';

  @override
  String get chartNoResolverAdd => '설치된 플러그인이 없습니다.';

  @override
  String get chartNoMatch => '일치하는 곡이 없습니다. 수동 검색을 사용해 주세요.';

  @override
  String get chartStatPeak => '최고';

  @override
  String get chartStatWeeks => '주간';

  @override
  String get chartStatChange => '변동';

  @override
  String menuSharePreparing(String title) {
    return '$title 공유 준비 중...';
  }

  @override
  String get menuOpenLinkFailed => '링크를 열 수 없습니다';

  @override
  String get localMusicFolders => '음악 폴더';

  @override
  String get localMusicCloseSearch => '검색 닫기';

  @override
  String get localMusicOpenSearch => '검색';

  @override
  String get localMusicNoMusicFound => '로컬 음악이 없습니다';

  @override
  String get localMusicNoSearchResults => '검색 결과가 없습니다.';

  @override
  String get importSongsTitle => '곡 가져오기';

  @override
  String get importNoPluginsLoaded =>
      '가져오기 플러그인이 없습니다. 외부 플레이리스트를 가져오려면 플러그인을 설치하세요.';

  @override
  String get importBloomeeFiles => 'Bloomee 파일 가져오기';

  @override
  String get importM3UFiles => 'M3U 플레이리스트 가져오기';

  @override
  String get importM3UNameDialogTitle => '플레이리스트 이름';

  @override
  String get importM3UNameHint => '이름을 입력하세요';

  @override
  String get importM3UNoTracks => 'M3U 파일에서 유효한 곡을 찾지 못했습니다.';

  @override
  String get importNoteTitle => '주의';

  @override
  String get importNoteMessage =>
      'Bloomee에서 생성한 파일만 정상적으로 가져올 수 있습니다. 계속하시겠습니까?';

  @override
  String get importTitle => '가져오기';

  @override
  String get importCheckingUrl => 'URL 확인 중...';

  @override
  String get importFetchingTracks => '곡 목록 가져오는 중...';

  @override
  String get importSavingToLibrary => '보관함에 저장 중...';

  @override
  String get importPasteUrlHint => '가져올 플레이리스트 또는 앨범 URL 입력';

  @override
  String get importAction => '가져오기';

  @override
  String importTrackCount(int count) {
    return '곡 $count개';
  }

  @override
  String get importResolving => '곡 매칭 중...';

  @override
  String importResolvingProgress(int done, int total) {
    return '매칭 중: $done / $total';
  }

  @override
  String get importReviewTitle => '가져오기 결과 검토';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '총 $total곡 중 $resolved곡 성공, $failed곡 실패';
  }

  @override
  String importSaveTracks(int count) {
    return '$count곡 저장';
  }

  @override
  String importTracksSaved(int count) {
    return '$count곡 저장됨!';
  }

  @override
  String get importDone => '완료';

  @override
  String get importMore => '추가 가져오기';

  @override
  String get importUnknownError => '알 수 없는 오류';

  @override
  String get importTryAgain => '다시 시도';

  @override
  String get importSkipTrack => '이 트랙 건너뛰기';

  @override
  String get importMatchOptions => '매치 옵션';

  @override
  String get importAutoMatched => '자동 매칭됨';

  @override
  String get importUserSelected => '선택됨';

  @override
  String get importSkipped => '건너뜀';

  @override
  String get importNoMatch => '일치 항목 없음';

  @override
  String get importReorderTip => '길게 눌러 순서를 변경하세요';

  @override
  String get importErrorCannotHandleUrl => '이 플러그인이 처리할 수 없는 URL입니다.';

  @override
  String get importErrorUnexpectedResponse => '플러그인에서 예상치 못한 응답을 받았습니다.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'URL 확인 실패: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return '정보 가져오기 실패: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return '곡 가져오기 실패: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return '플레이리스트 저장 실패: $error';
  }

  @override
  String get playlistPinToTop => '맨 위에 고정';

  @override
  String get playlistUnpin => '고정 해제';

  @override
  String get snackbarImportingMedia => '미디어 항목 가져오는 중...';

  @override
  String get snackbarPlaylistSaved => '보관함에 저장 완료!';

  @override
  String get snackbarInvalidFileFormat => '유효하지 않은 파일 형식';

  @override
  String get snackbarMediaItemImported => '미디어 항목 가져오기 완료';

  @override
  String get snackbarPlaylistImported => '플레이리스트 가져오기 완료';

  @override
  String get snackbarOpenImportForUrl => '보관함의 \'가져오기\' 메뉴를 통해 URL을 추가하세요.';

  @override
  String get snackbarProcessingFile => '파일 처리 중...';

  @override
  String snackbarPreparingShare(String title) {
    return '$title 공유 준비 중';
  }

  @override
  String snackbarPreparingExport(String title) {
    return '$title 내보내기 준비 중...';
  }

  @override
  String get pluginManagerTabInstalled => '설치됨';

  @override
  String get pluginManagerTabStore => '플러그인 스토어';

  @override
  String get pluginManagerSelectPackage => '플러그인 패키지(.bex) 선택';

  @override
  String get pluginManagerOutdatedManifest => '오래된 버전의 플러그인입니다. 업데이트를 권장합니다.';

  @override
  String get pluginManagerStatusActive => '활성';

  @override
  String get pluginManagerStatusInactive => '비활성';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return '$date 업데이트됨';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    return '$count개의 플러그인 설치 가능';
  }

  @override
  String get pluginRepositoryOutdatedManifest => '매니페스트 버전이 낮아 기능이 제한될 수 있습니다.';

  @override
  String get pluginRepositoryUnknownPublisher => '알 수 없는 게시자';

  @override
  String get pluginRepositoryActionRetry => '다시 시도';

  @override
  String get pluginRepositoryActionOutdated => '업데이트 필요';

  @override
  String get pluginRepositoryActionInstalled => '설치됨';

  @override
  String get pluginRepositoryActionInstall => '설치';

  @override
  String get pluginRepositoryActionUnavailable => '사용 불가';

  @override
  String get pluginRepositoryInstallFailed => '설치에 실패했습니다.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name 다운로드 실패.';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    return '$count개의 플레이리스트에서 곡이 교체되었습니다$queue.';
  }

  @override
  String get lyricsSearchFieldLabel => '가사 검색...';

  @override
  String get lyricsSearchEmptyPrompt => '곡명 또는 아티스트명을 입력해 가사를 찾으세요.';

  @override
  String lyricsSearchNoResults(String query) {
    return '\"$query\"에 대한 가사가 없습니다';
  }

  @override
  String get lyricsSearchApplied => '가사 적용 완료';

  @override
  String get lyricsSearchFetchFailed => '가사를 가져오지 못했습니다';

  @override
  String get lyricsSearchPreview => '미리보기';

  @override
  String get lyricsSearchPreviewTooltip => '가사 미리보기';

  @override
  String get lyricsSearchSynced => '동기화됨';

  @override
  String get lyricsSearchPreviewLoadFailed => '가사를 불러오지 못했습니다.';

  @override
  String get lyricsSearchApplyAction => '가사 적용';

  @override
  String get lyricsSettingsSearchTitle => '커스텀 가사 검색';

  @override
  String get lyricsSettingsSearchSubtitle => '온라인에서 다른 가사 찾기';

  @override
  String get lyricsSettingsSyncTitle => '동기화 조절 (지연/오프셋)';

  @override
  String get lyricsSettingsSyncSubtitle => '가사 싱크가 맞지 않을 때 수정하세요';

  @override
  String get lyricsSettingsSaveTitle => '오프라인 저장';

  @override
  String get lyricsSettingsSaveSubtitle => '가사를 기기에 저장합니다';

  @override
  String get lyricsSettingsDeleteTitle => '저장된 가사 삭제';

  @override
  String get lyricsSettingsDeleteSubtitle => '저장된 오프라인 가사 데이터 삭제';

  @override
  String get lyricsSyncTapToReset => '초기화하려면 탭하세요';

  @override
  String get upNextTitle => '다음 재생 예정';

  @override
  String upNextItemsInQueue(int count) {
    return '대기열에 $count곡 있음';
  }

  @override
  String get upNextAutoPlay => '자동 재생';

  @override
  String get tooltipCopyToClipboard => '클립보드에 복사';

  @override
  String get snackbarCopiedToClipboard => '복사되었습니다';

  @override
  String get tooltipSongInfo => '곡 정보';

  @override
  String get snackbarCannotDeletePlayingSong => '현재 재생 중인 곡은 삭제할 수 없습니다';

  @override
  String get playerLoopOff => '반복 안 함';

  @override
  String get playerLoopOne => '한 곡 반복';

  @override
  String get playerLoopAll => '전체 반복';

  @override
  String get snackbarOpeningAlbumPage => '원본 앨범 페이지를 엽니다.';

  @override
  String updateAvailableBody(String ver, String build) {
    return '새로운 버전의 Bloomee🌸가 출시되었습니다!\n\n버전: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return '플러그인 \"$id\" 설치됨';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return '플러그인 \"$id\" 로드됨';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return '플러그인 \"$id\" 삭제됨';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee 설정 중';

  @override
  String pluginBootstrapProgress(int percent) {
    return '플러그인 엔진 설정 중... $percent%';
  }

  @override
  String get pluginBootstrapHint => '이 과정은 처음 한 번만 진행됩니다.';

  @override
  String get pluginBootstrapErrorTitle => '연결 지연';

  @override
  String get pluginBootstrapErrorBody =>
      '일부 플러그인 설치에 실패했습니다. 다음 실행 시 다시 시도합니다.';

  @override
  String get pluginBootstrapContinue => '무시하고 계속';
}
