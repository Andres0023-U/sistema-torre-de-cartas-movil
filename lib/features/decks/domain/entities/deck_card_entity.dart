import 'package:equatable/equatable.dart';

class DeckCardEntity extends Equatable {
  final int deckId;
  final int cardId;
  final int quantity;

  const DeckCardEntity({
    required this.deckId,
    required this.cardId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [deckId, cardId, quantity];
}
