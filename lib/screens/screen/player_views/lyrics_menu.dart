import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class LyricsMenu extends StatefulWidget {
  const LyricsMenu({super.key});

  @override
  State<LyricsMenu> createState() => _LyricsMenuState();
}

class _LyricsMenuState extends State<LyricsMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'LyricsMenu');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          Color.fromARGB(255, 27, 27, 27),
        ),
      ),
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () {},
          child: const Row(
            children: <Widget>[
              Icon(
                MingCute.search_2_fill,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('Search Lyrics',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          child: const Row(
            children: <Widget>[
              Icon(
                MingCute.search_fill,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('Research Lyrics Auto',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          child: const Row(
            children: <Widget>[
              Icon(
                MingCute.time_line,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('Offset Lyrics',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          focusNode: _buttonFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(
            MingCute.more_1_fill,
            color: Default_Theme.primaryColor1,
            size: 20,
          ),
        );
      },
    );
  }
}
