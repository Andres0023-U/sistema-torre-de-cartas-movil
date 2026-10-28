import 'package:equatable/equatable.dart';

abstract class TournamentDetailEvent extends Equatable {
  const TournamentDetailEvent();

  @override
  List<Object?> get props => [];
}

class TournamentDetailRequested extends TournamentDetailEvent {
  final int tournamentId;

  const TournamentDetailRequested(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentStartRequested extends TournamentDetailEvent {
  const TournamentStartRequested();
}

