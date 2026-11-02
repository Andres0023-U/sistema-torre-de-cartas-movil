import 'package:dio/dio.dart';
import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entity.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository.dart';
import 'package:torre_de_cartas_movil/services/api/ranking_remote_data_source.dart';

class RankingForbiddenException implements Exception {
  final String message;

  const RankingForbiddenException(this.message);

  @override
  String toString() => message;
}

class RankingRepositoryImpl implements RankingRepository {
  final RankingRemoteDataSource remoteDataSource;

  RankingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GlobalRankingEntryEntity>> getGlobalRanking() async {
    try {
      return await remoteDataSource.getGlobalRanking();
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<GlobalRankingEntryEntity?> getMyRanking() async {
    try {
      return await remoteDataSource.getMyRanking();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TournamentRankingEntity> getTournamentRanking(int tournamentId) async {
    try {
      return await remoteDataSource.getTournamentRanking(tournamentId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const RankingForbiddenException(
          'No tienes permisos para consultar el ranking de este torneo. '
          'Como jugador, solo puedes ver torneos en los que estás inscrito.',
        );
      }
      throw Exception(_translateError(e));
    } catch (e) {
      if (e is RankingForbiddenException) rethrow;
      throw Exception(_translateError(e));
    }
  }

  String _translateError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 403) {
        return 'No tienes permisos para realizar esta consulta.';
      }
      if (error.response?.data is Map) {
        final data = Map<String, dynamic>.from(error.response!.data as Map);
        if (data['detail'] != null) {
          return data['detail'].toString();
        }
      }
      if (statusCode != null && statusCode >= 500) {
        return 'El servidor tardó demasiado o presentó un problema temporal ($statusCode). Intenta de nuevo.';
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
