import '../repositories/deck_repository.dart';

class RemoveCardFromDeckUseCase {
  final DeckRepository repository;

  RemoveCardFromDeckUseCase({required this.repository});

  Future<void> call(int deckId, int cardId) async {
    return await repository.removeCardFromDeck(deckId, cardId);
  }
}

