import '../../domain/entities/player_with_user_entity.dart';

class PlayerWithUserModel extends PlayerWithUserEntity {
  const PlayerWithUserModel({
    required super.playerId,
    required super.userId,
    required super.name,
    required super.email,
  });

  factory PlayerWithUserModel.fromJson(Map<String, dynamic> json) {
    return PlayerWithUserModel(
      playerId: json['player_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'user_id': userId,
      'name': name,
      'email': email,
    };
  }
}

