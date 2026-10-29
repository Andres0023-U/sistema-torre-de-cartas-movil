import 'package:equatable/equatable.dart';
import '../../domain/entities/tournament_create_entity.dart';

abstract class CreateTournamentEvent extends Equatable {
  const CreateTournamentEvent();

  @override
  List<Object?> get props => [];
}

class CreateTournamentSubmitted extends CreateTournamentEvent {
  final TournamentCreateEntity data;

  const CreateTournamentSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}

