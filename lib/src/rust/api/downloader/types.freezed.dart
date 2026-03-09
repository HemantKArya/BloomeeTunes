// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadManagerEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is DownloadManagerEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DownloadManagerEvent()';
  }
}

/// @nodoc
class $DownloadManagerEventCopyWith<$Res> {
  $DownloadManagerEventCopyWith(
      DownloadManagerEvent _, $Res Function(DownloadManagerEvent) __);
}

/// Adds pattern-matching-related methods to [DownloadManagerEvent].
extension DownloadManagerEventPatterns on DownloadManagerEvent {
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
    TResult Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated() when taskUpdated != null:
        return taskUpdated(_that);
      case DownloadManagerEvent_TaskCompletedPendingAck()
          when taskCompletedPendingAck != null:
        return taskCompletedPendingAck(_that);
      case DownloadManagerEvent_TaskRemoved() when taskRemoved != null:
        return taskRemoved(_that);
      case DownloadManagerEvent_RecoverySummary() when recoverySummary != null:
        return recoverySummary(_that);
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
    required TResult Function(DownloadManagerEvent_TaskUpdated value)
        taskUpdated,
    required TResult Function(
            DownloadManagerEvent_TaskCompletedPendingAck value)
        taskCompletedPendingAck,
    required TResult Function(DownloadManagerEvent_TaskRemoved value)
        taskRemoved,
    required TResult Function(DownloadManagerEvent_RecoverySummary value)
        recoverySummary,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated():
        return taskUpdated(_that);
      case DownloadManagerEvent_TaskCompletedPendingAck():
        return taskCompletedPendingAck(_that);
      case DownloadManagerEvent_TaskRemoved():
        return taskRemoved(_that);
      case DownloadManagerEvent_RecoverySummary():
        return recoverySummary(_that);
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
    TResult? Function(DownloadManagerEvent_TaskUpdated value)? taskUpdated,
    TResult? Function(DownloadManagerEvent_TaskCompletedPendingAck value)?
        taskCompletedPendingAck,
    TResult? Function(DownloadManagerEvent_TaskRemoved value)? taskRemoved,
    TResult? Function(DownloadManagerEvent_RecoverySummary value)?
        recoverySummary,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated() when taskUpdated != null:
        return taskUpdated(_that);
      case DownloadManagerEvent_TaskCompletedPendingAck()
          when taskCompletedPendingAck != null:
        return taskCompletedPendingAck(_that);
      case DownloadManagerEvent_TaskRemoved() when taskRemoved != null:
        return taskRemoved(_that);
      case DownloadManagerEvent_RecoverySummary() when recoverySummary != null:
        return recoverySummary(_that);
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
    TResult Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult Function(String taskId)? taskRemoved,
    TResult Function(int restored, int cleaned)? recoverySummary,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated() when taskUpdated != null:
        return taskUpdated(_that.field0);
      case DownloadManagerEvent_TaskCompletedPendingAck()
          when taskCompletedPendingAck != null:
        return taskCompletedPendingAck(_that.field0);
      case DownloadManagerEvent_TaskRemoved() when taskRemoved != null:
        return taskRemoved(_that.taskId);
      case DownloadManagerEvent_RecoverySummary() when recoverySummary != null:
        return recoverySummary(_that.restored, _that.cleaned);
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
    required TResult Function(DownloadTaskSnapshot field0) taskUpdated,
    required TResult Function(DownloadTaskSnapshot field0)
        taskCompletedPendingAck,
    required TResult Function(String taskId) taskRemoved,
    required TResult Function(int restored, int cleaned) recoverySummary,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated():
        return taskUpdated(_that.field0);
      case DownloadManagerEvent_TaskCompletedPendingAck():
        return taskCompletedPendingAck(_that.field0);
      case DownloadManagerEvent_TaskRemoved():
        return taskRemoved(_that.taskId);
      case DownloadManagerEvent_RecoverySummary():
        return recoverySummary(_that.restored, _that.cleaned);
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
    TResult? Function(DownloadTaskSnapshot field0)? taskUpdated,
    TResult? Function(DownloadTaskSnapshot field0)? taskCompletedPendingAck,
    TResult? Function(String taskId)? taskRemoved,
    TResult? Function(int restored, int cleaned)? recoverySummary,
  }) {
    final _that = this;
    switch (_that) {
      case DownloadManagerEvent_TaskUpdated() when taskUpdated != null:
        return taskUpdated(_that.field0);
      case DownloadManagerEvent_TaskCompletedPendingAck()
          when taskCompletedPendingAck != null:
        return taskCompletedPendingAck(_that.field0);
      case DownloadManagerEvent_TaskRemoved() when taskRemoved != null:
        return taskRemoved(_that.taskId);
      case DownloadManagerEvent_RecoverySummary() when recoverySummary != null:
        return recoverySummary(_that.restored, _that.cleaned);
      case _:
        return null;
    }
  }
}

/// @nodoc

class DownloadManagerEvent_TaskUpdated extends DownloadManagerEvent {
  const DownloadManagerEvent_TaskUpdated(this.field0) : super._();

  final DownloadTaskSnapshot field0;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadManagerEvent_TaskUpdatedCopyWith<DownloadManagerEvent_TaskUpdated>
      get copyWith => _$DownloadManagerEvent_TaskUpdatedCopyWithImpl<
          DownloadManagerEvent_TaskUpdated>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadManagerEvent_TaskUpdated &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'DownloadManagerEvent.taskUpdated(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $DownloadManagerEvent_TaskUpdatedCopyWith<$Res>
    implements $DownloadManagerEventCopyWith<$Res> {
  factory $DownloadManagerEvent_TaskUpdatedCopyWith(
          DownloadManagerEvent_TaskUpdated value,
          $Res Function(DownloadManagerEvent_TaskUpdated) _then) =
      _$DownloadManagerEvent_TaskUpdatedCopyWithImpl;
  @useResult
  $Res call({DownloadTaskSnapshot field0});
}

/// @nodoc
class _$DownloadManagerEvent_TaskUpdatedCopyWithImpl<$Res>
    implements $DownloadManagerEvent_TaskUpdatedCopyWith<$Res> {
  _$DownloadManagerEvent_TaskUpdatedCopyWithImpl(this._self, this._then);

  final DownloadManagerEvent_TaskUpdated _self;
  final $Res Function(DownloadManagerEvent_TaskUpdated) _then;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(DownloadManagerEvent_TaskUpdated(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DownloadTaskSnapshot,
    ));
  }
}

/// @nodoc

class DownloadManagerEvent_TaskCompletedPendingAck
    extends DownloadManagerEvent {
  const DownloadManagerEvent_TaskCompletedPendingAck(this.field0) : super._();

  final DownloadTaskSnapshot field0;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadManagerEvent_TaskCompletedPendingAckCopyWith<
          DownloadManagerEvent_TaskCompletedPendingAck>
      get copyWith =>
          _$DownloadManagerEvent_TaskCompletedPendingAckCopyWithImpl<
              DownloadManagerEvent_TaskCompletedPendingAck>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadManagerEvent_TaskCompletedPendingAck &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'DownloadManagerEvent.taskCompletedPendingAck(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $DownloadManagerEvent_TaskCompletedPendingAckCopyWith<$Res>
    implements $DownloadManagerEventCopyWith<$Res> {
  factory $DownloadManagerEvent_TaskCompletedPendingAckCopyWith(
          DownloadManagerEvent_TaskCompletedPendingAck value,
          $Res Function(DownloadManagerEvent_TaskCompletedPendingAck) _then) =
      _$DownloadManagerEvent_TaskCompletedPendingAckCopyWithImpl;
  @useResult
  $Res call({DownloadTaskSnapshot field0});
}

/// @nodoc
class _$DownloadManagerEvent_TaskCompletedPendingAckCopyWithImpl<$Res>
    implements $DownloadManagerEvent_TaskCompletedPendingAckCopyWith<$Res> {
  _$DownloadManagerEvent_TaskCompletedPendingAckCopyWithImpl(
      this._self, this._then);

  final DownloadManagerEvent_TaskCompletedPendingAck _self;
  final $Res Function(DownloadManagerEvent_TaskCompletedPendingAck) _then;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(DownloadManagerEvent_TaskCompletedPendingAck(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DownloadTaskSnapshot,
    ));
  }
}

/// @nodoc

class DownloadManagerEvent_TaskRemoved extends DownloadManagerEvent {
  const DownloadManagerEvent_TaskRemoved({required this.taskId}) : super._();

  final String taskId;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadManagerEvent_TaskRemovedCopyWith<DownloadManagerEvent_TaskRemoved>
      get copyWith => _$DownloadManagerEvent_TaskRemovedCopyWithImpl<
          DownloadManagerEvent_TaskRemoved>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadManagerEvent_TaskRemoved &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'DownloadManagerEvent.taskRemoved(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class $DownloadManagerEvent_TaskRemovedCopyWith<$Res>
    implements $DownloadManagerEventCopyWith<$Res> {
  factory $DownloadManagerEvent_TaskRemovedCopyWith(
          DownloadManagerEvent_TaskRemoved value,
          $Res Function(DownloadManagerEvent_TaskRemoved) _then) =
      _$DownloadManagerEvent_TaskRemovedCopyWithImpl;
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class _$DownloadManagerEvent_TaskRemovedCopyWithImpl<$Res>
    implements $DownloadManagerEvent_TaskRemovedCopyWith<$Res> {
  _$DownloadManagerEvent_TaskRemovedCopyWithImpl(this._self, this._then);

  final DownloadManagerEvent_TaskRemoved _self;
  final $Res Function(DownloadManagerEvent_TaskRemoved) _then;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
  }) {
    return _then(DownloadManagerEvent_TaskRemoved(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class DownloadManagerEvent_RecoverySummary extends DownloadManagerEvent {
  const DownloadManagerEvent_RecoverySummary(
      {required this.restored, required this.cleaned})
      : super._();

  final int restored;
  final int cleaned;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadManagerEvent_RecoverySummaryCopyWith<
          DownloadManagerEvent_RecoverySummary>
      get copyWith => _$DownloadManagerEvent_RecoverySummaryCopyWithImpl<
          DownloadManagerEvent_RecoverySummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadManagerEvent_RecoverySummary &&
            (identical(other.restored, restored) ||
                other.restored == restored) &&
            (identical(other.cleaned, cleaned) || other.cleaned == cleaned));
  }

  @override
  int get hashCode => Object.hash(runtimeType, restored, cleaned);

  @override
  String toString() {
    return 'DownloadManagerEvent.recoverySummary(restored: $restored, cleaned: $cleaned)';
  }
}

/// @nodoc
abstract mixin class $DownloadManagerEvent_RecoverySummaryCopyWith<$Res>
    implements $DownloadManagerEventCopyWith<$Res> {
  factory $DownloadManagerEvent_RecoverySummaryCopyWith(
          DownloadManagerEvent_RecoverySummary value,
          $Res Function(DownloadManagerEvent_RecoverySummary) _then) =
      _$DownloadManagerEvent_RecoverySummaryCopyWithImpl;
  @useResult
  $Res call({int restored, int cleaned});
}

/// @nodoc
class _$DownloadManagerEvent_RecoverySummaryCopyWithImpl<$Res>
    implements $DownloadManagerEvent_RecoverySummaryCopyWith<$Res> {
  _$DownloadManagerEvent_RecoverySummaryCopyWithImpl(this._self, this._then);

  final DownloadManagerEvent_RecoverySummary _self;
  final $Res Function(DownloadManagerEvent_RecoverySummary) _then;

  /// Create a copy of DownloadManagerEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? restored = null,
    Object? cleaned = null,
  }) {
    return _then(DownloadManagerEvent_RecoverySummary(
      restored: null == restored
          ? _self.restored
          : restored // ignore: cast_nullable_to_non_nullable
              as int,
      cleaned: null == cleaned
          ? _self.cleaned
          : cleaned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
