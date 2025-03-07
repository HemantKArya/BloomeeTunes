import 'package:Bloomee/plugins/ext_charts/billboard_charts.dart';
import 'package:Bloomee/plugins/ext_charts/last_dot_fm_charts.dart';
import 'package:Bloomee/plugins/ext_charts/melon_charts.dart';
import 'package:Bloomee/plugins/ext_charts/spotify_top50_chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Billboard Charts HOT100", () async {
    final bb = await getBillboardChart(BillboardCharts.HOT_100);
    expect(bb.chartItems != null, true);
    expect(bb.chartItems!.isNotEmpty, true);
  });

  test("Billboard Charts Billboard200", () async {
    final bb = await getBillboardChart(BillboardCharts.BILLBOARD_200);
    expect(bb.chartItems != null, true);
    expect(bb.chartItems!.isNotEmpty, true);
  });

  test("Billboard Charts Billboard 200", () async {
    final bb = await getBillboardChart(BillboardCharts.BILLBOARD_200);
    expect(bb.chartItems != null, true);
    expect(bb.chartItems!.isNotEmpty, true);
  });

  test("Last.FM Charts", () async {
    final lastFM = await getLastFmCharts(LastFMCharts.TOP_TRACKS);
    expect(lastFM.chartItems != null, true);
    expect(lastFM.chartItems!.isNotEmpty, true);
  });

  test("Melon Charts", () async {
    final melon = await getMelonChart(MelonCharts.TOP_100);
    expect(melon.chartItems != null, true);
    expect(melon.chartItems!.isNotEmpty, true);
  });

  test("Melon Charts DMonthly", () async {
    final melon = await getMelonChart(MelonCharts.DOMESTIC_MONTHLY);
    expect(melon.chartItems != null, true);
    expect(melon.chartItems!.isNotEmpty, true);
  });

  test("Spotify Charts", () async {
    final spotify = await getSpotifyTop50Chart(SpotifyCharts.TOP_50);
    expect(spotify.chartItems != null, true);
    expect(spotify.chartItems!.isNotEmpty, true);
  });
}
