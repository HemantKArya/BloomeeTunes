import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'About',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bloomee🌸\nAn Open Cross-Platform Music Player\nby",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Default_Theme.accentColor2,
                            fontSize: 25,
                            fontFamily: 'Unageo',
                            fontWeight: FontWeight.bold),
                      ),
                      const GradientText(
                          text: Text(
                            "@iamhemantindia",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Default_Theme.accentColor2,
                                fontSize: 30,
                                fontFamily: 'Unageo',
                                fontWeight: FontWeight.bold),
                          ),
                          gradient: LinearGradient(colors: [
                            Default_Theme.accentColor1,
                            Color.fromARGB(255, 224, 14, 192)
                          ])),
                      const Text("Crafting symphonies in code.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Default_Theme.accentColor2,
                              fontSize: 15,
                              fontFamily: 'Unageo',
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 10, right: 10, left: 10),
                        child: FutureBuilder(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final PackageInfo packageInfo =
                                  snapshot.data as PackageInfo;
                              return Text(
                                "v${packageInfo.version}+${int.parse(packageInfo.buildNumber) % 1000}",
                                style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withOpacity(0.5),
                                  fontSize: 15,
                                  fontFamily: 'Unageo',
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                launchUrl(
                                    Uri.parse(
                                        "https://github.com/HemantKArya/BloomeeTunes"),
                                    mode: LaunchMode.externalApplication);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Default_Theme.accentColor2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(MingCute.github_fill,
                                        color: Default_Theme.primaryColor2),
                                  ),
                                  Text(
                                    "Github",
                                    style: TextStyle(
                                        color: Default_Theme.primaryColor1,
                                        fontSize: 15,
                                        fontFamily: 'Unageo',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          ElevatedButton(
                              onPressed: () {
                                launchUrl(
                                    Uri.parse(
                                        "https://liberapay.com/hemantkarya"),
                                    mode: LaunchMode.externalApplication);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Icon(MingCute.paypal_fill,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "Buy me a coffee",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Unageo',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText({
    Key? key,
    required this.text,
    required this.gradient,
  }) : super(key: key);
  final Widget text;
  final Gradient gradient;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: text,
    );
  }
}
