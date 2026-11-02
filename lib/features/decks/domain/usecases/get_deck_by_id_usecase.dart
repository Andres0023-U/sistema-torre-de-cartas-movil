import 'package:torre_de_cartas_movil/models/decks/deck_entity.dart';
import 'package:torre_de_cartas_movil/features/decks/domain/repositories/deck_repository.dart';

class GetDeckByIdUseCase {
  final DeckRepository repository;

  GetDeckByIdUseCase({required this.repository});

  Future<DeckEntity> call(int deckId) async {
    return await repository.getDeck(deckId);
  }
}

