import 'package:Bloomee/plugins/billboard_charts.dart';
import 'package:Bloomee/plugins/chart_defines.dart';
import 'package:Bloomee/plugins/last_dot_fm_charts.dart';
import 'package:Bloomee/plugins/melon_charts.dart';

final List<ChartInfo> chartInfoList = [
  ChartInfo(
    chartFunction: getLastFmCharts,
    imgUrl: lastfmRandomIMGs.getImage(),
    title: LastFMCharts.TOP_TRACKS.title,
    url: LastFMCharts.TOP_TRACKS.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_DAILY.title,
    url: MelonCharts.DOMESTIC_DAILY.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_WEEKLY.title,
    url: MelonCharts.DOMESTIC_WEEKLY.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_MONTHLY.title,
    url: MelonCharts.DOMESTIC_MONTHLY.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.GENREOMICS_DAILY.title,
    url: MelonCharts.GENREOMICS_DAILY.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.GENREOMICS_WEEKLY.title,
    url: MelonCharts.GENREOMICS_WEEKLY.url,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.GENREOMICS_MONTHLY.title,
    url: MelonCharts.GENREOMICS_MONTHLY.url,
  ),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.HOT_100.title,
      url: BillboardCharts.HOT_100.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.BILLBOARD_200.title,
      url: BillboardCharts.BILLBOARD_200.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.BILLBOARD_GLOBAL_200.title,
      url: BillboardCharts.BILLBOARD_GLOBAL_200.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.KOREA_100.title,
      url: BillboardCharts.KOREA_100.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.INDIA_SONGS.title,
      url: BillboardCharts.INDIA_SONGS.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.JAPAN_HOT_100.title,
      url: BillboardCharts.JAPAN_HOT_100.url),
  ChartInfo(
      chartFunction: getBillboardChart,
      imgUrl: billboardRandomIMGs.getImage(),
      title: BillboardCharts.TIK_TOK_BILLBOARD_TOP_50.title,
      url: BillboardCharts.TIK_TOK_BILLBOARD_TOP_50.url),
];
