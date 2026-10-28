import 'package:dio/dio.dart';
import '../../domain/entities/global_ranking_entry_entity.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../datasources/ranking_remote_data_source.dart';

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

  String _translateError(Object error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response?.data as Map<String, dynamic>;
        if (data['detail'] != null) {
          return data['detail'].toString();
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return "El servidor tardó en responder. Intenta de nuevo.";
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return "No se pudo conectar con el servidor. Revisa tu internet e intenta de nuevo.";
      }
    }
    return "Ocurrió un error inesperado.";
  }
}
