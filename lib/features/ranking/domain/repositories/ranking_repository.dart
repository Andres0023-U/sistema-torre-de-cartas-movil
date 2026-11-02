import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';

abstract class RankingRepository {
  Future<List<GlobalRankingEntryEntity>> getGlobalRanking();
}
