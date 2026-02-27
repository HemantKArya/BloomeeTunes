import 'dart:convert';

import 'package:Bloomee/model/album_onl_model.dart';
import 'package:Bloomee/model/artist_onl_model.dart';
import 'package:Bloomee/model/playlist_onl_model.dart';
import 'package:Bloomee/services/db/global_db.dart';

/// Maps between [SavedCollectionsDB] (Isar entity) and domain
/// collection models ([ArtistModel], [AlbumModel], [PlaylistOnlModel]).
///
/// Extracted from free functions at bottom of `bloomee_db_service.dart`.

ArtistModel formatSavedArtistOnl(SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return ArtistModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageUrl: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    country: extra["country"],
  );
}

AlbumModel formatSavedAlbumOnl(SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return AlbumModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageURL: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    country: extra["country"],
    artists: extra["artists"],
    genre: extra["genre"],
    year: extra["year"],
    extra: extra,
    language: extra["language"],
  );
}

PlaylistOnlModel formatSavedPlaylistOnl(
    SavedCollectionsDB savedCollectionsDB) {
  Map extra = jsonDecode(savedCollectionsDB.extra ?? "{}");
  return PlaylistOnlModel(
    name: savedCollectionsDB.title,
    description: savedCollectionsDB.subtitle,
    imageURL: savedCollectionsDB.coverArt,
    source: savedCollectionsDB.source,
    sourceId: savedCollectionsDB.sourceId,
    sourceURL: savedCollectionsDB.sourceURL,
    artists: extra["artists"],
    language: extra["language"],
    year: extra["year"],
    extra: extra,
  );
}
