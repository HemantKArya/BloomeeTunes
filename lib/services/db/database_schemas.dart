import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// Shared by the live connection and short-lived backup worker connections.
const List<CollectionSchema<dynamic>> databaseSchemas = [
  TrackDBSchema,
  SearchHistoryDBSchema,
  PlaylistEntryDBSchema,
  LyricsDBSchema,
  PlaylistDBSchema,
  NotificationsDBSchema,
  PlaybackHistoryDBSchema,
  AppSettingsBoolDBSchema,
  AppSettingsStrDBSchema,
  DownloadDBSchema,
  CacheEntryDBSchema,
  PluginStorageEntitySchema,
];
