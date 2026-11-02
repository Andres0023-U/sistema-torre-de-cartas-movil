import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';

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

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory GlobalRankingEntryModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['last_result_date'] ?? json['lastResultDate'];
    final rawName = json['name'] ??
        json['player_name'] ??
        json['playerName'] ??
        json['user_name'] ??
        json['username'] ??
        '';
    return GlobalRankingEntryModel(
      position: _toInt(json['position'] ?? json['rank']),
      playerId: _toInt(
        json['player_id'] ?? json['playerId'] ?? json['id'] ?? json['user_id'],
      ),
      name: rawName.toString(),
      played: _toInt(
        json['played'] ?? json['matches_played'] ?? json['games_played'],
      ),
      won: _toInt(json['won'] ?? json['matches_won'] ?? json['wins']),
      lost: _toInt(json['lost'] ?? json['matches_lost'] ?? json['losses']),
      points: _toInt(json['points'] ?? json['total_points'] ?? json['score']),
      lastResultDate:
          rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
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
