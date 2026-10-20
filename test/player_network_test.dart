// Fault injection intentionally uses media_kit's native stream controllers.
// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/services/player/player_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' show MediaKit, Player;
import 'package:path/path.dart' as p;
import 'package:Bloomee/services/player/player_error_handler.dart';
import 'package:Bloomee/services/player/media_resolver_service.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/global_db.dart';
import 'package:Bloomee/services/plugin/plugin_service.dart';
import 'package:Bloomee/src/rust/api/plugin/commands.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:isar_community/isar.dart';

class _NoDownloads extends DownloadDAO {
  _NoDownloads(Future<Isar> db)
      : super(db, TrackDAO(db), PlaylistDAO(db, TrackDAO(db)));
  @override
  Future<DownloadDB?> getDownloadRecord(String mediaId) async => null;
}

class _QualitySettings extends SettingsDAO {
  _QualitySettings(super.db);
  @override
  Future<String?> getSettingStr(String key, {String? defaultValue}) async =>
      'High';
}

class _ControlledPlugin extends PluginService {
  final requests = <Completer<PluginResponse>>[];
  @override
  Future<PluginResponse> execute(
      {required String pluginId, required PluginRequest request}) {
    final result = Completer<PluginResponse>();
    requests.add(result);
    return result.future;
  }
}

Track _song(String id) => Track(
    id: id,
    title: id,
    artists: const [],
    thumbnail: const Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final library = Platform.environment['MPV_TEST_LIBRARY'] ??
      (Platform.isWindows
          ? p.absolute('build/windows/x64/runner/Debug/libmpv-2.dll')
          : null);
  final canRun = library != null && File(library).existsSync();

  testWidgets('a caller timeout and retry share the pending stream extraction',
      (tester) async {
    final db = Completer<Isar>().future;
    final plugin = _ControlledPlugin();
    final resolver = MediaResolverService(
        downloadDao: _NoDownloads(db),
        settingsDao: _QualitySettings(db),
        pluginService: plugin);
    final song = _song('content-resolver.example::song');
    final original = resolver.resolve(song);
    final timedOut = original.timeout(const Duration(seconds: 15));
    final failure = expectLater(timedOut, throwsA(isA<TimeoutException>()));
    await tester.pump(const Duration(seconds: 15));
    await failure;
    final retry = resolver.resolve(song);
    expect(plugin.requests, hasLength(1));
    plugin.requests.single.complete(const PluginResponse.streams([
      StreamSource(
          url: 'https://example.com/audio',
          quality: Quality.high,
          format: 'mp3')
    ]));
    await tester.pump();
    expect((await retry).uri.host, 'example.com');
    // Completed URLs are not cached indefinitely: later plays resolve afresh.
    final fresh = resolver.resolve(song);
    await tester.pump();
    expect(plugin.requests, hasLength(2));
    plugin.requests.last.complete(const PluginResponse.streams([
      StreamSource(
          url: 'https://example.com/new-audio',
          quality: Quality.high,
          format: 'mp3')
    ]));
    await tester.pump();
    expect((await fresh).uri.path, '/new-audio');
  });

  testWidgets('failed extraction is released so the next attempt can recover',
      (tester) async {
    final db = Completer<Isar>().future;
    final plugin = _ControlledPlugin();
    final resolver = MediaResolverService(
        downloadDao: _NoDownloads(db),
        settingsDao: _QualitySettings(db),
        pluginService: plugin);
    final song = _song('content-resolver.example::song');
    final first = expectLater(resolver.resolve(song), throwsStateError);
    await tester.pump();
    plugin.requests.single
        .completeError(StateError('temporary extraction failure'));
    await tester.pump();
    await first;
    final retry = resolver.resolve(song);
    await tester.pump();
    expect(plugin.requests, hasLength(2));
    plugin.requests.last.complete(const PluginResponse.streams([
      StreamSource(
          url: 'https://example.com/audio',
          quality: Quality.high,
          format: 'mp3')
    ]));
    await tester.pump();
    expect((await retry).uri.host, 'example.com');
  });

  testWidgets(
      'retry attempts are handled once each and switching tracks cancels old retries',
      (tester) async {
    final errors = PlayerErrorHandler();
    addTearDown(errors.dispose);
    final song = _song('first');
    var retries = 0;
    errors.onRetryCurrentTrack = () {
      retries++;
      errors.registerAttempt(song.id);
    };
    errors.registerAttempt(song.id);
    errors.handleError(PlayerErrorType.networkDropped, 'first failure', song);
    errors.handleError(
        PlayerErrorType.networkDropped, 'duplicate failure', song);
    await tester.pump(const Duration(seconds: 1));
    expect(retries, 1);
    errors.handleError(PlayerErrorType.networkDropped, 'retry failure', song);
    expect(errors.lastError.value!.message, 'retry failure');
    errors.registerAttempt('next');
    await tester.pump(const Duration(seconds: 3));
    expect(retries, 1);
    errors.handleError(
        PlayerErrorType.networkDropped, 'next track failure', _song('next'));
    expect(errors.lastError.value!.failedTrack!.id, 'next');
    errors.resetCircuitBreaker();
    await tester.pump(const Duration(seconds: 2));
    expect(retries, 1, reason: 'Stopping must cancel the pending reconnect.');
  });

  testWidgets('playback progress cannot replenish the automatic retry budget',
      (tester) async {
    final errors = PlayerErrorHandler();
    addTearDown(errors.dispose);
    final song = _song('intermittent');
    var retries = 0;
    var skips = 0;
    errors.onRetryCurrentTrack = () {
      retries++;
      errors.registerAttempt(song.id);
    };
    errors.onSkipToNext = () => skips++;
    errors.registerAttempt(song.id);
    for (var i = 0; i < 4; i++) {
      errors.markTrackSuccess(song.id);
      errors.handleError(PlayerErrorType.networkDropped, 'reset', song);
      await tester.pump(const Duration(seconds: 10));
    }
    expect(retries, 3);
    expect(skips, 1);
  });

  testWidgets('pause cancels a scheduled recovery', (tester) async {
    final errors = PlayerErrorHandler();
    addTearDown(errors.dispose);
    var retries = 0;
    errors.onRetryCurrentTrack = () => retries++;
    errors.registerAttempt('paused');
    errors.handleError(
        PlayerErrorType.networkDropped, 'reset', _song('paused'));
    errors.cancelPendingRetry();
    await tester.pump(const Duration(seconds: 10));
    expect(retries, 0);
  });

  test('native HTTP load failure produces one terminal error', () async {
    MediaKit.ensureInitialized(libmpv: library);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    });
    final engine = PlayerEngine();
    final errors = <String>[];
    final sub = engine.errorStream.listen(errors.add);
    try {
      final failure =
          engine.errorStream.first.timeout(const Duration(seconds: 10));
      await engine
          .openDirect(Uri.parse('http://127.0.0.1:${server.port}/denied'));
      await failure;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(errors, hasLength(1));
      expect(engine.state, EngineState.error);
      expect(engine.playing, false);
    } finally {
      await sub.cancel();
      await engine.dispose();
      await server.close(force: true);
    }
  }, skip: canRun ? false : 'Native libmpv unavailable.');

  for (final mode in [
    'standby',
    'paused',
    'playing',
    'reconnect',
    'completed'
  ]) {
    final standby = mode == 'standby';
    final autoPlay = mode != 'standby' && mode != 'paused';
    test('native $mode player bounds network reads and releases the transfer',
        () async {
      MediaKit.ensureInitialized(libmpv: library);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final nativePlayer = Player();
      final engine = PlayerEngine(playerA: nativePlayer);
      final playbackErrors = <String>[];
      final errorSub = engine.errorStream.listen(playbackErrors.add);
      var completions = 0;
      final completionSub =
          engine.completionStream.listen((_) => completions++);
      await engine.setVolume(0);
      var sent = 0;
      var requests = 0;
      final sockets = <Socket>{};
      final errors = <Object>[];
      final audioBytes = (mode == 'completed' ? 2 : 600) * 48000 * 2 * 2;
      final header = ByteData(44)
        ..setUint32(0, 0x52494646)
        ..setUint32(4, audioBytes + 36, Endian.little)
        ..setUint32(8, 0x57415645)
        ..setUint32(12, 0x666d7420)
        ..setUint32(16, 16, Endian.little)
        ..setUint16(20, 1, Endian.little)
        ..setUint16(22, 2, Endian.little)
        ..setUint32(24, 48000, Endian.little)
        ..setUint32(28, 192000, Endian.little)
        ..setUint16(32, 4, Endian.little)
        ..setUint16(34, 16, Endian.little)
        ..setUint32(36, 0x64617461)
        ..setUint32(40, audioBytes, Endian.little);
      final chunk = Uint8List(64 * 1024);
      Future<void> serve(Socket socket, String request) async {
        requests++;
        try {
          var offset = 0;
          final range = RegExp(r'range: bytes=(\d+)-', caseSensitive: false)
              .firstMatch(request);
          if (range != null) offset = int.parse(range.group(1)!);
          socket.add(ascii.encode(
              'HTTP/1.1 ${range == null ? "200 OK" : "206 Partial Content"}\r\n'
              'Content-Type: audio/wav\r\nAccept-Ranges: bytes\r\n'
              '${range == null ? "" : "Content-Range: bytes $offset-${audioBytes + 43}/${audioBytes + 44}\r\n"}'
              'Content-Length: ${audioBytes + 44 - offset}\r\nConnection: close\r\n\r\n'));
          if (offset < 44) {
            socket.add(header.buffer.asUint8List(offset));
            offset = 44;
          }
          while (sockets.contains(socket) && offset < audioBytes + 44) {
            final count = (audioBytes + 44 - offset).clamp(0, chunk.length);
            socket.add(Uint8List.sublistView(chunk, 0, count));
            sent += count;
            offset += count;
            await socket.flush();
            if (mode == 'reconnect' && requests == 1 && offset >= 128 * 1024) {
              // Interrupt a real HTTP body; subsequent range requests succeed.
              socket.destroy();
              break;
            }
            await Future<void>.delayed(const Duration(milliseconds: 1));
          }
        } on IOException {
          // A stopped preload closes the socket while the body is incomplete.
        } catch (error) {
          errors.add(error);
        } finally {
          sockets.remove(socket);
          socket.destroy();
        }
      }

      server.listen((socket) {
        sockets.add(socket);
        final request = StringBuffer();
        var dispatched = false;
        socket.listen((data) {
          request.write(ascii.decode(data));
          if (!dispatched && request.toString().contains('\r\n\r\n')) {
            dispatched = true;
            unawaited(serve(socket, request.toString()));
          }
        }, onDone: () {
          sockets.remove(socket);
          socket.destroy();
        }, onError: (Object error) {
          sockets.remove(socket);
          socket.destroy();
        });
      });
      try {
        final uri = Uri.parse('http://127.0.0.1:${server.port}/long.wav');
        if (standby) {
          expect(await engine.preloadNext(uri), true);
        } else {
          expect(
              await engine.openDirect(uri,
                  autoPlay: autoPlay && mode != 'playing'),
              isA<EngineSuccess>());
          if (mode == 'playing') await engine.play();
        }
        if (autoPlay) {
          await engine.positionStream
              .firstWhere((p) => p >= const Duration(seconds: 1))
              .timeout(const Duration(seconds: 10));
          // media_kit forwards these FFmpeg log messages even when playback
          // remains viable. Exercise its actual native diagnostic stream.
          nativePlayer.platform!.errorController
              .add('tcp: ffurl_read returned 0xffffd8ba');
          nativePlayer.platform!.errorController
              .add('tcp: ffurl_write returned 0xffffd8ba');
        }
        await Future<void>.delayed(const Duration(seconds: 3));
        // Allow ample TCP/decoder read-ahead beyond the four-MiB packet cache.
        // An unbounded disk cache fetches tens of MiB from this server instead.
        expect(requests, greaterThan(0));
        debugPrint('Native paused preload transferred $sent bytes');
        expect(sent, lessThan(12 * 1024 * 1024));
        expect(engine.playing, autoPlay && mode != 'completed');
        expect(playbackErrors, isEmpty);
        if (autoPlay && mode != 'completed') {
          expect(engine.position, greaterThan(const Duration(seconds: 2)));
        }
        expect(completions, mode == 'completed' ? 1 : 0);
        if (mode == 'reconnect') expect(requests, greaterThan(1));
        if (mode == 'playing') {
          final resumeAt = engine.position;
          await engine.stop();
          expect(
              await engine.openDirect(uri,
                  autoPlay: false, initialPosition: resumeAt),
              isA<EngineSuccess>());
          await engine.play();
          await engine.positionStream
              .firstWhere((p) => p >= resumeAt)
              .timeout(const Duration(seconds: 10));
          // A terminal EOF may reset the native position first. Recovery must
          // keep the last played position and must not advance the queue.
          nativePlayer.platform!.positionController.add(Duration.zero);
          nativePlayer.platform!.completedController.add(true);
          await engine.errorStream.first.timeout(const Duration(seconds: 3));
          expect(engine.recoveryPosition, greaterThanOrEqualTo(resumeAt));
          expect(engine.state, EngineState.error);
          expect(playbackErrors, hasLength(1));
        }
        if (standby) {
          await engine.clearPreload();
        } else {
          await engine.stop();
        }
        for (var i = 0; sockets.isNotEmpty && i < 100; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        expect(sockets, isEmpty,
            reason: 'Stopping preload must release the network read.');
        expect(errors, isEmpty);
      } finally {
        await errorSub.cancel();
        await completionSub.cancel();
        await engine.dispose();
        for (final socket in sockets.toList()) {
          socket.destroy();
        }
        await server.close();
      }
    },
        skip: canRun
            ? false
            : 'Set MPV_TEST_LIBRARY to the native libmpv library.',
        timeout: const Timeout(Duration(seconds: 30)));
  }
}
