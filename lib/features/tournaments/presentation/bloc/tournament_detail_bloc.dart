import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import '../../domain/usecases/get_tournament_players_usecase.dart';
import '../../domain/usecases/get_tournament_rounds_usecase.dart';
import '../../domain/usecases/get_tournaments_usecase.dart';
import '../../domain/usecases/start_tournament_usecase.dart';
import 'tournament_detail_event.dart';
import 'tournament_detail_state.dart';

class TournamentDetailBloc
    extends Bloc<TournamentDetailEvent, TournamentDetailState> {
  final GetTournamentsUseCase getTournamentsUseCase;
  final GetTournamentPlayersUseCase getTournamentPlayersUseCase;
  final GetTournamentRoundsUseCase getTournamentRoundsUseCase;
  final StartTournamentUseCase startTournamentUseCase;

  TournamentDetailBloc({
    required this.getTournamentsUseCase,
    required this.getTournamentPlayersUseCase,
    required this.getTournamentRoundsUseCase,
    required this.startTournamentUseCase,
  }) : super(const TournamentDetailInitial()) {
    on<TournamentDetailRequested>((event, emit) async {
      emit(const TournamentDetailLoading());
      try {
        emit(await _load(event.tournamentId));
      } catch (e) {
        emit(TournamentDetailFailure(_messageOf(e)));
      }
    });

    on<TournamentStartRequested>((event, emit) async {
      final current = state;
      if (current is! TournamentDetailLoaded || current.isStarting) return;

      final tournamentId = current.tournament.tournamentId;
      emit(TournamentDetailLoaded(
        tournament: current.tournament,
        players: current.players,
        rounds: current.rounds,
        isStarting: true,
      ));

      try {
        await startTournamentUseCase(tournamentId);
      } catch (e) {
        emit(TournamentDetailLoaded(
          tournament: current.tournament,
          players: current.players,
          rounds: current.rounds,
          errorMessage: _messageOf(e),
        ));
        return;
      }

      try {
        final fresh = await _load(tournamentId);
        emit(TournamentDetailLoaded(
          tournament: fresh.tournament,
          players: fresh.players,
          rounds: fresh.rounds,
          successMessage: 'Torneo iniciado',
        ));
      } catch (e) {
        // El torneo sí se inició, pero no se pudo recargar: se conservan
        // los datos mostrados y se avisa del error.
        emit(TournamentDetailLoaded(
          tournament: current.tournament,
          players: current.players,
          rounds: current.rounds,
          errorMessage: _messageOf(e),
        ));
      }
    });
  }

  Future<TournamentDetailLoaded> _load(int tournamentId) async {
    final tournaments = await getTournamentsUseCase();
    TournamentEntity? tournament;
    for (final t in tournaments) {
      if (t.tournamentId == tournamentId) {
        tournament = t;
        break;
      }
    }
    if (tournament == null) {
      throw Exception('No se encontró el torneo');
    }

    final results = await Future.wait([
      getTournamentPlayersUseCase(tournamentId),
      getTournamentRoundsUseCase(tournamentId),
    ]);

    return TournamentDetailLoaded(
      tournament: tournament,
      players: results[0] as List<TournamentPlayerEntity>,
      rounds: results[1] as List<RoundEntity>,
    );
  }

  String _messageOf(Object e) => e.toString().replaceAll('Exception: ', '');
}
