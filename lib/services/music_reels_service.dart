import 'dart:developer' as dev;
import 'package:audio_service/audio_service.dart';
import 'package:Bloomee/repository/Youtube/ytm/ytmusic.dart';
import 'package:Bloomee/services/audio_service_initializer.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';

class MusicReelsService {
  static final MusicReelsService _instance = MusicReelsService._internal();
  factory MusicReelsService() => _instance;
  MusicReelsService._internal();

  // Cache for random songs
  List<MediaItem> _cachedSongs = [];
  int _currentIndex = 0;
  bool isAutoPlayEnabled = true;

  // Sync with main player
  Future<void> syncWithPlayer() async {
    final playerInitializer = PlayerInitializer();
    final audioHandler = await playerInitializer.getBloomeeMusicPlayer();

    // If player is already playing from reels queue, sync our index
    if (audioHandler.queueTitle.value == "Reels Queue") {
      final currentIndex = audioHandler.queue.value
          .indexWhere((item) => item.id == audioHandler.currentMedia.id);
      if (currentIndex != -1) {
        _currentIndex = currentIndex;
      }
    }
  }

  Future<List<MediaItem>> getRandomSongs({int count = 20}) async {
    // Only return cached songs if we have at least half of the requested count
    if (_cachedSongs.length >= count ~/ 2) {
      dev.log("Returning cached songs", name: "MusicReelsService");
      return _cachedSongs;
    }

    try {
      dev.log("Starting to fetch online songs for reels",
          name: "MusicReelsService");

      // Get trending songs from YTMusic
      dev.log("Fetching trending songs from YTMusic...",
          name: "MusicReelsService");
      final ytMusic = YTMusic();

      // First try to get trending songs
      final Map trendingResponse = await ytMusic.browse(body: {
        "browseId": "FEmusic_trending",
      });

      List<Map> songsList = [];

      // Process trending songs
      try {
        if (trendingResponse.containsKey('contents')) {
          final contents = trendingResponse['contents'] as List;
          for (var item in contents) {
            if (item?['musicTwoRowItemRenderer']?['navigationEndpoint']
                    ?['watchEndpoint']?['videoId'] !=
                null) {
              final videoId = item['musicTwoRowItemRenderer']
                  ['navigationEndpoint']['watchEndpoint']['videoId'];
              final title = item['musicTwoRowItemRenderer']['title']['runs'][0]
                      ['text'] ??
                  'Unknown';
              final subtitle = item['musicTwoRowItemRenderer']['subtitle']
                      ['runs'][0]['text'] ??
                  'Unknown Artist';
              final thumbnail = item['musicTwoRowItemRenderer']
                              ['thumbnailRenderer']['musicThumbnailRenderer']
                          ['thumbnail']['thumbnails']
                      .last['url'] ??
                  '';

              songsList.add({
                'videoId': videoId,
                'title': title,
                'artists': subtitle,
                'duration': '180',
                'thumbnail': thumbnail,
              });
            }
          }
        }
      } catch (e) {
        dev.log("Error parsing YTMusic trending response: $e",
            name: "MusicReelsService");
      }

      // If we don't have enough trending songs, get some popular songs too
      if (songsList.length < count) {
        try {
          final searchResults =
              await ytMusic.searchYtm("popular songs", type: "songs");
          if (searchResults != null && searchResults['songs'] != null) {
            songsList.addAll(searchResults['songs']);
          }
        } catch (e) {
          dev.log("Error fetching additional songs: $e",
              name: "MusicReelsService");
        }
      }

      if (songsList.isEmpty) {
        throw Exception("No songs found from YTMusic");
      }

      dev.log("Found ${songsList.length} songs from YTMusic",
          name: "MusicReelsService");

      // Convert to MediaItems and add to cache
      List<MediaItem> newSongs = songsList
          .map((song) => MediaItem(
                id: 'youtube${song["videoId"]}',
                title: song["title"],
                artist: song["artists"] ?? song["artist"],
                duration:
                    Duration(seconds: int.parse(song["duration"] ?? '180')),
                artUri: Uri.parse(song["thumbnail"] ?? ''),
                extras: {
                  'source': 'youtube',
                  'perma_url':
                      'https://music.youtube.com/watch?v=${song["videoId"]}',
                  'url': 'https://music.youtube.com/watch?v=${song["videoId"]}',
                  'isReel': true,
                },
              ))
          .toList();

      // Shuffle the songs for variety
      newSongs.shuffle();

      // Take requested number of songs
      _cachedSongs = newSongs.take(count).toList();
      return _cachedSongs;
    } catch (e, stackTrace) {
      dev.log("Error getting songs for reels: $e", name: "MusicReelsService");
      dev.log("Stack trace: $stackTrace", name: "MusicReelsService");
      dev.log(
          "Current cache status - Songs in cache: ${_cachedSongs.length}, Current index: $_currentIndex",
          name: "MusicReelsService");
      // Return empty placeholder songs if both local and YTMusic fail
      _cachedSongs = _generateEmptySongs(count);
      dev.log("Returning empty placeholder songs", name: "MusicReelsService");
      return _cachedSongs;
    }
  }

  List<MediaItem> _generateEmptySongs(int count) {
    return List.generate(count, (index) {
      return MediaItem(
        id: 'empty_$index',
        title: 'No songs found',
        artist: 'Try adding some songs to your playlists',
        duration: const Duration(seconds: 30),
        artUri: Uri.parse(''),
        extras: {'isReel': true, 'isEmpty': true},
      );
    });
  }

  Future<bool> playCurrentSong() async {
    try {
      if (_cachedSongs.isEmpty) return false;

      dev.log("Playing song from reels: ${_cachedSongs[_currentIndex].title}",
          name: "MusicReelsService");

      // Get the singleton instance of BloomeeMusicPlayer
      final playerInitializer = PlayerInitializer();
      final audioHandler = await playerInitializer.getBloomeeMusicPlayer();

      // Convert MediaItems to MediaItemModels
      final mediaItemModels = _cachedSongs
          .map((item) => MediaItemModel(
                id: item.id,
                title: item.title,
                artist: item.artist ?? "",
                duration: item.duration ?? const Duration(seconds: 180),
                artUri: item.artUri ?? Uri.parse(""),
                extras: item.extras,
              ))
          .toList();

      // Add all songs to queue if not already there
      if (audioHandler.queue.value.isEmpty ||
          audioHandler.queueTitle.value != "Reels Queue") {
        await audioHandler.loadPlaylist(
          MediaPlaylist(
            playlistName: "Reels Queue",
            mediaItems: mediaItemModels,
          ),
          doPlay: false,
        );
      }

      // Skip to the current song and play
      await audioHandler.skipToQueueItem(_currentIndex);
      await audioHandler.play();
      return true;
    } catch (e) {
      dev.log("Error playing song in reels: $e", name: "MusicReelsService");
      return false;
    }
  }

  Future<MediaItem?> getNextSong() async {
    if (_cachedSongs.isEmpty) {
      await getRandomSongs(); // Fetch new songs if cache is empty
      if (_cachedSongs.isEmpty) return null;
    }

    _currentIndex = (_currentIndex + 1) % _cachedSongs.length;

    // If we're near the end of the list, fetch more songs in background
    if (_currentIndex >= _cachedSongs.length - 5) {
      try {
        final newSongs = await getRandomSongs(count: 20);
        if (newSongs.isNotEmpty) {
          final playerInitializer = PlayerInitializer();
          final audioHandler = await playerInitializer.getBloomeeMusicPlayer();

          // Convert and add new songs to queue
          final mediaItemModels = newSongs
              .map((item) => MediaItemModel(
                    id: item.id,
                    title: item.title,
                    artist: item.artist ?? "",
                    duration: item.duration ?? const Duration(seconds: 180),
                    artUri: item.artUri ?? Uri.parse(""),
                    extras: item.extras,
                  ))
              .toList();

          // Add to cache and queue
          _cachedSongs.addAll(newSongs);
          await audioHandler.addQueueItems(mediaItemModels);
        }
      } catch (e) {
        dev.log("Error adding more songs: $e", name: "MusicReelsService");
      }
    }

    if (isAutoPlayEnabled) {
      await playCurrentSong();
    }
    return _cachedSongs[_currentIndex];
  }

  Future<MediaItem?> getPreviousSong() async {
    if (_cachedSongs.isEmpty) return null;

    final oldIndex = _currentIndex;
    _currentIndex =
        (_currentIndex - 1 + _cachedSongs.length) % _cachedSongs.length;

    // If we went back to previous song, update player
    if (oldIndex != _currentIndex && isAutoPlayEnabled) {
      await playCurrentSong();
    }
    return _cachedSongs[_currentIndex];
  }

  void clearCache() {
    _cachedSongs.clear();
    _currentIndex = 0;
  }

  // Method to fetch lyrics for a song
  Future<String?> getLyrics(String songId) async {
    try {
      // You can integrate with your existing lyrics service here
      // For now, return null to indicate no lyrics available
      return null;
    } catch (e) {
      dev.log("Error fetching lyrics: $e", name: "MusicReelsService");
      return null;
    }
  }
}
