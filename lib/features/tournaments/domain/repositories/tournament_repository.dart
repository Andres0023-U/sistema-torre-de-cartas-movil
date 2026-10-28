import '../entities/tournament_entity.dart';

abstract class TournamentRepository {
  Future<List<TournamentEntity>> getTournaments();
}
