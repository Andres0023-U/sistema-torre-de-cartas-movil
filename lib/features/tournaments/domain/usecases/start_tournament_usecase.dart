import '../entities/start_tournament_response_entity.dart';
import '../repositories/tournament_repository.dart';

class StartTournamentUseCase {
  final TournamentRepository repository;

  StartTournamentUseCase({required this.repository});

  Future<StartTournamentResponseEntity> call(int tournamentId) async {
    return await repository.startTournament(tournamentId);
  }
}

