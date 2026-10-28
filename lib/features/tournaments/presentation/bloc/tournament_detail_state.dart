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

  /// true mientras se ejecuta la acción "Iniciar torneo".
  final bool isStarting;

  /// Mensaje de éxito de la última acción (se muestra una vez en un SnackBar).
  final String? successMessage;

  /// Mensaje de error de la última acción (se muestra una vez en un SnackBar).
  final String? errorMessage;

  const TournamentDetailLoaded({
    required this.tournament,
    required this.players,
    required this.rounds,
    this.isStarting = false,
    this.successMessage,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        tournament,
        players,
        rounds,
        isStarting,
        successMessage,
        errorMessage,
      ];
}

class TournamentDetailFailure extends TournamentDetailState {
  final String message;

  const TournamentDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
