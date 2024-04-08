// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'offline_cubit.dart';

class OfflineState extends Equatable {
  final List<MediaItemModel> songs;
  const OfflineState({required this.songs});
  @override
  List<Object> get props => [songs];

  OfflineState copyWith({
    List<MediaItemModel>? songs,
  }) {
    return OfflineState(
      songs: songs ?? this.songs,
    );
  }
}

class OfflineInitial extends OfflineState {
  OfflineInitial() : super(songs: []);
}

class OfflineEmpty extends OfflineState {
  OfflineEmpty() : super(songs: List.empty());
}
