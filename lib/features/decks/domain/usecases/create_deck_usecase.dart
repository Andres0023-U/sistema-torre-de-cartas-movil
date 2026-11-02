import 'package:torre_de_cartas_movil/models/decks/deck_create_entity.dart';
import 'package:torre_de_cartas_movil/models/decks/deck_entity.dart';
import 'package:torre_de_cartas_movil/features/decks/domain/repositories/deck_repository.dart';

class CreateDeckUseCase {
  final DeckRepository repository;

  CreateDeckUseCase({required this.repository});

  Future<DeckEntity> call(DeckCreateEntity data) async {
    return await repository.createDeck(data);
  }
}

