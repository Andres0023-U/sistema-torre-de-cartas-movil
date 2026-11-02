import 'package:torre_de_cartas_movil/models/tournaments/registration_entity.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';

class RegisterPlayerUseCase {
  final TournamentRepository repository;

  RegisterPlayerUseCase({required this.repository});

  Future<RegistrationEntity> call(int tournamentId, int playerId) async {
    return await repository.registerPlayer(tournamentId, playerId);
  }
}

