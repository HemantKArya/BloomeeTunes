import 'dart:async';

import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

class _Request {
  final String pluginId;
  final ContentImporterCommand command;
  final result = Completer<PluginResponse>();

  _Request(this.pluginId, this.command);
}

// Exercise the real service's request sharing and timeout policy; only replace
// the native bridge boundary and plugin discovery.
class _ControlledPlugin extends PluginService {
  final requests = <_Request>[];
  Completer<List<PluginInfo>>? discovery;

  @override
  Future<PluginResponse> execute({
    required String pluginId,
    required PluginRequest request,
  }) {
    final command = (request as PluginRequest_ContentImporter).field0;
    final pending = _Request(pluginId, command);
    requests.add(pending);
    return pending.result.future;
  }

  @override
  Future<List<PluginInfo>> getAvailablePlugins() async =>
      discovery == null ? [] : await discovery!.future;

  @override
  List<String> getLoadedPlugins() => [];
}

const _url = 'https://example.com/playlist';
const _summary = ImportCollectionSummary(
  title: 'Imported collection',
  kind: ImportCollectionType.playlist,
);
const _info = ContentImporterCommand.getCollectionInfo(url: _url);
const _tracks = ContentImporterCommand.getTracks(url: _url);

ContentImportCubit _cubit(_ControlledPlugin plugin) {
  final db = Completer<Isar>().future;
  return ContentImportCubit(
    pluginService: plugin,
    playlistDao: PlaylistDAO(db, TrackDAO(db)),
  );
}

Future<void> _acceptUrl(WidgetTester tester, _ControlledPlugin plugin) async {
  plugin.requests.last.result.complete(const PluginResponse.canHandle(true));
  await tester.pump();
  expect(plugin.requests.last.command, _info);
}

Future<void> _acceptInfo(WidgetTester tester, _ControlledPlugin plugin) async {
  plugin.requests.last.result
      .complete(const PluginResponse.collectionInfo(_summary));
  await tester.pump();
  expect(plugin.requests.last.command, _tracks);
}

void main() {
  testWidgets('URL timeout retry joins the same validation request',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await tester.pump(const Duration(seconds: 10));
    await import;
    expect(cubit.state.error, 'Plugin timed out while checking URL.');
    final retry = cubit.retry();
    expect(plugin.requests, hasLength(1));
    await _acceptUrl(tester, plugin);
    await _acceptInfo(tester, plugin);
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await retry;
    expect(cubit.state.phase, ImportPhase.review);
  });

  testWidgets('unsupported URL retry returns to input for correction',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    plugin.requests.last.result.complete(const PluginResponse.canHandle(false));
    await tester.pump();
    await import;
    expect(cubit.state.phase, ImportPhase.error);
    await cubit.retry();
    expect(cubit.state.phase, ImportPhase.idle);
    expect(plugin.requests, hasLength(1));
  });

  testWidgets('resolver discovery failure stays recoverable', (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    await _acceptInfo(tester, plugin);
    plugin.discovery = Completer<List<PluginInfo>>();
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    plugin.discovery!.completeError(StateError('discovery failed'));
    await tester.pump();
    await import;
    expect(cubit.state.phase, ImportPhase.error);
    expect(cubit.state.collectionInfo, _summary);
    plugin.discovery = null;
    final retry = cubit.retry();
    expect(plugin.requests.last.command, _tracks);
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await retry;
    expect(cubit.state.phase, ImportPhase.review);
  });

  testWidgets('slow metadata and track requests survive the old 10s deadline',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    await tester.pump(const Duration(seconds: 35));
    expect(cubit.state.phase, ImportPhase.fetchingInfo);
    await _acceptInfo(tester, plugin);
    await tester.pump(const Duration(seconds: 90));
    expect(cubit.state.phase, ImportPhase.fetchingTracks);
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await import;
    expect(cubit.state.phase, ImportPhase.review);
  });

  testWidgets('metadata retry joins pending work without repeating URL check',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    await tester.pump(const Duration(minutes: 1));
    await import;
    expect(cubit.state.error, 'Timed out fetching collection info.');
    final retry = cubit.retry();
    final duplicateRetry = cubit.retry();
    expect(cubit.state.phase, ImportPhase.fetchingInfo);
    expect(cubit.state.error, isNull);
    expect(plugin.requests, hasLength(2));
    await _acceptInfo(tester, plugin);
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await Future.wait([retry, duplicateRetry]);
    expect(cubit.state.phase, ImportPhase.review);
    expect(plugin.requests, hasLength(3));
  });

  testWidgets('track retry keeps metadata and joins pending track request',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    await _acceptInfo(tester, plugin);
    await tester.pump(const Duration(minutes: 2));
    await import;
    expect(cubit.state.error, 'Timed out fetching tracks.');
    final retry = cubit.retry();
    expect(cubit.state.collectionInfo, _summary);
    expect(plugin.requests, hasLength(3));
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await retry;
    expect(cubit.state.phase, ImportPhase.review);
  });

  testWidgets('native failure releases the request so retry can execute again',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    plugin.requests.last.result.completeError(StateError('network failure'));
    await tester.pump();
    await import;
    expect(cubit.state.phase, ImportPhase.error);
    final retry = cubit.retry();
    expect(plugin.requests, hasLength(3));
    expect(plugin.requests.last.command, _info);
    await _acceptInfo(tester, plugin);
    plugin.requests.last.result.complete(const PluginResponse.importTracks([]));
    await tester.pump();
    await retry;
    expect(cubit.state.phase, ImportPhase.review);
  });

  for (final stage in ['URL', 'metadata', 'tracks', 'discovery']) {
    testWidgets('reset ignores late $stage completion', (tester) async {
      final plugin = _ControlledPlugin();
      final cubit = _cubit(plugin);
      addTearDown(cubit.close);
      final import = cubit.checkUrl('importer', _url);
      if (stage != 'URL') await _acceptUrl(tester, plugin);
      if (stage == 'tracks' || stage == 'discovery') {
        await _acceptInfo(tester, plugin);
      }
      if (stage == 'discovery') {
        plugin.discovery = Completer<List<PluginInfo>>();
        plugin.requests.last.result
            .complete(const PluginResponse.importTracks([]));
        await tester.pump();
      }
      final requestCount = plugin.requests.length;
      cubit.reset();
      switch (stage) {
        case 'URL':
          plugin.requests.last.result
              .complete(const PluginResponse.canHandle(true));
        case 'metadata':
          plugin.requests.last.result
              .complete(const PluginResponse.collectionInfo(_summary));
        case 'tracks':
          plugin.requests.last.result
              .complete(const PluginResponse.importTracks([]));
        case 'discovery':
          plugin.discovery!.complete([]);
      }
      await tester.pump();
      await import;
      expect(cubit.state, const ContentImportState());
      expect(plugin.requests, hasLength(requestCount));
    });
  }

  testWidgets('superseded import cannot replace the new import state',
      (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    addTearDown(cubit.close);
    final first = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    final oldInfo = plugin.requests.last;
    final second = cubit.checkUrl('other-importer', 'https://example.com/new');
    oldInfo.result.complete(const PluginResponse.collectionInfo(_summary));
    await tester.pump();
    await first;
    expect(cubit.state.pluginId, 'other-importer');
    expect(cubit.state.collectionInfo, isNull);
    expect(cubit.state.phase, ImportPhase.checkingUrl);
    plugin.requests.last.result.complete(const PluginResponse.canHandle(false));
    await tester.pump();
    await second;
    expect(plugin.requests, hasLength(3));
  });

  testWidgets('close ignores late native failures', (tester) async {
    final plugin = _ControlledPlugin();
    final cubit = _cubit(plugin);
    final import = cubit.checkUrl('importer', _url);
    await _acceptUrl(tester, plugin);
    await cubit.close();
    plugin.requests.last.result
        .completeError(StateError('late network failure'));
    await tester.pump();
    await import;
  });

  testWidgets('request identity includes plugin, command and URL',
      (tester) async {
    final plugin = _ControlledPlugin();
    final results = [
      plugin.executeImport(pluginId: 'a', command: _info),
      plugin.executeImport(pluginId: 'a', command: _info),
      plugin.executeImport(pluginId: 'b', command: _info),
      plugin.executeImport(pluginId: 'a', command: _tracks),
      plugin.executeImport(
          pluginId: 'a',
          command:
              const ContentImporterCommand.getCollectionInfo(url: 'other')),
    ];
    expect(plugin.requests, hasLength(4));
    for (final request in plugin.requests) {
      request.result.complete(const PluginResponse.collectionInfo(_summary));
    }
    await tester.pump();
    await Future.wait(results);
    // Completed results are released rather than cached indefinitely.
    final fresh = plugin.executeImport(pluginId: 'a', command: _info);
    expect(plugin.requests, hasLength(5));
    plugin.requests.last.result
        .complete(const PluginResponse.collectionInfo(_summary));
    await tester.pump();
    await fresh;
  });

  testWidgets(
      'late native error after timeout is handled and permits a fresh request',
      (tester) async {
    final plugin = _ControlledPlugin();
    final pending = plugin.executeImport(pluginId: 'a', command: _info);
    final timeout = expectLater(pending, throwsA(isA<TimeoutException>()));
    await tester.pump(const Duration(minutes: 1));
    await timeout;
    plugin.requests.last.result.completeError(StateError('late failure'));
    await tester.pump();
    final retry = plugin.executeImport(pluginId: 'a', command: _info);
    expect(plugin.requests, hasLength(2));
    plugin.requests.last.result
        .complete(const PluginResponse.collectionInfo(_summary));
    await tester.pump();
    await retry;
  });
}
