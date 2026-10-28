import '../../domain/entities/global_ranking_entry_entity.dart';

class GlobalRankingEntryModel extends GlobalRankingEntryEntity {
  const GlobalRankingEntryModel({
    required super.position,
    required super.playerId,
    required super.name,
    required super.played,
    required super.won,
    required super.lost,
    required super.points,
    super.lastResultDate,
  });

  factory GlobalRankingEntryModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['last_result_date'] ?? json['lastResultDate'];
    return GlobalRankingEntryModel(
      position: json['position'] as int? ?? 0,
      playerId: json['player_id'] as int? ?? json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      lastResultDate: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'player_id': playerId,
      'name': name,
      'played': played,
      'won': won,
      'lost': lost,
      'points': points,
      if (lastResultDate != null)
        'last_result_date': lastResultDate?.toIso8601String(),
    };
  }
}
