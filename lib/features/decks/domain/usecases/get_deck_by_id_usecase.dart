import '../entities/deck_entity.dart';
import '../repositories/deck_repository.dart';

class GetDeckByIdUseCase {
  final DeckRepository repository;

  GetDeckByIdUseCase({required this.repository});

  Future<DeckEntity> call(int deckId) async {
    return await repository.getDeck(deckId);
  }
}

