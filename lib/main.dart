import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_bloc.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/blocs/timer/timer_bloc.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/services/shortcuts_intents.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:Bloomee/utils/ticker.dart';
import 'package:Bloomee/utils/url_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/search/fetch_search_results.dart';
import 'package:Bloomee/routes_and_consts/routes.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:Bloomee/services/discord_service.dart';

void processIncomingIntent(List<SharedMediaFile> sharedMediaFiles) {
  if (isUrl(sharedMediaFiles[0].path)) {
    final urlType = getUrlType(sharedMediaFiles[0].path);
    switch (urlType) {
      case UrlType.spotifyTrack:
        ExternalMediaImporter.sfyMediaImporter(sharedMediaFiles[0].path)
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
        ExternalMediaImporter.ytMediaImporter(sharedMediaFiles[0].path)
            .then((value) async {
          if (value != null) {
            await bloomeePlayerCubit.bloomeePlayer.addQueueItem(
              value,
            );
          }
        });
        break;
      case UrlType.other:
        if (sharedMediaFiles[0].mimeType == "application/octet-stream") {
          SnackbarService.showMessage("Processing File...");
          importItems(
              Uri.parse(sharedMediaFiles[0].path).toFilePath().toString());
        }
      default:
        log("Invalid URL");
    }
  }
}

Future<void> importItems(String path) async {
  bool _res = await ImportExportService.importMediaItem(path);
  if (_res) {
    SnackbarService.showMessage("Media Item Imported");
  } else {
    _res = await ImportExportService.importPlaylist(path);
    if (_res) {
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
  MetadataGod.initialize();
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
  final sharedMediaFiles = <SharedMediaFile>[];
  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid) {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentSub =
          ReceiveSharingIntent.instance.getMediaStream().listen((event) {
        sharedMediaFiles.clear();
        sharedMediaFiles.addAll(event);
        log(sharedMediaFiles[0].mimeType.toString(), name: "Shared Files");
        log(sharedMediaFiles[0].path, name: "Shared Files");
        processIncomingIntent(sharedMediaFiles);

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed

      ReceiveSharingIntent.instance.getInitialMedia().then((event) {
        sharedMediaFiles.clear();
        sharedMediaFiles.addAll(event);
        log(sharedMediaFiles[0].mimeType.toString(),
            name: "Shared Files Offline");
        log(sharedMediaFiles[0].path, name: "Shared Files Offline");
        processIncomingIntent(sharedMediaFiles);
        ReceiveSharingIntent.instance.reset();
      });
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    bloomeePlayerCubit.bloomeePlayer.audioPlayer.dispose();
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
      ],
      child: RepositoryProvider(
        create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>()),
        lazy: false,
        child: BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
          builder: (context, state) {
            if (state is BloomeePlayerInitial) {
              return const SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator());
            } else {
              return MaterialApp.router(
                shortcuts: {
                  LogicalKeySet(LogicalKeyboardKey.space):
                      const PlayPauseIntent(),
                  LogicalKeySet(LogicalKeyboardKey.mediaPlayPause):
                      const PlayPauseIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                      const PreviousIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowRight):
                      const NextIntent(),
                  LogicalKeySet(LogicalKeyboardKey.keyR): const RepeatIntent(),
                  LogicalKeySet(LogicalKeyboardKey.keyL): const LikeIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowRight,
                      LogicalKeyboardKey.alt): const NSecForwardIntent(),
                  LogicalKeySet(
                          LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.alt):
                      const NSecBackwardIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp):
                      const VolumeUpIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowDown):
                      const VolumeDownIntent(),
                },
                actions: {
                  PlayPauseIntent: CallbackAction(onInvoke: (intent) {
                    if (context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .audioPlayer
                        .playing) {
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .audioPlayer
                          .pause();
                    } else {
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .audioPlayer
                          .play();
                    }
                    return null;
                  }),
                  NextIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .skipToNext();
                    return null;
                  }),
                  PreviousIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .skipToPrevious();
                    return null;
                  }),
                  NSecForwardIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .seekNSecForward(const Duration(seconds: 5));
                    return null;
                  }),
                  NSecBackwardIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .seekNSecBackward(const Duration(seconds: 5));
                    return null;
                  }),
                  VolumeUpIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .audioPlayer
                        .setVolume((context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .audioPlayer
                                    .volume +
                                0.1)
                            .clamp(0.0, 1.0));
                    return null;
                  }),
                  VolumeDownIntent: CallbackAction(onInvoke: (intent) {
                    context
                        .read<BloomeePlayerCubit>()
                        .bloomeePlayer
                        .audioPlayer
                        .setVolume((context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .audioPlayer
                                    .volume -
                                0.1)
                            .clamp(0.0, 1.0));
                    return null;
                  }),
                },
                builder: (context, child) => ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(
                        start: 1921, end: double.infinity, name: '4K'),
                  ],
                ),
                scaffoldMessengerKey: SnackbarService.messengerKey,
                routerConfig: GlobalRoutes.globalRouter,
                theme: Default_Theme().defaultThemeData,
                scrollBehavior: CustomScrollBehavior(),
                debugShowCheckedModeBanner: false,
              );
            }
          },
        ),
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
        // etc.
      };
}
