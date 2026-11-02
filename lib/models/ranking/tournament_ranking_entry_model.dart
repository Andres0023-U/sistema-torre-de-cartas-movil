import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entry_entity.dart';

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

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory TournamentRankingEntryModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] ??
        json['player_name'] ??
        json['playerName'] ??
        json['username'] ??
        '';
    return TournamentRankingEntryModel(
      position: _toInt(json['position'] ?? json['rank']),
      playerId: _toInt(json['player_id'] ?? json['playerId'] ?? json['id']),
      name: rawName.toString(),
      played: _toInt(json['played']),
      won: _toInt(json['won']),
      lost: _toInt(json['lost']),
      points: _toInt(json['points']),
      life: _toInt(json['life']),
      eliminatedRound: _toNullableInt(
        json['eliminated_round'] ?? json['eliminatedRound'],
      ),
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
      'life': life,
      if (eliminatedRound != null) 'eliminated_round': eliminatedRound,
    };
  }
}
