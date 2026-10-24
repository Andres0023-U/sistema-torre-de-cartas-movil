import '../../domain/entities/tournament_ranking_entry_entity.dart';

class TournamentRankingEntryModel extends TournamentRankingEntryEntity {
  const TournamentRankingEntryModel({
    required super.position,
    required super.playerId,
    required super.name,
    required super.played,
    required super.won,
    required super.lost,
    required super.points,
    required super.life,
    super.eliminatedRound,
  });

  factory TournamentRankingEntryModel.fromJson(Map<String, dynamic> json) {
    return TournamentRankingEntryModel(
      position: json['position'] as int? ?? 0,
      playerId: json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      life: json['life'] as int? ?? 0,
      eliminatedRound: json['eliminatedRound'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'playerId': playerId,
      'name': name,
      'played': played,
      'won': won,
      'lost': lost,
      'points': points,
      'life': life,
      if (eliminatedRound != null) 'eliminatedRound': eliminatedRound,
    };
  }
}
