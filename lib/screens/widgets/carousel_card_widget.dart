import 'package:flutter/material.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/utils/load_Image.dart';

class CarouselCardView extends StatelessWidget {
  final String coverImageUrl;
  // final ImageProvider<Object> placeHolder =
  //     const AssetImage("assets/sample/album_cover_sam1.jpg");
  const CarouselCardView({super.key, required this.coverImageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 1.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: LoadImageCached(imageUrl: coverImageUrl),
        ),
      ),
      const Positioned(bottom: 15, right: 20, child: PlayPauseButton()),
    ]);
  }
}
