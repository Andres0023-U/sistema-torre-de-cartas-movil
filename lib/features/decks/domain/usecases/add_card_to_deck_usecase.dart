import '../entities/deck_card_entity.dart';
import '../repositories/deck_repository.dart';

class AddCardToDeckUseCase {
  final DeckRepository repository;

  AddCardToDeckUseCase({required this.repository});

  Future<DeckCardEntity> call(int deckId, int cardId, int quantity) async {
    return await repository.addCardToDeck(deckId, cardId, quantity);
  }
}

