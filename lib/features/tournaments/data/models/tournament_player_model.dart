import '../../domain/entities/tournament_player_entity.dart';

class TournamentPlayerModel extends TournamentPlayerEntity {
  const TournamentPlayerModel({
    required super.playerId,
    required super.name,
  });

  factory TournamentPlayerModel.fromJson(Map<String, dynamic> json) {
    return TournamentPlayerModel(
      playerId: json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'name': name,
    };
  }
}
