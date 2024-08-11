// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/screens/widgets/paging_scroll.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../theme_data/default.dart';

// ignore: must_be_immutable
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 15),
                child: Text(
                  category,
                  style: Default_Theme.secondoryTextStyle.merge(
                    const TextStyle(
                        color: Default_Theme.accentColor2,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: buildColumnsCards(list, context, columnLength: columnSize))
      ],
    );
  }

  bool get wantKeepAlive => true;
}

Widget buildColumnsCards(List<Widget> items, context, {int columnLength = 4}) {
  final cards = <Widget>[];
  Widget feautredCards;
  int endIndex = columnLength;
  double itemWidth = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
      ? ((MediaQuery.of(context).size.width - 40) * 0.88)
      : ((MediaQuery.of(context).size.width - 40) * 0.48);
  if (endIndex > items.length) endIndex = items.length;
  if (items.isNotEmpty) {
    for (int i = 0; i < items.length; i += columnLength) {
      if (endIndex > items.length) endIndex = items.length;
      List<Widget> currentRow = items.sublist(i, endIndex);
      // currentRow.add(const Spacer());
      endIndex = endIndex + columnLength;
      cards.add(SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: currentRow,
        ),
      ));
    }
    feautredCards = SizedBox(
      height: 70 * columnLength.toDouble() + 10,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: PagingScrollPhysics(
            itemCount: cards.length,
            viewSize: (MediaQuery.of(context).size.width - 40)),
        itemExtent: itemWidth,
        children: cards,
      ),
    );
  } else {
    feautredCards = Container();
  }
  return feautredCards;
}
