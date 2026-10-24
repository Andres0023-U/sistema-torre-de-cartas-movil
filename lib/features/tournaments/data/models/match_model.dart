import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.matchId,
    required super.roundId,
    required super.deck1Id,
    required super.deck2Id,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'] as int? ?? json['id'] as int? ?? 0,
      roundId: json['roundId'] as int? ?? 0,
      deck1Id: json['deck1Id'] as int? ?? 0,
      deck2Id: json['deck2Id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'roundId': roundId,
      'deck1Id': deck1Id,
      'deck2Id': deck2Id,
    };
  }
}
