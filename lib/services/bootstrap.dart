import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/repository/youtube/youtube_api.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Application bootstrap — run once before [runApp].
///
/// Responsibilities:
/// - Initialize platform path constants.
/// - Open the Isar database via [DBProvider].
/// - Schedule periodic DB maintenance tasks.
/// - Spin up [YouTubeServices] cache.
/// - Wire the [ServiceLocator].
Future<void> bootstrapApp() async {
  final String appDocPath = (await getApplicationDocumentsDirectory()).path;
  final String appSuppPath = (await getApplicationSupportDirectory()).path;

  // Open DB and schedule maintenance.
  await DBProvider.init(
      appSupportPath: appSuppPath, appDocumentsPath: appDocPath);
  DBProvider.scheduleMaintenance();

  YouTubeServices(appDocPath: appDocPath, appSuppPath: appSuppPath);

  // DI wiring.
  await ServiceLocator.setup();
}
