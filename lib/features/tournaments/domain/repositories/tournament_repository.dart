import '../entities/round_entity.dart';
import '../entities/tournament_entity.dart';
import '../entities/tournament_player_entity.dart';

abstract class TournamentRepository {
  Future<List<TournamentEntity>> getTournaments();
  Future<List<TournamentPlayerEntity>> getTournamentPlayers(int tournamentId);
  Future<List<RoundEntity>> getTournamentRounds(int tournamentId);
}
