import 'package:equatable/equatable.dart';

class GlobalRankingEntryEntity extends Equatable {
  final int position;
  final int playerId;
  final String name;
  final int played;
  final int won;
  final int lost;
  final int points;
  final DateTime? lastResultDate;

  const GlobalRankingEntryEntity({
    required this.position,
    required this.playerId,
    required this.name,
    required this.played,
    required this.won,
    required this.lost,
    required this.points,
    this.lastResultDate,
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
        lastResultDate,
      ];
}
