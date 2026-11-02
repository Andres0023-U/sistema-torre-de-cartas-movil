import 'package:equatable/equatable.dart';

class TournamentRankingEntryEntity extends Equatable {
  final int position;
  final int playerId;
  final String name;
  final int played;
  final int won;
  final int lost;
  final int points;
  final int life;
  final int? eliminatedRound;

  const TournamentRankingEntryEntity({
    required this.position,
    required this.playerId,
    required this.name,
    required this.played,
    required this.won,
    required this.lost,
    required this.points,
    required this.life,
    this.eliminatedRound,
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
        life,
        eliminatedRound,
      ];
}
