import '../entities/global_ranking_entry_entity.dart';

abstract class RankingRepository {
  Future<List<GlobalRankingEntryEntity>> getGlobalRanking();
}
