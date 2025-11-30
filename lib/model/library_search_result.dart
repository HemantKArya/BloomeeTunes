import 'package:Bloomee/model/songModel.dart';

class SongSearchResult {
  final MediaItemModel song;
  final String playlistName;

  const SongSearchResult({
    required this.song,
    required this.playlistName,
  });
}
