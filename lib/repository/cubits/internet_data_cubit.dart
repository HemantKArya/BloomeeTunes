import 'package:bloc/bloc.dart';

class InternetDataState {}

final class InternetDataInitial extends InternetDataState {}

class InternetDataCubit extends Cubit<InternetDataState> {
  InternetDataCubit() : super(InternetDataInitial());
}
