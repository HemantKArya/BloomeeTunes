import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/unicode_icons.dart';
import 'package:Bloomee/theme_data/default.dart';

import '../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'carousel_card_view.dart';

class CaraouselWidget extends StatefulWidget {
  CaraouselWidget({
    super.key,
  });

  @override
  State<CaraouselWidget> createState() => _CaraouselWidgetState();
}

class _CaraouselWidgetState extends State<CaraouselWidget> {
  bool _visibility = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 80),
            opacity: _visibility ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  children: [
                    Text(
                      "Trending",
                      style: Default_Theme.secondoryTextStyle.merge(
                          const TextStyle(
                              color: Default_Theme.primaryColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 19)),
                    ),
                    const UnicodeIcon(strCode: "\uf0e7"),
                  ],
                ),
              ),
            ),
          ),
        ),
        BlocBuilder<SaavnRepositoryCubit, SaavnRepositoryState>(
          buildWhen: (previous, current) {
            if (current.albumName == "Trendings" && previous != current) {
              return true;
            } else {
              return false;
            }
          },
          builder: (context, state) {
            if (state is SaavnRepositoryInitial) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator.adaptive()),
              ));
            } else {
              return CarouselSlider(
                options: CarouselOptions(
                    onPageChanged: (index, _) {
                      setState(() {
                        _visibility = index == 0;
                      });
                    },
                    height: 320.0,
                    viewportFraction: 0.7,
                    // aspectRatio: 15 / 16,
                    enableInfiniteScroll: false,
                    enlargeFactor: 0.2,
                    initialPage: 0,
                    enlargeCenterPage: true),
                items: [
                  for (var index = 0; index < state.mediaItems.length; index++)
                    GestureDetector(
                      onTap: () {
                        if (context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .currentPlaylist !=
                            state.mediaItems) {
                          context
                              .read<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .loadPlaylist(state, idx: index);
                        } else if (context
                                .read<BloomeePlayerCubit>()
                                .bloomeePlayer
                                .currentMedia !=
                            state.mediaItems[index]) {
                          context
                              .read<BloomeePlayerCubit>()
                              .bloomeePlayer
                              .prepare4play(idx: index);
                        }
                        context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                        context.pushNamed(GlobalStrConsts.playerScreen);
                      },
                      child: CarouselCardView(
                          coverImageUrl:
                              state.mediaItems[index].artUri.toString()),
                    ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
