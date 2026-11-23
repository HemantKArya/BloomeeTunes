import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/core/utils/app_distribution.dart';
import 'package:Bloomee/services/bloomee_updater_tools.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:Bloomee/services/feed/feed_rules.dart';
import 'package:Bloomee/services/feed/feed_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'notification_state.dart';

/// The inbox behind the bell: announcements from `feed.json` plus an
/// available app update. Nothing is stored but a small "what was seen"
/// record; the feed itself is cached by [FeedService].
class NotificationCubit extends Cubit<NotificationState> {
  final SettingsDAO _settings;
  final FeedService _feed;
  final DateTime Function() _now;
  final Future<String?> Function() _checkUpdate;
  final Future<FeedAudience> Function() _audienceLoader;

  FeedAudience? _audience;
  List<FeedItem> _all = const [];
  FeedMemory _memory = const FeedMemory();
  Timer? _startTimer;

  NotificationCubit({
    required SettingsDAO settingsDao,
    FeedService? feed,
    DateTime Function()? now,
    Future<String?> Function()? checkUpdate,
    Future<FeedAudience> Function()? audience,

    /// The network waits until startup has settled.
    Duration startDelay = const Duration(seconds: 10),
  })  : _settings = settingsDao,
        _feed = feed ?? FeedService(),
        _now = now ?? DateTime.now,
        _checkUpdate = checkUpdate ?? _availableUpdate,
        _audienceLoader = audience ?? _thisInstall,
        super(const NotificationState()) {
    _start(startDelay);
  }

  /// Preview is for checking entries before they go live.
  bool get canPreview => kDebugMode || _feed.isPreviewSource;

  Future<void> _start(Duration delay) async {
    try {
      _audience = await _audienceLoader();
      final saved = await _settings.getSettingStr(SettingKeys.feedMemory);
      _memory = FeedMemory.fromJson(saved == null ? null : jsonDecode(saved));
      if (_memory.firstRun == null) {
        _memory = _memory.copyWith(firstRun: _now());
        await _save();
      }
      final onHome = await _settings.getSettingBool(SettingKeys.feedOnHome);
      _all = await _feed.cached();
      _publish(state.copyWith(
        showOnHome: onHome ?? true,
        preview: _feed.isPreviewSource,
      ));
    } catch (e) {
      debugPrint('Inbox start failed: $e');
    }
    if (isClosed) return;
    _startTimer = Timer(delay, () {
      unawaited(refresh());
      unawaited(_loadUpdate());
    });
  }

  /// Asks for a newer feed. [force] skips the freshness window, for
  /// pull-to-refresh.
  Future<void> refresh({bool force = false}) async {
    if (_audience == null || isClosed) return;
    emit(state.copyWith(refreshing: true));
    final items = await _feed.refresh(force: force);
    if (isClosed) return;
    if (items != null) {
      _all = items;
      final pruned = _memory.prunedTo(items.map((i) => i.id));
      // Pruning only removes ids, so a size change means something left.
      if (pruned.seen.length + pruned.closed.length + pruned.dismissed.length !=
          _memory.seen.length +
              _memory.closed.length +
              _memory.dismissed.length) {
        _memory = pruned;
        await _save();
      }
    }
    _publish(state.copyWith(refreshing: false));
  }

  Future<void> _loadUpdate() async {
    final update = await _checkUpdate();
    if (isClosed || update == null) return;
    _publish(state.copyWith(update: () => update));
  }

  /// The inbox was opened: everything in it is no longer new.
  Future<void> markAllSeen() async {
    if (state.unread == 0) return;
    _memory = FeedRules.markSeen(_memory, state.items, update: state.update);
    _publish(state);
    await _save();
  }

  /// Removes an entry from the inbox for good.
  Future<void> dismiss(FeedItem item) async {
    _memory = FeedRules.dismiss(_memory, item);
    _publish(state);
    await _save();
  }

  /// Closes the Home card; the next queued one takes its place. The
  /// closed entry stays in the inbox.
  Future<void> closeHomeCard(FeedItem item) async {
    _memory = FeedRules.closeHomeCard(_memory, item);
    _publish(state);
    await _save();
  }

  /// The link to open for [item] on this install.
  String? actionUrl(FeedItem item) =>
      _audience == null ? null : item.actionUrlFor(_audience!);

  Future<void> setShowOnHome(bool value) async {
    _publish(state.copyWith(showOnHome: value));
    await _settings.putSettingBool(SettingKeys.feedOnHome, value);
  }

  void setPreview(bool value) {
    if (!canPreview) return;
    _publish(state.copyWith(preview: value));
  }

  void _publish(NotificationState next) {
    if (isClosed) return;
    final audience = _audience;
    if (audience == null) return emit(next);
    final now = _now();
    final items =
        FeedRules.inbox(_all, audience, now, _memory, preview: next.preview);
    emit(next.copyWith(
      items: items,
      homeCard: () => FeedRules.homeCard(items, now, _memory,
          enabled: next.showOnHome, preview: next.preview),
      newIds: {
        for (final i in items)
          if (!_memory.seen.contains(i.id)) i.id,
        if (next.update != null && next.update != _memory.seenUpdate)
          NotificationState.updateKey,
      },
    ));
  }

  Future<void> _save() async {
    try {
      await _settings.putSettingStr(
          SettingKeys.feedMemory, jsonEncode(_memory.toJson()));
    } catch (e) {
      debugPrint('Inbox state not saved: $e');
    }
  }

  static Future<FeedAudience> _thisInstall() async => FeedAudience(
        platform: Platform.operatingSystem,
        storeBuild: AppDistribution.isPackaged,
        appVersion: (await PackageInfo.fromPlatform()).version,
      );

  /// Shares the session's single update check with the startup dialog.
  static Future<String?> _availableUpdate() async {
    try {
      final updates = await getAppUpdates();
      if (updates['results'] != true) return null;
      return '${updates['newVer']}+${updates['newBuild']}';
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    _startTimer?.cancel();
    return super.close();
  }
}
