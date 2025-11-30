import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the visibility state of the full-screen player overlay.
/// This allows the player to stay mounted in the widget tree and just
/// animate in/out for smooth transitions like Spotify/YouTube Music.
class PlayerOverlayCubit extends Cubit<bool> {
  PlayerOverlayCubit() : super(false);

  /// Callback to collapse the UpNext panel, returns true if panel was expanded
  bool Function()? _collapseUpNextPanel;

  /// Register a callback to collapse the UpNext panel
  void registerUpNextPanelCollapse(bool Function() collapse) {
    _collapseUpNextPanel = collapse;
  }

  /// Unregister the UpNext panel collapse callback
  void unregisterUpNextPanelCollapse() {
    _collapseUpNextPanel = null;
  }

  /// Try to collapse the UpNext panel if it's expanded
  /// Returns true if the panel was collapsed, false otherwise
  bool collapseUpNextPanel() {
    return _collapseUpNextPanel?.call() ?? false;
  }

  /// Show the full player overlay
  void showPlayer() => emit(true);

  /// Hide the full player overlay
  void hidePlayer() => emit(false);

  /// Toggle the player overlay visibility
  void togglePlayer() => emit(!state);

  /// Check if player is visible
  bool get isPlayerVisible => state;
}
