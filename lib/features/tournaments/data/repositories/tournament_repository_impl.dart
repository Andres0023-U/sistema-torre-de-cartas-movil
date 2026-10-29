import 'package:dio/dio.dart';
import '../../domain/entities/player_with_user_entity.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/start_tournament_response_entity.dart';
import '../../domain/entities/tournament_create_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_remote_data_source.dart';
import '../models/tournament_create_model.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource remoteDataSource;

  TournamentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TournamentEntity>> getTournaments() async {
    try {
      return await remoteDataSource.getTournaments();
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<List<TournamentPlayerEntity>> getTournamentPlayers(
    int tournamentId,
  ) async {
    try {
      return await remoteDataSource.getTournamentPlayers(tournamentId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<List<RoundEntity>> getTournamentRounds(int tournamentId) async {
    try {
      return await remoteDataSource.getTournamentRounds(tournamentId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<StartTournamentResponseEntity> startTournament(
    int tournamentId,
  ) async {
    try {
      return await remoteDataSource.startTournament(tournamentId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<TournamentEntity> createTournament(TournamentCreateEntity data) async {
    try {
      return await remoteDataSource
          .createTournament(TournamentCreateModel.fromEntity(data));
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<List<PlayerWithUserEntity>> getAvailablePlayers() async {
    try {
      return await remoteDataSource.getAvailablePlayers();
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<RegistrationEntity> registerPlayer(
    int tournamentId,
    int playerId,
  ) async {
    try {
      return await remoteDataSource.registerPlayer(tournamentId, playerId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  String _translateError(Object error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response?.data as Map;
        final detail = data['detail'];
        if (detail is String) {
          return detail;
        }
        if (detail != null) {
          // Por ejemplo, en un 422 "detail" llega como lista.
          return 'Revisa los datos del torneo.';
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'El servidor tardó en responder. Intenta de nuevo.';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return 'No se pudo conectar con el servidor. Revisa tu internet e intenta de nuevo.';
      }
    }
    return 'Ocurrió un error inesperado.';
  }
}
