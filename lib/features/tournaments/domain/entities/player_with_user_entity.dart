import 'package:equatable/equatable.dart';

class PlayerWithUserEntity extends Equatable {
  final int playerId;
  final int userId;
  final String name;
  final String email;

  const PlayerWithUserEntity({
    required this.playerId,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [playerId, userId, name, email];
}

