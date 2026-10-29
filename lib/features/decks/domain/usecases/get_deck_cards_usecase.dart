import '../entities/deck_card_entity.dart';
import '../repositories/deck_repository.dart';

class GetDeckCardsUseCase {
  final DeckRepository repository;

  GetDeckCardsUseCase({required this.repository});

  Future<List<DeckCardEntity>> call(int deckId) async {
    return await repository.getDeckCards(deckId);
  }
}

