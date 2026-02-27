/// Canonical route names and paths for go_router navigation.
/// These replace route-name constants previously mixed into [GlobalStrConsts].
///
/// Usage:
///   context.goNamed(RoutePaths.playerScreen);
class RoutePaths {
  RoutePaths._();

  // ── Tab shell routes ────────────────────────────────────────────────────────
  static const String exploreScreen = "Explore";
  static const String libraryScreen = "Library";
  static const String searchScreen = "Search";
  static const String offlineScreen = "Offline";

  // ── Named screens ───────────────────────────────────────────────────────────
  static const String mainScreen = "MainPage";
  static const String testScreen = "TestPage";
  static const String playerScreen = "MusicPlayer";
  static const String playlistView = "PlaylistView";
  static const String addToPlaylistScreen = "AddToPlaylist";

  // ── Sub-routes ──────────────────────────────────────────────────────────────
  /// Import-media sub-route under Library
  static const String importMediaFromPlatforms = "ImportMediaFromPlatforms";
  static const String chartScreen = "ChartScreen";
}
