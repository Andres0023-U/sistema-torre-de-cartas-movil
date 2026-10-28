import '../entities/tournament_player_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentPlayersUseCase {
  final TournamentRepository repository;

  GetTournamentPlayersUseCase({required this.repository});

  Future<List<TournamentPlayerEntity>> call(int tournamentId) async {
    return await repository.getTournamentPlayers(tournamentId);
  }
}

