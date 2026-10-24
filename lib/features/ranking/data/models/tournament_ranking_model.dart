import '../../domain/entities/tournament_ranking_entity.dart';
import 'tournament_ranking_entry_model.dart';

class TournamentRankingModel extends TournamentRankingEntity {
  const TournamentRankingModel({
    required super.tournamentId,
    required super.isFinal,
    required super.ranking,
  });

  factory TournamentRankingModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['ranking'] as List<dynamic>? ?? [];
    return TournamentRankingModel(
      tournamentId: json['tournamentId'] as int? ?? 0,
      isFinal: json['final'] as bool? ?? false,
      ranking: rawList
          .map((e) => TournamentRankingEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'final': isFinal,
      'ranking': ranking
          .map((e) => (e as TournamentRankingEntryModel).toJson())
          .toList(),
    };
  }
}
