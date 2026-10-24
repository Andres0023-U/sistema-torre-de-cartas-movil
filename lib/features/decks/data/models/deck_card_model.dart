import '../../domain/entities/deck_card_entity.dart';

class DeckCardModel extends DeckCardEntity {
  const DeckCardModel({
    required super.deckId,
    required super.cardId,
    required super.quantity,
  });

  factory DeckCardModel.fromJson(Map<String, dynamic> json) {
    return DeckCardModel(
      deckId: json['deckId'] as int? ?? 0,
      cardId: json['cardId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'cardId': cardId,
      'quantity': quantity,
    };
  }
}
