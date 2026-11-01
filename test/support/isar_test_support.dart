import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';

Future<void> initializeTestIsar() async {
  var library = Platform.environment['ISAR_TEST_LIBRARY'];
  if (library == null) {
    final config = File('.dart_tool/package_config.json').absolute;
    final packages = (jsonDecode(await config.readAsString())
        as Map<String, dynamic>)['packages'] as List<dynamic>;
    final package = packages
        .cast<Map<String, dynamic>>()
        .singleWhere((entry) => entry['name'] == 'isar_community_flutter_libs');
    final rootUri = package['rootUri'] as String;
    final root =
        config.uri.resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
    final relativePath = switch (Platform.operatingSystem) {
      'windows' => 'windows/libisar.dll',
      'linux' => 'linux/libisar.so',
      'macos' => 'macos/libisar.dylib',
      _ => throw UnsupportedError('Database tests require a desktop host.'),
    };
    library = root.resolve(relativePath).toFilePath();
  }
  await Isar.initializeIsarCore(libraries: {Abi.current(): library});
}
