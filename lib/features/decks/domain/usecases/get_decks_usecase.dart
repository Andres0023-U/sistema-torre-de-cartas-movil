import 'package:torre_de_cartas_movil/models/decks/deck_entity.dart';
import 'package:torre_de_cartas_movil/features/decks/domain/repositories/deck_repository.dart';

class GetDecksUseCase {
  final DeckRepository repository;

  GetDecksUseCase({required this.repository});

  Future<List<DeckEntity>> call() async {
    return await repository.getMyDecks();
  }
}
