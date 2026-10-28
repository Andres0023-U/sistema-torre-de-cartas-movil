import '../entities/global_ranking_entry_entity.dart';
import '../repositories/ranking_repository.dart';

class GetRankingUseCase {
  final RankingRepository repository;

  GetRankingUseCase({required this.repository});

  Future<List<GlobalRankingEntryEntity>> call() async {
    return await repository.getGlobalRanking();
  }
}
