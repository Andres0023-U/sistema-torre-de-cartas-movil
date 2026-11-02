import 'package:torre_de_cartas_movil/models/tournaments/tournament_create_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';

class CreateTournamentUseCase {
  final TournamentRepository repository;

  CreateTournamentUseCase({required this.repository});

  Future<TournamentEntity> call(TournamentCreateEntity data) async {
    return await repository.createTournament(data);
  }
}

