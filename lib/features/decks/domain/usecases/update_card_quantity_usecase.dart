import '../entities/deck_card_entity.dart';
import '../repositories/deck_repository.dart';

class UpdateCardQuantityUseCase {
  final DeckRepository repository;

  UpdateCardQuantityUseCase({required this.repository});

  Future<DeckCardEntity> call(int deckId, int cardId, int quantity) async {
    return await repository.updateCardQuantity(deckId, cardId, quantity);
  }
}

