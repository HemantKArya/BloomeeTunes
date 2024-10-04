import 'dart:developer';

import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/url_launcher.dart';

class CheckUpdateView extends StatelessWidget {
  const CheckUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        title: Text(
          'Check for Updates',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: getLatestVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              log("data: ${snapshot.data}");
              if (!snapshot.data?["results"]) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      'Bloomee🌸 is up-to-date!!!',
                      style: const TextStyle(
                              color: Default_Theme.accentColor2, fontSize: 20)
                          .merge(Default_Theme.tertiaryTextStyle),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Current Version: ${snapshot.data?["currVer"]} + ${snapshot.data?["currBuild"]}',
                        style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withOpacity(0.5),
                                fontSize: 12)
                            .merge(Default_Theme.tertiaryTextStyle),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      'New Version of Bloomee🌸 is now available!!',
                      style: const TextStyle(
                              color: Default_Theme.accentColor2, fontSize: 20)
                          .merge(Default_Theme.tertiaryTextStyle),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Version: ${snapshot.data?["newVer"]}+ ${snapshot.data?["newBuild"]}',
                        style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withOpacity(0.8),
                                fontSize: 16)
                            .merge(Default_Theme.tertiaryTextStyle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: () {
                          launch_Url(Uri.parse(snapshot.data?["download_url"]));
                        },
                        child: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.open_in_browser_rounded,
                                  size: 25),
                              Text(
                                "Download Now",
                                style: const TextStyle(fontSize: 17).merge(
                                    Default_Theme.secondoryTextStyleMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Current Version: ${snapshot.data?["currVer"]} + ${snapshot.data?["currBuild"]}',
                        style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withOpacity(0.5),
                                fontSize: 12)
                            .merge(Default_Theme.tertiaryTextStyle),
                      ),
                    ),
                  ],
                );
              }
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2,
                        )),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth * 0.6,
                        child: Text(
                            'Checking if newer version are availible or not!',
                            style: const TextStyle(
                                    color: Default_Theme.accentColor2,
                                    fontSize: 20)
                                .merge(Default_Theme.tertiaryTextStyle),
                            textAlign: TextAlign.center),
                      );
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
