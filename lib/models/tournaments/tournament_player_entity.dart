import 'package:equatable/equatable.dart';

class TournamentPlayerEntity extends Equatable {
  final int playerId;
  final String name;

  const TournamentPlayerEntity({
    required this.playerId,
    required this.name,
  });

  @override
  List<Object?> get props => [playerId, name];
}
