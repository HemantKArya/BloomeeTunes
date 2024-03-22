// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/explore/cubit/explore_cubits.dart';
import 'package:Bloomee/model/chart_model.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChartScreen extends StatefulWidget {
  ChartCubit? chartCubit;
  ChartScreen({Key? key, this.chartCubit}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChartCubit, ChartState>(
        bloc: widget.chartCubit,
        builder: (context, state) {
          if (state is ChartInitial) {
            return const Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  )),
            );
          } else if (state.chart.chartItems!.isEmpty) {
            return Center(
              child: Text("Error: No Item in Chart",
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 235, 251)))),
            );
          } else {
            final ChartModel chart = state.chart;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                customDiscoverBar(context, state), //AppBar
                SliverList(
                    delegate: SliverChildListDelegate([
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chart.chartItems!.length,
                    itemBuilder: (context, index) {
                      return ChartListTile(
                        title: chart.chartItems![index].name!,
                        subtitle: chart.chartItems![index].subtitle!,
                        imgUrl: chart.chartItems![index].imageUrl!,
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

  SliverAppBar customDiscoverBar(BuildContext context, ChartState state) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding:
            const EdgeInsets.only(left: 8, bottom: 0, right: 0, top: 0),
        title: Text(state.chart.chartName,
            textScaleFactor: 1,
            textAlign: TextAlign.start,
            style: Default_Theme.secondoryTextStyleMedium.merge(const TextStyle(
                fontSize: 24, color: Color.fromARGB(255, 255, 235, 251)))),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(state.coverImg), fit: BoxFit.cover),
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
