import 'package:Bloomee/core/models/song_model.dart';

class SongSearchResult {
  final MediaItemModel song;
  final String playlistName;

  const SongSearchResult({
    required this.song,
    required this.playlistName,
  });
}
