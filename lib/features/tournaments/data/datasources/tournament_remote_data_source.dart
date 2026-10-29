import '../../../../core/network/dio_client.dart';
import '../models/player_with_user_model.dart';
import '../models/registration_model.dart';
import '../models/round_model.dart';
import '../models/start_tournament_response_model.dart';
import '../models/tournament_create_model.dart';
import '../models/tournament_model.dart';
import '../models/tournament_player_model.dart';

abstract class TournamentRemoteDataSource {
  Future<List<TournamentModel>> getTournaments();
  Future<List<TournamentPlayerModel>> getTournamentPlayers(int tournamentId);
  Future<List<RoundModel>> getTournamentRounds(int tournamentId);
  Future<StartTournamentResponseModel> startTournament(int tournamentId);
  Future<TournamentModel> createTournament(TournamentCreateModel data);
  Future<List<PlayerWithUserModel>> getAvailablePlayers();
  Future<RegistrationModel> registerPlayer(int tournamentId, int playerId);
}

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final DioClient dioClient;

  TournamentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TournamentModel>> getTournaments() async {
    final response = await dioClient.dio.get('/tournaments/');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TournamentPlayerModel>> getTournamentPlayers(
    int tournamentId,
  ) async {
    final response =
        await dioClient.dio.get('/tournaments/$tournamentId/players');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => TournamentPlayerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RoundModel>> getTournamentRounds(int tournamentId) async {
    final response =
        await dioClient.dio.get('/tournaments/$tournamentId/rounds');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => RoundModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PlayerWithUserModel>> getAvailablePlayers() async {
    final response = await dioClient.dio.get('/players/');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => PlayerWithUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RegistrationModel> registerPlayer(
    int tournamentId,
    int playerId,
  ) async {
    final response = await dioClient.dio.post(
      '/tournaments/$tournamentId/registrations',
      data: {'player_id': playerId},
    );
    return RegistrationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TournamentModel> createTournament(TournamentCreateModel data) async {
    final response = await dioClient.dio.post(
      '/tournaments/',
      data: data.toJson(),
    );
    return TournamentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<StartTournamentResponseModel> startTournament(
    int tournamentId,
  ) async {
    final response = await dioClient.dio.post(
      '/tournaments/$tournamentId/start',
      data: <String, dynamic>{},
    );
    return StartTournamentResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
