import 'dart:io';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';


class DiscordService {
  static DiscordRPC? _discordRPC;
  static int? _startTimeStamp;  // Persisting timestamp


  /// Initializes Discord RPC once
  static void initialize() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        DiscordRPC.initialize();
        _discordRPC = DiscordRPC(applicationId: '1339113296405725235');
        _discordRPC?.start(autoRegister: true);
        print(" Discord RPC initialized successfully");
      } catch (e) {
        print(' Failed to initialize Discord RPC: $e');
      }
    }
  }


  /// Updates the Discord presence
  static void updatePresence({
    required String title,
    required String artist,
    required bool isPlaying,
  }) {
    if (_discordRPC != null) {
      try {
        _startTimeStamp ??= DateTime.now().millisecondsSinceEpoch;


        _discordRPC!.updatePresence(
          DiscordPresence(
            details: title,
            state: isPlaying
                ? "Playing - ${artist.isNotEmpty ? artist : 'Unknown Artist'}"
                : "Paused - ${artist.isNotEmpty ? artist : 'Unknown Artist'}",
            largeImageKey: "bloomeetunes_logo",
            largeImageText: "BloomeeTunes",
            startTimeStamp: _startTimeStamp
          ),
        );
      } catch (e) {
        print(" Discord RPC Error: $e");
      }
    }
  }


  /// Clears Discord presence
  static void clearPresence() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      _discordRPC?.clearPresence();
      print(" Cleared Discord Presence");
    } catch (e) {
      print(" Failed to clear Discord RPC: $e");
    }
  }
  }
}



