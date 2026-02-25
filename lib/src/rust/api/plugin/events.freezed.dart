// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PluginManagerEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PluginManagerEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PluginManagerEvent()';
  }
}

/// @nodoc
class $PluginManagerEventCopyWith<$Res> {
  $PluginManagerEventCopyWith(
      PluginManagerEvent _, $Res Function(PluginManagerEvent) __);
}

/// Adds pattern-matching-related methods to [PluginManagerEvent].
extension PluginManagerEventPatterns on PluginManagerEvent {
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
    TResult Function(PluginManagerEvent_PluginLoading value)? pluginLoading,
    TResult Function(PluginManagerEvent_PluginLoaded value)? pluginLoaded,
    TResult Function(PluginManagerEvent_PluginLoadFailed value)?
        pluginLoadFailed,
    TResult Function(PluginManagerEvent_PluginUnloading value)? pluginUnloading,
    TResult Function(PluginManagerEvent_PluginUnloaded value)? pluginUnloaded,
    TResult Function(PluginManagerEvent_PluginUnloadFailed value)?
        pluginUnloadFailed,
    TResult Function(PluginManagerEvent_PluginInstalling value)?
        pluginInstalling,
    TResult Function(PluginManagerEvent_PluginInstalled value)? pluginInstalled,
    TResult Function(PluginManagerEvent_PluginInstallFailed value)?
        pluginInstallFailed,
    TResult Function(PluginManagerEvent_PluginDeleting value)? pluginDeleting,
    TResult Function(PluginManagerEvent_PluginDeleted value)? pluginDeleted,
    TResult Function(PluginManagerEvent_PluginDeleteFailed value)?
        pluginDeleteFailed,
    TResult Function(PluginManagerEvent_PluginListRefreshed value)?
        pluginListRefreshed,
    TResult Function(PluginManagerEvent_StorageSet value)? storageSet,
    TResult Function(PluginManagerEvent_StorageDeleted value)? storageDeleted,
    TResult Function(PluginManagerEvent_StorageCleared value)? storageCleared,
    TResult Function(PluginManagerEvent_ManagerInitialized value)?
        managerInitialized,
    TResult Function(PluginManagerEvent_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading() when pluginLoading != null:
        return pluginLoading(_that);
      case PluginManagerEvent_PluginLoaded() when pluginLoaded != null:
        return pluginLoaded(_that);
      case PluginManagerEvent_PluginLoadFailed() when pluginLoadFailed != null:
        return pluginLoadFailed(_that);
      case PluginManagerEvent_PluginUnloading() when pluginUnloading != null:
        return pluginUnloading(_that);
      case PluginManagerEvent_PluginUnloaded() when pluginUnloaded != null:
        return pluginUnloaded(_that);
      case PluginManagerEvent_PluginUnloadFailed()
          when pluginUnloadFailed != null:
        return pluginUnloadFailed(_that);
      case PluginManagerEvent_PluginInstalling() when pluginInstalling != null:
        return pluginInstalling(_that);
      case PluginManagerEvent_PluginInstalled() when pluginInstalled != null:
        return pluginInstalled(_that);
      case PluginManagerEvent_PluginInstallFailed()
          when pluginInstallFailed != null:
        return pluginInstallFailed(_that);
      case PluginManagerEvent_PluginDeleting() when pluginDeleting != null:
        return pluginDeleting(_that);
      case PluginManagerEvent_PluginDeleted() when pluginDeleted != null:
        return pluginDeleted(_that);
      case PluginManagerEvent_PluginDeleteFailed()
          when pluginDeleteFailed != null:
        return pluginDeleteFailed(_that);
      case PluginManagerEvent_PluginListRefreshed()
          when pluginListRefreshed != null:
        return pluginListRefreshed(_that);
      case PluginManagerEvent_StorageSet() when storageSet != null:
        return storageSet(_that);
      case PluginManagerEvent_StorageDeleted() when storageDeleted != null:
        return storageDeleted(_that);
      case PluginManagerEvent_StorageCleared() when storageCleared != null:
        return storageCleared(_that);
      case PluginManagerEvent_ManagerInitialized()
          when managerInitialized != null:
        return managerInitialized(_that);
      case PluginManagerEvent_Error() when error != null:
        return error(_that);
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
    required TResult Function(PluginManagerEvent_PluginLoading value)
        pluginLoading,
    required TResult Function(PluginManagerEvent_PluginLoaded value)
        pluginLoaded,
    required TResult Function(PluginManagerEvent_PluginLoadFailed value)
        pluginLoadFailed,
    required TResult Function(PluginManagerEvent_PluginUnloading value)
        pluginUnloading,
    required TResult Function(PluginManagerEvent_PluginUnloaded value)
        pluginUnloaded,
    required TResult Function(PluginManagerEvent_PluginUnloadFailed value)
        pluginUnloadFailed,
    required TResult Function(PluginManagerEvent_PluginInstalling value)
        pluginInstalling,
    required TResult Function(PluginManagerEvent_PluginInstalled value)
        pluginInstalled,
    required TResult Function(PluginManagerEvent_PluginInstallFailed value)
        pluginInstallFailed,
    required TResult Function(PluginManagerEvent_PluginDeleting value)
        pluginDeleting,
    required TResult Function(PluginManagerEvent_PluginDeleted value)
        pluginDeleted,
    required TResult Function(PluginManagerEvent_PluginDeleteFailed value)
        pluginDeleteFailed,
    required TResult Function(PluginManagerEvent_PluginListRefreshed value)
        pluginListRefreshed,
    required TResult Function(PluginManagerEvent_StorageSet value) storageSet,
    required TResult Function(PluginManagerEvent_StorageDeleted value)
        storageDeleted,
    required TResult Function(PluginManagerEvent_StorageCleared value)
        storageCleared,
    required TResult Function(PluginManagerEvent_ManagerInitialized value)
        managerInitialized,
    required TResult Function(PluginManagerEvent_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading():
        return pluginLoading(_that);
      case PluginManagerEvent_PluginLoaded():
        return pluginLoaded(_that);
      case PluginManagerEvent_PluginLoadFailed():
        return pluginLoadFailed(_that);
      case PluginManagerEvent_PluginUnloading():
        return pluginUnloading(_that);
      case PluginManagerEvent_PluginUnloaded():
        return pluginUnloaded(_that);
      case PluginManagerEvent_PluginUnloadFailed():
        return pluginUnloadFailed(_that);
      case PluginManagerEvent_PluginInstalling():
        return pluginInstalling(_that);
      case PluginManagerEvent_PluginInstalled():
        return pluginInstalled(_that);
      case PluginManagerEvent_PluginInstallFailed():
        return pluginInstallFailed(_that);
      case PluginManagerEvent_PluginDeleting():
        return pluginDeleting(_that);
      case PluginManagerEvent_PluginDeleted():
        return pluginDeleted(_that);
      case PluginManagerEvent_PluginDeleteFailed():
        return pluginDeleteFailed(_that);
      case PluginManagerEvent_PluginListRefreshed():
        return pluginListRefreshed(_that);
      case PluginManagerEvent_StorageSet():
        return storageSet(_that);
      case PluginManagerEvent_StorageDeleted():
        return storageDeleted(_that);
      case PluginManagerEvent_StorageCleared():
        return storageCleared(_that);
      case PluginManagerEvent_ManagerInitialized():
        return managerInitialized(_that);
      case PluginManagerEvent_Error():
        return error(_that);
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
    TResult? Function(PluginManagerEvent_PluginLoading value)? pluginLoading,
    TResult? Function(PluginManagerEvent_PluginLoaded value)? pluginLoaded,
    TResult? Function(PluginManagerEvent_PluginLoadFailed value)?
        pluginLoadFailed,
    TResult? Function(PluginManagerEvent_PluginUnloading value)?
        pluginUnloading,
    TResult? Function(PluginManagerEvent_PluginUnloaded value)? pluginUnloaded,
    TResult? Function(PluginManagerEvent_PluginUnloadFailed value)?
        pluginUnloadFailed,
    TResult? Function(PluginManagerEvent_PluginInstalling value)?
        pluginInstalling,
    TResult? Function(PluginManagerEvent_PluginInstalled value)?
        pluginInstalled,
    TResult? Function(PluginManagerEvent_PluginInstallFailed value)?
        pluginInstallFailed,
    TResult? Function(PluginManagerEvent_PluginDeleting value)? pluginDeleting,
    TResult? Function(PluginManagerEvent_PluginDeleted value)? pluginDeleted,
    TResult? Function(PluginManagerEvent_PluginDeleteFailed value)?
        pluginDeleteFailed,
    TResult? Function(PluginManagerEvent_PluginListRefreshed value)?
        pluginListRefreshed,
    TResult? Function(PluginManagerEvent_StorageSet value)? storageSet,
    TResult? Function(PluginManagerEvent_StorageDeleted value)? storageDeleted,
    TResult? Function(PluginManagerEvent_StorageCleared value)? storageCleared,
    TResult? Function(PluginManagerEvent_ManagerInitialized value)?
        managerInitialized,
    TResult? Function(PluginManagerEvent_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading() when pluginLoading != null:
        return pluginLoading(_that);
      case PluginManagerEvent_PluginLoaded() when pluginLoaded != null:
        return pluginLoaded(_that);
      case PluginManagerEvent_PluginLoadFailed() when pluginLoadFailed != null:
        return pluginLoadFailed(_that);
      case PluginManagerEvent_PluginUnloading() when pluginUnloading != null:
        return pluginUnloading(_that);
      case PluginManagerEvent_PluginUnloaded() when pluginUnloaded != null:
        return pluginUnloaded(_that);
      case PluginManagerEvent_PluginUnloadFailed()
          when pluginUnloadFailed != null:
        return pluginUnloadFailed(_that);
      case PluginManagerEvent_PluginInstalling() when pluginInstalling != null:
        return pluginInstalling(_that);
      case PluginManagerEvent_PluginInstalled() when pluginInstalled != null:
        return pluginInstalled(_that);
      case PluginManagerEvent_PluginInstallFailed()
          when pluginInstallFailed != null:
        return pluginInstallFailed(_that);
      case PluginManagerEvent_PluginDeleting() when pluginDeleting != null:
        return pluginDeleting(_that);
      case PluginManagerEvent_PluginDeleted() when pluginDeleted != null:
        return pluginDeleted(_that);
      case PluginManagerEvent_PluginDeleteFailed()
          when pluginDeleteFailed != null:
        return pluginDeleteFailed(_that);
      case PluginManagerEvent_PluginListRefreshed()
          when pluginListRefreshed != null:
        return pluginListRefreshed(_that);
      case PluginManagerEvent_StorageSet() when storageSet != null:
        return storageSet(_that);
      case PluginManagerEvent_StorageDeleted() when storageDeleted != null:
        return storageDeleted(_that);
      case PluginManagerEvent_StorageCleared() when storageCleared != null:
        return storageCleared(_that);
      case PluginManagerEvent_ManagerInitialized()
          when managerInitialized != null:
        return managerInitialized(_that);
      case PluginManagerEvent_Error() when error != null:
        return error(_that);
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
    TResult Function(String id)? pluginLoading,
    TResult Function(String id, PluginType pluginType)? pluginLoaded,
    TResult Function(String id, String error)? pluginLoadFailed,
    TResult Function(String id)? pluginUnloading,
    TResult Function(String id)? pluginUnloaded,
    TResult Function(String id, String error)? pluginUnloadFailed,
    TResult Function(String id)? pluginInstalling,
    TResult Function(String id)? pluginInstalled,
    TResult Function(String id, String error)? pluginInstallFailed,
    TResult Function(String id)? pluginDeleting,
    TResult Function(String id)? pluginDeleted,
    TResult Function(String id, String error)? pluginDeleteFailed,
    TResult Function(List<PluginInfo> plugins)? pluginListRefreshed,
    TResult Function(String pluginId, String key, String value)? storageSet,
    TResult Function(String pluginId, String key)? storageDeleted,
    TResult Function(String pluginId)? storageCleared,
    TResult Function()? managerInitialized,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading() when pluginLoading != null:
        return pluginLoading(_that.id);
      case PluginManagerEvent_PluginLoaded() when pluginLoaded != null:
        return pluginLoaded(_that.id, _that.pluginType);
      case PluginManagerEvent_PluginLoadFailed() when pluginLoadFailed != null:
        return pluginLoadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginUnloading() when pluginUnloading != null:
        return pluginUnloading(_that.id);
      case PluginManagerEvent_PluginUnloaded() when pluginUnloaded != null:
        return pluginUnloaded(_that.id);
      case PluginManagerEvent_PluginUnloadFailed()
          when pluginUnloadFailed != null:
        return pluginUnloadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginInstalling() when pluginInstalling != null:
        return pluginInstalling(_that.id);
      case PluginManagerEvent_PluginInstalled() when pluginInstalled != null:
        return pluginInstalled(_that.id);
      case PluginManagerEvent_PluginInstallFailed()
          when pluginInstallFailed != null:
        return pluginInstallFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginDeleting() when pluginDeleting != null:
        return pluginDeleting(_that.id);
      case PluginManagerEvent_PluginDeleted() when pluginDeleted != null:
        return pluginDeleted(_that.id);
      case PluginManagerEvent_PluginDeleteFailed()
          when pluginDeleteFailed != null:
        return pluginDeleteFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginListRefreshed()
          when pluginListRefreshed != null:
        return pluginListRefreshed(_that.plugins);
      case PluginManagerEvent_StorageSet() when storageSet != null:
        return storageSet(_that.pluginId, _that.key, _that.value);
      case PluginManagerEvent_StorageDeleted() when storageDeleted != null:
        return storageDeleted(_that.pluginId, _that.key);
      case PluginManagerEvent_StorageCleared() when storageCleared != null:
        return storageCleared(_that.pluginId);
      case PluginManagerEvent_ManagerInitialized()
          when managerInitialized != null:
        return managerInitialized();
      case PluginManagerEvent_Error() when error != null:
        return error(_that.message);
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
    required TResult Function(String id) pluginLoading,
    required TResult Function(String id, PluginType pluginType) pluginLoaded,
    required TResult Function(String id, String error) pluginLoadFailed,
    required TResult Function(String id) pluginUnloading,
    required TResult Function(String id) pluginUnloaded,
    required TResult Function(String id, String error) pluginUnloadFailed,
    required TResult Function(String id) pluginInstalling,
    required TResult Function(String id) pluginInstalled,
    required TResult Function(String id, String error) pluginInstallFailed,
    required TResult Function(String id) pluginDeleting,
    required TResult Function(String id) pluginDeleted,
    required TResult Function(String id, String error) pluginDeleteFailed,
    required TResult Function(List<PluginInfo> plugins) pluginListRefreshed,
    required TResult Function(String pluginId, String key, String value)
        storageSet,
    required TResult Function(String pluginId, String key) storageDeleted,
    required TResult Function(String pluginId) storageCleared,
    required TResult Function() managerInitialized,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading():
        return pluginLoading(_that.id);
      case PluginManagerEvent_PluginLoaded():
        return pluginLoaded(_that.id, _that.pluginType);
      case PluginManagerEvent_PluginLoadFailed():
        return pluginLoadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginUnloading():
        return pluginUnloading(_that.id);
      case PluginManagerEvent_PluginUnloaded():
        return pluginUnloaded(_that.id);
      case PluginManagerEvent_PluginUnloadFailed():
        return pluginUnloadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginInstalling():
        return pluginInstalling(_that.id);
      case PluginManagerEvent_PluginInstalled():
        return pluginInstalled(_that.id);
      case PluginManagerEvent_PluginInstallFailed():
        return pluginInstallFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginDeleting():
        return pluginDeleting(_that.id);
      case PluginManagerEvent_PluginDeleted():
        return pluginDeleted(_that.id);
      case PluginManagerEvent_PluginDeleteFailed():
        return pluginDeleteFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginListRefreshed():
        return pluginListRefreshed(_that.plugins);
      case PluginManagerEvent_StorageSet():
        return storageSet(_that.pluginId, _that.key, _that.value);
      case PluginManagerEvent_StorageDeleted():
        return storageDeleted(_that.pluginId, _that.key);
      case PluginManagerEvent_StorageCleared():
        return storageCleared(_that.pluginId);
      case PluginManagerEvent_ManagerInitialized():
        return managerInitialized();
      case PluginManagerEvent_Error():
        return error(_that.message);
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
    TResult? Function(String id)? pluginLoading,
    TResult? Function(String id, PluginType pluginType)? pluginLoaded,
    TResult? Function(String id, String error)? pluginLoadFailed,
    TResult? Function(String id)? pluginUnloading,
    TResult? Function(String id)? pluginUnloaded,
    TResult? Function(String id, String error)? pluginUnloadFailed,
    TResult? Function(String id)? pluginInstalling,
    TResult? Function(String id)? pluginInstalled,
    TResult? Function(String id, String error)? pluginInstallFailed,
    TResult? Function(String id)? pluginDeleting,
    TResult? Function(String id)? pluginDeleted,
    TResult? Function(String id, String error)? pluginDeleteFailed,
    TResult? Function(List<PluginInfo> plugins)? pluginListRefreshed,
    TResult? Function(String pluginId, String key, String value)? storageSet,
    TResult? Function(String pluginId, String key)? storageDeleted,
    TResult? Function(String pluginId)? storageCleared,
    TResult? Function()? managerInitialized,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case PluginManagerEvent_PluginLoading() when pluginLoading != null:
        return pluginLoading(_that.id);
      case PluginManagerEvent_PluginLoaded() when pluginLoaded != null:
        return pluginLoaded(_that.id, _that.pluginType);
      case PluginManagerEvent_PluginLoadFailed() when pluginLoadFailed != null:
        return pluginLoadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginUnloading() when pluginUnloading != null:
        return pluginUnloading(_that.id);
      case PluginManagerEvent_PluginUnloaded() when pluginUnloaded != null:
        return pluginUnloaded(_that.id);
      case PluginManagerEvent_PluginUnloadFailed()
          when pluginUnloadFailed != null:
        return pluginUnloadFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginInstalling() when pluginInstalling != null:
        return pluginInstalling(_that.id);
      case PluginManagerEvent_PluginInstalled() when pluginInstalled != null:
        return pluginInstalled(_that.id);
      case PluginManagerEvent_PluginInstallFailed()
          when pluginInstallFailed != null:
        return pluginInstallFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginDeleting() when pluginDeleting != null:
        return pluginDeleting(_that.id);
      case PluginManagerEvent_PluginDeleted() when pluginDeleted != null:
        return pluginDeleted(_that.id);
      case PluginManagerEvent_PluginDeleteFailed()
          when pluginDeleteFailed != null:
        return pluginDeleteFailed(_that.id, _that.error);
      case PluginManagerEvent_PluginListRefreshed()
          when pluginListRefreshed != null:
        return pluginListRefreshed(_that.plugins);
      case PluginManagerEvent_StorageSet() when storageSet != null:
        return storageSet(_that.pluginId, _that.key, _that.value);
      case PluginManagerEvent_StorageDeleted() when storageDeleted != null:
        return storageDeleted(_that.pluginId, _that.key);
      case PluginManagerEvent_StorageCleared() when storageCleared != null:
        return storageCleared(_that.pluginId);
      case PluginManagerEvent_ManagerInitialized()
          when managerInitialized != null:
        return managerInitialized();
      case PluginManagerEvent_Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class PluginManagerEvent_PluginLoading extends PluginManagerEvent {
  const PluginManagerEvent_PluginLoading({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginLoadingCopyWith<PluginManagerEvent_PluginLoading>
      get copyWith => _$PluginManagerEvent_PluginLoadingCopyWithImpl<
          PluginManagerEvent_PluginLoading>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginLoading &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginLoading(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginLoadingCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginLoadingCopyWith(
          PluginManagerEvent_PluginLoading value,
          $Res Function(PluginManagerEvent_PluginLoading) _then) =
      _$PluginManagerEvent_PluginLoadingCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginLoadingCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginLoadingCopyWith<$Res> {
  _$PluginManagerEvent_PluginLoadingCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginLoading _self;
  final $Res Function(PluginManagerEvent_PluginLoading) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginLoading(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginLoaded extends PluginManagerEvent {
  const PluginManagerEvent_PluginLoaded(
      {required this.id, required this.pluginType})
      : super._();

  final String id;
  final PluginType pluginType;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginLoadedCopyWith<PluginManagerEvent_PluginLoaded>
      get copyWith => _$PluginManagerEvent_PluginLoadedCopyWithImpl<
          PluginManagerEvent_PluginLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginLoaded &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pluginType, pluginType) ||
                other.pluginType == pluginType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pluginType);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginLoaded(id: $id, pluginType: $pluginType)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginLoadedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginLoadedCopyWith(
          PluginManagerEvent_PluginLoaded value,
          $Res Function(PluginManagerEvent_PluginLoaded) _then) =
      _$PluginManagerEvent_PluginLoadedCopyWithImpl;
  @useResult
  $Res call({String id, PluginType pluginType});
}

/// @nodoc
class _$PluginManagerEvent_PluginLoadedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginLoadedCopyWith<$Res> {
  _$PluginManagerEvent_PluginLoadedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginLoaded _self;
  final $Res Function(PluginManagerEvent_PluginLoaded) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pluginType = null,
  }) {
    return _then(PluginManagerEvent_PluginLoaded(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pluginType: null == pluginType
          ? _self.pluginType
          : pluginType // ignore: cast_nullable_to_non_nullable
              as PluginType,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginLoadFailed extends PluginManagerEvent {
  const PluginManagerEvent_PluginLoadFailed(
      {required this.id, required this.error})
      : super._();

  final String id;
  final String error;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginLoadFailedCopyWith<
          PluginManagerEvent_PluginLoadFailed>
      get copyWith => _$PluginManagerEvent_PluginLoadFailedCopyWithImpl<
          PluginManagerEvent_PluginLoadFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginLoadFailed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, error);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginLoadFailed(id: $id, error: $error)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginLoadFailedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginLoadFailedCopyWith(
          PluginManagerEvent_PluginLoadFailed value,
          $Res Function(PluginManagerEvent_PluginLoadFailed) _then) =
      _$PluginManagerEvent_PluginLoadFailedCopyWithImpl;
  @useResult
  $Res call({String id, String error});
}

/// @nodoc
class _$PluginManagerEvent_PluginLoadFailedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginLoadFailedCopyWith<$Res> {
  _$PluginManagerEvent_PluginLoadFailedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginLoadFailed _self;
  final $Res Function(PluginManagerEvent_PluginLoadFailed) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? error = null,
  }) {
    return _then(PluginManagerEvent_PluginLoadFailed(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginUnloading extends PluginManagerEvent {
  const PluginManagerEvent_PluginUnloading({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginUnloadingCopyWith<
          PluginManagerEvent_PluginUnloading>
      get copyWith => _$PluginManagerEvent_PluginUnloadingCopyWithImpl<
          PluginManagerEvent_PluginUnloading>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginUnloading &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginUnloading(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginUnloadingCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginUnloadingCopyWith(
          PluginManagerEvent_PluginUnloading value,
          $Res Function(PluginManagerEvent_PluginUnloading) _then) =
      _$PluginManagerEvent_PluginUnloadingCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginUnloadingCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginUnloadingCopyWith<$Res> {
  _$PluginManagerEvent_PluginUnloadingCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginUnloading _self;
  final $Res Function(PluginManagerEvent_PluginUnloading) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginUnloading(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginUnloaded extends PluginManagerEvent {
  const PluginManagerEvent_PluginUnloaded({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginUnloadedCopyWith<PluginManagerEvent_PluginUnloaded>
      get copyWith => _$PluginManagerEvent_PluginUnloadedCopyWithImpl<
          PluginManagerEvent_PluginUnloaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginUnloaded &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginUnloaded(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginUnloadedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginUnloadedCopyWith(
          PluginManagerEvent_PluginUnloaded value,
          $Res Function(PluginManagerEvent_PluginUnloaded) _then) =
      _$PluginManagerEvent_PluginUnloadedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginUnloadedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginUnloadedCopyWith<$Res> {
  _$PluginManagerEvent_PluginUnloadedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginUnloaded _self;
  final $Res Function(PluginManagerEvent_PluginUnloaded) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginUnloaded(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginUnloadFailed extends PluginManagerEvent {
  const PluginManagerEvent_PluginUnloadFailed(
      {required this.id, required this.error})
      : super._();

  final String id;
  final String error;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginUnloadFailedCopyWith<
          PluginManagerEvent_PluginUnloadFailed>
      get copyWith => _$PluginManagerEvent_PluginUnloadFailedCopyWithImpl<
          PluginManagerEvent_PluginUnloadFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginUnloadFailed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, error);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginUnloadFailed(id: $id, error: $error)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginUnloadFailedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginUnloadFailedCopyWith(
          PluginManagerEvent_PluginUnloadFailed value,
          $Res Function(PluginManagerEvent_PluginUnloadFailed) _then) =
      _$PluginManagerEvent_PluginUnloadFailedCopyWithImpl;
  @useResult
  $Res call({String id, String error});
}

/// @nodoc
class _$PluginManagerEvent_PluginUnloadFailedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginUnloadFailedCopyWith<$Res> {
  _$PluginManagerEvent_PluginUnloadFailedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginUnloadFailed _self;
  final $Res Function(PluginManagerEvent_PluginUnloadFailed) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? error = null,
  }) {
    return _then(PluginManagerEvent_PluginUnloadFailed(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginInstalling extends PluginManagerEvent {
  const PluginManagerEvent_PluginInstalling({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginInstallingCopyWith<
          PluginManagerEvent_PluginInstalling>
      get copyWith => _$PluginManagerEvent_PluginInstallingCopyWithImpl<
          PluginManagerEvent_PluginInstalling>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginInstalling &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginInstalling(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginInstallingCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginInstallingCopyWith(
          PluginManagerEvent_PluginInstalling value,
          $Res Function(PluginManagerEvent_PluginInstalling) _then) =
      _$PluginManagerEvent_PluginInstallingCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginInstallingCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginInstallingCopyWith<$Res> {
  _$PluginManagerEvent_PluginInstallingCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginInstalling _self;
  final $Res Function(PluginManagerEvent_PluginInstalling) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginInstalling(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginInstalled extends PluginManagerEvent {
  const PluginManagerEvent_PluginInstalled({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginInstalledCopyWith<
          PluginManagerEvent_PluginInstalled>
      get copyWith => _$PluginManagerEvent_PluginInstalledCopyWithImpl<
          PluginManagerEvent_PluginInstalled>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginInstalled &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginInstalled(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginInstalledCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginInstalledCopyWith(
          PluginManagerEvent_PluginInstalled value,
          $Res Function(PluginManagerEvent_PluginInstalled) _then) =
      _$PluginManagerEvent_PluginInstalledCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginInstalledCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginInstalledCopyWith<$Res> {
  _$PluginManagerEvent_PluginInstalledCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginInstalled _self;
  final $Res Function(PluginManagerEvent_PluginInstalled) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginInstalled(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginInstallFailed extends PluginManagerEvent {
  const PluginManagerEvent_PluginInstallFailed(
      {required this.id, required this.error})
      : super._();

  final String id;
  final String error;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginInstallFailedCopyWith<
          PluginManagerEvent_PluginInstallFailed>
      get copyWith => _$PluginManagerEvent_PluginInstallFailedCopyWithImpl<
          PluginManagerEvent_PluginInstallFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginInstallFailed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, error);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginInstallFailed(id: $id, error: $error)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginInstallFailedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginInstallFailedCopyWith(
          PluginManagerEvent_PluginInstallFailed value,
          $Res Function(PluginManagerEvent_PluginInstallFailed) _then) =
      _$PluginManagerEvent_PluginInstallFailedCopyWithImpl;
  @useResult
  $Res call({String id, String error});
}

/// @nodoc
class _$PluginManagerEvent_PluginInstallFailedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginInstallFailedCopyWith<$Res> {
  _$PluginManagerEvent_PluginInstallFailedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginInstallFailed _self;
  final $Res Function(PluginManagerEvent_PluginInstallFailed) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? error = null,
  }) {
    return _then(PluginManagerEvent_PluginInstallFailed(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginDeleting extends PluginManagerEvent {
  const PluginManagerEvent_PluginDeleting({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginDeletingCopyWith<PluginManagerEvent_PluginDeleting>
      get copyWith => _$PluginManagerEvent_PluginDeletingCopyWithImpl<
          PluginManagerEvent_PluginDeleting>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginDeleting &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginDeleting(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginDeletingCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginDeletingCopyWith(
          PluginManagerEvent_PluginDeleting value,
          $Res Function(PluginManagerEvent_PluginDeleting) _then) =
      _$PluginManagerEvent_PluginDeletingCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginDeletingCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginDeletingCopyWith<$Res> {
  _$PluginManagerEvent_PluginDeletingCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginDeleting _self;
  final $Res Function(PluginManagerEvent_PluginDeleting) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginDeleting(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginDeleted extends PluginManagerEvent {
  const PluginManagerEvent_PluginDeleted({required this.id}) : super._();

  final String id;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginDeletedCopyWith<PluginManagerEvent_PluginDeleted>
      get copyWith => _$PluginManagerEvent_PluginDeletedCopyWithImpl<
          PluginManagerEvent_PluginDeleted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginDeleted &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginDeleted(id: $id)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginDeletedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginDeletedCopyWith(
          PluginManagerEvent_PluginDeleted value,
          $Res Function(PluginManagerEvent_PluginDeleted) _then) =
      _$PluginManagerEvent_PluginDeletedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$PluginManagerEvent_PluginDeletedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginDeletedCopyWith<$Res> {
  _$PluginManagerEvent_PluginDeletedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginDeleted _self;
  final $Res Function(PluginManagerEvent_PluginDeleted) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(PluginManagerEvent_PluginDeleted(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginDeleteFailed extends PluginManagerEvent {
  const PluginManagerEvent_PluginDeleteFailed(
      {required this.id, required this.error})
      : super._();

  final String id;
  final String error;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginDeleteFailedCopyWith<
          PluginManagerEvent_PluginDeleteFailed>
      get copyWith => _$PluginManagerEvent_PluginDeleteFailedCopyWithImpl<
          PluginManagerEvent_PluginDeleteFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginDeleteFailed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, error);

  @override
  String toString() {
    return 'PluginManagerEvent.pluginDeleteFailed(id: $id, error: $error)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginDeleteFailedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginDeleteFailedCopyWith(
          PluginManagerEvent_PluginDeleteFailed value,
          $Res Function(PluginManagerEvent_PluginDeleteFailed) _then) =
      _$PluginManagerEvent_PluginDeleteFailedCopyWithImpl;
  @useResult
  $Res call({String id, String error});
}

/// @nodoc
class _$PluginManagerEvent_PluginDeleteFailedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginDeleteFailedCopyWith<$Res> {
  _$PluginManagerEvent_PluginDeleteFailedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginDeleteFailed _self;
  final $Res Function(PluginManagerEvent_PluginDeleteFailed) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? error = null,
  }) {
    return _then(PluginManagerEvent_PluginDeleteFailed(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_PluginListRefreshed extends PluginManagerEvent {
  const PluginManagerEvent_PluginListRefreshed(
      {required final List<PluginInfo> plugins})
      : _plugins = plugins,
        super._();

  final List<PluginInfo> _plugins;
  List<PluginInfo> get plugins {
    if (_plugins is EqualUnmodifiableListView) return _plugins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plugins);
  }

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_PluginListRefreshedCopyWith<
          PluginManagerEvent_PluginListRefreshed>
      get copyWith => _$PluginManagerEvent_PluginListRefreshedCopyWithImpl<
          PluginManagerEvent_PluginListRefreshed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_PluginListRefreshed &&
            const DeepCollectionEquality().equals(other._plugins, _plugins));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_plugins));

  @override
  String toString() {
    return 'PluginManagerEvent.pluginListRefreshed(plugins: $plugins)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_PluginListRefreshedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_PluginListRefreshedCopyWith(
          PluginManagerEvent_PluginListRefreshed value,
          $Res Function(PluginManagerEvent_PluginListRefreshed) _then) =
      _$PluginManagerEvent_PluginListRefreshedCopyWithImpl;
  @useResult
  $Res call({List<PluginInfo> plugins});
}

/// @nodoc
class _$PluginManagerEvent_PluginListRefreshedCopyWithImpl<$Res>
    implements $PluginManagerEvent_PluginListRefreshedCopyWith<$Res> {
  _$PluginManagerEvent_PluginListRefreshedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_PluginListRefreshed _self;
  final $Res Function(PluginManagerEvent_PluginListRefreshed) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? plugins = null,
  }) {
    return _then(PluginManagerEvent_PluginListRefreshed(
      plugins: null == plugins
          ? _self._plugins
          : plugins // ignore: cast_nullable_to_non_nullable
              as List<PluginInfo>,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_StorageSet extends PluginManagerEvent {
  const PluginManagerEvent_StorageSet(
      {required this.pluginId, required this.key, required this.value})
      : super._();

  final String pluginId;
  final String key;
  final String value;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_StorageSetCopyWith<PluginManagerEvent_StorageSet>
      get copyWith => _$PluginManagerEvent_StorageSetCopyWithImpl<
          PluginManagerEvent_StorageSet>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_StorageSet &&
            (identical(other.pluginId, pluginId) ||
                other.pluginId == pluginId) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pluginId, key, value);

  @override
  String toString() {
    return 'PluginManagerEvent.storageSet(pluginId: $pluginId, key: $key, value: $value)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_StorageSetCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_StorageSetCopyWith(
          PluginManagerEvent_StorageSet value,
          $Res Function(PluginManagerEvent_StorageSet) _then) =
      _$PluginManagerEvent_StorageSetCopyWithImpl;
  @useResult
  $Res call({String pluginId, String key, String value});
}

/// @nodoc
class _$PluginManagerEvent_StorageSetCopyWithImpl<$Res>
    implements $PluginManagerEvent_StorageSetCopyWith<$Res> {
  _$PluginManagerEvent_StorageSetCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_StorageSet _self;
  final $Res Function(PluginManagerEvent_StorageSet) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pluginId = null,
    Object? key = null,
    Object? value = null,
  }) {
    return _then(PluginManagerEvent_StorageSet(
      pluginId: null == pluginId
          ? _self.pluginId
          : pluginId // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_StorageDeleted extends PluginManagerEvent {
  const PluginManagerEvent_StorageDeleted(
      {required this.pluginId, required this.key})
      : super._();

  final String pluginId;
  final String key;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_StorageDeletedCopyWith<PluginManagerEvent_StorageDeleted>
      get copyWith => _$PluginManagerEvent_StorageDeletedCopyWithImpl<
          PluginManagerEvent_StorageDeleted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_StorageDeleted &&
            (identical(other.pluginId, pluginId) ||
                other.pluginId == pluginId) &&
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pluginId, key);

  @override
  String toString() {
    return 'PluginManagerEvent.storageDeleted(pluginId: $pluginId, key: $key)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_StorageDeletedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_StorageDeletedCopyWith(
          PluginManagerEvent_StorageDeleted value,
          $Res Function(PluginManagerEvent_StorageDeleted) _then) =
      _$PluginManagerEvent_StorageDeletedCopyWithImpl;
  @useResult
  $Res call({String pluginId, String key});
}

/// @nodoc
class _$PluginManagerEvent_StorageDeletedCopyWithImpl<$Res>
    implements $PluginManagerEvent_StorageDeletedCopyWith<$Res> {
  _$PluginManagerEvent_StorageDeletedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_StorageDeleted _self;
  final $Res Function(PluginManagerEvent_StorageDeleted) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pluginId = null,
    Object? key = null,
  }) {
    return _then(PluginManagerEvent_StorageDeleted(
      pluginId: null == pluginId
          ? _self.pluginId
          : pluginId // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_StorageCleared extends PluginManagerEvent {
  const PluginManagerEvent_StorageCleared({required this.pluginId}) : super._();

  final String pluginId;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_StorageClearedCopyWith<PluginManagerEvent_StorageCleared>
      get copyWith => _$PluginManagerEvent_StorageClearedCopyWithImpl<
          PluginManagerEvent_StorageCleared>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_StorageCleared &&
            (identical(other.pluginId, pluginId) ||
                other.pluginId == pluginId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pluginId);

  @override
  String toString() {
    return 'PluginManagerEvent.storageCleared(pluginId: $pluginId)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_StorageClearedCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_StorageClearedCopyWith(
          PluginManagerEvent_StorageCleared value,
          $Res Function(PluginManagerEvent_StorageCleared) _then) =
      _$PluginManagerEvent_StorageClearedCopyWithImpl;
  @useResult
  $Res call({String pluginId});
}

/// @nodoc
class _$PluginManagerEvent_StorageClearedCopyWithImpl<$Res>
    implements $PluginManagerEvent_StorageClearedCopyWith<$Res> {
  _$PluginManagerEvent_StorageClearedCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_StorageCleared _self;
  final $Res Function(PluginManagerEvent_StorageCleared) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pluginId = null,
  }) {
    return _then(PluginManagerEvent_StorageCleared(
      pluginId: null == pluginId
          ? _self.pluginId
          : pluginId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PluginManagerEvent_ManagerInitialized extends PluginManagerEvent {
  const PluginManagerEvent_ManagerInitialized() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_ManagerInitialized);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PluginManagerEvent.managerInitialized()';
  }
}

/// @nodoc

class PluginManagerEvent_Error extends PluginManagerEvent {
  const PluginManagerEvent_Error({required this.message}) : super._();

  final String message;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PluginManagerEvent_ErrorCopyWith<PluginManagerEvent_Error> get copyWith =>
      _$PluginManagerEvent_ErrorCopyWithImpl<PluginManagerEvent_Error>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PluginManagerEvent_Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'PluginManagerEvent.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $PluginManagerEvent_ErrorCopyWith<$Res>
    implements $PluginManagerEventCopyWith<$Res> {
  factory $PluginManagerEvent_ErrorCopyWith(PluginManagerEvent_Error value,
          $Res Function(PluginManagerEvent_Error) _then) =
      _$PluginManagerEvent_ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$PluginManagerEvent_ErrorCopyWithImpl<$Res>
    implements $PluginManagerEvent_ErrorCopyWith<$Res> {
  _$PluginManagerEvent_ErrorCopyWithImpl(this._self, this._then);

  final PluginManagerEvent_Error _self;
  final $Res Function(PluginManagerEvent_Error) _then;

  /// Create a copy of PluginManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(PluginManagerEvent_Error(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
