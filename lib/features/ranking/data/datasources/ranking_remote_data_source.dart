import '../../../../core/network/dio_client.dart';
import '../models/global_ranking_entry_model.dart';

abstract class RankingRemoteDataSource {
  Future<List<GlobalRankingEntryModel>> getGlobalRanking();
}

class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  final DioClient dioClient;

  RankingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<GlobalRankingEntryModel>> getGlobalRanking() async {
    final response = await dioClient.dio.get('/ranking/');
    final data = response.data as Map<String, dynamic>;
    final rawList = data['ranking'] as List<dynamic>? ?? [];
    return rawList
        .map((e) => GlobalRankingEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
