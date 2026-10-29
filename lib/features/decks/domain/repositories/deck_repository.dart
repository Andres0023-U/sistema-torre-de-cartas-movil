import '../entities/card_entity.dart';
import '../entities/deck_card_entity.dart';
import '../entities/deck_create_entity.dart';
import '../entities/deck_entity.dart';

abstract class DeckRepository {
  Future<List<DeckEntity>> getMyDecks();
  Future<DeckEntity> createDeck(DeckCreateEntity data);
  Future<DeckEntity> getDeck(int deckId);
  Future<List<DeckCardEntity>> getDeckCards(int deckId);
  Future<List<CardEntity>> getCatalog();
  Future<DeckCardEntity> addCardToDeck(
    int deckId,
    int cardId,
    int quantity,
  );
  Future<DeckCardEntity> updateCardQuantity(
    int deckId,
    int cardId,
    int quantity,
  );
  Future<void> removeCardFromDeck(int deckId, int cardId);
}
