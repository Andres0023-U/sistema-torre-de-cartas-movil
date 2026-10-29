import '../entities/deck_create_entity.dart';
import '../entities/deck_entity.dart';
import '../repositories/deck_repository.dart';

class CreateDeckUseCase {
  final DeckRepository repository;

  CreateDeckUseCase({required this.repository});

  Future<DeckEntity> call(DeckCreateEntity data) async {
    return await repository.createDeck(data);
  }
}

