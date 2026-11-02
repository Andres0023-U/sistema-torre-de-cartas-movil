import 'package:equatable/equatable.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entry_entity.dart';

class TournamentRankingEntity extends Equatable {
  final int tournamentId;
  final bool isFinal;
  final List<TournamentRankingEntryEntity> ranking;

  const TournamentRankingEntity({
    required this.tournamentId,
    required this.isFinal,
    required this.ranking,
  });

  @override
  List<Object?> get props => [tournamentId, isFinal, ranking];
}
