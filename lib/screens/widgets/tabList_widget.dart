import 'dart:io';
import 'package:Bloomee/screens/widgets/paging_scroll.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../theme_data/default.dart';

class CategoryLabel extends StatelessWidget {
  final String category;

  const CategoryLabel({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: RotatedBox(
          quarterTurns: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              category,
              style: Default_Theme.secondoryTextStyle.merge(
                const TextStyle(
                  color: Default_Theme.accentColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ColumnsCards extends StatelessWidget {
  final List<Widget> list;
  final int columnSize;
  final ScrollController scrollController; // Added scrollController

  const ColumnsCards({
    Key? key,
    required this.list,
    required this.columnSize,
    required this.scrollController, // Added scrollController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return Container();

    final double itemWidth =
        ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
            ? (MediaQuery.of(context).size.width - 40) * 0.88
            : (MediaQuery.of(context).size.width - 40) * 0.48;

    final List<Widget> cards = List.generate(
      (list.length / columnSize).ceil(),
      (index) {
        final startIndex = index * columnSize;
        final endIndex = (startIndex + columnSize).clamp(0, list.length);
        final currentRow = list.sublist(startIndex, endIndex);

        return SizedBox(
          width: itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: currentRow,
          ),
        );
      },
    );

    return Stack(
      children: [
        SizedBox(
          height: 70 * columnSize.toDouble() + 10,
          child: ListView(
            controller: scrollController, // Use the passed scrollController
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: PagingScrollPhysics(
              itemCount: cards.length,
              viewSize: MediaQuery.of(context).size.width - 40,
            ),
            itemExtent: itemWidth,
            children: cards,
          ),
        ),
      ],
    );
  }
}

class TabSongListWidget extends StatelessWidget {
  final List<Widget> list;
  final String category;
  final int columnSize;

  const TabSongListWidget({
    Key? key,
    required this.list,
    required this.category,
    required this.columnSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final double itemWidth =
        ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
            ? (MediaQuery.of(context).size.width - 40) * 0.88
            : (MediaQuery.of(context).size.width - 40) * 0.48;

    return Column(
      children: [
        if (Platform.isWindows || Platform.isLinux)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(MingCute.left_line),
                  onPressed: () {
                    scrollController.animateTo(
                      scrollController.offset - itemWidth,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(MingCute.right_line),
                  onPressed: () {
                    scrollController.animateTo(
                      scrollController.offset + itemWidth,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryLabel(category: category),
            Expanded(
              child: ColumnsCards(
                list: list,
                columnSize: columnSize,
                scrollController: scrollController, // Pass scrollController
              ),
            ),
          ],
        ),
      ],
    );
  }
}
