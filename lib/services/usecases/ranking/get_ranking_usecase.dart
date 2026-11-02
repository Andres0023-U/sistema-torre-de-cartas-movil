import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository repository;

  GetRankingUseCase({required this.repository});

  Future<List<GlobalRankingEntryEntity>> call() async {
    return await repository.getGlobalRanking();
  }
}
