import 'package:torre_de_cartas_movil/models/tournaments/player_with_user_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/registration_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/round_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/start_tournament_response_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_create_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_player_entity.dart';

abstract class TournamentRepository {
  Future<List<TournamentEntity>> getTournaments();
  Future<List<TournamentPlayerEntity>> getTournamentPlayers(int tournamentId);
  Future<List<RoundEntity>> getTournamentRounds(int tournamentId);
  Future<StartTournamentResponseEntity> startTournament(int tournamentId);
  Future<TournamentEntity> createTournament(TournamentCreateEntity data);
  Future<List<PlayerWithUserEntity>> getAvailablePlayers();
  Future<RegistrationEntity> registerPlayer(int tournamentId, int playerId);
}
