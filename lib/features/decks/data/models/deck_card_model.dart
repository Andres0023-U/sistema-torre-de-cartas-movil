import '../../domain/entities/deck_card_entity.dart';

class DeckCardModel extends DeckCardEntity {
  const DeckCardModel({
    required super.deckId,
    required super.cardId,
    required super.quantity,
  });

  factory DeckCardModel.fromJson(Map<String, dynamic> json) {
    return DeckCardModel(
      deckId: json['deck_id'] as int? ?? json['deckId'] as int? ?? 0,
      cardId: json['card_id'] as int? ?? json['cardId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deck_id': deckId,
      'card_id': cardId,
      'quantity': quantity,
    };
  }
}
