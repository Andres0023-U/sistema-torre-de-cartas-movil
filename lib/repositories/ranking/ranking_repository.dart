import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entity.dart';

abstract class RankingRepository {
  Future<List<GlobalRankingEntryEntity>> getGlobalRanking();
  Future<GlobalRankingEntryEntity?> getMyRanking();
  Future<TournamentRankingEntity> getTournamentRanking(int tournamentId);
}
