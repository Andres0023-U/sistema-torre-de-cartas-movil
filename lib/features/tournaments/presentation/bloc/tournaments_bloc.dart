import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tournaments_usecase.dart';
import 'tournaments_event.dart';
import 'tournaments_state.dart';

class TournamentsBloc extends Bloc<TournamentsEvent, TournamentsState> {
  final GetTournamentsUseCase getTournamentsUseCase;

  TournamentsBloc({required this.getTournamentsUseCase})
      : super(const TournamentsInitial()) {
    on<TournamentsRequested>((event, emit) async {
      emit(const TournamentsLoading());
      try {
        final tournaments = await getTournamentsUseCase();
        emit(TournamentsLoaded(tournaments));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(TournamentsFailure(message));
      }
    });
  }
}
