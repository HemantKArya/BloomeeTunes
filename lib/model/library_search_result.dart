import 'package:Bloomee/model/song_model.dart';

class SongSearchResult {
  final MediaItemModel song;
  final String playlistName;

  const SongSearchResult({
    required this.song,
    required this.playlistName,
  });
}
