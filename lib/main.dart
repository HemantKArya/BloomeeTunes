import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/model/youtube_vid_model.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/repository/cubits/fetch_search_results.dart';
import 'package:Bloomee/routes_and_consts/routes.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/import_playlist_cubit.dart';
import 'package:Bloomee/services/db/cubit/bloomee_db_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'blocs/mediaPlayer/bloomee_player_cubit.dart';

bool isYoutubeLink(String link) {
  if (link.contains("youtube.com") || link.contains("youtu.be")) {
    return true;
  } else {
    return false;
  }
}

String? extractVideoId(String url) {
  Uri uri = Uri.parse(url);

  // Check if the URL is from youtube.com
  if (uri.host == 'youtube.com') {
    return uri.queryParameters['v']; // Retrieve video ID from query parameter
  }

  // Check if the URL is from youtu.be
  if (uri.host == 'youtu.be') {
    return uri.pathSegments.first; // Retrieve video ID from path
  }

  // Invalid URL format
  return null;
}

void ProcessIncomingIntent(List<SharedMediaFile> _sharedFiles) {
  if (Uri.tryParse(_sharedFiles[0].path) != null &&
      isYoutubeLink(_sharedFiles[0].path)) {
    var _tempId = extractVideoId(_sharedFiles[0].path);
    if (_tempId != null) {
      log(extractVideoId(_sharedFiles[0].path).toString(),
          name: "Shared Files");
      var _tempVid = YouTubeServices().getVideoFromId(_tempId);
      _tempVid.then((value) {
        if (value != null) {
          YouTubeServices()
              .formatVideo(video: value, quality: "High")
              .then((value) async {
            if (value != null) {
              MediaItemModel _mIM = fromYtVidSongMap2MediaItem(value);
              MediaPlaylist _tempPlaylist = MediaPlaylist(
                albumName: "Shared Playlist",
                mediaItems: [_mIM],
              );
              log(_mIM.title, name: "Shared Files");
              await bloomeePlayerCubit.bloomeePlayer
                  .loadPlaylist(_tempPlaylist, doPlay: true);
              GlobalRoutes.globalRouter.pushNamed(GlobalStrConsts.playerScreen);
            }
          });
        }
      });
    }
  }
}

late BloomeePlayerCubit bloomeePlayerCubit;
void setupPlayerCubit() {
  bloomeePlayerCubit = BloomeePlayerCubit();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    dotenv.load(fileName: "assets/.env");
  } on Exception catch (e) {
    log("error $e");
    dotenv.load(mergeWith: io.Platform.environment);
  }
  setupPlayerCubit();
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
  final _sharedFiles = <SharedMediaFile>[];
  @override
  void initState() {
    super.initState();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentSub = ReceiveSharingIntent.getMediaStream().listen((event) {
      _sharedFiles.clear();
      _sharedFiles.addAll(event);
      log(_sharedFiles[0].mimeType.toString(), name: "Shared Files");
      log(_sharedFiles[0].path, name: "Shared Files");
      ProcessIncomingIntent(_sharedFiles);

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.reset();
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((event) {
      _sharedFiles.clear();
      _sharedFiles.addAll(event);
      log(_sharedFiles[0].mimeType.toString(), name: "Shared Files Offline");
      log(_sharedFiles[0].path, name: "Shared Files Offline");
      ProcessIncomingIntent(_sharedFiles);
      ReceiveSharingIntent.reset();
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    bloomeePlayerCubit.bloomeePlayer.audioPlayer.dispose();
    bloomeePlayerCubit.close();
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
          create: (context) => BloomeeDBCubit(),
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
          create: (context) => AddToPlaylistCubit(
              bloomeeDBCubit: context.read<BloomeeDBCubit>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ImportPlaylistCubit(),
        ),
        BlocProvider(
          create: (context) => FetchSearchResultsCubit(),
        )
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => SaavnRepositoryCubit()),
          RepositoryProvider(
            create: (context) => SaavnSearchRepositoryCubit(),
          ),
        ],
        child: BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
          builder: (context, state) {
            if (state is BloomeePlayerInitial) {
              return const SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator());
            } else {
              return MaterialApp.router(
                scaffoldMessengerKey: SnackbarService.messengerKey,
                routerConfig: GlobalRoutes.globalRouter,
              );
            }
          },
        ),
      ),
    );
  }
}
