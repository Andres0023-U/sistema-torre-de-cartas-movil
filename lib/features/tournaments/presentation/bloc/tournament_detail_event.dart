import 'package:equatable/equatable.dart';
import '../../domain/entities/player_with_user_entity.dart';

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


class AvailablePlayersRequested extends TournamentDetailEvent {
  const AvailablePlayersRequested();
}

class PlayerRegistrationRequested extends TournamentDetailEvent {
  final PlayerWithUserEntity player;

  const PlayerRegistrationRequested(this.player);

  @override
  List<Object?> get props => [player];
}
