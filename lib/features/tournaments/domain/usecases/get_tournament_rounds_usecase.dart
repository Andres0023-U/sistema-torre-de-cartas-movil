import '../entities/round_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentRoundsUseCase {
  final TournamentRepository repository;

  GetTournamentRoundsUseCase({required this.repository});

  Future<List<RoundEntity>> call(int tournamentId) async {
    return await repository.getTournamentRounds(tournamentId);
  }
}

