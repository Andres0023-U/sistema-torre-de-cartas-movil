import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entity.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository.dart';

class GetTournamentRankingUseCase {
  final RankingRepository repository;

  GetTournamentRankingUseCase({required this.repository});

  Future<TournamentRankingEntity> call(int tournamentId) async {
    return await repository.getTournamentRanking(tournamentId);
  }
}

