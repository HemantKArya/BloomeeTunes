/// Keys for user-facing settings stored in the database (Isar SettingDB).
/// These replace settings-key constants previously mixed into [GlobalStrConsts].
///
/// Usage:
///   SettingsDAO.getSettingStr(SettingKeys.downQuality, defaultValue: "Medium");
class SettingKeys {
  SettingKeys._();

  // ── App behaviour ───────────────────────────────────────────────────────────
  static const String autoUpdateNotify = "auto_update_notify";
  static const String autoSlideCharts = "auto_slide_charts";

  // ── Playback ────────────────────────────────────────────────────────────────
  static const String strmQuality = "streamQuality";
  static const String autoPlay = "autoPlaySimilarItems";
  static const String autoResolveUnavailableTracks =
      "autoResolveUnavailableTracks";

  // ── Crossfade ───────────────────────────────────────────────────────────────
  /// Crossfade duration in seconds (0 = disabled). Stored as String.
  static const String crossfadeDuration = "crossfadeDuration";

  // ── Equalizer ───────────────────────────────────────────────────────────────
  /// Whether the 10-band EQ is enabled. Stored as bool.
  static const String eqEnabled = "eqEnabled";

  /// JSON-encoded list of 10 gain values (doubles, -15..+15 dB).
  static const String eqBandGains = "eqBandGains";

  /// Name of the currently selected EQ preset (e.g. "Flat", "Rock").
  static const String eqPreset = "eqPreset";

  // ── Downloads ───────────────────────────────────────────────────────────────
  static const String downPathSetting = "downloadPath";

  /// Special playlist name for downloaded tracks.
  static const String downloadPlaylist = "_DOWNLOADS";
  static const String downQuality = "downloadQuality";

  // ── Backup ──────────────────────────────────────────────────────────────────
  static const String backupPath = "backupPath";
  static const String autoBackup = "autoBackup";

  // ── History ─────────────────────────────────────────────────────────────────
  static const String historyClearTime = "autoHistoryCleanupTime";

  /// Special playlist name for recently played tracks.
  static const String recentlyPlayedPlaylist = "recently_played";

  // ── Location / charts ───────────────────────────────────────────────────────
  static const String languageCode = "languageCode";
  static const String autoGetCountry = "autoGetCountry";
  static const String countryCode = "countryCode";
  static const String chartShowMap = "chartShowMap";

  // ── Lyrics ──────────────────────────────────────────────────────────────────
  static const String autoSaveLyrics = "autoSaveLyrics";

  // ── Onboarding / changelogs ─────────────────────────────────────────────────
  /// Tracks the last changelog version the user has read.
  /// Value format: e.g. "v2.11.6+171".
  static const String readChangelogs = "readChangelogs";

  /// Whether the first-run plugin repository bootstrap has been completed.
  /// Once true, the bootstrap is never run again even if the user uninstalls plugins.
  static const String repositoriesBootstrapped = "repositoriesBootstrapped";
  static const String appSetupCompleted = "appSetupCompleted";

  // ── Plugins ────────────────────────────────────────────────────────────────
  /// JSON-encoded list of plugin IDs that should auto-load on app startup.
  static const String autoLoadPluginIds = "autoLoadPluginIds";

  /// ID of the content resolver plugin used for home page sections.
  /// Empty string or null = use the first available content resolver.
  static const String homePluginId = "homePluginId";

  /// ID of the content resolver plugin last used for search.
  /// Empty string = use the first available content resolver.
  static const String searchPluginId = "searchPluginId";

  /// JSON-encoded list of content resolver plugin IDs in priority order
  /// for the cross-plugin metadata resolver.
  static const String resolverPriority = "resolverPriority";

  /// JSON-encoded list of lyrics provider plugin IDs in priority order.
  static const String lyricsPriority = "lyricsPriority";

  /// ID of the search suggestion provider plugin.
  /// Empty string = no plugin-based suggestions.
  static const String suggestionPluginId = "suggestionPluginId";

  /// ISO 8601 UTC timestamp of the last repository sync cycle.
  static const String pluginRepositoryLastSync = "pluginRepositoryLastSync";

  // ── Local music ─────────────────────────────────────────────────────────────
  /// JSON-encoded list of directory paths to scan for local audio files.
  static const String localMusicFolders = "localMusicFolders";

  /// Whether to auto-scan local music folders on app startup.
  static const String localMusicAutoScan = "localMusicAutoScan";

  /// ISO 8601 timestamp of the last local music scan.
  static const String localMusicLastScan = "localMusicLastScan";

  /// Special playlist name for locally discovered tracks.
  static const String localMusicPlaylist = "_LOCAL_MUSIC";

  /// Whether to confirm before deleting a local track.
  static const String localMusicConfirmDelete = 'localMusicConfirmDelete';
}
