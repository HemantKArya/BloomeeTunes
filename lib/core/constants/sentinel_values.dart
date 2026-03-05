/// Application-wide sentinel values and shared model instances.
///
/// These replace the legacy [mediaItemModelNull] sentinel that depended
/// on [MediaItemModel]. All player code should use [trackNull] instead.
library sentinel_values;

import 'package:Bloomee/core/models/exported.dart';

/// A null/empty [Track] sentinel used as a default value
/// where a non-nullable Track is required but no track is loaded.
final Track trackNull = Track(
  id: 'Null',
  title: 'Null',
  artists: const [],
  thumbnail: const Artwork(url: '', layout: ImageLayout.square),
  isExplicit: false,
);

/// Check whether a [Track] is the null sentinel.
bool isTrackNull(Track track) => track.id == 'Null' && track.title == 'Null';
