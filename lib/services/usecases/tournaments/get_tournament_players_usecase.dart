import 'package:torre_de_cartas_movil/models/tournaments/tournament_player_entity.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';

class GetTournamentPlayersUseCase {
  final TournamentRepository repository;

  GetTournamentPlayersUseCase({required this.repository});

  Future<List<TournamentPlayerEntity>> call(int tournamentId) async {
    return await repository.getTournamentPlayers(tournamentId);
  }
}

