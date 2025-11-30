import 'package:Bloomee/screens/widgets/global_footer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/screen/common_views/add_to_playlist_screen.dart';
import 'package:Bloomee/screens/screen/player_screen.dart';
import 'package:Bloomee/screens/screen/explore_screen.dart';
import 'package:Bloomee/screens/screen/library_screen.dart';
import 'package:Bloomee/screens/screen/library_views/import_media_view.dart';
import 'package:Bloomee/screens/screen/library_views/playlist_screen.dart';
import 'package:Bloomee/screens/screen/offline_screen.dart';
import 'package:Bloomee/screens/screen/search_screen.dart';
import 'package:Bloomee/screens/screen/chart/chart_view.dart';

class GlobalRoutes {
  static final globalRouterKey = GlobalKey<NavigatorState>();

  static final globalRouter = GoRouter(
    initialLocation: '/Explore',
    navigatorKey: globalRouterKey,
    routes: [
      GoRoute(
        name: GlobalStrConsts.playerScreen,
        path: "/MusicPlayer",
        parentNavigatorKey: globalRouterKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AudioPlayerView(),
            transitionDuration: const Duration(milliseconds: 100),
            reverseTransitionDuration: const Duration(milliseconds: 100),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                reverseCurve: Curves.easeIn,
                curve: Curves.easeInOut,
              );
              final offsetAnimation = curvedAnimation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/AddToPlaylist',
        parentNavigatorKey: globalRouterKey,
        name: GlobalStrConsts.addToPlaylistScreen,
        builder: (context, state) => const AddToPlaylistScreen(),
      ),
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              GlobalFooter(navigationShell: navigationShell),
          branches: [
            // StatefulShellBranch(routes: [
            //   GoRoute(
            //     name: GlobalStrConsts.testScreen,
            //     path: '/Test',
            //     builder: (context, state) => TestView(),
            //   ),
            // ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  name: GlobalStrConsts.exploreScreen,
                  path: '/Explore',
                  builder: (context, state) => const ExploreScreen(),
                  routes: [
                    GoRoute(
                        name: GlobalStrConsts.ChartScreen,
                        path: 'ChartScreen:chartName',
                        builder: (context, state) => ChartScreen(
                            chartName:
                                state.pathParameters['chartName'] ?? "none")),
                  ])
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  name: GlobalStrConsts.libraryScreen,
                  path: '/Library',
                  builder: (context, state) => const LibraryScreen(),
                  routes: [
                    GoRoute(
                      path: GlobalStrConsts.ImportMediaFromPlatforms,
                      name: GlobalStrConsts.ImportMediaFromPlatforms,
                      builder: (context, state) =>
                          const ImportMediaFromPlatformsView(),
                    ),
                    GoRoute(
                      name: GlobalStrConsts.playlistView,
                      path: GlobalStrConsts.playlistView,
                      builder: (context, state) {
                        return const PlaylistView();
                      },
                    ),
                  ]),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: GlobalStrConsts.searchScreen,
                path: '/Search',
                builder: (context, state) {
                  if (state.uri.queryParameters['query'] != null) {
                    return SearchScreen(
                      searchQuery:
                          state.uri.queryParameters['query']!.toString(),
                    );
                  } else {
                    return const SearchScreen();
                  }
                },
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: GlobalStrConsts.offlineScreen,
                path: '/Offline',
                builder: (context, state) => const OfflineScreen(),
              ),
            ]),
          ])
    ],
  );
}
