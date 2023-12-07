import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Settings',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: getLatestVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?["results"]) {
                if (int.parse(snapshot.data?["currBuild"]) >
                    int.parse(snapshot.data?["newBuild"])) {
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
                  return Text(
                    'New Version of Bloomee🌸!!',
                    style: const TextStyle(
                            color: Default_Theme.accentColor2, fontSize: 20)
                        .merge(Default_Theme.tertiaryTextStyle),
                  );
                }
              } else {
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
                        'Failed to fetch data from internet!',
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
