import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/repository/Saavn/cubit/saavn_repository_cubit.dart';
import 'package:Bloomee/screens/widgets/horizontalSongCard_widget.dart';

import '../../theme_data/default.dart';

class TabSongListWidget extends StatefulWidget {
  const TabSongListWidget({
    super.key,
  });

  @override
  State<TabSongListWidget> createState() => _TabSongListWidgetState();
}

class _TabSongListWidgetState extends State<TabSongListWidget>
    with AutomaticKeepAliveClientMixin {
  int _tab_index = 0;
  @override
  void initState() {
    super.initState();
    context.read<SaavnRepositoryCubit>().fetchTopResultsfromSaavn();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          //tabs vertical
          width: 65,
          // color: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: RotatedBox(
              quarterTurns: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _tab_index = 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 15),
                      child: Text(
                        "Recently",
                        style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                color: Default_Theme.primaryColor1,
                                fontSize: 20)),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _tab_index = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        "Trending",
                        style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                                color: Default_Theme.primaryColor1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _tab_index == 0 ? const SongListWidget() : const Text("hi")
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SongListWidget extends StatelessWidget {
  const SongListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.46,
        // width: MediaQuery.of(context).size.width * 0.82,
        child: BlocBuilder<SaavnRepositoryCubit, SaavnRepositoryState>(
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
                  padding: EdgeInsets.only(right: 70),
                  child: SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: Default_Theme.accentColor2,
                      )),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: state.mediaItems.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: HorizontalSongCardWidget(
                          mediaPlaylist: state,
                          index: index,
                          showLiked: true,
                          showOptions: true,
                        ));
                  });
            }
          },
        ),
      ),
    );
  }
}
