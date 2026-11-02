import 'package:equatable/equatable.dart';

class DeckEntity extends Equatable {
  final int deckId;
  final int playerId;
  final String name;

  const DeckEntity({
    required this.deckId,
    required this.playerId,
    required this.name,
  });

  @override
  List<Object?> get props => [deckId, playerId, name];
}
