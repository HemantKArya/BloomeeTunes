import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        surfaceTintColor: Default_Theme.themeColor,
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bloomee🌸\nAn Open-Source Music Player\nby",
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
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse("https://github.com/HemantKArya/BloomeeTunes"),
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
                      "Contribute on Github",
                      style: TextStyle(
                          color: Default_Theme.primaryColor1,
                          fontSize: 15,
                          fontFamily: 'Unageo',
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
          ],
        ),
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
