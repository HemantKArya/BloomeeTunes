import 'package:Bloomee/core/models/song_model.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:audio_service/audio_service.dart';

/// Maps between [MediaItemDB] (Isar entity) and [MediaItemModel] (domain).
///
/// Extracted from `song_model.dart` to keep domain models DB-free.

MediaItemDB mediaItemToMediaItemDB(MediaItem mediaItem) {
  return MediaItemDB(
      title: mediaItem.title,
      album: mediaItem.album ?? "Unknown",
      artist: mediaItem.artist ?? "Unknown",
      artURL: mediaItem.artUri.toString(),
      genre: mediaItem.genre ?? "Unknown",
      mediaID: mediaItem.id,
      duration: mediaItem.duration?.inSeconds,
      streamingURL: mediaItem.extras?["url"],
      permaURL: mediaItem.extras?["perma_url"],
      language: mediaItem.extras?["language"] ?? "Unknown",
      isLiked: false,
      source: mediaItem.extras?["source"] ?? "Saavn");
}

MediaItemModel mediaItemDBToMediaItem(MediaItemDB mediaItemDB) {
  return MediaItemModel(
      id: mediaItemDB.mediaID,
      title: mediaItemDB.title,
      album: mediaItemDB.album,
      artist: mediaItemDB.artist,
      duration: mediaItemDB.duration != null
          ? Duration(seconds: mediaItemDB.duration!)
          : const Duration(seconds: 120),
      artUri: Uri.parse(mediaItemDB.artURL),
      genre: mediaItemDB.genre,
      extras: {
        "url": mediaItemDB.streamingURL,
        "source": mediaItemDB.source ?? "None",
        "perma_url": mediaItemDB.permaURL,
        "language": mediaItemDB.language,
      });
}
