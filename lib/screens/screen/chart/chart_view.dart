// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/plugins/billboard_charts.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/theme_data/default.dart';

class ChartScreen extends StatefulWidget {
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
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late Future _chartData;
  @override
  void initState() {
    super.initState();
    _chartData = widget.chartInfo!.chartFunction(url: widget.chartInfo!.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _chartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  )),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: Default_Theme.secondoryTextStyleMedium,
              ),
            );
          } else {
            final List<Map<String, String>>? melon = snapshot.data;
            return CustomScrollView(
              slivers: [
                customDiscoverBar(context), //AppBar
                SliverList(
                    delegate: SliverChildListDelegate([
                  ListView.builder(
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
                  ),
                ]))
              ],
            );
          }
        },
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
        title: Text(widget.chartInfo!.title,
            textScaleFactor: 1,
            textAlign: TextAlign.start,
            style: Default_Theme.secondoryTextStyleMedium.merge(const TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 235, 251)))),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.chartInfo!.imgUrl),
                    fit: BoxFit.cover),
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
