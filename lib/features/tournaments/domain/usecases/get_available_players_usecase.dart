import 'package:torre_de_cartas_movil/models/tournaments/player_with_user_entity.dart';
import 'package:torre_de_cartas_movil/features/tournaments/domain/repositories/tournament_repository.dart';

class GetAvailablePlayersUseCase {
  final TournamentRepository repository;

  GetAvailablePlayersUseCase({required this.repository});

  Future<List<PlayerWithUserEntity>> call() async {
    return await repository.getAvailablePlayers();
  }
}

