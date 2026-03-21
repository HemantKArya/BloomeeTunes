import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the visibility state of the full-screen player overlay.
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

  void showPlayer() => emit(true);

  void hidePlayer() => emit(false);

  void togglePlayer() => emit(!state);

  bool get isPlayerVisible => state;
}
