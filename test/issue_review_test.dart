import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:Bloomee/core/models/lyrics_models.dart';
import 'package:Bloomee/services/download/download_storage.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:Bloomee/services/plugin_bootstrap_service.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/plugins/services/plugin_repository_service.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';
import 'package:Bloomee/src/rust/api/plugin/plugin_info.dart';
import 'package:Bloomee/src/rust/api/plugin/manifest.dart';
import 'package:Bloomee/src/rust/api/plugin/types.dart';
import 'package:isar_community/isar.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart'
    show Track, Artwork, ImageLayout;
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class _Player implements BloomeeMusicPlayer {
  @override
  final mediaItem = BehaviorSubject<MediaItem?>.seeded(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlayerCubit implements BloomeePlayerCubit {
  @override
  final BloomeeMusicPlayer bloomeePlayer;
  _PlayerCubit(this.bloomeePlayer);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedLyrics extends LyricsDAO {
  _DelayedLyrics() : super(Completer<Isar>().future);
  final pending = Completer<Lyrics?>();
  @override
  Future<Lyrics?> getLyrics(String mediaID) => pending.future;
}

class _Settings extends SettingsDAO {
  _Settings() : super(Completer<Isar>().future);
  final strings = <String, String>{};
  @override
  Future<String?> getSettingStr(String key, {String? defaultValue}) async =>
      strings[key] ?? defaultValue;
  @override
  Future<void> putSettingStr(String key, String value) async {
    strings[key] = value;
  }

  @override
  Future<void> putSettingBool(String key, bool value) async {}
}

class _Manifest implements Manifest {
  @override
  String get id => 'test.provider';
  @override
  String get version => '1';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Info implements PluginInfo {
  @override
  Manifest get manifest => _Manifest();
  @override
  PluginType get pluginType => PluginType.contentResolver;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plugins extends PluginService {
  bool failLoad = false;
  final loaded = <String>[];
  @override
  Future<void> initialize({String? pluginsDir}) async {}
  @override
  Future<List<PluginInfo>> getAvailablePlugins() async => [_Info()];
  @override
  List<String> getLoadedPlugins() => loaded;
  @override
  Future<void> loadPlugin(
      {required String pluginId, required PluginType pluginType}) async {
    if (failLoad) throw StateError('Invalid plugin');
    loaded.add(pluginId);
  }
}

class _Repositories extends PluginRepositoryService {
  _Repositories(SettingsDAO settings) : super(settingsDao: settings);
  @override
  Future<int> ensureRepositoryUrls(Iterable<String> urls) async => 0;
  @override
  Future<PluginRepositoryModel> fetchRepository(String url) async =>
      PluginRepositoryModel(
          url: url,
          schemaVersion: '1',
          name: 'Test',
          description: '',
          plugins: [
            RemotePluginModel(
                assetName: 'provider.bex',
                description: '',
                id: 'test.provider',
                name: 'Test provider',
                manifestVersion: '1.0',
                type: 'content-resolver',
                version: '1',
                downloadUrl: 'https://example.com/provider.bex'),
          ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final closeBeforeResult in [false, true]) {
    test('lyrics cache failure remains safe (closed=$closeBeforeResult)',
        () async {
      final player = _Player();
      final cache = _DelayedLyrics();
      final cubit = LyricsCubit(_PlayerCubit(player),
          lyricsDao: cache,
          settingsDao: _Settings(),
          pluginService: _Plugins());
      final request = cubit.getLyrics(const Track(
          id: 'test.provider::song',
          title: 'Song',
          artists: [],
          thumbnail: Artwork(url: '', layout: ImageLayout.square),
          isExplicit: false));
      if (closeBeforeResult) await cubit.close();
      cache.pending.completeError(StateError('Cache unavailable'));
      await request;
      if (!closeBeforeResult) {
        expect(cubit.state, isA<LyricsNoPlugin>());
        await cubit.close();
      }
      await player.mediaItem.close();
    });
  }

  for (final failLoad in [false, true]) {
    test('partial setup verifies installed plugin can load (failure=$failLoad)',
        () async {
      final settings = _Settings();
      final plugins = _Plugins()..failLoad = failLoad;
      final result = await http.runWithClient(
          () => PluginBootstrapService.run(
                pluginService: plugins,
                repositoryService: _Repositories(settings),
                settingsDao: settings,
                onProgress: (_) {},
              ),
          () => MockClient((request) async => http.Response(
              jsonEncode({
                'repositories': [
                  {'url': 'https://example.com/repo.json', 'install': true}
                ]
              }),
              200)));
      expect(result.success, !failLoad);
      expect(result.errors.isNotEmpty, failLoad);
      expect(plugins.loaded, failLoad ? isEmpty : contains('test.provider'));
    });
  }

  test('LRC parses seconds, centiseconds, milliseconds and repeated timestamps',
      () {
    final parsed = ParsedLyrics(
        duration: '',
        syncedLyrics:
            '[ar:Metadata]\n[00:12.45]hello\n[00:02][00:22.005]repeat\n[00:05.5]half\n[00:99.00]invalid');
    expect(parsed.lyrics.map((line) => line.start.inMilliseconds),
        [2000, 5500, 12450, 22005]);
    expect(parsed.lyrics.map((line) => line.text),
        ['repeat', 'half', 'hello', 'repeat']);
    parsed.parseLyrics('[00:01.00]new');
    expect(parsed.lyrics, hasLength(1));
  });

  test('short and empty lyrics can be logged without RangeError', () {
    final lyrics = Lyrics(
        artist: '',
        title: '',
        lyricsPlain: '',
        lyricsSynced: '',
        id: '',
        provider: LyricsProvider.plugin);
    expect(lyrics.toString, returnsNormally);
    expect(lyrics.parsedLyrics!.lyrics, isEmpty);
  });

  test('document URI stays intact in playback and file resolution', () async {
    const uri =
        'content://com.android.externalstorage.documents/tree/primary%3AMusic/document/primary%3AMusic%2Fa.m4a';
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DownloadStorage.channel, (call) async {
      calls.add(call);
      return call.method == 'exists' ? true : null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DownloadStorage.channel, null));
    expect(DownloadStorage.mediaUri(uri, 'a.m4a').toString(), uri);
    expect(await DownloadFileResolver().resolve(uri, 'a.m4a'), uri);
    await DownloadStorage.delete(uri, 'a.m4a');
    expect(calls.map((call) => call.method), ['exists', 'delete']);
    expect(calls.last.arguments, {'uri': uri});
  });

  test('filesystem downloads still resolve and delete normally', () async {
    final dir = await Directory.systemTemp.createTemp('bloomee_storage_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file =
        await File(p.join(dir.path, 'song.mp3')).writeAsString('audio');
    expect(
        await DownloadFileResolver().resolve(dir.path, 'song.mp3'), file.path);
    expect(DownloadStorage.mediaUri(dir.path, 'song.mp3'), Uri.file(file.path));
    await DownloadStorage.delete(dir.path, 'song.mp3');
    expect(await DownloadStorage.exists(dir.path, 'song.mp3'), false);
  });
}
