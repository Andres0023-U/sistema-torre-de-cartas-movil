import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import '../../domain/usecases/get_tournament_players_usecase.dart';
import '../../domain/usecases/get_tournament_rounds_usecase.dart';
import '../../domain/usecases/get_tournaments_usecase.dart';
import 'tournament_detail_event.dart';
import 'tournament_detail_state.dart';

class TournamentDetailBloc
    extends Bloc<TournamentDetailEvent, TournamentDetailState> {
  final GetTournamentsUseCase getTournamentsUseCase;
  final GetTournamentPlayersUseCase getTournamentPlayersUseCase;
  final GetTournamentRoundsUseCase getTournamentRoundsUseCase;

  TournamentDetailBloc({
    required this.getTournamentsUseCase,
    required this.getTournamentPlayersUseCase,
    required this.getTournamentRoundsUseCase,
  }) : super(const TournamentDetailInitial()) {
    on<TournamentDetailRequested>((event, emit) async {
      emit(const TournamentDetailLoading());
      try {
        final tournaments = await getTournamentsUseCase();
        TournamentEntity? tournament;
        for (final t in tournaments) {
          if (t.tournamentId == event.tournamentId) {
            tournament = t;
            break;
          }
        }
        if (tournament == null) {
          emit(const TournamentDetailFailure('No se encontró el torneo'));
          return;
        }

        final results = await Future.wait([
          getTournamentPlayersUseCase(event.tournamentId),
          getTournamentRoundsUseCase(event.tournamentId),
        ]);

        emit(TournamentDetailLoaded(
          tournament: tournament,
          players: results[0] as List<TournamentPlayerEntity>,
          rounds: results[1] as List<RoundEntity>,
        ));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(TournamentDetailFailure(message));
      }
    });
  }
}
