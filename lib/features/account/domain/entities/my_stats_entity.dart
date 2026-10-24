import 'package:equatable/equatable.dart';

class MyStatsEntity extends Equatable {
  final int? position;
  final int playerId;
  final String? name;
  final int played;
  final int won;
  final int lost;
  final int points;
  final int tournamentsWon;

  const MyStatsEntity({
    this.position,
    required this.playerId,
    this.name,
    required this.played,
    required this.won,
    required this.lost,
    required this.points,
    required this.tournamentsWon,
  });

  @override
  List<Object?> get props => [
        position,
        playerId,
        name,
        played,
        won,
        lost,
        points,
        tournamentsWon,
      ];
}
