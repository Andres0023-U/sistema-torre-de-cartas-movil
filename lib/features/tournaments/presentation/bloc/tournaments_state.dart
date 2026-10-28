import 'package:equatable/equatable.dart';
import '../../domain/entities/tournament_entity.dart';

abstract class TournamentsState extends Equatable {
  const TournamentsState();

  @override
  List<Object?> get props => [];
}

class TournamentsInitial extends TournamentsState {
  const TournamentsInitial();
}

class TournamentsLoading extends TournamentsState {
  const TournamentsLoading();
}

class TournamentsLoaded extends TournamentsState {
  final List<TournamentEntity> tournaments;

  const TournamentsLoaded(this.tournaments);

  @override
  List<Object?> get props => [tournaments];
}

class TournamentsFailure extends TournamentsState {
  final String message;

  const TournamentsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
