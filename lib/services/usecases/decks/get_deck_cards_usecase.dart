import 'package:torre_de_cartas_movil/models/decks/deck_card_entity.dart';
import 'package:torre_de_cartas_movil/repositories/decks/deck_repository.dart';

class GetDeckCardsUseCase {
  final DeckRepository repository;

  GetDeckCardsUseCase({required this.repository});

  Future<List<DeckCardEntity>> call(int deckId) async {
    return await repository.getDeckCards(deckId);
  }
}

