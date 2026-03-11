// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commands.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChartProviderCommand {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ChartProviderCommand);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChartProviderCommand()';
  }
}

/// @nodoc
class $ChartProviderCommandCopyWith<$Res> {
  $ChartProviderCommandCopyWith(
      ChartProviderCommand _, $Res Function(ChartProviderCommand) __);
}

/// Adds pattern-matching-related methods to [ChartProviderCommand].
extension ChartProviderCommandPatterns on ChartProviderCommand {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChartProviderCommand_GetCharts value)? getCharts,
    TResult Function(ChartProviderCommand_GetChartDetails value)?
        getChartDetails,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts() when getCharts != null:
        return getCharts(_that);
      case ChartProviderCommand_GetChartDetails() when getChartDetails != null:
        return getChartDetails(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChartProviderCommand_GetCharts value) getCharts,
    required TResult Function(ChartProviderCommand_GetChartDetails value)
        getChartDetails,
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts():
        return getCharts(_that);
      case ChartProviderCommand_GetChartDetails():
        return getChartDetails(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChartProviderCommand_GetCharts value)? getCharts,
    TResult? Function(ChartProviderCommand_GetChartDetails value)?
        getChartDetails,
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts() when getCharts != null:
        return getCharts(_that);
      case ChartProviderCommand_GetChartDetails() when getChartDetails != null:
        return getChartDetails(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? getCharts,
    TResult Function(String id)? getChartDetails,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts() when getCharts != null:
        return getCharts();
      case ChartProviderCommand_GetChartDetails() when getChartDetails != null:
        return getChartDetails(_that.id);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() getCharts,
    required TResult Function(String id) getChartDetails,
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts():
        return getCharts();
      case ChartProviderCommand_GetChartDetails():
        return getChartDetails(_that.id);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? getCharts,
    TResult? Function(String id)? getChartDetails,
  }) {
    final _that = this;
    switch (_that) {
      case ChartProviderCommand_GetCharts() when getCharts != null:
        return getCharts();
      case ChartProviderCommand_GetChartDetails() when getChartDetails != null:
        return getChartDetails(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ChartProviderCommand_GetCharts extends ChartProviderCommand {
  const ChartProviderCommand_GetCharts() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChartProviderCommand_GetCharts);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ChartProviderCommand.getCharts()';
  }
}

/// @nodoc

class ChartProviderCommand_GetChartDetails extends ChartProviderCommand {
  const ChartProviderCommand_GetChartDetails({required this.id}) : super._();

  final String id;

  /// Create a copy of ChartProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChartProviderCommand_GetChartDetailsCopyWith<
          ChartProviderCommand_GetChartDetails>
      get copyWith => _$ChartProviderCommand_GetChartDetailsCopyWithImpl<
          ChartProviderCommand_GetChartDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChartProviderCommand_GetChartDetails &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ChartProviderCommand.getChartDetails(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ChartProviderCommand_GetChartDetailsCopyWith<$Res>
    implements $ChartProviderCommandCopyWith<$Res> {
  factory $ChartProviderCommand_GetChartDetailsCopyWith(
          ChartProviderCommand_GetChartDetails value,
          $Res Function(ChartProviderCommand_GetChartDetails) _then) =
      _$ChartProviderCommand_GetChartDetailsCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ChartProviderCommand_GetChartDetailsCopyWithImpl<$Res>
    implements $ChartProviderCommand_GetChartDetailsCopyWith<$Res> {
  _$ChartProviderCommand_GetChartDetailsCopyWithImpl(this._self, this._then);

  final ChartProviderCommand_GetChartDetails _self;
  final $Res Function(ChartProviderCommand_GetChartDetails) _then;

  /// Create a copy of ChartProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ChartProviderCommand_GetChartDetails(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ContentResolverCommand {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ContentResolverCommand);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ContentResolverCommand()';
  }
}

/// @nodoc
class $ContentResolverCommandCopyWith<$Res> {
  $ContentResolverCommandCopyWith(
      ContentResolverCommand _, $Res Function(ContentResolverCommand) __);
}

/// Adds pattern-matching-related methods to [ContentResolverCommand].
extension ContentResolverCommandPatterns on ContentResolverCommand {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContentResolverCommand_GetAlbumDetails value)?
        getAlbumDetails,
    TResult Function(ContentResolverCommand_GetArtistDetails value)?
        getArtistDetails,
    TResult Function(ContentResolverCommand_GetPlaylistDetails value)?
        getPlaylistDetails,
    TResult Function(ContentResolverCommand_GetStreams value)? getStreams,
    TResult Function(ContentResolverCommand_Search value)? search,
    TResult Function(ContentResolverCommand_MoreAlbumTracks value)?
        moreAlbumTracks,
    TResult Function(ContentResolverCommand_MoreArtistAlbums value)?
        moreArtistAlbums,
    TResult Function(ContentResolverCommand_MorePlaylistTracks value)?
        morePlaylistTracks,
    TResult Function(ContentResolverCommand_GetRadioTracks value)?
        getRadioTracks,
    TResult Function(ContentResolverCommand_GetHomeSections value)?
        getHomeSections,
    TResult Function(ContentResolverCommand_LoadMore value)? loadMore,
    TResult Function(ContentResolverCommand_GetSegmentsForTrack value)?
        getSegmentsForTrack,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails()
          when getAlbumDetails != null:
        return getAlbumDetails(_that);
      case ContentResolverCommand_GetArtistDetails()
          when getArtistDetails != null:
        return getArtistDetails(_that);
      case ContentResolverCommand_GetPlaylistDetails()
          when getPlaylistDetails != null:
        return getPlaylistDetails(_that);
      case ContentResolverCommand_GetStreams() when getStreams != null:
        return getStreams(_that);
      case ContentResolverCommand_Search() when search != null:
        return search(_that);
      case ContentResolverCommand_MoreAlbumTracks()
          when moreAlbumTracks != null:
        return moreAlbumTracks(_that);
      case ContentResolverCommand_MoreArtistAlbums()
          when moreArtistAlbums != null:
        return moreArtistAlbums(_that);
      case ContentResolverCommand_MorePlaylistTracks()
          when morePlaylistTracks != null:
        return morePlaylistTracks(_that);
      case ContentResolverCommand_GetRadioTracks() when getRadioTracks != null:
        return getRadioTracks(_that);
      case ContentResolverCommand_GetHomeSections()
          when getHomeSections != null:
        return getHomeSections(_that);
      case ContentResolverCommand_LoadMore() when loadMore != null:
        return loadMore(_that);
      case ContentResolverCommand_GetSegmentsForTrack()
          when getSegmentsForTrack != null:
        return getSegmentsForTrack(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ContentResolverCommand_GetAlbumDetails value)
        getAlbumDetails,
    required TResult Function(ContentResolverCommand_GetArtistDetails value)
        getArtistDetails,
    required TResult Function(ContentResolverCommand_GetPlaylistDetails value)
        getPlaylistDetails,
    required TResult Function(ContentResolverCommand_GetStreams value)
        getStreams,
    required TResult Function(ContentResolverCommand_Search value) search,
    required TResult Function(ContentResolverCommand_MoreAlbumTracks value)
        moreAlbumTracks,
    required TResult Function(ContentResolverCommand_MoreArtistAlbums value)
        moreArtistAlbums,
    required TResult Function(ContentResolverCommand_MorePlaylistTracks value)
        morePlaylistTracks,
    required TResult Function(ContentResolverCommand_GetRadioTracks value)
        getRadioTracks,
    required TResult Function(ContentResolverCommand_GetHomeSections value)
        getHomeSections,
    required TResult Function(ContentResolverCommand_LoadMore value) loadMore,
    required TResult Function(ContentResolverCommand_GetSegmentsForTrack value)
        getSegmentsForTrack,
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails():
        return getAlbumDetails(_that);
      case ContentResolverCommand_GetArtistDetails():
        return getArtistDetails(_that);
      case ContentResolverCommand_GetPlaylistDetails():
        return getPlaylistDetails(_that);
      case ContentResolverCommand_GetStreams():
        return getStreams(_that);
      case ContentResolverCommand_Search():
        return search(_that);
      case ContentResolverCommand_MoreAlbumTracks():
        return moreAlbumTracks(_that);
      case ContentResolverCommand_MoreArtistAlbums():
        return moreArtistAlbums(_that);
      case ContentResolverCommand_MorePlaylistTracks():
        return morePlaylistTracks(_that);
      case ContentResolverCommand_GetRadioTracks():
        return getRadioTracks(_that);
      case ContentResolverCommand_GetHomeSections():
        return getHomeSections(_that);
      case ContentResolverCommand_LoadMore():
        return loadMore(_that);
      case ContentResolverCommand_GetSegmentsForTrack():
        return getSegmentsForTrack(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContentResolverCommand_GetAlbumDetails value)?
        getAlbumDetails,
    TResult? Function(ContentResolverCommand_GetArtistDetails value)?
        getArtistDetails,
    TResult? Function(ContentResolverCommand_GetPlaylistDetails value)?
        getPlaylistDetails,
    TResult? Function(ContentResolverCommand_GetStreams value)? getStreams,
    TResult? Function(ContentResolverCommand_Search value)? search,
    TResult? Function(ContentResolverCommand_MoreAlbumTracks value)?
        moreAlbumTracks,
    TResult? Function(ContentResolverCommand_MoreArtistAlbums value)?
        moreArtistAlbums,
    TResult? Function(ContentResolverCommand_MorePlaylistTracks value)?
        morePlaylistTracks,
    TResult? Function(ContentResolverCommand_GetRadioTracks value)?
        getRadioTracks,
    TResult? Function(ContentResolverCommand_GetHomeSections value)?
        getHomeSections,
    TResult? Function(ContentResolverCommand_LoadMore value)? loadMore,
    TResult? Function(ContentResolverCommand_GetSegmentsForTrack value)?
        getSegmentsForTrack,
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails()
          when getAlbumDetails != null:
        return getAlbumDetails(_that);
      case ContentResolverCommand_GetArtistDetails()
          when getArtistDetails != null:
        return getArtistDetails(_that);
      case ContentResolverCommand_GetPlaylistDetails()
          when getPlaylistDetails != null:
        return getPlaylistDetails(_that);
      case ContentResolverCommand_GetStreams() when getStreams != null:
        return getStreams(_that);
      case ContentResolverCommand_Search() when search != null:
        return search(_that);
      case ContentResolverCommand_MoreAlbumTracks()
          when moreAlbumTracks != null:
        return moreAlbumTracks(_that);
      case ContentResolverCommand_MoreArtistAlbums()
          when moreArtistAlbums != null:
        return moreArtistAlbums(_that);
      case ContentResolverCommand_MorePlaylistTracks()
          when morePlaylistTracks != null:
        return morePlaylistTracks(_that);
      case ContentResolverCommand_GetRadioTracks() when getRadioTracks != null:
        return getRadioTracks(_that);
      case ContentResolverCommand_GetHomeSections()
          when getHomeSections != null:
        return getHomeSections(_that);
      case ContentResolverCommand_LoadMore() when loadMore != null:
        return loadMore(_that);
      case ContentResolverCommand_GetSegmentsForTrack()
          when getSegmentsForTrack != null:
        return getSegmentsForTrack(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? getAlbumDetails,
    TResult Function(String id)? getArtistDetails,
    TResult Function(String id)? getPlaylistDetails,
    TResult Function(String id)? getStreams,
    TResult Function(
            String query, ContentSearchFilter filter, String? pageToken)?
        search,
    TResult Function(String id, String pageToken)? moreAlbumTracks,
    TResult Function(String id, String pageToken)? moreArtistAlbums,
    TResult Function(String id, String pageToken)? morePlaylistTracks,
    TResult Function(String id, String? pageToken)? getRadioTracks,
    TResult Function()? getHomeSections,
    TResult Function(String id, String moreLink)? loadMore,
    TResult Function(String id)? getSegmentsForTrack,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails()
          when getAlbumDetails != null:
        return getAlbumDetails(_that.id);
      case ContentResolverCommand_GetArtistDetails()
          when getArtistDetails != null:
        return getArtistDetails(_that.id);
      case ContentResolverCommand_GetPlaylistDetails()
          when getPlaylistDetails != null:
        return getPlaylistDetails(_that.id);
      case ContentResolverCommand_GetStreams() when getStreams != null:
        return getStreams(_that.id);
      case ContentResolverCommand_Search() when search != null:
        return search(_that.query, _that.filter, _that.pageToken);
      case ContentResolverCommand_MoreAlbumTracks()
          when moreAlbumTracks != null:
        return moreAlbumTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_MoreArtistAlbums()
          when moreArtistAlbums != null:
        return moreArtistAlbums(_that.id, _that.pageToken);
      case ContentResolverCommand_MorePlaylistTracks()
          when morePlaylistTracks != null:
        return morePlaylistTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetRadioTracks() when getRadioTracks != null:
        return getRadioTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetHomeSections()
          when getHomeSections != null:
        return getHomeSections();
      case ContentResolverCommand_LoadMore() when loadMore != null:
        return loadMore(_that.id, _that.moreLink);
      case ContentResolverCommand_GetSegmentsForTrack()
          when getSegmentsForTrack != null:
        return getSegmentsForTrack(_that.id);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) getAlbumDetails,
    required TResult Function(String id) getArtistDetails,
    required TResult Function(String id) getPlaylistDetails,
    required TResult Function(String id) getStreams,
    required TResult Function(
            String query, ContentSearchFilter filter, String? pageToken)
        search,
    required TResult Function(String id, String pageToken) moreAlbumTracks,
    required TResult Function(String id, String pageToken) moreArtistAlbums,
    required TResult Function(String id, String pageToken) morePlaylistTracks,
    required TResult Function(String id, String? pageToken) getRadioTracks,
    required TResult Function() getHomeSections,
    required TResult Function(String id, String moreLink) loadMore,
    required TResult Function(String id) getSegmentsForTrack,
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails():
        return getAlbumDetails(_that.id);
      case ContentResolverCommand_GetArtistDetails():
        return getArtistDetails(_that.id);
      case ContentResolverCommand_GetPlaylistDetails():
        return getPlaylistDetails(_that.id);
      case ContentResolverCommand_GetStreams():
        return getStreams(_that.id);
      case ContentResolverCommand_Search():
        return search(_that.query, _that.filter, _that.pageToken);
      case ContentResolverCommand_MoreAlbumTracks():
        return moreAlbumTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_MoreArtistAlbums():
        return moreArtistAlbums(_that.id, _that.pageToken);
      case ContentResolverCommand_MorePlaylistTracks():
        return morePlaylistTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetRadioTracks():
        return getRadioTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetHomeSections():
        return getHomeSections();
      case ContentResolverCommand_LoadMore():
        return loadMore(_that.id, _that.moreLink);
      case ContentResolverCommand_GetSegmentsForTrack():
        return getSegmentsForTrack(_that.id);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? getAlbumDetails,
    TResult? Function(String id)? getArtistDetails,
    TResult? Function(String id)? getPlaylistDetails,
    TResult? Function(String id)? getStreams,
    TResult? Function(
            String query, ContentSearchFilter filter, String? pageToken)?
        search,
    TResult? Function(String id, String pageToken)? moreAlbumTracks,
    TResult? Function(String id, String pageToken)? moreArtistAlbums,
    TResult? Function(String id, String pageToken)? morePlaylistTracks,
    TResult? Function(String id, String? pageToken)? getRadioTracks,
    TResult? Function()? getHomeSections,
    TResult? Function(String id, String moreLink)? loadMore,
    TResult? Function(String id)? getSegmentsForTrack,
  }) {
    final _that = this;
    switch (_that) {
      case ContentResolverCommand_GetAlbumDetails()
          when getAlbumDetails != null:
        return getAlbumDetails(_that.id);
      case ContentResolverCommand_GetArtistDetails()
          when getArtistDetails != null:
        return getArtistDetails(_that.id);
      case ContentResolverCommand_GetPlaylistDetails()
          when getPlaylistDetails != null:
        return getPlaylistDetails(_that.id);
      case ContentResolverCommand_GetStreams() when getStreams != null:
        return getStreams(_that.id);
      case ContentResolverCommand_Search() when search != null:
        return search(_that.query, _that.filter, _that.pageToken);
      case ContentResolverCommand_MoreAlbumTracks()
          when moreAlbumTracks != null:
        return moreAlbumTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_MoreArtistAlbums()
          when moreArtistAlbums != null:
        return moreArtistAlbums(_that.id, _that.pageToken);
      case ContentResolverCommand_MorePlaylistTracks()
          when morePlaylistTracks != null:
        return morePlaylistTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetRadioTracks() when getRadioTracks != null:
        return getRadioTracks(_that.id, _that.pageToken);
      case ContentResolverCommand_GetHomeSections()
          when getHomeSections != null:
        return getHomeSections();
      case ContentResolverCommand_LoadMore() when loadMore != null:
        return loadMore(_that.id, _that.moreLink);
      case ContentResolverCommand_GetSegmentsForTrack()
          when getSegmentsForTrack != null:
        return getSegmentsForTrack(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ContentResolverCommand_GetAlbumDetails extends ContentResolverCommand {
  const ContentResolverCommand_GetAlbumDetails({required this.id}) : super._();

  final String id;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetAlbumDetailsCopyWith<
          ContentResolverCommand_GetAlbumDetails>
      get copyWith => _$ContentResolverCommand_GetAlbumDetailsCopyWithImpl<
          ContentResolverCommand_GetAlbumDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetAlbumDetails &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ContentResolverCommand.getAlbumDetails(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetAlbumDetailsCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetAlbumDetailsCopyWith(
          ContentResolverCommand_GetAlbumDetails value,
          $Res Function(ContentResolverCommand_GetAlbumDetails) _then) =
      _$ContentResolverCommand_GetAlbumDetailsCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ContentResolverCommand_GetAlbumDetailsCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetAlbumDetailsCopyWith<$Res> {
  _$ContentResolverCommand_GetAlbumDetailsCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_GetAlbumDetails _self;
  final $Res Function(ContentResolverCommand_GetAlbumDetails) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ContentResolverCommand_GetAlbumDetails(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetArtistDetails extends ContentResolverCommand {
  const ContentResolverCommand_GetArtistDetails({required this.id}) : super._();

  final String id;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetArtistDetailsCopyWith<
          ContentResolverCommand_GetArtistDetails>
      get copyWith => _$ContentResolverCommand_GetArtistDetailsCopyWithImpl<
          ContentResolverCommand_GetArtistDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetArtistDetails &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ContentResolverCommand.getArtistDetails(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetArtistDetailsCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetArtistDetailsCopyWith(
          ContentResolverCommand_GetArtistDetails value,
          $Res Function(ContentResolverCommand_GetArtistDetails) _then) =
      _$ContentResolverCommand_GetArtistDetailsCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ContentResolverCommand_GetArtistDetailsCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetArtistDetailsCopyWith<$Res> {
  _$ContentResolverCommand_GetArtistDetailsCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_GetArtistDetails _self;
  final $Res Function(ContentResolverCommand_GetArtistDetails) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ContentResolverCommand_GetArtistDetails(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetPlaylistDetails extends ContentResolverCommand {
  const ContentResolverCommand_GetPlaylistDetails({required this.id})
      : super._();

  final String id;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetPlaylistDetailsCopyWith<
          ContentResolverCommand_GetPlaylistDetails>
      get copyWith => _$ContentResolverCommand_GetPlaylistDetailsCopyWithImpl<
          ContentResolverCommand_GetPlaylistDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetPlaylistDetails &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ContentResolverCommand.getPlaylistDetails(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetPlaylistDetailsCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetPlaylistDetailsCopyWith(
          ContentResolverCommand_GetPlaylistDetails value,
          $Res Function(ContentResolverCommand_GetPlaylistDetails) _then) =
      _$ContentResolverCommand_GetPlaylistDetailsCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ContentResolverCommand_GetPlaylistDetailsCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetPlaylistDetailsCopyWith<$Res> {
  _$ContentResolverCommand_GetPlaylistDetailsCopyWithImpl(
      this._self, this._then);

  final ContentResolverCommand_GetPlaylistDetails _self;
  final $Res Function(ContentResolverCommand_GetPlaylistDetails) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ContentResolverCommand_GetPlaylistDetails(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetStreams extends ContentResolverCommand {
  const ContentResolverCommand_GetStreams({required this.id}) : super._();

  final String id;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetStreamsCopyWith<ContentResolverCommand_GetStreams>
      get copyWith => _$ContentResolverCommand_GetStreamsCopyWithImpl<
          ContentResolverCommand_GetStreams>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetStreams &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ContentResolverCommand.getStreams(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetStreamsCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetStreamsCopyWith(
          ContentResolverCommand_GetStreams value,
          $Res Function(ContentResolverCommand_GetStreams) _then) =
      _$ContentResolverCommand_GetStreamsCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ContentResolverCommand_GetStreamsCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetStreamsCopyWith<$Res> {
  _$ContentResolverCommand_GetStreamsCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_GetStreams _self;
  final $Res Function(ContentResolverCommand_GetStreams) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ContentResolverCommand_GetStreams(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_Search extends ContentResolverCommand {
  const ContentResolverCommand_Search(
      {required this.query, required this.filter, this.pageToken})
      : super._();

  final String query;
  final ContentSearchFilter filter;
  final String? pageToken;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_SearchCopyWith<ContentResolverCommand_Search>
      get copyWith => _$ContentResolverCommand_SearchCopyWithImpl<
          ContentResolverCommand_Search>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_Search &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.pageToken, pageToken) ||
                other.pageToken == pageToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, filter, pageToken);

  @override
  String toString() {
    return 'ContentResolverCommand.search(query: $query, filter: $filter, pageToken: $pageToken)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_SearchCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_SearchCopyWith(
          ContentResolverCommand_Search value,
          $Res Function(ContentResolverCommand_Search) _then) =
      _$ContentResolverCommand_SearchCopyWithImpl;
  @useResult
  $Res call({String query, ContentSearchFilter filter, String? pageToken});
}

/// @nodoc
class _$ContentResolverCommand_SearchCopyWithImpl<$Res>
    implements $ContentResolverCommand_SearchCopyWith<$Res> {
  _$ContentResolverCommand_SearchCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_Search _self;
  final $Res Function(ContentResolverCommand_Search) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
    Object? filter = null,
    Object? pageToken = freezed,
  }) {
    return _then(ContentResolverCommand_Search(
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      filter: null == filter
          ? _self.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as ContentSearchFilter,
      pageToken: freezed == pageToken
          ? _self.pageToken
          : pageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_MoreAlbumTracks extends ContentResolverCommand {
  const ContentResolverCommand_MoreAlbumTracks(
      {required this.id, required this.pageToken})
      : super._();

  final String id;
  final String pageToken;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_MoreAlbumTracksCopyWith<
          ContentResolverCommand_MoreAlbumTracks>
      get copyWith => _$ContentResolverCommand_MoreAlbumTracksCopyWithImpl<
          ContentResolverCommand_MoreAlbumTracks>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_MoreAlbumTracks &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageToken, pageToken) ||
                other.pageToken == pageToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pageToken);

  @override
  String toString() {
    return 'ContentResolverCommand.moreAlbumTracks(id: $id, pageToken: $pageToken)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_MoreAlbumTracksCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_MoreAlbumTracksCopyWith(
          ContentResolverCommand_MoreAlbumTracks value,
          $Res Function(ContentResolverCommand_MoreAlbumTracks) _then) =
      _$ContentResolverCommand_MoreAlbumTracksCopyWithImpl;
  @useResult
  $Res call({String id, String pageToken});
}

/// @nodoc
class _$ContentResolverCommand_MoreAlbumTracksCopyWithImpl<$Res>
    implements $ContentResolverCommand_MoreAlbumTracksCopyWith<$Res> {
  _$ContentResolverCommand_MoreAlbumTracksCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_MoreAlbumTracks _self;
  final $Res Function(ContentResolverCommand_MoreAlbumTracks) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pageToken = null,
  }) {
    return _then(ContentResolverCommand_MoreAlbumTracks(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pageToken: null == pageToken
          ? _self.pageToken
          : pageToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_MoreArtistAlbums extends ContentResolverCommand {
  const ContentResolverCommand_MoreArtistAlbums(
      {required this.id, required this.pageToken})
      : super._();

  final String id;
  final String pageToken;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_MoreArtistAlbumsCopyWith<
          ContentResolverCommand_MoreArtistAlbums>
      get copyWith => _$ContentResolverCommand_MoreArtistAlbumsCopyWithImpl<
          ContentResolverCommand_MoreArtistAlbums>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_MoreArtistAlbums &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageToken, pageToken) ||
                other.pageToken == pageToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pageToken);

  @override
  String toString() {
    return 'ContentResolverCommand.moreArtistAlbums(id: $id, pageToken: $pageToken)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_MoreArtistAlbumsCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_MoreArtistAlbumsCopyWith(
          ContentResolverCommand_MoreArtistAlbums value,
          $Res Function(ContentResolverCommand_MoreArtistAlbums) _then) =
      _$ContentResolverCommand_MoreArtistAlbumsCopyWithImpl;
  @useResult
  $Res call({String id, String pageToken});
}

/// @nodoc
class _$ContentResolverCommand_MoreArtistAlbumsCopyWithImpl<$Res>
    implements $ContentResolverCommand_MoreArtistAlbumsCopyWith<$Res> {
  _$ContentResolverCommand_MoreArtistAlbumsCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_MoreArtistAlbums _self;
  final $Res Function(ContentResolverCommand_MoreArtistAlbums) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pageToken = null,
  }) {
    return _then(ContentResolverCommand_MoreArtistAlbums(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pageToken: null == pageToken
          ? _self.pageToken
          : pageToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_MorePlaylistTracks extends ContentResolverCommand {
  const ContentResolverCommand_MorePlaylistTracks(
      {required this.id, required this.pageToken})
      : super._();

  final String id;
  final String pageToken;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_MorePlaylistTracksCopyWith<
          ContentResolverCommand_MorePlaylistTracks>
      get copyWith => _$ContentResolverCommand_MorePlaylistTracksCopyWithImpl<
          ContentResolverCommand_MorePlaylistTracks>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_MorePlaylistTracks &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageToken, pageToken) ||
                other.pageToken == pageToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pageToken);

  @override
  String toString() {
    return 'ContentResolverCommand.morePlaylistTracks(id: $id, pageToken: $pageToken)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_MorePlaylistTracksCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_MorePlaylistTracksCopyWith(
          ContentResolverCommand_MorePlaylistTracks value,
          $Res Function(ContentResolverCommand_MorePlaylistTracks) _then) =
      _$ContentResolverCommand_MorePlaylistTracksCopyWithImpl;
  @useResult
  $Res call({String id, String pageToken});
}

/// @nodoc
class _$ContentResolverCommand_MorePlaylistTracksCopyWithImpl<$Res>
    implements $ContentResolverCommand_MorePlaylistTracksCopyWith<$Res> {
  _$ContentResolverCommand_MorePlaylistTracksCopyWithImpl(
      this._self, this._then);

  final ContentResolverCommand_MorePlaylistTracks _self;
  final $Res Function(ContentResolverCommand_MorePlaylistTracks) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pageToken = null,
  }) {
    return _then(ContentResolverCommand_MorePlaylistTracks(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pageToken: null == pageToken
          ? _self.pageToken
          : pageToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetRadioTracks extends ContentResolverCommand {
  const ContentResolverCommand_GetRadioTracks(
      {required this.id, this.pageToken})
      : super._();

  final String id;
  final String? pageToken;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetRadioTracksCopyWith<
          ContentResolverCommand_GetRadioTracks>
      get copyWith => _$ContentResolverCommand_GetRadioTracksCopyWithImpl<
          ContentResolverCommand_GetRadioTracks>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetRadioTracks &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageToken, pageToken) ||
                other.pageToken == pageToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pageToken);

  @override
  String toString() {
    return 'ContentResolverCommand.getRadioTracks(id: $id, pageToken: $pageToken)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetRadioTracksCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetRadioTracksCopyWith(
          ContentResolverCommand_GetRadioTracks value,
          $Res Function(ContentResolverCommand_GetRadioTracks) _then) =
      _$ContentResolverCommand_GetRadioTracksCopyWithImpl;
  @useResult
  $Res call({String id, String? pageToken});
}

/// @nodoc
class _$ContentResolverCommand_GetRadioTracksCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetRadioTracksCopyWith<$Res> {
  _$ContentResolverCommand_GetRadioTracksCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_GetRadioTracks _self;
  final $Res Function(ContentResolverCommand_GetRadioTracks) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pageToken = freezed,
  }) {
    return _then(ContentResolverCommand_GetRadioTracks(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pageToken: freezed == pageToken
          ? _self.pageToken
          : pageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetHomeSections extends ContentResolverCommand {
  const ContentResolverCommand_GetHomeSections() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetHomeSections);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ContentResolverCommand.getHomeSections()';
  }
}

/// @nodoc

class ContentResolverCommand_LoadMore extends ContentResolverCommand {
  const ContentResolverCommand_LoadMore(
      {required this.id, required this.moreLink})
      : super._();

  final String id;
  final String moreLink;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_LoadMoreCopyWith<ContentResolverCommand_LoadMore>
      get copyWith => _$ContentResolverCommand_LoadMoreCopyWithImpl<
          ContentResolverCommand_LoadMore>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_LoadMore &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moreLink, moreLink) ||
                other.moreLink == moreLink));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, moreLink);

  @override
  String toString() {
    return 'ContentResolverCommand.loadMore(id: $id, moreLink: $moreLink)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_LoadMoreCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_LoadMoreCopyWith(
          ContentResolverCommand_LoadMore value,
          $Res Function(ContentResolverCommand_LoadMore) _then) =
      _$ContentResolverCommand_LoadMoreCopyWithImpl;
  @useResult
  $Res call({String id, String moreLink});
}

/// @nodoc
class _$ContentResolverCommand_LoadMoreCopyWithImpl<$Res>
    implements $ContentResolverCommand_LoadMoreCopyWith<$Res> {
  _$ContentResolverCommand_LoadMoreCopyWithImpl(this._self, this._then);

  final ContentResolverCommand_LoadMore _self;
  final $Res Function(ContentResolverCommand_LoadMore) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? moreLink = null,
  }) {
    return _then(ContentResolverCommand_LoadMore(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moreLink: null == moreLink
          ? _self.moreLink
          : moreLink // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ContentResolverCommand_GetSegmentsForTrack
    extends ContentResolverCommand {
  const ContentResolverCommand_GetSegmentsForTrack({required this.id})
      : super._();

  final String id;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentResolverCommand_GetSegmentsForTrackCopyWith<
          ContentResolverCommand_GetSegmentsForTrack>
      get copyWith => _$ContentResolverCommand_GetSegmentsForTrackCopyWithImpl<
          ContentResolverCommand_GetSegmentsForTrack>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentResolverCommand_GetSegmentsForTrack &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'ContentResolverCommand.getSegmentsForTrack(id: $id)';
  }
}

/// @nodoc
abstract mixin class $ContentResolverCommand_GetSegmentsForTrackCopyWith<$Res>
    implements $ContentResolverCommandCopyWith<$Res> {
  factory $ContentResolverCommand_GetSegmentsForTrackCopyWith(
          ContentResolverCommand_GetSegmentsForTrack value,
          $Res Function(ContentResolverCommand_GetSegmentsForTrack) _then) =
      _$ContentResolverCommand_GetSegmentsForTrackCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$ContentResolverCommand_GetSegmentsForTrackCopyWithImpl<$Res>
    implements $ContentResolverCommand_GetSegmentsForTrackCopyWith<$Res> {
  _$ContentResolverCommand_GetSegmentsForTrackCopyWithImpl(
      this._self, this._then);

  final ContentResolverCommand_GetSegmentsForTrack _self;
  final $Res Function(ContentResolverCommand_GetSegmentsForTrack) _then;

  /// Create a copy of ContentResolverCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(ContentResolverCommand_GetSegmentsForTrack(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$LyricsProviderCommand {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LyricsProviderCommand);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'LyricsProviderCommand()';
  }
}

/// @nodoc
class $LyricsProviderCommandCopyWith<$Res> {
  $LyricsProviderCommandCopyWith(
      LyricsProviderCommand _, $Res Function(LyricsProviderCommand) __);
}

/// Adds pattern-matching-related methods to [LyricsProviderCommand].
extension LyricsProviderCommandPatterns on LyricsProviderCommand {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LyricsProviderCommand_GetLyrics value)? getLyrics,
    TResult Function(LyricsProviderCommand_Search value)? search,
    TResult Function(LyricsProviderCommand_GetLyricsById value)? getLyricsById,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics() when getLyrics != null:
        return getLyrics(_that);
      case LyricsProviderCommand_Search() when search != null:
        return search(_that);
      case LyricsProviderCommand_GetLyricsById() when getLyricsById != null:
        return getLyricsById(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LyricsProviderCommand_GetLyrics value) getLyrics,
    required TResult Function(LyricsProviderCommand_Search value) search,
    required TResult Function(LyricsProviderCommand_GetLyricsById value)
        getLyricsById,
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics():
        return getLyrics(_that);
      case LyricsProviderCommand_Search():
        return search(_that);
      case LyricsProviderCommand_GetLyricsById():
        return getLyricsById(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LyricsProviderCommand_GetLyrics value)? getLyrics,
    TResult? Function(LyricsProviderCommand_Search value)? search,
    TResult? Function(LyricsProviderCommand_GetLyricsById value)? getLyricsById,
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics() when getLyrics != null:
        return getLyrics(_that);
      case LyricsProviderCommand_Search() when search != null:
        return search(_that);
      case LyricsProviderCommand_GetLyricsById() when getLyricsById != null:
        return getLyricsById(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TrackMetadata metadata)? getLyrics,
    TResult Function(String query)? search,
    TResult Function(String id)? getLyricsById,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics() when getLyrics != null:
        return getLyrics(_that.metadata);
      case LyricsProviderCommand_Search() when search != null:
        return search(_that.query);
      case LyricsProviderCommand_GetLyricsById() when getLyricsById != null:
        return getLyricsById(_that.id);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TrackMetadata metadata) getLyrics,
    required TResult Function(String query) search,
    required TResult Function(String id) getLyricsById,
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics():
        return getLyrics(_that.metadata);
      case LyricsProviderCommand_Search():
        return search(_that.query);
      case LyricsProviderCommand_GetLyricsById():
        return getLyricsById(_that.id);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TrackMetadata metadata)? getLyrics,
    TResult? Function(String query)? search,
    TResult? Function(String id)? getLyricsById,
  }) {
    final _that = this;
    switch (_that) {
      case LyricsProviderCommand_GetLyrics() when getLyrics != null:
        return getLyrics(_that.metadata);
      case LyricsProviderCommand_Search() when search != null:
        return search(_that.query);
      case LyricsProviderCommand_GetLyricsById() when getLyricsById != null:
        return getLyricsById(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class LyricsProviderCommand_GetLyrics extends LyricsProviderCommand {
  const LyricsProviderCommand_GetLyrics({required this.metadata}) : super._();

  final TrackMetadata metadata;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LyricsProviderCommand_GetLyricsCopyWith<LyricsProviderCommand_GetLyrics>
      get copyWith => _$LyricsProviderCommand_GetLyricsCopyWithImpl<
          LyricsProviderCommand_GetLyrics>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LyricsProviderCommand_GetLyrics &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata);

  @override
  String toString() {
    return 'LyricsProviderCommand.getLyrics(metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $LyricsProviderCommand_GetLyricsCopyWith<$Res>
    implements $LyricsProviderCommandCopyWith<$Res> {
  factory $LyricsProviderCommand_GetLyricsCopyWith(
          LyricsProviderCommand_GetLyrics value,
          $Res Function(LyricsProviderCommand_GetLyrics) _then) =
      _$LyricsProviderCommand_GetLyricsCopyWithImpl;
  @useResult
  $Res call({TrackMetadata metadata});
}

/// @nodoc
class _$LyricsProviderCommand_GetLyricsCopyWithImpl<$Res>
    implements $LyricsProviderCommand_GetLyricsCopyWith<$Res> {
  _$LyricsProviderCommand_GetLyricsCopyWithImpl(this._self, this._then);

  final LyricsProviderCommand_GetLyrics _self;
  final $Res Function(LyricsProviderCommand_GetLyrics) _then;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadata = null,
  }) {
    return _then(LyricsProviderCommand_GetLyrics(
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as TrackMetadata,
    ));
  }
}

/// @nodoc

class LyricsProviderCommand_Search extends LyricsProviderCommand {
  const LyricsProviderCommand_Search({required this.query}) : super._();

  final String query;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LyricsProviderCommand_SearchCopyWith<LyricsProviderCommand_Search>
      get copyWith => _$LyricsProviderCommand_SearchCopyWithImpl<
          LyricsProviderCommand_Search>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LyricsProviderCommand_Search &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @override
  String toString() {
    return 'LyricsProviderCommand.search(query: $query)';
  }
}

/// @nodoc
abstract mixin class $LyricsProviderCommand_SearchCopyWith<$Res>
    implements $LyricsProviderCommandCopyWith<$Res> {
  factory $LyricsProviderCommand_SearchCopyWith(
          LyricsProviderCommand_Search value,
          $Res Function(LyricsProviderCommand_Search) _then) =
      _$LyricsProviderCommand_SearchCopyWithImpl;
  @useResult
  $Res call({String query});
}

/// @nodoc
class _$LyricsProviderCommand_SearchCopyWithImpl<$Res>
    implements $LyricsProviderCommand_SearchCopyWith<$Res> {
  _$LyricsProviderCommand_SearchCopyWithImpl(this._self, this._then);

  final LyricsProviderCommand_Search _self;
  final $Res Function(LyricsProviderCommand_Search) _then;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
  }) {
    return _then(LyricsProviderCommand_Search(
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class LyricsProviderCommand_GetLyricsById extends LyricsProviderCommand {
  const LyricsProviderCommand_GetLyricsById({required this.id}) : super._();

  final String id;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LyricsProviderCommand_GetLyricsByIdCopyWith<
          LyricsProviderCommand_GetLyricsById>
      get copyWith => _$LyricsProviderCommand_GetLyricsByIdCopyWithImpl<
          LyricsProviderCommand_GetLyricsById>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LyricsProviderCommand_GetLyricsById &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'LyricsProviderCommand.getLyricsById(id: $id)';
  }
}

/// @nodoc
abstract mixin class $LyricsProviderCommand_GetLyricsByIdCopyWith<$Res>
    implements $LyricsProviderCommandCopyWith<$Res> {
  factory $LyricsProviderCommand_GetLyricsByIdCopyWith(
          LyricsProviderCommand_GetLyricsById value,
          $Res Function(LyricsProviderCommand_GetLyricsById) _then) =
      _$LyricsProviderCommand_GetLyricsByIdCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$LyricsProviderCommand_GetLyricsByIdCopyWithImpl<$Res>
    implements $LyricsProviderCommand_GetLyricsByIdCopyWith<$Res> {
  _$LyricsProviderCommand_GetLyricsByIdCopyWithImpl(this._self, this._then);

  final LyricsProviderCommand_GetLyricsById _self;
  final $Res Function(LyricsProviderCommand_GetLyricsById) _then;

  /// Create a copy of LyricsProviderCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(LyricsProviderCommand_GetLyricsById(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$PluginRequest {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginRequest &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'PluginRequest(field0: $field0)';
  }
}

/// @nodoc
class $PluginRequestCopyWith<$Res> {
  $PluginRequestCopyWith(PluginRequest _, $Res Function(PluginRequest) __);
}

/// Adds pattern-matching-related methods to [PluginRequest].
extension PluginRequestPatterns on PluginRequest {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PluginRequest_ContentResolver value)? contentResolver,
    TResult Function(PluginRequest_ChartProvider value)? chartProvider,
    TResult Function(PluginRequest_LyricsProvider value)? lyricsProvider,
    TResult Function(PluginRequest_SearchSuggestionProvider value)?
        searchSuggestionProvider,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that);
      case PluginRequest_LyricsProvider() when lyricsProvider != null:
        return lyricsProvider(_that);
      case PluginRequest_SearchSuggestionProvider()
          when searchSuggestionProvider != null:
        return searchSuggestionProvider(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PluginRequest_ContentResolver value)
        contentResolver,
    required TResult Function(PluginRequest_ChartProvider value) chartProvider,
    required TResult Function(PluginRequest_LyricsProvider value)
        lyricsProvider,
    required TResult Function(PluginRequest_SearchSuggestionProvider value)
        searchSuggestionProvider,
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver():
        return contentResolver(_that);
      case PluginRequest_ChartProvider():
        return chartProvider(_that);
      case PluginRequest_LyricsProvider():
        return lyricsProvider(_that);
      case PluginRequest_SearchSuggestionProvider():
        return searchSuggestionProvider(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PluginRequest_ContentResolver value)? contentResolver,
    TResult? Function(PluginRequest_ChartProvider value)? chartProvider,
    TResult? Function(PluginRequest_LyricsProvider value)? lyricsProvider,
    TResult? Function(PluginRequest_SearchSuggestionProvider value)?
        searchSuggestionProvider,
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that);
      case PluginRequest_LyricsProvider() when lyricsProvider != null:
        return lyricsProvider(_that);
      case PluginRequest_SearchSuggestionProvider()
          when searchSuggestionProvider != null:
        return searchSuggestionProvider(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ContentResolverCommand field0)? contentResolver,
    TResult Function(ChartProviderCommand field0)? chartProvider,
    TResult Function(LyricsProviderCommand field0)? lyricsProvider,
    TResult Function(SearchSuggestionCommand field0)? searchSuggestionProvider,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that.field0);
      case PluginRequest_LyricsProvider() when lyricsProvider != null:
        return lyricsProvider(_that.field0);
      case PluginRequest_SearchSuggestionProvider()
          when searchSuggestionProvider != null:
        return searchSuggestionProvider(_that.field0);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ContentResolverCommand field0) contentResolver,
    required TResult Function(ChartProviderCommand field0) chartProvider,
    required TResult Function(LyricsProviderCommand field0) lyricsProvider,
    required TResult Function(SearchSuggestionCommand field0)
        searchSuggestionProvider,
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver():
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider():
        return chartProvider(_that.field0);
      case PluginRequest_LyricsProvider():
        return lyricsProvider(_that.field0);
      case PluginRequest_SearchSuggestionProvider():
        return searchSuggestionProvider(_that.field0);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ContentResolverCommand field0)? contentResolver,
    TResult? Function(ChartProviderCommand field0)? chartProvider,
    TResult? Function(LyricsProviderCommand field0)? lyricsProvider,
    TResult? Function(SearchSuggestionCommand field0)? searchSuggestionProvider,
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that.field0);
      case PluginRequest_LyricsProvider() when lyricsProvider != null:
        return lyricsProvider(_that.field0);
      case PluginRequest_SearchSuggestionProvider()
          when searchSuggestionProvider != null:
        return searchSuggestionProvider(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class PluginRequest_ContentResolver extends PluginRequest {
  const PluginRequest_ContentResolver(this.field0) : super._();

  @override
  final ContentResolverCommand field0;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginRequest_ContentResolverCopyWith<PluginRequest_ContentResolver>
      get copyWith => _$PluginRequest_ContentResolverCopyWithImpl<
          PluginRequest_ContentResolver>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginRequest_ContentResolver &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginRequest.contentResolver(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginRequest_ContentResolverCopyWith<$Res>
    implements $PluginRequestCopyWith<$Res> {
  factory $PluginRequest_ContentResolverCopyWith(
          PluginRequest_ContentResolver value,
          $Res Function(PluginRequest_ContentResolver) _then) =
      _$PluginRequest_ContentResolverCopyWithImpl;
  @useResult
  $Res call({ContentResolverCommand field0});

  $ContentResolverCommandCopyWith<$Res> get field0;
}

/// @nodoc
class _$PluginRequest_ContentResolverCopyWithImpl<$Res>
    implements $PluginRequest_ContentResolverCopyWith<$Res> {
  _$PluginRequest_ContentResolverCopyWithImpl(this._self, this._then);

  final PluginRequest_ContentResolver _self;
  final $Res Function(PluginRequest_ContentResolver) _then;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginRequest_ContentResolver(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ContentResolverCommand,
    ));
  }

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentResolverCommandCopyWith<$Res> get field0 {
    return $ContentResolverCommandCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class PluginRequest_ChartProvider extends PluginRequest {
  const PluginRequest_ChartProvider(this.field0) : super._();

  @override
  final ChartProviderCommand field0;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginRequest_ChartProviderCopyWith<PluginRequest_ChartProvider>
      get copyWith => _$PluginRequest_ChartProviderCopyWithImpl<
          PluginRequest_ChartProvider>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginRequest_ChartProvider &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginRequest.chartProvider(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginRequest_ChartProviderCopyWith<$Res>
    implements $PluginRequestCopyWith<$Res> {
  factory $PluginRequest_ChartProviderCopyWith(
          PluginRequest_ChartProvider value,
          $Res Function(PluginRequest_ChartProvider) _then) =
      _$PluginRequest_ChartProviderCopyWithImpl;
  @useResult
  $Res call({ChartProviderCommand field0});

  $ChartProviderCommandCopyWith<$Res> get field0;
}

/// @nodoc
class _$PluginRequest_ChartProviderCopyWithImpl<$Res>
    implements $PluginRequest_ChartProviderCopyWith<$Res> {
  _$PluginRequest_ChartProviderCopyWithImpl(this._self, this._then);

  final PluginRequest_ChartProvider _self;
  final $Res Function(PluginRequest_ChartProvider) _then;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginRequest_ChartProvider(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ChartProviderCommand,
    ));
  }

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChartProviderCommandCopyWith<$Res> get field0 {
    return $ChartProviderCommandCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class PluginRequest_LyricsProvider extends PluginRequest {
  const PluginRequest_LyricsProvider(this.field0) : super._();

  @override
  final LyricsProviderCommand field0;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginRequest_LyricsProviderCopyWith<PluginRequest_LyricsProvider>
      get copyWith => _$PluginRequest_LyricsProviderCopyWithImpl<
          PluginRequest_LyricsProvider>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginRequest_LyricsProvider &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginRequest.lyricsProvider(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginRequest_LyricsProviderCopyWith<$Res>
    implements $PluginRequestCopyWith<$Res> {
  factory $PluginRequest_LyricsProviderCopyWith(
          PluginRequest_LyricsProvider value,
          $Res Function(PluginRequest_LyricsProvider) _then) =
      _$PluginRequest_LyricsProviderCopyWithImpl;
  @useResult
  $Res call({LyricsProviderCommand field0});

  $LyricsProviderCommandCopyWith<$Res> get field0;
}

/// @nodoc
class _$PluginRequest_LyricsProviderCopyWithImpl<$Res>
    implements $PluginRequest_LyricsProviderCopyWith<$Res> {
  _$PluginRequest_LyricsProviderCopyWithImpl(this._self, this._then);

  final PluginRequest_LyricsProvider _self;
  final $Res Function(PluginRequest_LyricsProvider) _then;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginRequest_LyricsProvider(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as LyricsProviderCommand,
    ));
  }

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LyricsProviderCommandCopyWith<$Res> get field0 {
    return $LyricsProviderCommandCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class PluginRequest_SearchSuggestionProvider extends PluginRequest {
  const PluginRequest_SearchSuggestionProvider(this.field0) : super._();

  @override
  final SearchSuggestionCommand field0;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginRequest_SearchSuggestionProviderCopyWith<
          PluginRequest_SearchSuggestionProvider>
      get copyWith => _$PluginRequest_SearchSuggestionProviderCopyWithImpl<
          PluginRequest_SearchSuggestionProvider>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginRequest_SearchSuggestionProvider &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginRequest.searchSuggestionProvider(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginRequest_SearchSuggestionProviderCopyWith<$Res>
    implements $PluginRequestCopyWith<$Res> {
  factory $PluginRequest_SearchSuggestionProviderCopyWith(
          PluginRequest_SearchSuggestionProvider value,
          $Res Function(PluginRequest_SearchSuggestionProvider) _then) =
      _$PluginRequest_SearchSuggestionProviderCopyWithImpl;
  @useResult
  $Res call({SearchSuggestionCommand field0});

  $SearchSuggestionCommandCopyWith<$Res> get field0;
}

/// @nodoc
class _$PluginRequest_SearchSuggestionProviderCopyWithImpl<$Res>
    implements $PluginRequest_SearchSuggestionProviderCopyWith<$Res> {
  _$PluginRequest_SearchSuggestionProviderCopyWithImpl(this._self, this._then);

  final PluginRequest_SearchSuggestionProvider _self;
  final $Res Function(PluginRequest_SearchSuggestionProvider) _then;

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginRequest_SearchSuggestionProvider(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SearchSuggestionCommand,
    ));
  }

  /// Create a copy of PluginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchSuggestionCommandCopyWith<$Res> get field0 {
    return $SearchSuggestionCommandCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc
mixin _$PluginResponse {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PluginResponse);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PluginResponse()';
  }
}

/// @nodoc
class $PluginResponseCopyWith<$Res> {
  $PluginResponseCopyWith(PluginResponse _, $Res Function(PluginResponse) __);
}

/// Adds pattern-matching-related methods to [PluginResponse].
extension PluginResponsePatterns on PluginResponse {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PluginResponse_AlbumDetails value)? albumDetails,
    TResult Function(PluginResponse_ArtistDetails value)? artistDetails,
    TResult Function(PluginResponse_PlaylistDetails value)? playlistDetails,
    TResult Function(PluginResponse_Streams value)? streams,
    TResult Function(PluginResponse_Search value)? search,
    TResult Function(PluginResponse_MoreTracks value)? moreTracks,
    TResult Function(PluginResponse_MoreAlbums value)? moreAlbums,
    TResult Function(PluginResponse_HomeSections value)? homeSections,
    TResult Function(PluginResponse_LoadMoreItems value)? loadMoreItems,
    TResult Function(PluginResponse_Charts value)? charts,
    TResult Function(PluginResponse_ChartDetails value)? chartDetails,
    TResult Function(PluginResponse_Segments value)? segments,
    TResult Function(PluginResponse_LyricsResult value)? lyricsResult,
    TResult Function(PluginResponse_LyricsSearchResults value)?
        lyricsSearchResults,
    TResult Function(PluginResponse_LyricsById value)? lyricsById,
    TResult Function(PluginResponse_Suggestions value)? suggestions,
    TResult Function(PluginResponse_Ack value)? ack,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails() when albumDetails != null:
        return albumDetails(_that);
      case PluginResponse_ArtistDetails() when artistDetails != null:
        return artistDetails(_that);
      case PluginResponse_PlaylistDetails() when playlistDetails != null:
        return playlistDetails(_that);
      case PluginResponse_Streams() when streams != null:
        return streams(_that);
      case PluginResponse_Search() when search != null:
        return search(_that);
      case PluginResponse_MoreTracks() when moreTracks != null:
        return moreTracks(_that);
      case PluginResponse_MoreAlbums() when moreAlbums != null:
        return moreAlbums(_that);
      case PluginResponse_HomeSections() when homeSections != null:
        return homeSections(_that);
      case PluginResponse_LoadMoreItems() when loadMoreItems != null:
        return loadMoreItems(_that);
      case PluginResponse_Charts() when charts != null:
        return charts(_that);
      case PluginResponse_ChartDetails() when chartDetails != null:
        return chartDetails(_that);
      case PluginResponse_Segments() when segments != null:
        return segments(_that);
      case PluginResponse_LyricsResult() when lyricsResult != null:
        return lyricsResult(_that);
      case PluginResponse_LyricsSearchResults()
          when lyricsSearchResults != null:
        return lyricsSearchResults(_that);
      case PluginResponse_LyricsById() when lyricsById != null:
        return lyricsById(_that);
      case PluginResponse_Suggestions() when suggestions != null:
        return suggestions(_that);
      case PluginResponse_Ack() when ack != null:
        return ack(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PluginResponse_AlbumDetails value) albumDetails,
    required TResult Function(PluginResponse_ArtistDetails value) artistDetails,
    required TResult Function(PluginResponse_PlaylistDetails value)
        playlistDetails,
    required TResult Function(PluginResponse_Streams value) streams,
    required TResult Function(PluginResponse_Search value) search,
    required TResult Function(PluginResponse_MoreTracks value) moreTracks,
    required TResult Function(PluginResponse_MoreAlbums value) moreAlbums,
    required TResult Function(PluginResponse_HomeSections value) homeSections,
    required TResult Function(PluginResponse_LoadMoreItems value) loadMoreItems,
    required TResult Function(PluginResponse_Charts value) charts,
    required TResult Function(PluginResponse_ChartDetails value) chartDetails,
    required TResult Function(PluginResponse_Segments value) segments,
    required TResult Function(PluginResponse_LyricsResult value) lyricsResult,
    required TResult Function(PluginResponse_LyricsSearchResults value)
        lyricsSearchResults,
    required TResult Function(PluginResponse_LyricsById value) lyricsById,
    required TResult Function(PluginResponse_Suggestions value) suggestions,
    required TResult Function(PluginResponse_Ack value) ack,
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails():
        return albumDetails(_that);
      case PluginResponse_ArtistDetails():
        return artistDetails(_that);
      case PluginResponse_PlaylistDetails():
        return playlistDetails(_that);
      case PluginResponse_Streams():
        return streams(_that);
      case PluginResponse_Search():
        return search(_that);
      case PluginResponse_MoreTracks():
        return moreTracks(_that);
      case PluginResponse_MoreAlbums():
        return moreAlbums(_that);
      case PluginResponse_HomeSections():
        return homeSections(_that);
      case PluginResponse_LoadMoreItems():
        return loadMoreItems(_that);
      case PluginResponse_Charts():
        return charts(_that);
      case PluginResponse_ChartDetails():
        return chartDetails(_that);
      case PluginResponse_Segments():
        return segments(_that);
      case PluginResponse_LyricsResult():
        return lyricsResult(_that);
      case PluginResponse_LyricsSearchResults():
        return lyricsSearchResults(_that);
      case PluginResponse_LyricsById():
        return lyricsById(_that);
      case PluginResponse_Suggestions():
        return suggestions(_that);
      case PluginResponse_Ack():
        return ack(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PluginResponse_AlbumDetails value)? albumDetails,
    TResult? Function(PluginResponse_ArtistDetails value)? artistDetails,
    TResult? Function(PluginResponse_PlaylistDetails value)? playlistDetails,
    TResult? Function(PluginResponse_Streams value)? streams,
    TResult? Function(PluginResponse_Search value)? search,
    TResult? Function(PluginResponse_MoreTracks value)? moreTracks,
    TResult? Function(PluginResponse_MoreAlbums value)? moreAlbums,
    TResult? Function(PluginResponse_HomeSections value)? homeSections,
    TResult? Function(PluginResponse_LoadMoreItems value)? loadMoreItems,
    TResult? Function(PluginResponse_Charts value)? charts,
    TResult? Function(PluginResponse_ChartDetails value)? chartDetails,
    TResult? Function(PluginResponse_Segments value)? segments,
    TResult? Function(PluginResponse_LyricsResult value)? lyricsResult,
    TResult? Function(PluginResponse_LyricsSearchResults value)?
        lyricsSearchResults,
    TResult? Function(PluginResponse_LyricsById value)? lyricsById,
    TResult? Function(PluginResponse_Suggestions value)? suggestions,
    TResult? Function(PluginResponse_Ack value)? ack,
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails() when albumDetails != null:
        return albumDetails(_that);
      case PluginResponse_ArtistDetails() when artistDetails != null:
        return artistDetails(_that);
      case PluginResponse_PlaylistDetails() when playlistDetails != null:
        return playlistDetails(_that);
      case PluginResponse_Streams() when streams != null:
        return streams(_that);
      case PluginResponse_Search() when search != null:
        return search(_that);
      case PluginResponse_MoreTracks() when moreTracks != null:
        return moreTracks(_that);
      case PluginResponse_MoreAlbums() when moreAlbums != null:
        return moreAlbums(_that);
      case PluginResponse_HomeSections() when homeSections != null:
        return homeSections(_that);
      case PluginResponse_LoadMoreItems() when loadMoreItems != null:
        return loadMoreItems(_that);
      case PluginResponse_Charts() when charts != null:
        return charts(_that);
      case PluginResponse_ChartDetails() when chartDetails != null:
        return chartDetails(_that);
      case PluginResponse_Segments() when segments != null:
        return segments(_that);
      case PluginResponse_LyricsResult() when lyricsResult != null:
        return lyricsResult(_that);
      case PluginResponse_LyricsSearchResults()
          when lyricsSearchResults != null:
        return lyricsSearchResults(_that);
      case PluginResponse_LyricsById() when lyricsById != null:
        return lyricsById(_that);
      case PluginResponse_Suggestions() when suggestions != null:
        return suggestions(_that);
      case PluginResponse_Ack() when ack != null:
        return ack(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AlbumDetails field0)? albumDetails,
    TResult Function(ArtistDetails field0)? artistDetails,
    TResult Function(PlaylistDetails field0)? playlistDetails,
    TResult Function(List<StreamSource> field0)? streams,
    TResult Function(PagedMediaItems field0)? search,
    TResult Function(PagedTracks field0)? moreTracks,
    TResult Function(PagedAlbums field0)? moreAlbums,
    TResult Function(List<Section> field0)? homeSections,
    TResult Function(List<MediaItem> field0)? loadMoreItems,
    TResult Function(List<ChartSummary> field0)? charts,
    TResult Function(List<ChartItem> field0)? chartDetails,
    TResult Function(List<TrackSegment> field0)? segments,
    TResult Function((PluginLyrics, LyricsMetadata)? field0)? lyricsResult,
    TResult Function(List<LyricsMatch> field0)? lyricsSearchResults,
    TResult Function(PluginLyrics field0, LyricsMetadata field1)? lyricsById,
    TResult Function(List<Suggestion> field0)? suggestions,
    TResult Function()? ack,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails() when albumDetails != null:
        return albumDetails(_that.field0);
      case PluginResponse_ArtistDetails() when artistDetails != null:
        return artistDetails(_that.field0);
      case PluginResponse_PlaylistDetails() when playlistDetails != null:
        return playlistDetails(_that.field0);
      case PluginResponse_Streams() when streams != null:
        return streams(_that.field0);
      case PluginResponse_Search() when search != null:
        return search(_that.field0);
      case PluginResponse_MoreTracks() when moreTracks != null:
        return moreTracks(_that.field0);
      case PluginResponse_MoreAlbums() when moreAlbums != null:
        return moreAlbums(_that.field0);
      case PluginResponse_HomeSections() when homeSections != null:
        return homeSections(_that.field0);
      case PluginResponse_LoadMoreItems() when loadMoreItems != null:
        return loadMoreItems(_that.field0);
      case PluginResponse_Charts() when charts != null:
        return charts(_that.field0);
      case PluginResponse_ChartDetails() when chartDetails != null:
        return chartDetails(_that.field0);
      case PluginResponse_Segments() when segments != null:
        return segments(_that.field0);
      case PluginResponse_LyricsResult() when lyricsResult != null:
        return lyricsResult(_that.field0);
      case PluginResponse_LyricsSearchResults()
          when lyricsSearchResults != null:
        return lyricsSearchResults(_that.field0);
      case PluginResponse_LyricsById() when lyricsById != null:
        return lyricsById(_that.field0, _that.field1);
      case PluginResponse_Suggestions() when suggestions != null:
        return suggestions(_that.field0);
      case PluginResponse_Ack() when ack != null:
        return ack();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AlbumDetails field0) albumDetails,
    required TResult Function(ArtistDetails field0) artistDetails,
    required TResult Function(PlaylistDetails field0) playlistDetails,
    required TResult Function(List<StreamSource> field0) streams,
    required TResult Function(PagedMediaItems field0) search,
    required TResult Function(PagedTracks field0) moreTracks,
    required TResult Function(PagedAlbums field0) moreAlbums,
    required TResult Function(List<Section> field0) homeSections,
    required TResult Function(List<MediaItem> field0) loadMoreItems,
    required TResult Function(List<ChartSummary> field0) charts,
    required TResult Function(List<ChartItem> field0) chartDetails,
    required TResult Function(List<TrackSegment> field0) segments,
    required TResult Function((PluginLyrics, LyricsMetadata)? field0)
        lyricsResult,
    required TResult Function(List<LyricsMatch> field0) lyricsSearchResults,
    required TResult Function(PluginLyrics field0, LyricsMetadata field1)
        lyricsById,
    required TResult Function(List<Suggestion> field0) suggestions,
    required TResult Function() ack,
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails():
        return albumDetails(_that.field0);
      case PluginResponse_ArtistDetails():
        return artistDetails(_that.field0);
      case PluginResponse_PlaylistDetails():
        return playlistDetails(_that.field0);
      case PluginResponse_Streams():
        return streams(_that.field0);
      case PluginResponse_Search():
        return search(_that.field0);
      case PluginResponse_MoreTracks():
        return moreTracks(_that.field0);
      case PluginResponse_MoreAlbums():
        return moreAlbums(_that.field0);
      case PluginResponse_HomeSections():
        return homeSections(_that.field0);
      case PluginResponse_LoadMoreItems():
        return loadMoreItems(_that.field0);
      case PluginResponse_Charts():
        return charts(_that.field0);
      case PluginResponse_ChartDetails():
        return chartDetails(_that.field0);
      case PluginResponse_Segments():
        return segments(_that.field0);
      case PluginResponse_LyricsResult():
        return lyricsResult(_that.field0);
      case PluginResponse_LyricsSearchResults():
        return lyricsSearchResults(_that.field0);
      case PluginResponse_LyricsById():
        return lyricsById(_that.field0, _that.field1);
      case PluginResponse_Suggestions():
        return suggestions(_that.field0);
      case PluginResponse_Ack():
        return ack();
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AlbumDetails field0)? albumDetails,
    TResult? Function(ArtistDetails field0)? artistDetails,
    TResult? Function(PlaylistDetails field0)? playlistDetails,
    TResult? Function(List<StreamSource> field0)? streams,
    TResult? Function(PagedMediaItems field0)? search,
    TResult? Function(PagedTracks field0)? moreTracks,
    TResult? Function(PagedAlbums field0)? moreAlbums,
    TResult? Function(List<Section> field0)? homeSections,
    TResult? Function(List<MediaItem> field0)? loadMoreItems,
    TResult? Function(List<ChartSummary> field0)? charts,
    TResult? Function(List<ChartItem> field0)? chartDetails,
    TResult? Function(List<TrackSegment> field0)? segments,
    TResult? Function((PluginLyrics, LyricsMetadata)? field0)? lyricsResult,
    TResult? Function(List<LyricsMatch> field0)? lyricsSearchResults,
    TResult? Function(PluginLyrics field0, LyricsMetadata field1)? lyricsById,
    TResult? Function(List<Suggestion> field0)? suggestions,
    TResult? Function()? ack,
  }) {
    final _that = this;
    switch (_that) {
      case PluginResponse_AlbumDetails() when albumDetails != null:
        return albumDetails(_that.field0);
      case PluginResponse_ArtistDetails() when artistDetails != null:
        return artistDetails(_that.field0);
      case PluginResponse_PlaylistDetails() when playlistDetails != null:
        return playlistDetails(_that.field0);
      case PluginResponse_Streams() when streams != null:
        return streams(_that.field0);
      case PluginResponse_Search() when search != null:
        return search(_that.field0);
      case PluginResponse_MoreTracks() when moreTracks != null:
        return moreTracks(_that.field0);
      case PluginResponse_MoreAlbums() when moreAlbums != null:
        return moreAlbums(_that.field0);
      case PluginResponse_HomeSections() when homeSections != null:
        return homeSections(_that.field0);
      case PluginResponse_LoadMoreItems() when loadMoreItems != null:
        return loadMoreItems(_that.field0);
      case PluginResponse_Charts() when charts != null:
        return charts(_that.field0);
      case PluginResponse_ChartDetails() when chartDetails != null:
        return chartDetails(_that.field0);
      case PluginResponse_Segments() when segments != null:
        return segments(_that.field0);
      case PluginResponse_LyricsResult() when lyricsResult != null:
        return lyricsResult(_that.field0);
      case PluginResponse_LyricsSearchResults()
          when lyricsSearchResults != null:
        return lyricsSearchResults(_that.field0);
      case PluginResponse_LyricsById() when lyricsById != null:
        return lyricsById(_that.field0, _that.field1);
      case PluginResponse_Suggestions() when suggestions != null:
        return suggestions(_that.field0);
      case PluginResponse_Ack() when ack != null:
        return ack();
      case _:
        return null;
    }
  }
}

/// @nodoc

class PluginResponse_AlbumDetails extends PluginResponse {
  const PluginResponse_AlbumDetails(this.field0) : super._();

  final AlbumDetails field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_AlbumDetailsCopyWith<PluginResponse_AlbumDetails>
      get copyWith => _$PluginResponse_AlbumDetailsCopyWithImpl<
          PluginResponse_AlbumDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_AlbumDetails &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.albumDetails(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_AlbumDetailsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_AlbumDetailsCopyWith(
          PluginResponse_AlbumDetails value,
          $Res Function(PluginResponse_AlbumDetails) _then) =
      _$PluginResponse_AlbumDetailsCopyWithImpl;
  @useResult
  $Res call({AlbumDetails field0});
}

/// @nodoc
class _$PluginResponse_AlbumDetailsCopyWithImpl<$Res>
    implements $PluginResponse_AlbumDetailsCopyWith<$Res> {
  _$PluginResponse_AlbumDetailsCopyWithImpl(this._self, this._then);

  final PluginResponse_AlbumDetails _self;
  final $Res Function(PluginResponse_AlbumDetails) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_AlbumDetails(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as AlbumDetails,
    ));
  }
}

/// @nodoc

class PluginResponse_ArtistDetails extends PluginResponse {
  const PluginResponse_ArtistDetails(this.field0) : super._();

  final ArtistDetails field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_ArtistDetailsCopyWith<PluginResponse_ArtistDetails>
      get copyWith => _$PluginResponse_ArtistDetailsCopyWithImpl<
          PluginResponse_ArtistDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_ArtistDetails &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.artistDetails(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_ArtistDetailsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_ArtistDetailsCopyWith(
          PluginResponse_ArtistDetails value,
          $Res Function(PluginResponse_ArtistDetails) _then) =
      _$PluginResponse_ArtistDetailsCopyWithImpl;
  @useResult
  $Res call({ArtistDetails field0});
}

/// @nodoc
class _$PluginResponse_ArtistDetailsCopyWithImpl<$Res>
    implements $PluginResponse_ArtistDetailsCopyWith<$Res> {
  _$PluginResponse_ArtistDetailsCopyWithImpl(this._self, this._then);

  final PluginResponse_ArtistDetails _self;
  final $Res Function(PluginResponse_ArtistDetails) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_ArtistDetails(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ArtistDetails,
    ));
  }
}

/// @nodoc

class PluginResponse_PlaylistDetails extends PluginResponse {
  const PluginResponse_PlaylistDetails(this.field0) : super._();

  final PlaylistDetails field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_PlaylistDetailsCopyWith<PluginResponse_PlaylistDetails>
      get copyWith => _$PluginResponse_PlaylistDetailsCopyWithImpl<
          PluginResponse_PlaylistDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_PlaylistDetails &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.playlistDetails(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_PlaylistDetailsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_PlaylistDetailsCopyWith(
          PluginResponse_PlaylistDetails value,
          $Res Function(PluginResponse_PlaylistDetails) _then) =
      _$PluginResponse_PlaylistDetailsCopyWithImpl;
  @useResult
  $Res call({PlaylistDetails field0});
}

/// @nodoc
class _$PluginResponse_PlaylistDetailsCopyWithImpl<$Res>
    implements $PluginResponse_PlaylistDetailsCopyWith<$Res> {
  _$PluginResponse_PlaylistDetailsCopyWithImpl(this._self, this._then);

  final PluginResponse_PlaylistDetails _self;
  final $Res Function(PluginResponse_PlaylistDetails) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_PlaylistDetails(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PlaylistDetails,
    ));
  }
}

/// @nodoc

class PluginResponse_Streams extends PluginResponse {
  const PluginResponse_Streams(final List<StreamSource> field0)
      : _field0 = field0,
        super._();

  final List<StreamSource> _field0;
  List<StreamSource> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_StreamsCopyWith<PluginResponse_Streams> get copyWith =>
      _$PluginResponse_StreamsCopyWithImpl<PluginResponse_Streams>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_Streams &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.streams(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_StreamsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_StreamsCopyWith(PluginResponse_Streams value,
          $Res Function(PluginResponse_Streams) _then) =
      _$PluginResponse_StreamsCopyWithImpl;
  @useResult
  $Res call({List<StreamSource> field0});
}

/// @nodoc
class _$PluginResponse_StreamsCopyWithImpl<$Res>
    implements $PluginResponse_StreamsCopyWith<$Res> {
  _$PluginResponse_StreamsCopyWithImpl(this._self, this._then);

  final PluginResponse_Streams _self;
  final $Res Function(PluginResponse_Streams) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_Streams(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<StreamSource>,
    ));
  }
}

/// @nodoc

class PluginResponse_Search extends PluginResponse {
  const PluginResponse_Search(this.field0) : super._();

  final PagedMediaItems field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_SearchCopyWith<PluginResponse_Search> get copyWith =>
      _$PluginResponse_SearchCopyWithImpl<PluginResponse_Search>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_Search &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.search(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_SearchCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_SearchCopyWith(PluginResponse_Search value,
          $Res Function(PluginResponse_Search) _then) =
      _$PluginResponse_SearchCopyWithImpl;
  @useResult
  $Res call({PagedMediaItems field0});
}

/// @nodoc
class _$PluginResponse_SearchCopyWithImpl<$Res>
    implements $PluginResponse_SearchCopyWith<$Res> {
  _$PluginResponse_SearchCopyWithImpl(this._self, this._then);

  final PluginResponse_Search _self;
  final $Res Function(PluginResponse_Search) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_Search(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PagedMediaItems,
    ));
  }
}

/// @nodoc

class PluginResponse_MoreTracks extends PluginResponse {
  const PluginResponse_MoreTracks(this.field0) : super._();

  final PagedTracks field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_MoreTracksCopyWith<PluginResponse_MoreTracks> get copyWith =>
      _$PluginResponse_MoreTracksCopyWithImpl<PluginResponse_MoreTracks>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_MoreTracks &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.moreTracks(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_MoreTracksCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_MoreTracksCopyWith(PluginResponse_MoreTracks value,
          $Res Function(PluginResponse_MoreTracks) _then) =
      _$PluginResponse_MoreTracksCopyWithImpl;
  @useResult
  $Res call({PagedTracks field0});
}

/// @nodoc
class _$PluginResponse_MoreTracksCopyWithImpl<$Res>
    implements $PluginResponse_MoreTracksCopyWith<$Res> {
  _$PluginResponse_MoreTracksCopyWithImpl(this._self, this._then);

  final PluginResponse_MoreTracks _self;
  final $Res Function(PluginResponse_MoreTracks) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_MoreTracks(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PagedTracks,
    ));
  }
}

/// @nodoc

class PluginResponse_MoreAlbums extends PluginResponse {
  const PluginResponse_MoreAlbums(this.field0) : super._();

  final PagedAlbums field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_MoreAlbumsCopyWith<PluginResponse_MoreAlbums> get copyWith =>
      _$PluginResponse_MoreAlbumsCopyWithImpl<PluginResponse_MoreAlbums>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_MoreAlbums &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.moreAlbums(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_MoreAlbumsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_MoreAlbumsCopyWith(PluginResponse_MoreAlbums value,
          $Res Function(PluginResponse_MoreAlbums) _then) =
      _$PluginResponse_MoreAlbumsCopyWithImpl;
  @useResult
  $Res call({PagedAlbums field0});
}

/// @nodoc
class _$PluginResponse_MoreAlbumsCopyWithImpl<$Res>
    implements $PluginResponse_MoreAlbumsCopyWith<$Res> {
  _$PluginResponse_MoreAlbumsCopyWithImpl(this._self, this._then);

  final PluginResponse_MoreAlbums _self;
  final $Res Function(PluginResponse_MoreAlbums) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_MoreAlbums(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PagedAlbums,
    ));
  }
}

/// @nodoc

class PluginResponse_HomeSections extends PluginResponse {
  const PluginResponse_HomeSections(final List<Section> field0)
      : _field0 = field0,
        super._();

  final List<Section> _field0;
  List<Section> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_HomeSectionsCopyWith<PluginResponse_HomeSections>
      get copyWith => _$PluginResponse_HomeSectionsCopyWithImpl<
          PluginResponse_HomeSections>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_HomeSections &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.homeSections(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_HomeSectionsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_HomeSectionsCopyWith(
          PluginResponse_HomeSections value,
          $Res Function(PluginResponse_HomeSections) _then) =
      _$PluginResponse_HomeSectionsCopyWithImpl;
  @useResult
  $Res call({List<Section> field0});
}

/// @nodoc
class _$PluginResponse_HomeSectionsCopyWithImpl<$Res>
    implements $PluginResponse_HomeSectionsCopyWith<$Res> {
  _$PluginResponse_HomeSectionsCopyWithImpl(this._self, this._then);

  final PluginResponse_HomeSections _self;
  final $Res Function(PluginResponse_HomeSections) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_HomeSections(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<Section>,
    ));
  }
}

/// @nodoc

class PluginResponse_LoadMoreItems extends PluginResponse {
  const PluginResponse_LoadMoreItems(final List<MediaItem> field0)
      : _field0 = field0,
        super._();

  final List<MediaItem> _field0;
  List<MediaItem> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_LoadMoreItemsCopyWith<PluginResponse_LoadMoreItems>
      get copyWith => _$PluginResponse_LoadMoreItemsCopyWithImpl<
          PluginResponse_LoadMoreItems>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_LoadMoreItems &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.loadMoreItems(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_LoadMoreItemsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_LoadMoreItemsCopyWith(
          PluginResponse_LoadMoreItems value,
          $Res Function(PluginResponse_LoadMoreItems) _then) =
      _$PluginResponse_LoadMoreItemsCopyWithImpl;
  @useResult
  $Res call({List<MediaItem> field0});
}

/// @nodoc
class _$PluginResponse_LoadMoreItemsCopyWithImpl<$Res>
    implements $PluginResponse_LoadMoreItemsCopyWith<$Res> {
  _$PluginResponse_LoadMoreItemsCopyWithImpl(this._self, this._then);

  final PluginResponse_LoadMoreItems _self;
  final $Res Function(PluginResponse_LoadMoreItems) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_LoadMoreItems(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<MediaItem>,
    ));
  }
}

/// @nodoc

class PluginResponse_Charts extends PluginResponse {
  const PluginResponse_Charts(final List<ChartSummary> field0)
      : _field0 = field0,
        super._();

  final List<ChartSummary> _field0;
  List<ChartSummary> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_ChartsCopyWith<PluginResponse_Charts> get copyWith =>
      _$PluginResponse_ChartsCopyWithImpl<PluginResponse_Charts>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_Charts &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.charts(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_ChartsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_ChartsCopyWith(PluginResponse_Charts value,
          $Res Function(PluginResponse_Charts) _then) =
      _$PluginResponse_ChartsCopyWithImpl;
  @useResult
  $Res call({List<ChartSummary> field0});
}

/// @nodoc
class _$PluginResponse_ChartsCopyWithImpl<$Res>
    implements $PluginResponse_ChartsCopyWith<$Res> {
  _$PluginResponse_ChartsCopyWithImpl(this._self, this._then);

  final PluginResponse_Charts _self;
  final $Res Function(PluginResponse_Charts) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_Charts(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<ChartSummary>,
    ));
  }
}

/// @nodoc

class PluginResponse_ChartDetails extends PluginResponse {
  const PluginResponse_ChartDetails(final List<ChartItem> field0)
      : _field0 = field0,
        super._();

  final List<ChartItem> _field0;
  List<ChartItem> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_ChartDetailsCopyWith<PluginResponse_ChartDetails>
      get copyWith => _$PluginResponse_ChartDetailsCopyWithImpl<
          PluginResponse_ChartDetails>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_ChartDetails &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.chartDetails(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_ChartDetailsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_ChartDetailsCopyWith(
          PluginResponse_ChartDetails value,
          $Res Function(PluginResponse_ChartDetails) _then) =
      _$PluginResponse_ChartDetailsCopyWithImpl;
  @useResult
  $Res call({List<ChartItem> field0});
}

/// @nodoc
class _$PluginResponse_ChartDetailsCopyWithImpl<$Res>
    implements $PluginResponse_ChartDetailsCopyWith<$Res> {
  _$PluginResponse_ChartDetailsCopyWithImpl(this._self, this._then);

  final PluginResponse_ChartDetails _self;
  final $Res Function(PluginResponse_ChartDetails) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_ChartDetails(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<ChartItem>,
    ));
  }
}

/// @nodoc

class PluginResponse_Segments extends PluginResponse {
  const PluginResponse_Segments(final List<TrackSegment> field0)
      : _field0 = field0,
        super._();

  final List<TrackSegment> _field0;
  List<TrackSegment> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_SegmentsCopyWith<PluginResponse_Segments> get copyWith =>
      _$PluginResponse_SegmentsCopyWithImpl<PluginResponse_Segments>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_Segments &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.segments(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_SegmentsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_SegmentsCopyWith(PluginResponse_Segments value,
          $Res Function(PluginResponse_Segments) _then) =
      _$PluginResponse_SegmentsCopyWithImpl;
  @useResult
  $Res call({List<TrackSegment> field0});
}

/// @nodoc
class _$PluginResponse_SegmentsCopyWithImpl<$Res>
    implements $PluginResponse_SegmentsCopyWith<$Res> {
  _$PluginResponse_SegmentsCopyWithImpl(this._self, this._then);

  final PluginResponse_Segments _self;
  final $Res Function(PluginResponse_Segments) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_Segments(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<TrackSegment>,
    ));
  }
}

/// @nodoc

class PluginResponse_LyricsResult extends PluginResponse {
  const PluginResponse_LyricsResult([this.field0]) : super._();

  final (PluginLyrics, LyricsMetadata)? field0;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_LyricsResultCopyWith<PluginResponse_LyricsResult>
      get copyWith => _$PluginResponse_LyricsResultCopyWithImpl<
          PluginResponse_LyricsResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_LyricsResult &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'PluginResponse.lyricsResult(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_LyricsResultCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_LyricsResultCopyWith(
          PluginResponse_LyricsResult value,
          $Res Function(PluginResponse_LyricsResult) _then) =
      _$PluginResponse_LyricsResultCopyWithImpl;
  @useResult
  $Res call({(PluginLyrics, LyricsMetadata)? field0});
}

/// @nodoc
class _$PluginResponse_LyricsResultCopyWithImpl<$Res>
    implements $PluginResponse_LyricsResultCopyWith<$Res> {
  _$PluginResponse_LyricsResultCopyWithImpl(this._self, this._then);

  final PluginResponse_LyricsResult _self;
  final $Res Function(PluginResponse_LyricsResult) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(PluginResponse_LyricsResult(
      freezed == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as (PluginLyrics, LyricsMetadata)?,
    ));
  }
}

/// @nodoc

class PluginResponse_LyricsSearchResults extends PluginResponse {
  const PluginResponse_LyricsSearchResults(final List<LyricsMatch> field0)
      : _field0 = field0,
        super._();

  final List<LyricsMatch> _field0;
  List<LyricsMatch> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_LyricsSearchResultsCopyWith<
          PluginResponse_LyricsSearchResults>
      get copyWith => _$PluginResponse_LyricsSearchResultsCopyWithImpl<
          PluginResponse_LyricsSearchResults>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_LyricsSearchResults &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.lyricsSearchResults(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_LyricsSearchResultsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_LyricsSearchResultsCopyWith(
          PluginResponse_LyricsSearchResults value,
          $Res Function(PluginResponse_LyricsSearchResults) _then) =
      _$PluginResponse_LyricsSearchResultsCopyWithImpl;
  @useResult
  $Res call({List<LyricsMatch> field0});
}

/// @nodoc
class _$PluginResponse_LyricsSearchResultsCopyWithImpl<$Res>
    implements $PluginResponse_LyricsSearchResultsCopyWith<$Res> {
  _$PluginResponse_LyricsSearchResultsCopyWithImpl(this._self, this._then);

  final PluginResponse_LyricsSearchResults _self;
  final $Res Function(PluginResponse_LyricsSearchResults) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_LyricsSearchResults(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<LyricsMatch>,
    ));
  }
}

/// @nodoc

class PluginResponse_LyricsById extends PluginResponse {
  const PluginResponse_LyricsById(this.field0, this.field1) : super._();

  final PluginLyrics field0;
  final LyricsMetadata field1;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_LyricsByIdCopyWith<PluginResponse_LyricsById> get copyWith =>
      _$PluginResponse_LyricsByIdCopyWithImpl<PluginResponse_LyricsById>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_LyricsById &&
            (identical(other.field0, field0) || other.field0 == field0) &&
            (identical(other.field1, field1) || other.field1 == field1));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0, field1);

  @override
  String toString() {
    return 'PluginResponse.lyricsById(field0: $field0, field1: $field1)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_LyricsByIdCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_LyricsByIdCopyWith(PluginResponse_LyricsById value,
          $Res Function(PluginResponse_LyricsById) _then) =
      _$PluginResponse_LyricsByIdCopyWithImpl;
  @useResult
  $Res call({PluginLyrics field0, LyricsMetadata field1});
}

/// @nodoc
class _$PluginResponse_LyricsByIdCopyWithImpl<$Res>
    implements $PluginResponse_LyricsByIdCopyWith<$Res> {
  _$PluginResponse_LyricsByIdCopyWithImpl(this._self, this._then);

  final PluginResponse_LyricsById _self;
  final $Res Function(PluginResponse_LyricsById) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
    Object? field1 = null,
  }) {
    return _then(PluginResponse_LyricsById(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PluginLyrics,
      null == field1
          ? _self.field1
          : field1 // ignore: cast_nullable_to_non_nullable
              as LyricsMetadata,
    ));
  }
}

/// @nodoc

class PluginResponse_Suggestions extends PluginResponse {
  const PluginResponse_Suggestions(final List<Suggestion> field0)
      : _field0 = field0,
        super._();

  final List<Suggestion> _field0;
  List<Suggestion> get field0 {
    if (_field0 is EqualUnmodifiableListView) return _field0;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginResponse_SuggestionsCopyWith<PluginResponse_Suggestions>
      get copyWith =>
          _$PluginResponse_SuggestionsCopyWithImpl<PluginResponse_Suggestions>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginResponse_Suggestions &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @override
  String toString() {
    return 'PluginResponse.suggestions(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $PluginResponse_SuggestionsCopyWith<$Res>
    implements $PluginResponseCopyWith<$Res> {
  factory $PluginResponse_SuggestionsCopyWith(PluginResponse_Suggestions value,
          $Res Function(PluginResponse_Suggestions) _then) =
      _$PluginResponse_SuggestionsCopyWithImpl;
  @useResult
  $Res call({List<Suggestion> field0});
}

/// @nodoc
class _$PluginResponse_SuggestionsCopyWithImpl<$Res>
    implements $PluginResponse_SuggestionsCopyWith<$Res> {
  _$PluginResponse_SuggestionsCopyWithImpl(this._self, this._then);

  final PluginResponse_Suggestions _self;
  final $Res Function(PluginResponse_Suggestions) _then;

  /// Create a copy of PluginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(PluginResponse_Suggestions(
      null == field0
          ? _self._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<Suggestion>,
    ));
  }
}

/// @nodoc

class PluginResponse_Ack extends PluginResponse {
  const PluginResponse_Ack() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PluginResponse_Ack);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PluginResponse.ack()';
  }
}

/// @nodoc
mixin _$SearchSuggestionCommand {
  int? get limit;
  bool get includeEntities;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchSuggestionCommandCopyWith<SearchSuggestionCommand> get copyWith =>
      _$SearchSuggestionCommandCopyWithImpl<SearchSuggestionCommand>(
          this as SearchSuggestionCommand, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchSuggestionCommand &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.includeEntities, includeEntities) ||
                other.includeEntities == includeEntities));
  }

  @override
  int get hashCode => Object.hash(runtimeType, limit, includeEntities);

  @override
  String toString() {
    return 'SearchSuggestionCommand(limit: $limit, includeEntities: $includeEntities)';
  }
}

/// @nodoc
abstract mixin class $SearchSuggestionCommandCopyWith<$Res> {
  factory $SearchSuggestionCommandCopyWith(SearchSuggestionCommand value,
          $Res Function(SearchSuggestionCommand) _then) =
      _$SearchSuggestionCommandCopyWithImpl;
  @useResult
  $Res call({int? limit, bool includeEntities});
}

/// @nodoc
class _$SearchSuggestionCommandCopyWithImpl<$Res>
    implements $SearchSuggestionCommandCopyWith<$Res> {
  _$SearchSuggestionCommandCopyWithImpl(this._self, this._then);

  final SearchSuggestionCommand _self;
  final $Res Function(SearchSuggestionCommand) _then;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = freezed,
    Object? includeEntities = null,
  }) {
    return _then(_self.copyWith(
      limit: freezed == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      includeEntities: null == includeEntities
          ? _self.includeEntities
          : includeEntities // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SearchSuggestionCommand].
extension SearchSuggestionCommandPatterns on SearchSuggestionCommand {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchSuggestionCommand_GetSuggestions value)?
        getSuggestions,
    TResult Function(SearchSuggestionCommand_GetDefaultSuggestions value)?
        getDefaultSuggestions,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions() when getSuggestions != null:
        return getSuggestions(_that);
      case SearchSuggestionCommand_GetDefaultSuggestions()
          when getDefaultSuggestions != null:
        return getDefaultSuggestions(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchSuggestionCommand_GetSuggestions value)
        getSuggestions,
    required TResult Function(
            SearchSuggestionCommand_GetDefaultSuggestions value)
        getDefaultSuggestions,
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions():
        return getSuggestions(_that);
      case SearchSuggestionCommand_GetDefaultSuggestions():
        return getDefaultSuggestions(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchSuggestionCommand_GetSuggestions value)?
        getSuggestions,
    TResult? Function(SearchSuggestionCommand_GetDefaultSuggestions value)?
        getDefaultSuggestions,
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions() when getSuggestions != null:
        return getSuggestions(_that);
      case SearchSuggestionCommand_GetDefaultSuggestions()
          when getDefaultSuggestions != null:
        return getDefaultSuggestions(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String query, int? limit, bool includeEntities)?
        getSuggestions,
    TResult Function(int? limit, bool includeEntities)? getDefaultSuggestions,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions() when getSuggestions != null:
        return getSuggestions(_that.query, _that.limit, _that.includeEntities);
      case SearchSuggestionCommand_GetDefaultSuggestions()
          when getDefaultSuggestions != null:
        return getDefaultSuggestions(_that.limit, _that.includeEntities);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String query, int? limit, bool includeEntities)
        getSuggestions,
    required TResult Function(int? limit, bool includeEntities)
        getDefaultSuggestions,
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions():
        return getSuggestions(_that.query, _that.limit, _that.includeEntities);
      case SearchSuggestionCommand_GetDefaultSuggestions():
        return getDefaultSuggestions(_that.limit, _that.includeEntities);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String query, int? limit, bool includeEntities)?
        getSuggestions,
    TResult? Function(int? limit, bool includeEntities)? getDefaultSuggestions,
  }) {
    final _that = this;
    switch (_that) {
      case SearchSuggestionCommand_GetSuggestions() when getSuggestions != null:
        return getSuggestions(_that.query, _that.limit, _that.includeEntities);
      case SearchSuggestionCommand_GetDefaultSuggestions()
          when getDefaultSuggestions != null:
        return getDefaultSuggestions(_that.limit, _that.includeEntities);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SearchSuggestionCommand_GetSuggestions extends SearchSuggestionCommand {
  const SearchSuggestionCommand_GetSuggestions(
      {required this.query, this.limit, required this.includeEntities})
      : super._();

  final String query;
  @override
  final int? limit;
  @override
  final bool includeEntities;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchSuggestionCommand_GetSuggestionsCopyWith<
          SearchSuggestionCommand_GetSuggestions>
      get copyWith => _$SearchSuggestionCommand_GetSuggestionsCopyWithImpl<
          SearchSuggestionCommand_GetSuggestions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchSuggestionCommand_GetSuggestions &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.includeEntities, includeEntities) ||
                other.includeEntities == includeEntities));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query, limit, includeEntities);

  @override
  String toString() {
    return 'SearchSuggestionCommand.getSuggestions(query: $query, limit: $limit, includeEntities: $includeEntities)';
  }
}

/// @nodoc
abstract mixin class $SearchSuggestionCommand_GetSuggestionsCopyWith<$Res>
    implements $SearchSuggestionCommandCopyWith<$Res> {
  factory $SearchSuggestionCommand_GetSuggestionsCopyWith(
          SearchSuggestionCommand_GetSuggestions value,
          $Res Function(SearchSuggestionCommand_GetSuggestions) _then) =
      _$SearchSuggestionCommand_GetSuggestionsCopyWithImpl;
  @override
  @useResult
  $Res call({String query, int? limit, bool includeEntities});
}

/// @nodoc
class _$SearchSuggestionCommand_GetSuggestionsCopyWithImpl<$Res>
    implements $SearchSuggestionCommand_GetSuggestionsCopyWith<$Res> {
  _$SearchSuggestionCommand_GetSuggestionsCopyWithImpl(this._self, this._then);

  final SearchSuggestionCommand_GetSuggestions _self;
  final $Res Function(SearchSuggestionCommand_GetSuggestions) _then;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
    Object? limit = freezed,
    Object? includeEntities = null,
  }) {
    return _then(SearchSuggestionCommand_GetSuggestions(
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      limit: freezed == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      includeEntities: null == includeEntities
          ? _self.includeEntities
          : includeEntities // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class SearchSuggestionCommand_GetDefaultSuggestions
    extends SearchSuggestionCommand {
  const SearchSuggestionCommand_GetDefaultSuggestions(
      {this.limit, required this.includeEntities})
      : super._();

  @override
  final int? limit;
  @override
  final bool includeEntities;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchSuggestionCommand_GetDefaultSuggestionsCopyWith<
          SearchSuggestionCommand_GetDefaultSuggestions>
      get copyWith =>
          _$SearchSuggestionCommand_GetDefaultSuggestionsCopyWithImpl<
              SearchSuggestionCommand_GetDefaultSuggestions>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchSuggestionCommand_GetDefaultSuggestions &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.includeEntities, includeEntities) ||
                other.includeEntities == includeEntities));
  }

  @override
  int get hashCode => Object.hash(runtimeType, limit, includeEntities);

  @override
  String toString() {
    return 'SearchSuggestionCommand.getDefaultSuggestions(limit: $limit, includeEntities: $includeEntities)';
  }
}

/// @nodoc
abstract mixin class $SearchSuggestionCommand_GetDefaultSuggestionsCopyWith<
    $Res> implements $SearchSuggestionCommandCopyWith<$Res> {
  factory $SearchSuggestionCommand_GetDefaultSuggestionsCopyWith(
          SearchSuggestionCommand_GetDefaultSuggestions value,
          $Res Function(SearchSuggestionCommand_GetDefaultSuggestions) _then) =
      _$SearchSuggestionCommand_GetDefaultSuggestionsCopyWithImpl;
  @override
  @useResult
  $Res call({int? limit, bool includeEntities});
}

/// @nodoc
class _$SearchSuggestionCommand_GetDefaultSuggestionsCopyWithImpl<$Res>
    implements $SearchSuggestionCommand_GetDefaultSuggestionsCopyWith<$Res> {
  _$SearchSuggestionCommand_GetDefaultSuggestionsCopyWithImpl(
      this._self, this._then);

  final SearchSuggestionCommand_GetDefaultSuggestions _self;
  final $Res Function(SearchSuggestionCommand_GetDefaultSuggestions) _then;

  /// Create a copy of SearchSuggestionCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? limit = freezed,
    Object? includeEntities = null,
  }) {
    return _then(SearchSuggestionCommand_GetDefaultSuggestions(
      limit: freezed == limit
          ? _self.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      includeEntities: null == includeEntities
          ? _self.includeEntities
          : includeEntities // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
