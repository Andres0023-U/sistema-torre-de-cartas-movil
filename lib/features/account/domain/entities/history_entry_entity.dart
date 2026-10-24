import 'package:equatable/equatable.dart';

class HistoryEntryEntity extends Equatable {
  final int matchId;
  final int tournamentId;
  final String tournamentName;
  final int roundNumber;
  final String roundName;
  final int? opponentPlayerId;
  final String? opponentName;
  final bool won;
  final int points;
  final String endPhase;
  final String date;

  const HistoryEntryEntity({
    required this.matchId,
    required this.tournamentId,
    required this.tournamentName,
    required this.roundNumber,
    required this.roundName,
    this.opponentPlayerId,
    this.opponentName,
    required this.won,
    required this.points,
    required this.endPhase,
    required this.date,
  });

  @override
  List<Object?> get props => [
        matchId,
        tournamentId,
        tournamentName,
        roundNumber,
        roundName,
        opponentPlayerId,
        opponentName,
        won,
        points,
        endPhase,
        date,
      ];
}
