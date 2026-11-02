import 'package:torre_de_cartas_movil/models/decks/deck_card_entity.dart';
import 'package:torre_de_cartas_movil/repositories/decks/deck_repository.dart';

class UpdateCardQuantityUseCase {
  final DeckRepository repository;

  UpdateCardQuantityUseCase({required this.repository});

  Future<DeckCardEntity> call(int deckId, int cardId, int quantity) async {
    return await repository.updateCardQuantity(deckId, cardId, quantity);
  }
}

