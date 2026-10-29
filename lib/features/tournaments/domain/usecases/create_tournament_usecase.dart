import '../entities/tournament_create_entity.dart';
import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class CreateTournamentUseCase {
  final TournamentRepository repository;

  CreateTournamentUseCase({required this.repository});

  Future<TournamentEntity> call(TournamentCreateEntity data) async {
    return await repository.createTournament(data);
  }
}

