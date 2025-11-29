// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/model/chart_model.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:Bloomee/utils/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class ChartScreen extends StatefulWidget {
  final String chartName;
  const ChartScreen({Key? key, required this.chartName}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Future<ChartModel?> chartModel = Future.value(null);
  Future<ChartModel?> getChart() async {
    return await BloomeeDBService.getChart(widget.chartName);
  }

  @override
  void initState() {
    setState(() {
      chartModel = getChart();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: chartModel,
          builder: (context, state) {
            if (state.connectionState == ConnectionState.waiting ||
                state.data == null) {
              return const Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2,
                    )),
              );
            } else if (state.data!.chartItems!.isEmpty) {
              return Center(
                child: Text("Error: No Item in Chart",
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                        const TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 255, 235, 251)))),
              );
            } else {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  customDiscoverBar(context, state.data!), //AppBar
                  SliverList(
                      delegate: SliverChildListDelegate([
                    ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.data!.chartItems!.length,
                      itemBuilder: (context, index) {
                        return ChartListTile(
                          title: state.data!.chartItems![index].name!,
                          subtitle: state.data!.chartItems![index].subtitle!,
                          imgUrl: state.data!.chartItems![index].imageUrl!,
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
      ),
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context, ChartModel state) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      expandedHeight: 200,
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
          ),
          child: IconButton(
            icon: const Icon(MingCute.external_link_line),
            onPressed: () {
              state.url != null ? launch_Url(Uri.parse(state.url!)) : null;
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding:
            const EdgeInsets.only(left: 8, bottom: 0, right: 0, top: 0),
        title: Text(state.chartName,
            textScaler: const TextScaler.linear(1.0),
            textAlign: TextAlign.start,
            style: Default_Theme.secondoryTextStyleMedium.merge(const TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 235, 251)))),
        background: Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                child: LoadImageCached(
                  imageUrl: formatImgURL(
                      state.chartItems!.first.imageUrl.toString(),
                      ImageQuality.high),
                  fit: BoxFit.cover,
                ),
              );
            }),
            Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                  Default_Theme.themeColor.withValues(alpha: 0.8),
                  Default_Theme.themeColor.withValues(alpha: 0.4),
                  Default_Theme.themeColor.withValues(alpha: 0.1),
                  Default_Theme.themeColor.withValues(alpha: 0),
                ]))))
          ],
        ),
      ),
    );
  }
}
