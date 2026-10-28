import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentsUseCase {
  final TournamentRepository repository;

  GetTournamentsUseCase({required this.repository});

  Future<List<TournamentEntity>> call() async {
    return await repository.getTournaments();
  }
}
