import 'package:Bloomee/repository/Youtube/yt_charts_home.dart';
import 'package:bloc/bloc.dart';

part 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit() : super(ExploreInitial()) {
    getTrendingVideos();
  }

  void getTrendingVideos() async {
    final ytCharts = await fetchTrendingVideos();

    emit(state.copyWith(ytCharts: ytCharts));
  }
}
