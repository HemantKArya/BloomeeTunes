import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<bool> {
  MiniPlayerCubit() : super(false);
}
