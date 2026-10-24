import '../../domain/entities/my_stats_entity.dart';

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
      position: json['position'] as int?,
      playerId: json['playerId'] as int? ?? 0,
      name: json['name'] as String?,
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      tournamentsWon: json['tournamentsWon'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (position != null) 'position': position,
      'playerId': playerId,
      if (name != null) 'name': name,
      'played': played,
      'won': won,
      'lost': lost,
      'points': points,
      'tournamentsWon': tournamentsWon,
    };
  }
}
