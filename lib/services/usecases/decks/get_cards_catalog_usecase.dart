import 'package:torre_de_cartas_movil/models/decks/card_entity.dart';
import 'package:torre_de_cartas_movil/repositories/decks/deck_repository.dart';

class GetCardsCatalogUseCase {
  final DeckRepository repository;

  GetCardsCatalogUseCase({required this.repository});

  Future<List<CardEntity>> call() async {
    return await repository.getCatalog();
  }
}

