import 'package:dio/dio.dart';
import 'package:torre_de_cartas_movil/services/core/dio_client.dart';
import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_model.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_model.dart';

abstract class RankingRemoteDataSource {
  Future<List<GlobalRankingEntryModel>> getGlobalRanking();
  Future<GlobalRankingEntryModel?> getMyRanking();
  Future<TournamentRankingModel> getTournamentRanking(int tournamentId);
}

class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  final DioClient dioClient;

  RankingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<GlobalRankingEntryModel>> getGlobalRanking() async {
    final response = await dioClient.dio.get(
      '/ranking/',
      options: Options(
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
    final raw = response.data;
    List<dynamic> rawList = const [];
    if (raw is List) {
      rawList = raw;
    } else if (raw is Map) {
      final candidate = raw['ranking'] ??
          raw['results'] ??
          raw['items'] ??
          raw['data'] ??
          raw['players'];
      if (candidate is List) {
        rawList = candidate;
      }
    }

    final entries = <GlobalRankingEntryModel>[];
    for (var i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        if (map['position'] == null || map['position'] == 0) {
          map['position'] = i + 1;
        }
        entries.add(GlobalRankingEntryModel.fromJson(map));
      }
    }
    return entries;
  }

  @override
  Future<GlobalRankingEntryModel?> getMyRanking() async {
    try {
      final response = await dioClient.dio.get(
        '/ranking/me',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      final raw = response.data;
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        if (map['ranking'] is Map) {
          return GlobalRankingEntryModel.fromJson(
            Map<String, dynamic>.from(map['ranking'] as Map),
          );
        }
        if (map['stats'] is Map) {
          return GlobalRankingEntryModel.fromJson(
            Map<String, dynamic>.from(map['stats'] as Map),
          );
        }
        return GlobalRankingEntryModel.fromJson(map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<TournamentRankingModel> getTournamentRanking(int tournamentId) async {
    final response =
        await dioClient.dio.get('/tournaments/$tournamentId/ranking');
    final raw = response.data;
    if (raw is Map) {
      return TournamentRankingModel.fromJson(Map<String, dynamic>.from(raw));
    }
    if (raw is List) {
      return TournamentRankingModel.fromJson({
        'tournament_id': tournamentId,
        'final': false,
        'ranking': raw,
      });
    }
    return TournamentRankingModel(
      tournamentId: tournamentId,
      isFinal: false,
      ranking: const [],
    );
  }
}
