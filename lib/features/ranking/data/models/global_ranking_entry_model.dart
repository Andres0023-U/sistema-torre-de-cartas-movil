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
  });

  factory GlobalRankingEntryModel.fromJson(Map<String, dynamic> json) {
    return GlobalRankingEntryModel(
      position: json['position'] as int? ?? 0,
      playerId: json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
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
    };
  }
}
