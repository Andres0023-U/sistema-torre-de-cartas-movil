import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

class RankingRequested extends RankingEvent {
  final bool isPlayer;
  final String? currentUserName;

  const RankingRequested({
    this.isPlayer = false,
    this.currentUserName,
  });

  @override
  List<Object?> get props => [isPlayer, currentUserName];
}

class LocalTournamentsRequested extends RankingEvent {
  const LocalTournamentsRequested();
}

class LocalTournamentSelected extends RankingEvent {
  final int tournamentId;

  const LocalTournamentSelected(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}
