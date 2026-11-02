import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entity.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entry_model.dart';

class TournamentRankingModel extends TournamentRankingEntity {
  const TournamentRankingModel({
    required super.tournamentId,
    required super.isFinal,
    required super.ranking,
  });

  factory TournamentRankingModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['ranking'] as List<dynamic>? ?? const [];
    final entries = <TournamentRankingEntryModel>[];
    for (var i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        if (map['position'] == null || map['position'] == 0) {
          map['position'] = i + 1;
        }
        entries.add(TournamentRankingEntryModel.fromJson(map));
      }
    }

    final rawId = json['tournament_id'] ?? json['tournamentId'] ?? 0;
    final tournamentId = rawId is int
        ? rawId
        : (rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0);

    return TournamentRankingModel(
      tournamentId: tournamentId,
      isFinal: json['final'] as bool? ?? json['is_final'] as bool? ?? false,
      ranking: entries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'final': isFinal,
      'ranking': ranking
          .map((e) => (e as TournamentRankingEntryModel).toJson())
          .toList(),
    };
  }
}
