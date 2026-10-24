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
      playerId: json['playerId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}
