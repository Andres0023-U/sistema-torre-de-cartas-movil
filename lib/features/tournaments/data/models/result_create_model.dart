import '../../domain/entities/result_create_entity.dart';

class ResultCreateModel extends ResultCreateEntity {
  const ResultCreateModel({
    required super.winnerId,
    required super.endPhase,
    required super.player1FinalLife,
    required super.player2FinalLife,
  });

  factory ResultCreateModel.fromJson(Map<String, dynamic> json) {
    return ResultCreateModel(
      winnerId: json['winnerId'] as int? ?? 0,
      endPhase: json['endPhase'] as String? ?? '',
      player1FinalLife: json['player1FinalLife'] as int? ?? 0,
      player2FinalLife: json['player2FinalLife'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winnerId': winnerId,
      'endPhase': endPhase,
      'player1FinalLife': player1FinalLife,
      'player2FinalLife': player2FinalLife,
    };
  }
}
