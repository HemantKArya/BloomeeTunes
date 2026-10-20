import 'dart:convert';
import 'dart:io';

import 'package:Bloomee/services/backup/backup_files.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class TestPicker extends FilePicker {
  FilePickerResult? picked;
  String? destination;

  @override
  Future<FilePickerResult?> pickFiles(
          {String? dialogTitle,
          String? initialDirectory,
          FileType type = FileType.any,
          List<String>? allowedExtensions,
          Function(FilePickerStatus)? onFileLoading,
          bool allowCompression = false,
          int compressionQuality = 0,
          bool allowMultiple = false,
          bool withData = false,
          bool withReadStream = false,
          bool lockParentWindow = false,
          bool readSequential = false}) async =>
      picked;

  @override
  Future<String?> saveFile(
          {String? dialogTitle,
          String? fileName,
          String? initialDirectory,
          FileType type = FileType.any,
          List<String>? allowedExtensions,
          Uint8List? bytes,
          bool lockParentWindow = false}) async =>
      destination;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late TestPicker picker;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('bloomee_transport_test_');
    picker = TestPicker();
    FilePicker.platform = picker;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => root.path);
  });
  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), null);
    await root.delete(recursive: true);
  });

  test('picker cancellation has no file side effects', () async {
    expect(await BackupFiles().pick(), isNull);
    expect(root.listSync(), isEmpty);
  });

  test('picked provider stream is staged without changing the original',
      () async {
    final original = File(p.join(root.path, 'original.json'));
    await original.writeAsString('{"example":true}');
    picker.picked = FilePickerResult([
      PlatformFile(
          name: 'copy.json',
          size: original.lengthSync(),
          readStream: original.openRead())
    ]);
    final files = BackupFiles();
    final staged = await files.pick();
    expect(staged, isNot(original.path));
    expect(await File(staged!).readAsString(), await original.readAsString());
    await files.release(staged);
    expect(File(staged).existsSync(), false);
    expect(original.existsSync(), true);
    await files.release(original.path);
    expect(original.existsSync(), true);
  });

  test('Save As cancellation leaves source and destination unchanged',
      () async {
    final original = File(p.join(root.path, 'source.json'));
    await original.writeAsString('{}');
    expect(await BackupFiles().save(original.path), isNull);
    expect(await original.readAsString(), '{}');
  });

  test('desktop Save As writes the selected destination', () async {
    if (Platform.isAndroid || Platform.isIOS) return;
    final original = File(p.join(root.path, 'source.json'));
    await original.writeAsString('{"data":1}');
    picker.destination = p.join(root.path, 'chosen.json');
    expect(await BackupFiles().save(original.path), picker.destination);
    expect(await File(picker.destination!).readAsString(), '{"data":1}');
  });

  test('safe filenames retain JSON suffix and fit filesystem byte limits', () {
    final name = BackupFiles.safeName('${List.filled(200, '🌙').join()}.json');
    expect(utf8.encode(name).length, lessThanOrEqualTo(160));
    expect(name.endsWith('.json'), true);
    expect(BackupFiles.safeName('../sample.json'), 'sample.json');
    expect(BackupFiles.safeName('..'), 'bloomee.json');
  });
}
