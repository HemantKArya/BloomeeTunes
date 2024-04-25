import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/screens/screen/home_views/youtube_views/playlist.dart';
import 'package:Bloomee/screens/widgets/paging_scroll.dart';
import 'package:Bloomee/screens/widgets/square_card.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/external_list_importer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HorizontalCardView extends StatelessWidget {
  final Map<String, dynamic> data;
  const HorizontalCardView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Padding(
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
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: 20,
            //   ),
            //   child: Text(
            //     "YTMusic",
            //     textAlign: TextAlign.start,
            //     style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Default_Theme.primaryColor2.withOpacity(0.8))
            //         .merge(Default_Theme.secondoryTextStyle),
            //   ),
            // ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: PagingScrollPhysics(
                    itemCount: 20,
                    viewSize: MediaQuery.of(context).size.width * 0.88),
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  for (int i = 0; i < data['items'].length; i++)
                    SquareImgCard(
                      imgPath: data["items"][i]["image"].toString(),
                      title: data["items"][i]["title"].toString(),
                      subtitle: data["items"][i]["subtitle"].toString(),
                      isWide: (data["items"][i]['type'] == "video" ||
                              data["items"][i]['type'] == "chart")
                          ? true
                          : false,
                      tag: (data["items"][i]['type'] == "playlist" ||
                              data["items"][i]['type'] == "chart")
                          ? '${data["items"][i]["count"]} Tracks'
                          : data["items"][i]["count"].toString(),
                      isList: (data["items"][i]['type'] == "playlist" ||
                              data["items"][i]['type'] == "chart")
                          ? true
                          : false,
                      onTap: () {
                        switch (data["items"][i]['type']) {
                          case "playlist":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YoutubePlaylist(
                                        imgPath: data["items"][i]["image"],
                                        title: data["items"][i]["title"],
                                        subtitle: data["items"][i]["subtitle"],
                                        type: data["items"][i]["type"],
                                        id: data["items"][i]["id"])));
                            break;
                          case "chart":
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YoutubePlaylist(
                                        imgPath: data["items"][i]["image"],
                                        title: data["items"][i]["title"],
                                        subtitle: data["items"][i]["subtitle"],
                                        type: data["items"][i]["type"],
                                        id: data["items"][i]["id"])));
                            break;
                          case "video":
                            ExternalMediaImporter.ytMediaImporter(
                                    'https://youtu.be/${(data["items"][i]["id"] as String).replaceAll("youtube", "")}')
                                .then((value) async {
                              if (value != null) {
                                await context
                                    .read<BloomeePlayerCubit>()
                                    .bloomeePlayer
                                    .addQueueItem(value, doPlay: true);
                              }
                            });
                            break;
                          default:
                          // Navigator.pushNamed(context, '/album', arguments: data["items"][i]);
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
