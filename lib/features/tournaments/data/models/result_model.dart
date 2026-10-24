import '../../domain/entities/result_entity.dart';

class ResultModel extends ResultEntity {
  const ResultModel({
    required super.resultId,
    required super.matchId,
    super.winnerId,
    super.endPhase,
    super.player1FinalLife,
    super.player2FinalLife,
    super.player1Points,
    super.player2Points,
    super.date,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      resultId: json['resultId'] as int? ?? json['id'] as int? ?? 0,
      matchId: json['matchId'] as int? ?? 0,
      winnerId: json['winnerId'] as int? ?? json['winnerDeckId'] as int?,
      endPhase: json['endPhase'] as String?,
      player1FinalLife: json['player1FinalLife'] as int? ?? json['lifePlayer1'] as int?,
      player2FinalLife: json['player2FinalLife'] as int? ?? json['lifePlayer2'] as int?,
      player1Points: json['player1Points'] as int? ?? json['pointsPlayer1'] as int?,
      player2Points: json['player2Points'] as int? ?? json['pointsPlayer2'] as int?,
      date: json['date'] as String? ?? json['dateTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'matchId': matchId,
      if (winnerId != null) 'winnerId': winnerId,
      if (endPhase != null) 'endPhase': endPhase,
      if (player1FinalLife != null) 'player1FinalLife': player1FinalLife,
      if (player2FinalLife != null) 'player2FinalLife': player2FinalLife,
      if (player1Points != null) 'player1Points': player1Points,
      if (player2Points != null) 'player2Points': player2Points,
      if (date != null) 'date': date,
    };
  }
}
