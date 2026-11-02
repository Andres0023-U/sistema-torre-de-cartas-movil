import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository.dart';

class GetMyRankingUseCase {
  final RankingRepository repository;

  GetMyRankingUseCase({required this.repository});

  Future<GlobalRankingEntryEntity?> call() async {
    return await repository.getMyRanking();
  }
}

