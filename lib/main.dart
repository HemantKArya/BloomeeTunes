import 'dart:developer';
import 'dart:io';
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
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'blocs/mediaPlayer/bloomee_player_cubit.dart';

void main() {
  try {
    dotenv.load(fileName: "assets/.env");
  } on Exception catch (e) {
    log("error $e");
    dotenv.load(mergeWith: Platform.environment);
  }
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
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BloomeePlayerCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => MediaDBCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              CurrentPlaylistCubit(mediaDBCubit: context.read<MediaDBCubit>()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) =>
              LibraryItemsCubit(mediaDBCubit: context.read<MediaDBCubit>()),
        ),
        BlocProvider(
          create: (context) =>
              AddToPlaylistCubit(mediaDBCubit: context.read<MediaDBCubit>()),
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
                routerConfig: GlobalRoutes().globalRouter,
              );
            }
          },
        ),
      ),
    );
  }
}
