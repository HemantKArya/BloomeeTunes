// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/constants/sentinel_values.dart';

part 'add_to_playlist_state.dart';

class AddToPlaylistCubit extends Cubit<AddToPlaylistState> {
  AddToPlaylistCubit() : super(AddToPlaylistInitial());

  void setTrack(Track track) {
    emit(state.copyWith(track: track));
  }
}
