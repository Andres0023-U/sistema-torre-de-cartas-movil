import 'package:equatable/equatable.dart';

abstract class DeckDetailEvent extends Equatable {
  const DeckDetailEvent();

  @override
  List<Object?> get props => [];
}

class DeckDetailRequested extends DeckDetailEvent {
  final int deckId;

  const DeckDetailRequested(this.deckId);

  @override
  List<Object?> get props => [deckId];
}

class DeckAddCardRequested extends DeckDetailEvent {
  final int cardId;
  final int quantity;

  const DeckAddCardRequested({
    required this.cardId,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [cardId, quantity];
}

class DeckUpdateCardQuantityRequested extends DeckDetailEvent {
  final int cardId;
  final int quantity;

  const DeckUpdateCardQuantityRequested({
    required this.cardId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cardId, quantity];
}

class DeckRemoveCardRequested extends DeckDetailEvent {
  final int cardId;

  const DeckRemoveCardRequested(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

