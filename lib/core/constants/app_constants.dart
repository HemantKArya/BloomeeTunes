import 'package:Bloomee/model/song_model.dart';

/// Application-wide sentinel values and shared model instances.
/// Previously defined in [routes_and_consts/global_conts.dart].

/// A null/empty [MediaItemModel] sentinel used as a default value
/// where a non-nullable MediaItemModel is required but no track is loaded.
MediaItemModel mediaItemModelNull = MediaItemModel(id: "Null", title: "Null");
