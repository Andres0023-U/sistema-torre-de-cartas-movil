import 'package:equatable/equatable.dart';
import '../../domain/entities/tournament_entity.dart';

abstract class CreateTournamentState extends Equatable {
  const CreateTournamentState();

  @override
  List<Object?> get props => [];
}

class CreateTournamentInitial extends CreateTournamentState {
  const CreateTournamentInitial();
}

class CreateTournamentSubmitting extends CreateTournamentState {
  const CreateTournamentSubmitting();
}

class CreateTournamentSuccess extends CreateTournamentState {
  final TournamentEntity tournament;

  const CreateTournamentSuccess(this.tournament);

  @override
  List<Object?> get props => [tournament];
}

class CreateTournamentFailure extends CreateTournamentState {
  final String message;

  const CreateTournamentFailure(this.message);

  @override
  List<Object?> get props => [message];
}

