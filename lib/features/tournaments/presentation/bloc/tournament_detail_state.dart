import 'package:equatable/equatable.dart';
import '../../domain/entities/player_with_user_entity.dart';
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

const Object _keep = Object();

class TournamentDetailLoaded extends TournamentDetailState {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;

  /// true mientras se ejecuta la acción "Iniciar torneo".
  final bool isStarting;

  /// Jugadores disponibles para inscribir (null si aún no se han cargado).
  final List<PlayerWithUserEntity>? availablePlayers;
  final bool isLoadingAvailablePlayers;
  final String? availablePlayersError;

  /// player_id del jugador que se está inscribiendo (null si ninguno).
  final int? registeringPlayerId;

  /// Mensaje de éxito de la última acción (se muestra una vez en un SnackBar).
  final String? successMessage;

  /// Mensaje de error de la última acción (se muestra una vez en un SnackBar).
  final String? errorMessage;

  const TournamentDetailLoaded({
    required this.tournament,
    required this.players,
    required this.rounds,
    this.isStarting = false,
    this.availablePlayers,
    this.isLoadingAvailablePlayers = false,
    this.availablePlayersError,
    this.registeringPlayerId,
    this.successMessage,
    this.errorMessage,
  });

  /// Copia conservando los datos. Los mensajes de un solo uso
  /// ([successMessage] y [errorMessage]) NO se conservan: solo se incluyen
  /// si se pasan explícitamente.
  TournamentDetailLoaded copyWith({
    TournamentEntity? tournament,
    List<TournamentPlayerEntity>? players,
    List<RoundEntity>? rounds,
    bool? isStarting,
    Object? availablePlayers = _keep,
    bool? isLoadingAvailablePlayers,
    Object? availablePlayersError = _keep,
    Object? registeringPlayerId = _keep,
    String? successMessage,
    String? errorMessage,
  }) {
    return TournamentDetailLoaded(
      tournament: tournament ?? this.tournament,
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      isStarting: isStarting ?? this.isStarting,
      availablePlayers: identical(availablePlayers, _keep)
          ? this.availablePlayers
          : availablePlayers as List<PlayerWithUserEntity>?,
      isLoadingAvailablePlayers:
          isLoadingAvailablePlayers ?? this.isLoadingAvailablePlayers,
      availablePlayersError: identical(availablePlayersError, _keep)
          ? this.availablePlayersError
          : availablePlayersError as String?,
      registeringPlayerId: identical(registeringPlayerId, _keep)
          ? this.registeringPlayerId
          : registeringPlayerId as int?,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        tournament,
        players,
        rounds,
        isStarting,
        availablePlayers,
        isLoadingAvailablePlayers,
        availablePlayersError,
        registeringPlayerId,
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
