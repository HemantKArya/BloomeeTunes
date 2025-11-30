import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the visibility state of the full-screen player overlay.
/// This allows the player to stay mounted in the widget tree and just
/// animate in/out for smooth transitions like Spotify/YouTube Music.
class PlayerOverlayCubit extends Cubit<bool> {
  PlayerOverlayCubit() : super(false);

  /// Show the full player overlay
  void showPlayer() => emit(true);

  /// Hide the full player overlay
  void hidePlayer() => emit(false);

  /// Toggle the player overlay visibility
  void togglePlayer() => emit(!state);

  /// Check if player is visible
  bool get isPlayerVisible => state;
}
