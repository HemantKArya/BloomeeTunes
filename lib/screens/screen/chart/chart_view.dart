// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/plugins/billboard_charts.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/theme_data/default.dart';

class ChartScreen extends StatelessWidget {
  ChartInfo? chartInfo;
  ChartScreen({Key? key, this.chartInfo}) : super(key: key) {
    chartInfo ??= ChartInfo(
      chartFunction: getBillboardChart,
      title: BillboardCharts.BILLBOARD_200.title,
      url: BillboardCharts.BILLBOARD_200.url,
      imgUrl: billboardRandomIMGs.getImage(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          customDiscoverBar(context), //AppBar
          SliverList(
              delegate: SliverChildListDelegate([
            FutureBuilder(
                future: chartInfo!.chartFunction(url: chartInfo!.url),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    final List<Map<String, String>>? melon = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: melon?.length,
                      itemBuilder: (context, index) {
                        return ChartListTile(
                          title: melon![index]['title']!,
                          subtitle: melon[index]['label']!,
                          imgUrl: melon[index]['img']!,
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Default_Theme.primaryTextStyle,
                      ),
                    );
                  }
                }),
          ]))
        ],
      ),
      backgroundColor: Default_Theme.themeColor,
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding:
            const EdgeInsets.only(left: 8, bottom: 0, right: 0, top: 0),
        title: Text(chartInfo!.title,
            textScaleFactor: 1,
            textAlign: TextAlign.start,
            style: Default_Theme.secondoryTextStyleMedium.merge(const TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 235, 251)))),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(chartInfo!.imgUrl), fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                  Default_Theme.themeColor.withOpacity(0.8),
                  Default_Theme.themeColor.withOpacity(0.4),
                  Default_Theme.themeColor.withOpacity(0.1),
                  Default_Theme.themeColor.withOpacity(0),
                ]))))
          ],
        ),
      ),
    );
  }
}
