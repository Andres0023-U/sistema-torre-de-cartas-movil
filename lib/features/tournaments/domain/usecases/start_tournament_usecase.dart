import 'package:torre_de_cartas_movil/models/tournaments/start_tournament_response_entity.dart';
import 'package:torre_de_cartas_movil/features/tournaments/domain/repositories/tournament_repository.dart';

class StartTournamentUseCase {
  final TournamentRepository repository;

  StartTournamentUseCase({required this.repository});

  Future<StartTournamentResponseEntity> call(int tournamentId) async {
    return await repository.startTournament(tournamentId);
  }
}

