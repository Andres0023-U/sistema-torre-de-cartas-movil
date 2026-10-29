import '../entities/registration_entity.dart';
import '../repositories/tournament_repository.dart';

class RegisterPlayerUseCase {
  final TournamentRepository repository;

  RegisterPlayerUseCase({required this.repository});

  Future<RegistrationEntity> call(int tournamentId, int playerId) async {
    return await repository.registerPlayer(tournamentId, playerId);
  }
}

