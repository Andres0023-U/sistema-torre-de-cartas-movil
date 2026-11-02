import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/create_tournament_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/create_tournament_event.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/create_tournament_state.dart';

class CreateTournamentBloc
    extends Bloc<CreateTournamentEvent, CreateTournamentState> {
  final CreateTournamentUseCase createTournamentUseCase;

  CreateTournamentBloc({required this.createTournamentUseCase})
      : super(const CreateTournamentInitial()) {
    on<CreateTournamentSubmitted>((event, emit) async {
      if (state is CreateTournamentSubmitting) return;
      emit(const CreateTournamentSubmitting());
      try {
        final tournament = await createTournamentUseCase(event.data);
        emit(CreateTournamentSuccess(tournament));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(CreateTournamentFailure(message));
      }
    });
  }
}

