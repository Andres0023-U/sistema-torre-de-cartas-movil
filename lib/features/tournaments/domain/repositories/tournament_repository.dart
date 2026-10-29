import '../entities/player_with_user_entity.dart';
import '../entities/registration_entity.dart';
import '../entities/round_entity.dart';
import '../entities/start_tournament_response_entity.dart';
import '../entities/tournament_create_entity.dart';
import '../entities/tournament_entity.dart';
import '../entities/tournament_player_entity.dart';

abstract class TournamentRepository {
  Future<List<TournamentEntity>> getTournaments();
  Future<List<TournamentPlayerEntity>> getTournamentPlayers(int tournamentId);
  Future<List<RoundEntity>> getTournamentRounds(int tournamentId);
  Future<StartTournamentResponseEntity> startTournament(int tournamentId);
  Future<TournamentEntity> createTournament(TournamentCreateEntity data);
  Future<List<PlayerWithUserEntity>> getAvailablePlayers();
  Future<RegistrationEntity> registerPlayer(int tournamentId, int playerId);
}
