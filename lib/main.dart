import 'dart:async';
import 'dart:io' as io;
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/global_events/global_events_cubit.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_bloc.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/blocs/timer/timer_bloc.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/screens/widgets/global_event_listener.dart';
import 'package:Bloomee/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/keyboard_shortcuts_service.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:Bloomee/utils/ticker.dart';
import 'package:Bloomee/utils/url_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/search/fetch_search_results.dart';
import 'package:Bloomee/routes_and_consts/routes.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:Bloomee/services/discord_service.dart';

void processIncomingIntent(SharedMedia sharedMedia) {
  // Check if there's text content that might be a URL
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    final urlType = getUrlType(sharedMedia.content!);
    switch (urlType) {
      case UrlType.spotifyTrack:
        ExternalMediaImporter.sfyMediaImporter(sharedMedia.content!)
            .then((value) async {
          if (value != null) {
            await bloomeePlayerCubit.bloomeePlayer.addQueueItem(
              value,
            );
          }
        });
        break;
      case UrlType.spotifyPlaylist:
        SnackbarService.showMessage("Import Spotify Playlist from library!");
        break;
      case UrlType.youtubePlaylist:
        SnackbarService.showMessage("Import Youtube Playlist from library!");
        break;
      case UrlType.spotifyAlbum:
        SnackbarService.showMessage("Import Spotify Album from library!");
        break;
      case UrlType.youtubeVideo:
        ExternalMediaImporter.ytMediaImporter(sharedMedia.content!)
            .then((value) async {
          if (value != null) {
            await bloomeePlayerCubit.bloomeePlayer
                .updateQueue([value], doPlay: true);
          }
        });
        break;
      case UrlType.other:
        // Handle as file if it's a file URL
        if (sharedMedia.attachments != null &&
            sharedMedia.attachments!.isNotEmpty) {
          final attachment = sharedMedia.attachments!.first;
          SnackbarService.showMessage("Processing File...");
          importItems(attachment!.path);
        }
    }
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    // Handle attachments
    // todo: handle multiple attachments
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

late BloomeePlayerCubit bloomeePlayerCubit;
void setupPlayerCubit() {
  bloomeePlayerCubit = BloomeePlayerCubit();
}

Future<void> initServices() async {
  String appDocPath = (await getApplicationDocumentsDirectory()).path;
  String appSuppPath = (await getApplicationSupportDirectory()).path;
  BloomeeDBService(appDocPath: appDocPath, appSuppPath: appSuppPath);
  YouTubeServices(appDocPath: appDocPath, appSuppPath: appSuppPath);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  if (io.Platform.isLinux || io.Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
    );
  }
  await initServices();
  setHighRefreshRate();
  setupPlayerCubit();
  DiscordService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize the player
  // This widget is the root of your application.
  late StreamSubscription _intentSub;
  SharedMedia? sharedMedia;
  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid) {
      initPlatformState();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final handler = ShareHandlerPlatform.instance;
    sharedMedia = await handler.getInitialSharedMedia();

    _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      setState(() {
        sharedMedia = media;
      });
      if (sharedMedia != null) {
        processIncomingIntent(sharedMedia!);
      }
    });
    if (!mounted) return;

    setState(() {
      // If there's initial shared media, process it
      if (sharedMedia != null) {
        processIncomingIntent(sharedMedia!);
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    bloomeePlayerCubit.close();
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => bloomeePlayerCubit,
          lazy: false,
        ),
        BlocProvider(
            create: (context) =>
                MiniPlayerBloc(playerCubit: bloomeePlayerCubit),
            lazy: true),
        BlocProvider(
          create: (context) => BloomeeDBCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => SettingsCubit(),
          lazy: false,
        ),
        BlocProvider(create: (context) => NotificationCubit(), lazy: false),
        BlocProvider(
            create: (context) => TimerBloc(
                ticker: const Ticker(), bloomeePlayer: bloomeePlayerCubit)),
        BlocProvider(
          create: (context) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => CurrentPlaylistCubit(
              bloomeeDBCubit: context.read<BloomeeDBCubit>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              LibraryItemsCubit(bloomeeDBCubit: context.read<BloomeeDBCubit>()),
        ),
        BlocProvider(
          create: (context) => AddToPlaylistCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ImportPlaylistCubit(),
        ),
        BlocProvider(
          create: (context) => FetchSearchResultsCubit(),
        ),
        BlocProvider(create: (context) => SearchSuggestionBloc()),
        BlocProvider(
          create: (context) => LyricsCubit(bloomeePlayerCubit),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(playerCubit: bloomeePlayerCubit),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => GlobalEventsCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PlayerOverlayCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ShortcutIndicatorCubit(),
          lazy: false,
        ),
      ],
      child: BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
        builder: (context, state) {
          if (state is BloomeePlayerInitial) {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return KeyboardShortcutsHandler(
              child: ShortcutIndicatorOverlay(
                child: MaterialApp.router(
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
          }
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        // etc.
      };
}
