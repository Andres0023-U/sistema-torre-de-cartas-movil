import 'package:equatable/equatable.dart';

class MatchEntity extends Equatable {
  final int matchId;
  final int roundId;
  final int deck1Id;
  final int deck2Id;

  const MatchEntity({
    required this.matchId,
    required this.roundId,
    required this.deck1Id,
    required this.deck2Id,
  });

  @override
  List<Object?> get props => [matchId, roundId, deck1Id, deck2Id];
}
