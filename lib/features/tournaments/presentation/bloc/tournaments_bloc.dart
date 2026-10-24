import 'package:flutter_bloc/flutter_bloc.dart';
import 'tournaments_event.dart';
import 'tournaments_state.dart';

class TournamentsBloc extends Bloc<TournamentsEvent, TournamentsState> {
  TournamentsBloc() : super(TournamentsInitialState()) {
    on<LoadTournamentsEvent>((event, emit) {
      // TODO: Implementar carga de torneos
    });
  }
}
