// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get onboardingTitle => 'Bloomee\'ye hoş geldiniz';

  @override
  String get onboardingSubtitle => 'Dilinizi ve bölgenizi seçin.';

  @override
  String get continueButton => 'Devam';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navLibrary => 'Kitaplık';

  @override
  String get navSearch => 'Ara';

  @override
  String get navLocal => 'Cihazdaki müzikler';

  @override
  String get navOffline => 'Çevrimdışı';

  @override
  String get playerEnjoyingFrom => 'Çalınan kaynak';

  @override
  String get playerPlayWithMix => 'Otomatik karışımla çal';

  @override
  String get playerPlayNext => 'Sıradaki olarak çal';

  @override
  String get playerAddToQueue => 'Sıraya ekle';

  @override
  String get playerAddToFavorites => 'Favorilere ekle';

  @override
  String get playerNoLyricsFound => 'Şarkı sözü bulunamadı';

  @override
  String get playerLyricsNoPlugin =>
      'Şarkı sözü sağlayıcısı ayarlanmamış. Yüklemek için Ayarlar → Eklentiler bölümüne gidin.';

  @override
  String get localMusicTitle => 'Cihazdaki müzikler';

  @override
  String get localMusicGrantPermission => 'İzin ver';

  @override
  String get localMusicStorageAccessRequired => 'Depolama erişimi gerekli';

  @override
  String get localMusicStorageAccessDesc =>
      'Cihazınızdaki ses dosyalarını taramak ve çalmak için erişim izni verin.';

  @override
  String get localMusicAddFolder => 'Müzik klasörü ekle';

  @override
  String get localMusicScanNow => 'Şimdi tara';

  @override
  String localMusicScanFailed(String message) {
    return 'Tarama başarısız: $message';
  }

  @override
  String get localMusicScanning => 'Cihazdaki ses dosyaları taranıyor…';

  @override
  String get localMusicShuffle => 'Karıştır';

  @override
  String get localMusicPlayAll => 'Tümünü çal';

  @override
  String get localMusicSearchHint => 'Cihazdaki müziklerde ara…';

  @override
  String get localMusicRescanDevice => 'Cihazı yeniden tara';

  @override
  String get buttonCancel => 'İptal';

  @override
  String get buttonDelete => 'Sil';

  @override
  String get buttonOk => 'Tamam';

  @override
  String get buttonUpdate => 'Güncelle';

  @override
  String get buttonDownload => 'İndir';

  @override
  String get buttonLater => 'Daha sonra';

  @override
  String get buttonInfo => 'Bilgi';

  @override
  String get buttonMore => 'Diğer';

  @override
  String get dialogDeleteTrack => 'Parçayı sil';

  @override
  String dialogDeleteTrackMessage(String title) {
    return '“$title” cihazınızdan silinsin mi? Bu işlem geri alınamaz.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Bu parça şuralardan da kaldırılacak:';

  @override
  String get dialogDontAskAgain => 'Bir daha sorma';

  @override
  String get dialogUpdateAvailable => 'Güncelleme mevcut';

  @override
  String get dialogUpdateNow => 'Şimdi güncelle';

  @override
  String get dialogDownloadPlaylist => 'Çalma listesini indir';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '“$title” listesindeki $count şarkı indirilsin mi? Şarkılar indirme sırasına eklenecek.';
  }

  @override
  String get dialogDownloadAll => 'Tümünü indir';

  @override
  String get playlistEdit => 'Çalma listesini düzenle';

  @override
  String get playlistShareFile => 'Dosyayı paylaş';

  @override
  String get playlistExportFile => 'Dosyayı dışa aktar';

  @override
  String get playlistPlay => 'Çal';

  @override
  String get playlistAddToQueue => 'Çalma listesini sıraya ekle';

  @override
  String get playlistShare => 'Çalma listesini paylaş';

  @override
  String get playlistDelete => 'Çalma listesini sil';

  @override
  String get playlistEmptyState => 'Henüz şarkı yok';

  @override
  String get playlistAvailableOffline => 'Çevrimdışı kullanılabilir';

  @override
  String get playlistShuffle => 'Karıştır';

  @override
  String get playlistNoMatchSearch => 'Aramanızla eşleşen çalma listesi yok';

  @override
  String get playlistCreateNew => 'Çalma listesi oluştur';

  @override
  String get playlistCreateFirstOne =>
      'Henüz çalma listesi yok. Başlamak için bir tane oluşturun.';

  @override
  String get addToPlaylistNoSongSelected => 'Şarkı seçilmedi';

  @override
  String get createPlaylistDialogBarrierLabel =>
      'Çalma listesi oluşturma penceresi';

  @override
  String get createPlaylistDialogNameHint => 'Yaz şarkıları';

  @override
  String get createPlaylistDialogCreate => 'Oluştur';

  @override
  String playlistSongCount(int count) {
    return '$count şarkı';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title, $playlist listesinden kaldırıldı';
  }

  @override
  String get playlistFailedToLoad => 'Çalma listesi yüklenemedi';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsPlugins => 'Eklentiler';

  @override
  String get settingsPluginsSubtitle =>
      'Eklentileri yükleyin, etkinleştirin ve yönetin.';

  @override
  String get settingsUpdates => 'Güncellemeler';

  @override
  String get settingsUpdatesSubtitle => 'Yeni güncellemeleri denetleyin';

  @override
  String get settingsDownloads => 'İndirilenler';

  @override
  String get settingsDownloadsSubtitle =>
      'İndirme klasörü, ses kalitesi ve diğer seçenekler';

  @override
  String get settingsLocalTracks => 'Cihazdaki parçalar';

  @override
  String get settingsLocalTracksSubtitle =>
      'Müzik taraması, klasörler ve otomatik tarama ayarları';

  @override
  String get settingsPlayer => 'Oynatıcı ayarları';

  @override
  String get settingsPlayerSubtitle =>
      'Ses kalitesi, otomatik oynatma ve diğer seçenekler';

  @override
  String get settingsPluginDefaults => 'Varsayılan eklentiler';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Keşfet kaynağı ve kaynak çözümleyici önceliği';

  @override
  String get settingsUIElements => 'Arayüz ve hizmetler';

  @override
  String get settingsUIElementsSubtitle =>
      'Otomatik kaydırma ve arayüz ayarları';

  @override
  String get settingsLastFM => 'Last.fm ayarları';

  @override
  String get settingsLastFMSubtitle =>
      'API anahtarları ve dinleme geçmişi gönderimi';

  @override
  String get settingsStorage => 'Depolama';

  @override
  String get settingsStorageSubtitle =>
      'Yedekleme, önbellek, geçmiş ve geri yükleme';

  @override
  String get settingsLanguageCountry => 'Dil ve ülke';

  @override
  String get settingsLanguageCountrySubtitle => 'Dilinizi ve ülkenizi seçin.';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsAboutSubtitle =>
      'Uygulama, sürüm ve geliştirici bilgileri';

  @override
  String get settingsScanning => 'Tarama';

  @override
  String get settingsMusicFolders => 'Müzik klasörleri';

  @override
  String get settingsQuality => 'Kalite';

  @override
  String get settingsHistory => 'Geçmiş';

  @override
  String get settingsBackupRestore => 'Yedekleme ve geri yükleme';

  @override
  String get settingsAutomatic => 'Otomatik';

  @override
  String get settingsDangerZone => 'Sıfırlama işlemleri';

  @override
  String get settingsScrobbling => 'Dinleme geçmişi gönderimi';

  @override
  String get settingsAuthentication => 'Kimlik doğrulama';

  @override
  String get settingsHomeScreen => 'Ana ekran';

  @override
  String get settingsChartVisibility => 'Liste görünürlüğü';

  @override
  String get dialogAddingToDownloadQueue => 'İndirme sırasına ekleniyor';

  @override
  String get emptyNoInternet => 'İnternet bağlantısı yok';

  @override
  String get emptyNoContentPlugin =>
      'Etkin içerik çözümleyici yok. Eklenti yöneticisinden birini etkinleştirin.';

  @override
  String get emptyRefreshingSource =>
      'Keşfet kaynağı yenileniyor… Önceki kaynak artık kullanılamıyor.';

  @override
  String get emptyNoTracks => 'Kullanılabilir parça yok';

  @override
  String get emptyNoResults => 'Eşleşme bulunamadı';

  @override
  String snackbarDeletedTrack(String title) {
    return '“$title” silindi';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '“$title” silinemedi';
  }

  @override
  String get snackbarAddedToNextQueue => 'Sıradaki olarak eklendi';

  @override
  String get snackbarAddedToQueue => 'Sıraya eklendi';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title favorilere eklendi';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Çalınıyor: $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return '$name sıraya eklendi';
  }

  @override
  String get snackbarPlaylistUpdated => 'Çalma listesi güncellendi';

  @override
  String get snackbarLinkCopied => 'Bağlantı kopyalandı';

  @override
  String get snackbarCouldNotOpenLink => 'Bağlantı açılamadı';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'İndirme sırasına $count şarkı eklendi';
  }

  @override
  String get searchHintExplore => 'Ne dinlemek istersiniz?';

  @override
  String get searchHintLibrary => 'Kitaplıkta ara…';

  @override
  String get searchHintPlaylists => 'Çalma listelerinde ara…';

  @override
  String get searchStartTyping => 'Aramak için yazmaya başlayın';

  @override
  String get searchNoSuggestions => 'Öneri bulunamadı';

  @override
  String get searchNoResults =>
      'Sonuç bulunamadı.\nBaşka bir sözcük veya kaynak deneyin.';

  @override
  String get searchFailed => 'Arama başarısız';

  @override
  String get searchDiscover => 'Yeni müzikler keşfedin';

  @override
  String get searchSources => 'Kaynaklar';

  @override
  String get searchNoPlugins => 'Yüklü eklenti yok';

  @override
  String get searchTracks => 'Parçalar';

  @override
  String get searchAlbums => 'Albümler';

  @override
  String get searchArtists => 'Sanatçılar';

  @override
  String get searchPlaylists => 'Çalma listeleri';

  @override
  String get exploreDiscover => 'Keşfet';

  @override
  String get exploreRecently => 'Son dinlenenler';

  @override
  String get exploreLastFmPicks => 'Last.fm önerileri';

  @override
  String get exploreFailedToLoad => 'Ana sayfa bölümleri yüklenemedi.';

  @override
  String get libraryTitle => 'Kitaplık';

  @override
  String get libraryEmptyState =>
      'Kitaplığınız henüz boş. Buraya şarkı ve çalma listesi ekleyebilirsiniz.';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName listesinde';
  }

  @override
  String get menuAddToPlaylist => 'Çalma listesine ekle';

  @override
  String get menuSmartReplace => 'Eşleşen parçayla değiştir';

  @override
  String get menuShare => 'Paylaş';

  @override
  String get menuAvailableOffline => 'Çevrimdışı kullanılabilir';

  @override
  String get menuDownload => 'İndir';

  @override
  String get menuOpenOriginalLink => 'Orijinal bağlantıyı aç';

  @override
  String get menuDeleteTrack => 'Sil';

  @override
  String get tooltipRemoveFromLibrary => 'Kitaplıktan kaldır';

  @override
  String get tooltipSaveToLibrary => 'Kitaplığa kaydet';

  @override
  String get tooltipOpenOriginalLink => 'Orijinal bağlantıyı aç';

  @override
  String get tooltipAvailableOffline => 'Çevrimdışı kullanılabilir';

  @override
  String get tooltipMoreOptions => 'Diğer seçenekler';

  @override
  String get appuiTitle => 'Arayüz ve hizmetler';

  @override
  String get appuiAutoSlideCharts => 'Listeleri otomatik kaydır';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Ana ekrandaki listeleri otomatik kaydır.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Last.fm önerilerini göster. Oturum açıp uygulamayı yeniden başlatmanız gerekir.';

  @override
  String get appuiNoChartsAvailable =>
      'Kullanılabilir liste yok. Bir liste sağlayıcısı eklentisini etkinleştirin.';

  @override
  String get appuiLoginToLastFm => 'Önce Last.fm hesabınıza giriş yapın.';

  @override
  String get appuiShowInCarousel => 'Ana ekrandaki dönen bölümde göster.';

  @override
  String get countrySettingTitle => 'Ülke ve dil';

  @override
  String get countrySettingAutoDetect => 'Ülkeyi otomatik algıla';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Uygulama açıldığında ülkenizi otomatik algıla.';

  @override
  String get countrySettingCountryLabel => 'Ülke';

  @override
  String get countrySettingLanguageLabel => 'Dil';

  @override
  String get countrySettingSystemDefault => 'Sistem varsayılanı';

  @override
  String get downloadSettingTitle => 'İndirilenler';

  @override
  String get downloadSettingQuality => 'İndirme kalitesi';

  @override
  String get downloadSettingQualitySubtitle =>
      'İndirilen tüm parçalar için tercih edilen ses kalitesi.';

  @override
  String get downloadSettingFolder => 'İndirme klasörü';

  @override
  String get downloadSettingResetFolder => 'İndirme klasörünü sıfırla';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Varsayılan indirme konumunu geri yükle.';

  @override
  String get lastfmTitle => 'Last.fm';

  @override
  String get lastfmScrobbleTracks => 'Dinleme geçmişini gönder';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Dinlediğiniz parçaları Last.fm profilinize gönder.';

  @override
  String get lastfmAuthFirst => 'Önce Last.fm API erişimini doğrulayın.';

  @override
  String get lastfmAuthenticatedAs => 'Giriş yapılan hesap';

  @override
  String get lastfmAuthFailed => 'Kimlik doğrulama başarısız:';

  @override
  String get lastfmNotAuthenticated => 'Kimlik doğrulanmadı';

  @override
  String get lastfmSteps =>
      'Kimlik doğrulama adımları:\n1. last.fm üzerinden hesap açın veya giriş yapın.\n2. last.fm/api/account/create adresinden bir API anahtarı oluşturun.\n3. API anahtarını ve gizli anahtarı aşağıya girin.\n4. “1. Yetkilendirmeyi başlat” düğmesine dokunup tarayıcıda onaylayın.\n5. “2. Oturum anahtarını al ve kaydet” düğmesine dokunun.';

  @override
  String get lastfmApiKey => 'API anahtarı';

  @override
  String get lastfmApiSecret => 'Gizli API anahtarı';

  @override
  String get lastfmStartAuth => '1. Yetkilendirmeyi başlat';

  @override
  String get lastfmGetSession => '2. Oturum anahtarını al ve kaydet';

  @override
  String get lastfmRemoveKeys => 'Anahtarları kaldır';

  @override
  String get lastfmStartAuthFirst =>
      'Önce yetkilendirmeyi başlatın, ardından tarayıcıda onaylayın.';

  @override
  String get localSettingTitle => 'Cihazdaki parçalar';

  @override
  String get localSettingAutoScan => 'Başlangıçta otomatik tara';

  @override
  String get localSettingAutoScanSubtitle =>
      'Uygulama başladığında cihazdaki yeni parçaları otomatik tara.';

  @override
  String get localSettingLastScan => 'Son tarama';

  @override
  String get localSettingNeverScanned => 'Hiç taranmadı';

  @override
  String get localSettingScanInProgress => 'Tarama sürüyor…';

  @override
  String get localSettingScanNowSubtitle => 'Tüm kitaplığı şimdi tara.';

  @override
  String get localSettingNoFolders =>
      'Henüz klasör eklenmedi. Taramak için bir klasör ekleyin.';

  @override
  String get localSettingAddFolder => 'Klasör ekle';

  @override
  String get playerSettingTitle => 'Oynatıcı ayarları';

  @override
  String get playerSettingStreamingHeader => 'Çevrimiçi ses';

  @override
  String get playerSettingStreamQuality => 'Çevrimiçi ses kalitesi';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Çevrimiçi oynatmada kullanılan ses bit hızı.';

  @override
  String get playerSettingQualityLow => 'Düşük';

  @override
  String get playerSettingQualityMedium => 'Orta';

  @override
  String get playerSettingQualityHigh => 'Yüksek';

  @override
  String get playerSettingPlaybackHeader => 'Oynatma';

  @override
  String get playerSettingAutoPlay => 'Otomatik oynatma';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Sıra bittiğinde benzer şarkılar ekle.';

  @override
  String get playerSettingAutoFallback => 'Alternatif kaynakla çal';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Eklenti eksikse veya ses akışı sağlamazsa yalnızca oynatma için uyumlu bir çözümleyici dene.';

  @override
  String get playerSettingCrossfade => 'Parçalar arası geçiş';

  @override
  String get playerSettingCrossfadeOff => 'Kapalı';

  @override
  String get playerSettingCrossfadeInstant => 'Parçalar arası anında geçiş';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Parçalar arasında $seconds sn geçiş';
  }

  @override
  String get playerSettingEqualizer => 'Ekolayzır';

  @override
  String get playerSettingEqualizerActive => 'Etkin';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Etkin — $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'FFmpeg ile 10 bantlı parametrik ekolayzır.';

  @override
  String get pluginDefaultsTitle => 'Varsayılan eklentiler';

  @override
  String get pluginDefaultsDiscoverHeader => 'Keşfet kaynağı';

  @override
  String get pluginDefaultsNoResolver =>
      'Etkin içerik çözümleyici yok. Keşfet kaynağı seçmek için bir eklentiyi etkinleştirin.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Kullanılabilir ilk içerik çözümleyiciyi kullan.';

  @override
  String get pluginDefaultsPriorityHeader => 'Çözümleyici önceliği';

  @override
  String get pluginDefaultsNoPriority =>
      'Etkin içerik çözümleyici yok. Eklentiler etkinleştirildiğinde burada sıralayabilirsiniz.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Sıralamak için sürükleyin. Listelerdeki veya içe aktarılan parçalar için çalınabilir eşleşme aranırken önceliği yüksek çözümleyiciler önce denenir.';

  @override
  String get pluginDefaultsLyricsHeader => 'Şarkı sözü önceliği';

  @override
  String get pluginDefaultsLyricsNone => 'Etkin şarkı sözü sağlayıcısı yok.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'Şarkı sözü sağlayıcılarını sürükleyerek sıralayın. İlk sağlayıcı önce denenir.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Arama önerileri';

  @override
  String get pluginDefaultsSuggestionsNone => 'Etkin öneri sağlayıcısı yok.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Yok';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Yalnızca arama geçmişini kullan.';

  @override
  String get storageSettingTitle => 'Depolama';

  @override
  String get storageClearHistoryEvery => 'Geçmişi temizleme aralığı';

  @override
  String get storageClearHistorySubtitle =>
      'Seçilen süre sonunda dinleme geçmişini temizle.';

  @override
  String storageDays(int count) {
    return '$count gün';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Yedek kaydedildi: $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Yedek paylaşılamadı: $error';
  }

  @override
  String get storageRestoreBackup => 'Yedeği geri yükle';

  @override
  String get storageRestoreBackupSubtitle =>
      'Ayarlarınızı ve verilerinizi bir yedek dosyasından geri yükleyin.';

  @override
  String get storageAutoBackup => 'Otomatik yedekleme';

  @override
  String get storageAutoLyrics => 'Şarkı sözlerini otomatik kaydet';

  @override
  String get storageAutoLyricsSubtitle =>
      'Şarkı çalarken sözlerini otomatik kaydet.';

  @override
  String get storageResetApp => 'Bloomee\'yi sıfırla';

  @override
  String get storageResetConfirmTitle => 'Sıfırlamayı onayla';

  @override
  String get storageResetButton => 'Sıfırla';

  @override
  String get storageRestoreOptionsTitle => 'Geri yükleme seçenekleri';

  @override
  String get storageRestoreContinue => 'Devam';

  @override
  String get storageRestoreConfirmTitle => 'Geri yüklemeyi onayla';

  @override
  String get storageRestoreYes => 'Evet, geri yükle';

  @override
  String get storageRestoring =>
      'Seçilen veriler geri yükleniyor…\nİşlem tamamlanana kadar bekleyin.';

  @override
  String get storageRestoreFailedTitle => 'Geri yükleme başarısız';

  @override
  String get updateSettingTitle => 'Güncellemeler';

  @override
  String get updateCheckForUpdates => 'Güncellemeleri denetle';

  @override
  String get updateCheckSubtitle =>
      'Yeni bir Bloomee sürümü olup olmadığını denetleyin.';

  @override
  String get updateAutoNotify => 'Güncellemeleri bildir';

  @override
  String get updateAutoNotifySubtitle =>
      'Uygulama açıldığında yeni güncellemelerden haberdar ol.';

  @override
  String get updateCheckTitle => 'Güncellemeleri denetle';

  @override
  String get updateUpToDate => 'Bloomee güncel';

  @override
  String get updateViewPreRelease => 'En son ön sürümü görüntüle';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Geçerli sürüm: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'Yeni bir Bloomee sürümü mevcut';

  @override
  String updateVersion(String ver, String build) {
    return 'Sürüm: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Şimdi indir';

  @override
  String get updateChecking => 'Güncellemeler denetleniyor…';

  @override
  String get timerTitle => 'Uyku zamanlayıcısı';

  @override
  String get timerInterludeMessage => 'Oynatma şu süre sonra duracak:';

  @override
  String get timerHours => 'Saat';

  @override
  String get timerMinutes => 'Dakika';

  @override
  String get timerSeconds => 'Saniye';

  @override
  String get timerStop => 'Zamanlayıcıyı durdur';

  @override
  String get timerFinishedMessage => 'Uyku zamanlayıcısı oynatmayı durdurdu.';

  @override
  String get timerGotIt => 'Tamam';

  @override
  String get timerSetTimeError => 'Lütfen bir süre belirleyin';

  @override
  String get timerStart => 'Zamanlayıcıyı başlat';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsEmpty => 'Henüz bildirim yok';

  @override
  String get recentsTitle => 'Geçmiş';

  @override
  String playlistByCreator(String creator) {
    return 'Hazırlayan: $creator';
  }

  @override
  String get playlistYou => 'Siz';

  @override
  String get pluginManagerTitle => 'Eklentiler';

  @override
  String get pluginManagerEmpty =>
      'Yüklü eklenti yok.\n.bex dosyası eklemek için + düğmesine dokunun.';

  @override
  String get pluginManagerFilterAll => 'Tümü';

  @override
  String get pluginManagerFilterContent => 'İçerik çözümleyiciler';

  @override
  String get pluginManagerFilterCharts => 'Liste sağlayıcıları';

  @override
  String get pluginManagerFilterLyrics => 'Şarkı sözü sağlayıcıları';

  @override
  String get pluginManagerFilterSuggestions => 'Öneri sağlayıcıları';

  @override
  String get pluginManagerFilterImporters => 'İçerik içe aktarıcıları';

  @override
  String get pluginManagerTooltipRefresh => 'Yenile';

  @override
  String get pluginManagerTooltipInstall => 'Eklenti yükle';

  @override
  String get pluginManagerNoMatch => 'Bu filtreyle eşleşen eklenti yok';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Dosya seçilemedi: $error';
  }

  @override
  String get pluginManagerInstalling => 'Eklenti yükleniyor…';

  @override
  String get pluginManagerTypeContentResolver => 'İçerik çözümleyici';

  @override
  String get pluginManagerTypeChartProvider => 'Liste sağlayıcısı';

  @override
  String get pluginManagerTypeLyricsProvider => 'Şarkı sözü sağlayıcısı';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Arama önerileri';

  @override
  String get pluginManagerTypeContentImporter => 'İçerik içe aktarıcısı';

  @override
  String get pluginManagerDeleteTitle => 'Eklenti silinsin mi?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '“$name” silinsin mi? Eklenti dosyaları kalıcı olarak silinecek.';
  }

  @override
  String get pluginManagerDeleteAction => 'Sil';

  @override
  String get pluginManagerCancel => 'İptal';

  @override
  String get pluginManagerEnablePlugin => 'Eklentiyi etkinleştir';

  @override
  String get pluginManagerUnloadPlugin => 'Eklentiyi devre dışı bırak';

  @override
  String get pluginManagerDeleting => 'Siliniyor…';

  @override
  String get pluginManagerApiKeysTitle => 'API anahtarları';

  @override
  String get pluginManagerApiKeysSaved => 'API anahtarları kaydedildi';

  @override
  String get pluginManagerSave => 'Kaydet';

  @override
  String get pluginManagerDetailVersion => 'Sürüm';

  @override
  String get pluginManagerDetailType => 'Tür';

  @override
  String get pluginManagerDetailPublisher => 'Yayıncı';

  @override
  String get pluginManagerDetailLastUpdated => 'Son güncelleme';

  @override
  String get pluginManagerDetailCreated => 'Oluşturulma';

  @override
  String get pluginManagerDetailHomepage => 'Web sitesi';

  @override
  String get pluginManagerDeleteStorageTitle => 'Eklenti verileri silinsin mi?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '“$name” için kaydedilen API anahtarları ve ayarlar da silinsin mi?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Verileri koru';

  @override
  String get pluginManagerDeleteStorageRemove => 'Verileri sil';

  @override
  String get segmentsSheetTitle => 'Bölümler';

  @override
  String get segmentsSheetEmpty => 'Kullanılabilir bölüm yok';

  @override
  String get segmentsSheetUntitled => 'Adsız bölüm';

  @override
  String get smartReplaceTitle => 'Eşleşen parçayla değiştir';

  @override
  String smartReplaceSubtitle(String title) {
    return '“$title” için çalınabilir bir alternatif seçin ve kayıtlı çalma listelerindeki bağlantılarını güncelleyin.';
  }

  @override
  String get smartReplaceClose => 'Kapat';

  @override
  String get smartReplaceNoMatch => 'Alternatif bulunamadı';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Etkin çözümleyici eklentileri yeterince yakın bir eşleşme bulamadı.';

  @override
  String get smartReplaceBestMatch => 'En yakın eşleşme';

  @override
  String get smartReplaceSearchFailed => 'Arama başarısız';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Parça değiştirilemedi: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Parça değiştirildi$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' ve sıra güncellendi';

  @override
  String get playerUnknownQueue => 'Bilinmiyor';

  @override
  String playerLiked(String title) {
    return '$title favorilere eklendi';
  }

  @override
  String playerUnliked(String title) {
    return '$title favorilerden kaldırıldı';
  }

  @override
  String get offlineNoDownloads => 'İndirilen parça yok';

  @override
  String get offlineTitle => 'Çevrimdışı';

  @override
  String get offlineSearchHint => 'Şarkılarınızda ara…';

  @override
  String get offlineRefreshTooltip => 'İndirilenleri yenile';

  @override
  String get offlineCloseSearch => 'Aramayı kapat';

  @override
  String get offlineSearchTooltip => 'Ara';

  @override
  String get offlineOpenFailed =>
      'Bu çevrimdışı parça açılamadı. İndirilenleri yenilemeyi deneyin.';

  @override
  String get offlinePlayFailed =>
      'Bu çevrimdışı şarkı çalınamadı. Lütfen yeniden deneyin.';

  @override
  String albumViewTrackCount(int count) {
    return '$count parça';
  }

  @override
  String get albumViewLoadFailed => 'Albüm yüklenemedi';

  @override
  String get aboutCraftingSubtitle => 'Müzik için geliştirildi.';

  @override
  String get aboutFollowGitHub => 'GitHub\'da takip et';

  @override
  String get aboutSendInquiry => 'İş için iletişime geç';

  @override
  String get aboutCreativeHighlights => 'Güncellemeler ve projeler';

  @override
  String get aboutTipQuote =>
      'Bloomee\'yi beğeniyor musunuz? Geliştirmeye destek olabilirsiniz.';

  @override
  String get aboutTipButton => 'Destek ol';

  @override
  String get aboutTipDesc =>
      'Katkınız Bloomee\'nin geliştirilmesine yardımcı olur.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Şarkı bilgileri';

  @override
  String get songInfoSectionTechnical => 'Teknik bilgiler';

  @override
  String get songInfoSectionActions => 'İşlemler';

  @override
  String get songInfoLabelTitle => 'Başlık';

  @override
  String get songInfoLabelArtist => 'Sanatçı';

  @override
  String get songInfoLabelAlbum => 'Albüm';

  @override
  String get songInfoLabelDuration => 'Süre';

  @override
  String get songInfoLabelSource => 'Kaynak';

  @override
  String get songInfoLabelMediaId => 'Medya kimliği';

  @override
  String get songInfoLabelPluginId => 'Eklenti kimliği';

  @override
  String get songInfoCopyId => 'Kimliği kopyala';

  @override
  String get songInfoCopyLink => 'Bağlantıyı kopyala';

  @override
  String get songInfoOpenBrowser => 'Tarayıcıda aç';

  @override
  String get songInfoIdCopied => 'Medya kimliği kopyalandı';

  @override
  String get songInfoLinkCopied => 'Bağlantı kopyalandı';

  @override
  String get songInfoNoLink => 'Kullanılabilir bağlantı yok';

  @override
  String get songInfoOpenFailed => 'Bağlantı açılamadı';

  @override
  String get songInfoUpdateMetadata => 'Parça bilgilerini güncelle';

  @override
  String get songInfoMetadataUpdated => 'Parça bilgileri güncellendi';

  @override
  String get songInfoMetadataUpdateFailed => 'Parça bilgileri güncellenemedi';

  @override
  String get songInfoMetadataUnavailable =>
      'Bu kaynak için parça bilgileri güncellenemiyor';

  @override
  String get songInfoSearchTitle => 'Bu şarkıyı Bloomee\'de ara';

  @override
  String get songInfoSearchArtist => 'Bu sanatçıyı Bloomee\'de ara';

  @override
  String get songInfoSearchAlbum => 'Bu albümü Bloomee\'de ara';

  @override
  String get eqTitle => 'Ekolayzır';

  @override
  String get chartNoItems => 'Bu listede öğe yok';

  @override
  String get chartLoadFailed => 'Liste yüklenemedi';

  @override
  String get chartPlay => 'Çal';

  @override
  String get chartResolving => 'Eşleşme aranıyor';

  @override
  String get chartReady => 'Hazır';

  @override
  String get chartAddToPlaylist => 'Çalma listesine ekle';

  @override
  String get chartNoResolver =>
      'Etkin içerik çözümleyici yok. Çalmak için bir eklenti yükleyin.';

  @override
  String get chartResolveFailed => 'Eşleşme bulunamadı. Aramaya geçiliyor…';

  @override
  String get chartNoResolverAdd => 'Etkin içerik çözümleyici yok.';

  @override
  String get chartNoMatch => 'Eşleşme bulunamadı. Elle aramayı deneyin.';

  @override
  String get chartStatPeak => 'En yüksek sıra';

  @override
  String get chartStatWeeks => 'Hafta';

  @override
  String get chartStatChange => 'Değişim';

  @override
  String menuSharePreparing(String title) {
    return '$title paylaşım için hazırlanıyor.';
  }

  @override
  String get menuOpenLinkFailed => 'Bağlantı açılamadı';

  @override
  String get localMusicFolders => 'Müzik klasörleri';

  @override
  String get localMusicRemoveFolder => 'Klasörü kaldır';

  @override
  String get localMusicCloseSearch => 'Aramayı kapat';

  @override
  String get localMusicOpenSearch => 'Ara';

  @override
  String get localMusicNoMusicFound => 'Cihazda müzik bulunamadı';

  @override
  String get localMusicNoSearchResults =>
      'Aramanızla eşleşen parça bulunamadı.';

  @override
  String localMusicTrackCount(int count) {
    return '$count parça';
  }

  @override
  String get importSongsTitle => 'Şarkı içe aktar';

  @override
  String get importNoPluginsLoaded =>
      'Etkin içerik içe aktarıcısı yok.\nDiğer hizmetlerden çalma listesi almak için bir içe aktarma eklentisi yükleyin.';

  @override
  String get importBloomeeFiles => 'Bloomee dosyalarını içe aktar';

  @override
  String get importM3UFiles => 'M3U çalma listesini içe aktar';

  @override
  String get importM3UNameDialogTitle => 'Çalma listesi adı';

  @override
  String get importM3UNameHint => 'Bu çalma listesi için bir ad girin';

  @override
  String get importM3UNoTracks => 'M3U dosyasında geçerli parça bulunamadı.';

  @override
  String get importNoteTitle => 'Bilgi';

  @override
  String get importNoteMessage =>
      'Yalnızca Bloomee\'nin oluşturduğu dosyalar içe aktarılabilir.\nBaşka bir kaynaktan alınan dosyalar çalışmaz. Yine de devam edilsin mi?';

  @override
  String get importTitle => 'İçe aktar';

  @override
  String get importCheckingUrl => 'Bağlantı denetleniyor…';

  @override
  String get importFetchingTracks => 'Parçalar alınıyor…';

  @override
  String get importSavingToLibrary => 'Kitaplığa kaydediliyor…';

  @override
  String get importPasteUrlHint =>
      'İçe aktarmak için çalma listesi veya albüm bağlantısı yapıştırın';

  @override
  String get importAction => 'İçe aktar';

  @override
  String importTrackCount(int count) {
    return '$count parça';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Parçalar eşleştiriliyor: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return '$count parçayı kaydet';
  }

  @override
  String importTracksSaved(int count) {
    return '$count parça kaydedildi';
  }

  @override
  String get importDone => 'Tamamlandı';

  @override
  String get importMore => 'Başka içerik aktar';

  @override
  String get importUnknownError => 'Bilinmeyen hata';

  @override
  String get importTryAgain => 'Yeniden dene';

  @override
  String get importSkipTrack => 'Bu parçayı atla';

  @override
  String get importMatchOptions => 'Eşleşme seçenekleri';

  @override
  String get importSkipped => 'Atlandı';

  @override
  String get importReorderTip =>
      'Sıralamayı değiştirmek için bir çalma listesine basılı tutun';

  @override
  String get importErrorCannotHandleUrl =>
      'Bu eklenti verilen bağlantıyı desteklemiyor.';

  @override
  String get importErrorUnexpectedResponse =>
      'Eklentiden beklenmeyen yanıt alındı.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Bağlantı denetlenemedi: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Koleksiyon bilgileri alınamadı: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Parçalar alınamadı: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Çalma listesi kaydedilemedi: $error';
  }

  @override
  String get playlistPinToTop => 'En üste sabitle';

  @override
  String get playlistUnpin => 'Sabitlemeyi kaldır';

  @override
  String get snackbarInvalidFileFormat => 'Geçersiz dosya biçimi';

  @override
  String get snackbarProcessingFile => 'Dosya işleniyor…';

  @override
  String get pluginManagerTabInstalled => 'Yüklü';

  @override
  String get pluginManagerTabStore => 'Eklenti mağazası';

  @override
  String get pluginManagerSelectPackage => 'Eklenti paketi seçin (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'Eklenti eski bir bildirim biçimi kullanıyor. Bazı özellikler çalışmayabilir. Güncellemeyi deneyin.';

  @override
  String get pluginManagerStatusActive => 'Etkin';

  @override
  String get pluginManagerStatusInactive => 'Devre dışı';

  @override
  String get pluginRepositoryAddTitle => 'Depo ekle';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Geçerli bir eklenti deposunun JSON dosyası bağlantısını girin.';

  @override
  String get pluginRepositoryAddAction => 'Depo ekle';

  @override
  String get pluginRepositoryTitle => 'Eklenti depoları';

  @override
  String get pluginRepositorySubtitle =>
      'Eklentilere göz atmak için bir JSON kaynağı ekleyin.';

  @override
  String get pluginRepositoryEmpty => 'Henüz depo eklenmedi.';

  @override
  String get pluginRepositoryUnknownUpdate => 'Güncelleme bilgisi yok';

  @override
  String get pluginRepositoryNoDescription => 'Açıklama belirtilmemiş.';

  @override
  String get pluginRepositoryUrlCopied => 'Depo bağlantısı panoya kopyalandı';

  @override
  String pluginRepositoryPluginsCount(int count) {
    return '$count eklenti';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Güncelleme: $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    return '$count eklenti kullanılabilir';
  }

  @override
  String get pluginRepositoryOutdatedManifest =>
      'Eski bildirim biçimi. Bazı özellikler çalışmayabilir.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Bilinmeyen yayıncı';

  @override
  String get pluginRepositoryActionRetry => 'Yeniden dene';

  @override
  String get pluginRepositoryActionOutdated => 'Eski sürüm';

  @override
  String get pluginRepositoryActionInstalled => 'Yüklü';

  @override
  String get pluginRepositoryActionInstall => 'Yükle';

  @override
  String get pluginRepositoryActionUnavailable => 'Kullanılamıyor';

  @override
  String get pluginRepositoryInstallFailed => 'Yükleme başarısız.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name indirilemedi.';
  }

  @override
  String get pluginRepositoryErrorLoad => 'Depolar yüklenemedi.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'Depo bağlantısı veya dosyası geçersiz.';

  @override
  String get pluginRepositoryErrorRemove => 'Depo kaldırılamadı.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    return '$count çalma listesinde değiştirildi$queue.';
  }

  @override
  String get lyricsSearchFieldLabel => 'Şarkı sözü ara…';

  @override
  String get lyricsSearchEmptyPrompt =>
      'Şarkı sözü bulmak için şarkı veya sanatçı adı yazın.';

  @override
  String lyricsSearchNoResults(String query) {
    return '“$query” için şarkı sözü bulunamadı';
  }

  @override
  String get lyricsSearchApplied => 'Şarkı sözleri uygulandı';

  @override
  String get lyricsSearchFetchFailed => 'Şarkı sözleri alınamadı';

  @override
  String get lyricsSearchPreview => 'Önizleme';

  @override
  String get lyricsSearchPreviewTooltip => 'Şarkı sözlerini önizle';

  @override
  String get lyricsSearchSynced => 'Eşzamanlı';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Şarkı sözleri yüklenemedi.';

  @override
  String get lyricsSearchApplyAction => 'Şarkı sözlerini uygula';

  @override
  String get lyricsSettingsSearchTitle => 'Başka şarkı sözü ara';

  @override
  String get lyricsSettingsSearchSubtitle => 'İnternette farklı sürümler bulun';

  @override
  String get lyricsSettingsSyncTitle => 'Zamanlamayı ayarla';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'Erken veya geç görünen şarkı sözlerini düzeltin';

  @override
  String get lyricsSettingsSaveTitle => 'Çevrimdışı kaydet';

  @override
  String get lyricsSettingsSaveSubtitle =>
      'Bu şarkı sözlerini cihazınıza kaydedin';

  @override
  String get lyricsSettingsDeleteTitle => 'Kayıtlı şarkı sözlerini sil';

  @override
  String get lyricsSettingsDeleteSubtitle =>
      'Çevrimdışı şarkı sözü verilerini kaldırın';

  @override
  String get lyricsSyncTapToReset => 'Sıfırlamak için dokunun';

  @override
  String get upNextTitle => 'Sıradakiler';

  @override
  String upNextItemsInQueue(int count) {
    return 'Sırada $count öğe';
  }

  @override
  String get tooltipCopyToClipboard => 'Panoya kopyala';

  @override
  String get snackbarCopiedToClipboard => 'Panoya kopyalandı';

  @override
  String get tooltipSongInfo => 'Şarkı bilgileri';

  @override
  String get snackbarCannotDeletePlayingSong => 'Çalınan şarkı silinemez';

  @override
  String get playerLoopOff => 'Kapalı';

  @override
  String get playerLoopOne => 'Birini tekrarla';

  @override
  String get playerLoopAll => 'Tümünü tekrarla';

  @override
  String get snackbarOpeningAlbumPage => 'Orijinal albüm sayfası açılıyor.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Yeni bir Bloomee sürümü mevcut.\n\nSürüm: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return '“$id” eklentisi yüklendi';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return '“$id” eklentisi silindi';
  }

  @override
  String get pluginBootstrapTitle => 'Bloomee hazırlanıyor';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Yeni eklenti altyapısı hazırlanıyor… %$percent';
  }

  @override
  String get pluginBootstrapHint => 'Bu işlem yalnızca bir kez yapılır.';

  @override
  String get backupSave => 'Yedeği JSON olarak kaydet';

  @override
  String get backupShare => 'JSON yedeğini paylaş';

  @override
  String get backupPortableDetails =>
      'Çalma listeleri, favoriler, kayıtlı koleksiyonlar, geçmişler ve taşınabilir tercihleri içerir. Ses dosyaları, hesaplar ve cihaz klasörleri dahil değildir.';

  @override
  String get backupHistories => 'Dinleme ve arama geçmişleri';

  @override
  String get backupPreferences => 'Taşınabilir tercihler';

  @override
  String get backupNewCopy => 'Yeni çalma listeleri olarak içe aktar';

  @override
  String get backupMerge => 'Mevcut verilerle birleştir';

  @override
  String get backupReplace => 'Seçilen bölümleri değiştir';

  @override
  String get backupMergeDetails =>
      'Mevcut parçalar, parça bilgileri ve tercihler korunur. Eksik parçalar dosyadaki sırayla sona eklenir. Favoriler birleştirilir.';

  @override
  String get backupReplaceWarning =>
      'Seçilen bölümler değiştirilir. Kitaplık seçilirse mevcut çalma listeleri ve favoriler de değiştirilir. Seçilmeyen bölümler ve cihazdaki dosyalar korunur. Önce uygulamaya özel bir kurtarma kopyası oluşturulur.';

  @override
  String get backupAutoDetails =>
      'Uygulamaya özel yedi kurtarma kopyası tutulur. Uygulama açıldığında denetlenir; en fazla 24 saatte bir kopya oluşturulur. Uygulama kaldırıldığında bu kopyalar silinir.';

  @override
  String get backupLocationDetails =>
      '“Yedeği kaydet” seçeneğiyle bir konum belirleyin. Uygulamaya özel kurtarma kopyaları uygulamanın içinde tutulur.';

  @override
  String get backupResetDetails =>
      'Uygulama bir sonraki açılışta tüm veritabanı verilerini sıfırlar. İndirilen ses dosyaları ve yüklü eklenti dosyaları cihazda kalır. Önce uygulamaya özel bir kurtarma kopyası oluşturulur.';

  @override
  String get backupResetPending =>
      'Sıfırlama planlandı. Tamamlamak için Bloomee\'yi kapatıp yeniden açın.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return 'Çalma listeleri: $playlists · Parçalar: $tracks';
  }

  @override
  String backupImportResult(
      int playlists, int tracks, int history, int settings) {
    return 'İçe aktarma tamamlandı. Oluşturulan çalma listeleri: $playlists; eklenen parça kayıtları: $tracks; eklenen geçmiş kayıtları: $history; uygulanan tercihler: $settings.';
  }

  @override
  String get backupRefreshFailed =>
      'Veriler içe aktarıldı. Tüm tercihleri yenilemek için Bloomee\'yi kapatıp yeniden açın.';

  @override
  String get backupRecoveryCopies => 'Kurtarma kopyaları';

  @override
  String get backupNoRecoveryCopies => 'Henüz kurtarma kopyası yok.';

  @override
  String get backupRecoveryAutomatic => 'Otomatik yedek';

  @override
  String get backupRecoveryBeforeImport => 'İçe aktarma öncesi';

  @override
  String get backupRecoveryBeforeReset => 'Sıfırlama öncesi';

  @override
  String get backupCancelReset => 'Sıfırlamayı iptal et';

  @override
  String get libraryRecoveryTitle => 'Eksik kitaplığı kurtar';

  @override
  String get libraryRecoverySubtitle =>
      'Önceki sürümlerden kalan çalma listelerini ve indirme kayıtlarını ara.';

  @override
  String get libraryRecoveryChooseSource =>
      'Taranacak eski veritabanını seçin. Geçerli kitaplığınız ve orijinal dosyalarınız korunur.';

  @override
  String get libraryRecoveryNoSources =>
      'Korunmuş veritabanı bulunamadı. Yalnızca ses dosyalarıyla parçaların eskiden hangi çalma listelerinde olduğu kurtarılamaz.';

  @override
  String libraryRecoverySummary(
      int tracks, int playlists, int downloads, int unavailable) {
    return '$tracks parça, $playlists çalma listesi ve $downloads indirme kaydı bulundu. Şu anda $unavailable dosya kullanılamıyor; kayıtları korunacak.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return 'Bu kopyadan kurtarılamayan bozuk çalma listesi başvuruları: $broken.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'Kurtarma işlemi eksik parçaları, çalma listesi öğelerini ve indirme kayıtlarını ekler. Mevcut çalma listeleri, dosya eşlemeleri ve ayarlar korunur. Önce bir kurtarma kopyası oluşturulur. Başka bir eski kopyada kitaplığınızın daha fazla içeriği varsa işlemi o kopyayla tekrarlayın.';

  @override
  String get libraryRecoveryMerge => 'Kurtarılan kitaplığı birleştir';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Kurtarma tamamlandı. Eklenen çalma listesi öğeleri: $entries; indirme kayıtları: $downloads.';
  }

  @override
  String get backupStartupFailed => 'Bloomee başlatılamadı';

  @override
  String get backupStartupFailedDetails =>
      'Veritabanınız otomatik onarılmadan veya değiştirilmeden başlatma durduruldu. Uygulamayı kapatıp yeniden deneyin. Bu hatayı bildirirken uygulama verilerini koruyun.';

  @override
  String get lyricsTitle => 'Şarkı sözleri';

  @override
  String get lyricsEnterFullscreen => 'Şarkı sözlerini tam ekranda göster';

  @override
  String get lyricsExitFullscreen => 'Tam ekrandan çık';

  @override
  String get lyricsFollowPlayback => 'Oynatmayı takip et';

  @override
  String get lyricsTimingEarlier => 'Daha erken göster';

  @override
  String get lyricsTimingLater => 'Daha geç göster';

  @override
  String get lyricsTimingSave => 'Zamanlamayı kaydet';

  @override
  String get lyricsSaved => 'Şarkı sözleri kaydedildi.';

  @override
  String get lyricsSaveFailed =>
      'Şarkı sözleri kaydedilemedi. Yeniden deneyin.';

  @override
  String get lyricsDeleteFailed =>
      'Kayıtlı şarkı sözleri silinemedi. Yeniden deneyin.';

  @override
  String get artistTopSongs => 'Popüler şarkılar';

  @override
  String get artistLoadFailed => 'Sanatçı yüklenemedi';

  @override
  String get artistNoTopSongs => 'Popüler şarkı bulunamadı';

  @override
  String get artistNoAlbums => 'Kullanılabilir albüm yok';

  @override
  String get snackbarOpeningArtistPage => 'Orijinal sanatçı sayfası açılıyor.';

  @override
  String get snackbarOpeningPlaylistPage =>
      'Orijinal çalma listesi sayfası açılıyor.';

  @override
  String get playlistSaveOrderFailed =>
      'Çalma listesi sırası kaydedilemedi. Lütfen yeniden deneyin.';

  @override
  String get playlistReorderTracksHint =>
      'Parçaları sıralamak için tutamacı basılı tutup sürükleyin';

  @override
  String get playlistTrackCountLabel => 'Parça sayısı';

  @override
  String get playlistDescription => 'Açıklama';

  @override
  String get playlistOriginalUrl => 'Orijinal bağlantı';

  @override
  String get searchSearching => 'Aranıyor…';

  @override
  String get searchSuggestions => 'Öneriler';

  @override
  String get searchTopResults => 'En iyi sonuçlar';

  @override
  String get changelogEmpty => 'Değişiklik bilgisi bulunamadı.';

  @override
  String get changelogTitle => 'Yenilikler';

  @override
  String get changelogLatest => 'En son';

  @override
  String get changelogNext => 'Sonraki sürüm';

  @override
  String changelogVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Kurulum tamamlanmadı';

  @override
  String get pluginBootstrapRetryBody =>
      'Bazı eklentiler şu anda yüklenemedi. Kurulumu tamamlamak için yeniden deneyin.';

  @override
  String get pluginBootstrapInternetTitle => 'İnternet bağlantısı gerekli';

  @override
  String get pluginBootstrapInternetBody =>
      'Bloomee, ülkenizi algılamak ve eklenti altyapısını hazırlamak için ilk kurulumda internet bağlantısına ihtiyaç duyar.';

  @override
  String get buttonExit => 'Çıkış';

  @override
  String get eqSource => 'Ekolayzır kaynağı';

  @override
  String get eqBuiltin => 'Uygulama ekolayzırı';

  @override
  String get eqBuiltinSubtitle => '10 bantlı ekolayzır';

  @override
  String get eqDevice => 'Cihaz ekolayzırı';

  @override
  String get eqDeviceSubtitle => 'Sistem / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'Uygulama ekolayzırı devre dışı. Cihaz ekolayzırını cihazınızın ses ayarlarından yapılandırın.';

  @override
  String get eqPresets => 'Ön ayarlar';

  @override
  String get eqCustomCurve => 'Özel eğri';

  @override
  String get shortcutMuted => 'Ses kapalı';

  @override
  String get shortcutUnmuted => 'Ses açık';

  @override
  String get shortcutShuffleOn => 'Karışık çalma açık';

  @override
  String get shortcutShuffleOff => 'Karışık çalma kapalı';

  @override
  String get shortcutRepeatOff => 'Tekrarlama kapalı';

  @override
  String get shortcutLiked => 'Favorilere eklendi';

  @override
  String get shortcutUnliked => 'Favorilerden kaldırıldı';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'İndirme klasörü seçilemedi: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Sürüm bilgisi alınamadı';

  @override
  String get backupNewCopyDetails =>
      'Ayrı çalma listeleri oluşturur ve favorileri birleştirir. Mevcut çalma listeleri korunur. Seçilen geçmişler ve tercihler de içe aktarılır.';

  @override
  String get changelogCurrent => 'Geçerli';

  @override
  String get backupLibrary =>
      'Kitaplık (çalma listeleri, favoriler ve kayıtlı koleksiyonlar)';

  @override
  String get eqPresetFlat => 'Düz';

  @override
  String get eqPresetAcoustic => 'Akustik';

  @override
  String get eqPresetBassBoost => 'Bas güçlendirme';

  @override
  String get eqPresetBassReducer => 'Bas azaltma';

  @override
  String get eqPresetClassical => 'Klasik';

  @override
  String get eqPresetDance => 'Dans';

  @override
  String get eqPresetDeep => 'Derin';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Elektronik';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Caz';

  @override
  String get eqPresetLatin => 'Latin';

  @override
  String get eqPresetLive => 'Canlı';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetPiano => 'Piyano';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRB => 'R&B';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetSmallSpeakers => 'Küçük hoparlörler';

  @override
  String get eqPresetSpokenWord => 'Konuşma';

  @override
  String get eqPresetTrebleBoost => 'Tiz güçlendirme';

  @override
  String get eqPresetTrebleReducer => 'Tiz azaltma';

  @override
  String get eqPresetVocalBooster => 'Vokal güçlendirme';

  @override
  String get eqPresetCustom => 'Özel';
}
