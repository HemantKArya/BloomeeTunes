// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_bloc.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_event.dart';
import 'package:Bloomee/plugins/blocs/chart/chart_state.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/screens/widgets/chart_list_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:icons_plus/icons_plus.dart';

/// Displays the details (items) of a specific chart.
///
/// Takes [pluginId] and [chartId] from the route, creates its own
/// [ChartBloc], and dispatches [LoadChartDetails].
class ChartScreen extends StatelessWidget {
  final String pluginId;
  final String chartId;
  final String chartTitle;

  const ChartScreen({
    super.key,
    required this.pluginId,
    required this.chartId,
    required this.chartTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartBloc(pluginService: ServiceLocator.pluginService)
        ..add(LoadChartDetails(pluginId: pluginId, chartId: chartId)),
      child: _ChartScreenBody(chartTitle: chartTitle),
    );
  }
}

class _ChartScreenBody extends StatelessWidget {
  final String chartTitle;

  const _ChartScreenBody({required this.chartTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: BlocBuilder<ChartBloc, ChartState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, state),
                if (state.chartDetailStatus == ChartStatus.loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2,
                        ),
                      ),
                    ),
                  )
                else if (state.chartDetailStatus == ChartStatus.error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: SignBoardWidget(
                        message: state.error ?? 'Failed to load chart',
                        icon: MingCute.warning_line,
                      ),
                    ),
                  )
                else if (state.chartItems.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "No items in chart",
                        style: Default_Theme.secondoryTextStyleMedium.merge(
                          const TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 255, 235, 251),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 5),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.chartItems.length,
                        itemBuilder: (context, index) {
                          final chartItem = state.chartItems[index];
                          final (title, subtitle, imgUrl) =
                              _extractItemInfo(chartItem);
                          return ChartListTile(
                            title: title,
                            subtitle: subtitle,
                            imgUrl: imgUrl,
                          );
                        },
                      ),
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, ChartState state) {
    String? coverUrl;
    if (state.chartItems.isNotEmpty) {
      final (_, _, url) = _extractItemInfo(state.chartItems.first);
      coverUrl = url;
    }

    return SliverAppBar(
      floating: true,
      pinned: state.chartDetailStatus != ChartStatus.loaded,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      expandedHeight: coverUrl != null && coverUrl.isNotEmpty ? 200 : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 8, bottom: 0),
        title: Text(
          chartTitle,
          textScaler: const TextScaler.linear(1.0),
          textAlign: TextAlign.start,
          style: Default_Theme.secondoryTextStyleMedium.merge(
            const TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 255, 235, 251),
            ),
          ),
        ),
        background: coverUrl != null && coverUrl.isNotEmpty
            ? Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: LoadImageCached(
                        imageUrl: formatImgURL(coverUrl!, ImageQuality.high),
                        fallbackUrl: coverUrl,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  /// Extracts (title, subtitle, imageUrl) from a [ChartItem].
  static (String, String, String) _extractItemInfo(ChartItem chartItem) {
    return chartItem.item.when(
      track: (track) => (
        track.title,
        track.artists.map((a) => a.name).join(', '),
        track.thumbnail.url,
      ),
      album: (album) => (
        album.title,
        album.artists.map((a) => a.name).join(', '),
        album.thumbnail?.url ?? '',
      ),
      artist: (artist) => (
        artist.name,
        artist.subtitle ?? '',
        artist.thumbnail?.url ?? '',
      ),
      playlist: (playlist) => (
        playlist.title,
        playlist.owner ?? '',
        playlist.thumbnail.url,
      ),
    );
  }
}
