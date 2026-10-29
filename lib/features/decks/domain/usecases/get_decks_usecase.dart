import '../entities/deck_entity.dart';
import '../repositories/deck_repository.dart';

class GetDecksUseCase {
  final DeckRepository repository;

  GetDecksUseCase({required this.repository});

  Future<List<DeckEntity>> call() async {
    return await repository.getMyDecks();
  }
}
