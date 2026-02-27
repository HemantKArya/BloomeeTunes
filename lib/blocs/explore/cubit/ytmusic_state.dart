part of 'ytmusic_cubit.dart';

class YTMusicCubitState extends Equatable {
  final Map<String, List<dynamic>> ytmData;
  const YTMusicCubitState({
    required this.ytmData,
  });

  YTMusicCubitState copyWith({
    Map<String, List<dynamic>>? ytmData,
  }) {
    return YTMusicCubitState(
      ytmData: ytmData ?? this.ytmData,
    );
  }

  @override
  List<Object?> get props => [ytmData, ytmData.keys, ytmData.hashCode];
}

class YTMusicCubitInitial extends YTMusicCubitState {
  YTMusicCubitInitial() : super(ytmData: {});
}
