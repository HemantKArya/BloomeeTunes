import 'dart:async';

import 'package:Bloomee/services/backup/incoming_backup_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('ls.bloomee/imports');
  late List<String> pending;
  late List<String> acknowledged;

  setUp(() {
    pending = [];
    acknowledged = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      if (call.method == 'pending') return List<String>.of(pending);
      if (call.method == 'acknowledge') {
        final path = (call.arguments as Map)['path'] as String;
        acknowledged.add(path);
        pending.remove(path);
      }
      return null;
    });
  });
  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  Future<void> available() {
    final done = Completer<void>();
    binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec()
          .encodeMethodCall(const MethodCall('available')),
      (_) => done.complete(),
    );
    return done.future;
  }

  test(
      'cold-start inbox handles every file in order and acknowledges afterward',
      () async {
    pending.addAll(['one', 'two']);
    final seen = <String>[];
    final service = IncomingBackupService(
        enabled: true,
        onFile: (path) async {
          expect(acknowledged, isNot(contains(path)));
          seen.add(path);
        },
        onError: (error) => fail(error));
    await service.start();
    expect(seen, ['one', 'two']);
    expect(acknowledged, seen);
    expect(pending, isEmpty);
    service.dispose();
  });

  test(
      'warm events during processing are drained without reentering or duplicating',
      () async {
    pending.add('one');
    final seen = <String>[];
    var active = false;
    final service = IncomingBackupService(
        enabled: true,
        onFile: (path) async {
          expect(active, false);
          active = true;
          seen.add(path);
          if (path == 'one') {
            pending.add('two');
            await available();
            await available();
          }
          active = false;
        },
        onError: (error) => fail(error));
    await service.start();
    expect(seen, ['one', 'two']);
    expect(acknowledged, ['one', 'two']);
    service.dispose();
  });

  test('handler failure retains an unacknowledged file for retry', () async {
    pending.add('one');
    final errors = <String>[];
    final broken = IncomingBackupService(
        enabled: true,
        onFile: (_) async {
          throw StateError('interrupted');
        },
        onError: errors.add);
    await broken.start();
    broken.dispose();
    expect(errors.single, contains('interrupted'));
    expect(acknowledged, isEmpty);
    expect(pending, ['one']);
    final recovered = IncomingBackupService(
        enabled: true, onFile: (_) async {}, onError: (e) => fail(e));
    await recovered.start();
    recovered.dispose();
    expect(acknowledged, ['one']);
  });

  test('shared URL text is delivered without pretending it is a file',
      () async {
    var delivered = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      if (call.method == 'texts' && !delivered) {
        delivered = true;
        return ['https://example.com/music'];
      }
      return <String>[];
    });
    final seen = <String>[];
    final service = IncomingBackupService(
        enabled: true,
        onFile: (_) async => fail('URL must not become a backup file'),
        onText: (text) async => seen.add(text),
        onError: (e) => fail(e));
    await service.start();
    service.dispose();
    expect(seen, ['https://example.com/music']);
  });
}
