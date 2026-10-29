import '../entities/player_with_user_entity.dart';
import '../repositories/tournament_repository.dart';

class GetAvailablePlayersUseCase {
  final TournamentRepository repository;

  GetAvailablePlayersUseCase({required this.repository});

  Future<List<PlayerWithUserEntity>> call() async {
    return await repository.getAvailablePlayers();
  }
}

