import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';

class MyStatsModel extends MyStatsEntity {
  const MyStatsModel({
    super.position,
    required super.playerId,
    super.name,
    required super.played,
    required super.won,
    required super.lost,
    required super.points,
    required super.tournamentsWon,
  });

  factory MyStatsModel.fromJson(Map<String, dynamic> json) {
    return MyStatsModel(
      position: (json['position'] as num?)?.toInt(),
      playerId: (json['playerId'] as num?)?.toInt() ??
          (json['player_id'] as num?)?.toInt() ??
          0,
      name: json['name'] as String?,
      played: (json['played'] as num?)?.toInt() ?? 0,
      won: (json['won'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      tournamentsWon: (json['tournamentsWon'] as num?)?.toInt() ??
          (json['tournaments_won'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (position != null) 'position': position,
      'player_id': playerId,
      if (name != null) 'name': name,
      'played': played,
      'won': won,
      'lost': lost,
      'points': points,
      'tournaments_won': tournamentsWon,
    };
  }
}
