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
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that);
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
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver():
        return contentResolver(_that);
      case PluginRequest_ChartProvider():
        return chartProvider(_that);
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
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that);
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
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that.field0);
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
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver():
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider():
        return chartProvider(_that.field0);
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
  }) {
    final _that = this;
    switch (_that) {
      case PluginRequest_ContentResolver() when contentResolver != null:
        return contentResolver(_that.field0);
      case PluginRequest_ChartProvider() when chartProvider != null:
        return chartProvider(_that.field0);
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

// dart format on
