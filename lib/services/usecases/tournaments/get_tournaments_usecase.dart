import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';

class GetTournamentsUseCase {
  final TournamentRepository repository;

  GetTournamentsUseCase({required this.repository});

  Future<List<TournamentEntity>> call() async {
    return await repository.getTournaments();
  }
}
