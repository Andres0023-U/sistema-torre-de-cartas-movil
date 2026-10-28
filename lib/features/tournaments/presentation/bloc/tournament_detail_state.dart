import 'package:equatable/equatable.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';

abstract class TournamentDetailState extends Equatable {
  const TournamentDetailState();

  @override
  List<Object?> get props => [];
}

class TournamentDetailInitial extends TournamentDetailState {
  const TournamentDetailInitial();
}

class TournamentDetailLoading extends TournamentDetailState {
  const TournamentDetailLoading();
}

class TournamentDetailLoaded extends TournamentDetailState {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;

  const TournamentDetailLoaded({
    required this.tournament,
    required this.players,
    required this.rounds,
  });

  @override
  List<Object?> get props => [tournament, players, rounds];
}

class TournamentDetailFailure extends TournamentDetailState {
  final String message;

  const TournamentDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

