import 'dart:io';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/youtube_views/playlist.dart';
import 'package:Bloomee/screens/widgets/square_card.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class HorizontalCardView extends StatelessWidget {
  final Map<String, dynamic> data;
  final ScrollController _scrollController = ScrollController();

  HorizontalCardView({
    super.key,
    required this.data,
  });

  void _scrollToNext() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToPrevious() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 5,
            ),
            child: Text(
              data["title"].toString(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Default_Theme.accentColor2)
                  .merge(Default_Theme.secondoryTextStyle),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  if (Platform.isWindows || Platform.isLinux)
                    IconButton(
                      icon: const Icon(MingCute.left_line),
                      onPressed: _scrollToPrevious,
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: data['items'].length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            switch (data["items"][i]['type']) {
                              case "playlist":
                              case "chart":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => YoutubePlaylist(
                                      imgPath: data["items"][i]["image"],
                                      title: data["items"][i]["title"],
                                      subtitle: data["items"][i]["subtitle"],
                                      type: data["items"][i]["type"],
                                      id: data["items"][i]["id"],
                                    ),
                                  ),
                                );
                                break;
                              case "video":
                                ExternalMediaImporter.ytMediaImporter(
                                        'https://youtu.be/${(data["items"][i]["id"] as String).replaceAll("youtube", "")}')
                                    .then((value) async {
                                  if (value != null) {
                                    await context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .addQueueItem(value);
                                  }
                                });
                                break;
                              default:
                            }
                          },
                          child: SquareImgCard(
                            imgPath: data["items"][i]["image"].toString(),
                            title: data["items"][i]["title"].toString(),
                            subtitle: data["items"][i]["subtitle"].toString(),
                            isWide: data["items"][i]['isWide'],
                            tag: (data["items"][i]['type'] == "playlist" ||
                                    data["items"][i]['type'] == "chart")
                                ? '${data["items"][i]["count"]}'
                                    .replaceAll('songs', 'Tracks')
                                : data["items"][i]["count"].toString(),
                            isList: (data["items"][i]['type'] == "playlist" ||
                                    data["items"][i]['type'] == "chart")
                                ? true
                                : false,
                          ),
                        );
                      },
                    ),
                  ),
                  if (Platform.isWindows || Platform.isLinux)
                    IconButton(
                      icon: const Icon(MingCute.right_line),
                      onPressed: _scrollToNext,
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
