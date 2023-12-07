// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/model/songModel.dart';

class MediaPlaylist {
  late List<MediaItemModel> mediaItems;
  bool isLiked = false;
  String albumName = "Unknown";
  MediaPlaylist({
    required this.mediaItems,
    this.isLiked = false,
    required this.albumName,
  });
}
