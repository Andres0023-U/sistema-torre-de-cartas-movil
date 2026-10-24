import 'package:equatable/equatable.dart';

class ResultEntity extends Equatable {
  final int resultId;
  final int matchId;
  final int? winnerId;
  final String? endPhase;
  final int? player1FinalLife;
  final int? player2FinalLife;
  final int? player1Points;
  final int? player2Points;
  final String? date;

  const ResultEntity({
    required this.resultId,
    required this.matchId,
    this.winnerId,
    this.endPhase,
    this.player1FinalLife,
    this.player2FinalLife,
    this.player1Points,
    this.player2Points,
    this.date,
  });

  @override
  List<Object?> get props => [
        resultId,
        matchId,
        winnerId,
        endPhase,
        player1FinalLife,
        player2FinalLife,
        player1Points,
        player2Points,
        date,
      ];
}
