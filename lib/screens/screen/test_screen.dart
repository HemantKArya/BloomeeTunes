import 'dart:developer';
import 'package:Bloomee/model/lyrics_models.dart';
import 'package:Bloomee/repository/Lyrics/lrcnet_api.dart';
import 'package:Bloomee/repository/Lyrics/lyrics.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';

class TestView extends StatelessWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Tests',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Test View",
              style: TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () async {
                LyricsRepository.getLyrics("bliss", "milet",
                        album: "anytime anywhere",
                        duration: Duration(seconds: 260),
                        provider: LyricsProvider.lrcnet)
                    .then((value) {
                  log(value.toString());
                });
              },
              child: const Text(
                "Test API",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
