import 'package:torre_de_cartas_movil/models/tournaments/round_entity.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';

class GetTournamentRoundsUseCase {
  final TournamentRepository repository;

  GetTournamentRoundsUseCase({required this.repository});

  Future<List<RoundEntity>> call(int tournamentId) async {
    return await repository.getTournamentRounds(tournamentId);
  }
}

