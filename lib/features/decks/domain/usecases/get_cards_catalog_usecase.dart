import '../entities/card_entity.dart';
import '../repositories/deck_repository.dart';

class GetCardsCatalogUseCase {
  final DeckRepository repository;

  GetCardsCatalogUseCase({required this.repository});

  Future<List<CardEntity>> call() async {
    return await repository.getCatalog();
  }
}

