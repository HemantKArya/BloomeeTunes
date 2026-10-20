import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/services/player/player_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final library = Platform.environment['MPV_TEST_LIBRARY'] ??
      (Platform.isWindows
          ? p.absolute('build/windows/x64/runner/Debug/libmpv-2.dll')
          : null);
  final canRun = library != null && File(library).existsSync();

  for (final standby in [true, false]) {
    test(
        'paused native ${standby ? 'standby' : 'active'} player bounds network reads and releases the transfer',
        () async {
      MediaKit.ensureInitialized(libmpv: library);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final engine = PlayerEngine();
      var sent = 0;
      var requests = 0;
      final sockets = <Socket>{};
      final errors = <Object>[];
      const audioBytes =
          600 * 48000 * 2 * 2; // Ten minutes of PCM, not silence compression.
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
          expect(await engine.openDirect(uri, autoPlay: false),
              isA<EngineSuccess>());
        }
        await Future<void>.delayed(const Duration(seconds: 3));
        // Allow ample TCP/decoder read-ahead beyond the four-MiB packet cache.
        // An unbounded disk cache fetches tens of MiB from this server instead.
        expect(requests, greaterThan(0));
        debugPrint('Native paused preload transferred $sent bytes');
        expect(sent, lessThan(12 * 1024 * 1024));
        expect(engine.playing, false);
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
