import 'dart:async';
import 'dart:io' as io;
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/global_events/global_events_cubit.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/history/cubit/history_cubit.dart';
import 'package:Bloomee/blocs/explore/cubit/recently_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/repository/bloomee/download_repository.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/notification_dao.dart';
import 'package:Bloomee/services/db/dao/library_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/blocs/timer/timer_bloc.dart';
import 'package:Bloomee/screens/widgets/global_event_listener.dart';
import 'package:Bloomee/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/bootstrap.dart';
import 'package:Bloomee/services/keyboard_shortcuts_service.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/utils/ticker.dart';
import 'package:Bloomee/utils/url_checker.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/routes/app_router.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/media_player/bloomee_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/services/db/legacy/legacy_migration_service.dart'
    as legacy_migration;
import 'package:Bloomee/screens/widgets/legacy_migration_overlay.dart';
import 'package:Bloomee/screens/widgets/plugin_bootstrap_overlay.dart';
import 'package:Bloomee/services/plugin_bootstrap_service.dart';
import 'package:Bloomee/screens/widgets/onboarding_overlay.dart';
import 'package:Bloomee/services/onboarding_service.dart';

void processIncomingIntent(SharedMedia sharedMedia) {
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    SnackbarService.showMessage(
        'Open the Import screen in Library to import from this URL.');
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    final attachment = sharedMedia.attachments!.first;
    if (attachment != null) {
      SnackbarService.showMessage('Processing File...');
      importItems(attachment.path);
    }
  }
}

Future<void> importItems(String path) async {
  bool res = await ImportExportService.importMediaItem(path);
  if (res) {
    SnackbarService.showMessage("Media Item Imported");
  } else {
    res = await ImportExportService.importPlaylist(path);
    if (res) {
      SnackbarService.showMessage("Playlist Imported");
    } else {
      SnackbarService.showMessage("Invalid File Format");
    }
  }
}

Future<void> setHighRefreshRate() async {
  if (io.Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  MediaKit.ensureInitialized();
  await bootstrapApp();
  setHighRefreshRate();
  DiscordService.initialize();

  final player = await AudioService.init(
    builder: () => BloomeeMusicPlayer(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.BloomeePlayer.notification.status',
      androidNotificationChannelName: 'BloomeTunes',
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidResumeOnClick: true,
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: false,
      notificationColor: Default_Theme.accentColor2,
    ),
  );

  runApp(MyApp(player: player));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.player});
  final BloomeeMusicPlayer player;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<SharedMedia>? _intentSub;
  SharedMedia? sharedMedia;

  bool _onboardingPending = false;
  bool _bootstrapPending = false;
  bool _migrationPending = false;

  @override
  void initState() {
    super.initState();

    _onboardingPending = !OnboardingService.onboardingDone;
    _bootstrapPending = !PluginBootstrapService.bootstrapDone;

    _migrationPending = legacy_migration.needsMigration(
      DBProvider.appSuppDir,
      DBProvider.appDocDir,
    );

    if (!_onboardingPending && !_bootstrapPending) {
      _runPluginSyncIfDue();
    }

    if (io.Platform.isAndroid) {
      initPlatformState();
      _requestNotificationPermission();
    }
  }

  void _runPluginSyncIfDue() {
    unawaited(
      PluginBootstrapService.syncOnAppOpenIfDue(
        pluginService: ServiceLocator.pluginService,
        repositoryService: ServiceLocator.pluginRepositoryService,
        settingsDao: SettingsDAO(DBProvider.db),
      ),
    );
  }

  Future<void> initPlatformState() async {
    try {
      final handler = ShareHandlerPlatform.instance;
      sharedMedia = await handler.getInitialSharedMedia();

      _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
        if (!mounted) return;
        setState(() => sharedMedia = media);
        processIncomingIntent(media);
      });

      if (!mounted) return;
      if (sharedMedia != null) {
        setState(() {});
        processIncomingIntent(sharedMedia!);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize share handler: $error\n$stackTrace');
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (io.Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingPending) {
      return OnboardingOverlay(
        onComplete: () {
          setState(() {
            _onboardingPending = false;
          });
          if (!_bootstrapPending) {
            _runPluginSyncIfDue();
          }
        },
      );
    }

    if (_bootstrapPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: PluginBootstrapOverlay(
          onComplete: () {
            _runPluginSyncIfDue();
            setState(() => _bootstrapPending = false);
          },
        ),
      );
    }

    if (_migrationPending) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: LegacyMigrationOverlay(
          appSuppDir: DBProvider.appSuppDir,
          appDocDir: DBProvider.appDocDir,
          onComplete: (result) {
            if (!result.success) return;
            setState(() => _migrationPending = false);
          },
        ),
      );
    }

    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    final historyDao = HistoryDAO(DBProvider.db, trackDao);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PluginBloc(
            pluginService: ServiceLocator.pluginService,
            eventBus: ServiceLocator.pluginEventBus,
          )..add(const InitializePluginSystem()),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => BloomeePlayerCubit(widget.player),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              MiniPlayerCubit(playerCubit: context.read<BloomeePlayerCubit>()),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => SettingsCubit(
            SettingsRepository(SettingsDAO(DBProvider.db)),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => NotificationCubit(
            notificationDao: NotificationDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => TimerBloc(
              ticker: const Ticker(),
              bloomeePlayer: context.read<BloomeePlayerCubit>()),
        ),
        BlocProvider(
          create: (_) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => CurrentPlaylistCubit(playlistDao: playlistDao),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => RecentlyCubit(historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => HistoryCubit(historyDao: historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => LibraryItemsCubit(
            playlistDao: playlistDao,
            libraryDao: LibraryDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (_) => ContentImportCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (_) => AddToPlaylistCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => SearchSuggestionBloc(
            searchHistoryDao: SearchHistoryDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
            settingsDao: SettingsDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => LyricsCubit(
            context.read<BloomeePlayerCubit>(),
            lyricsDao: LyricsDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(
            playerCubit: context.read<BloomeePlayerCubit>(),
            cacheDao: CacheDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
            downloadRepo: DownloadRepository(
              DownloadDAO(DBProvider.db, trackDao, playlistDao),
            ),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => GlobalEventsCubit(
            settingsDao: SettingsDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => PlayerOverlayCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => ShortcutIndicatorCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => LocalMusicCubit(),
          lazy: true,
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final locale = settingsState.languageCode.isEmpty
              ? null
              : Locale(settingsState.languageCode);

          return KeyboardShortcutsHandler(
            child: ShortcutIndicatorOverlay(
              child: MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                builder: (context, child) => ResponsiveBreakpoints.builder(
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                        start: 1921, end: double.infinity, name: '4K'),
                  ],
                  child: GlobalEventListener(
                    navigatorKey: GlobalRoutes.globalRouterKey,
                    child: child!,
                  ),
                ),
                scaffoldMessengerKey: SnackbarService.messengerKey,
                routerConfig: GlobalRoutes.globalRouter,
                theme: Default_Theme().defaultThemeData,
                scrollBehavior: CustomScrollBehavior(),
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
