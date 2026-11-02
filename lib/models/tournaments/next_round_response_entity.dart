import 'package:equatable/equatable.dart';

class NextRoundResponseEntity extends Equatable {
  final String status;
  final int? roundId;
  final int? championDeckId;
  final int? championPlayerId;

  const NextRoundResponseEntity({
    required this.status,
    this.roundId,
    this.championDeckId,
    this.championPlayerId,
  });

  @override
  List<Object?> get props => [
        status,
        roundId,
        championDeckId,
        championPlayerId,
      ];
}
