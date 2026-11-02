import 'package:equatable/equatable.dart';

class ResultCreateEntity extends Equatable {
  final int winnerId;
  final String endPhase;
  final int player1FinalLife;
  final int player2FinalLife;

  const ResultCreateEntity({
    required this.winnerId,
    required this.endPhase,
    required this.player1FinalLife,
    required this.player2FinalLife,
  });

  @override
  List<Object?> get props => [
        winnerId,
        endPhase,
        player1FinalLife,
        player2FinalLife,
      ];
}
