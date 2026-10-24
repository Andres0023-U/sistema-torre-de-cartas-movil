import 'package:equatable/equatable.dart';

class StartTournamentResponseEntity extends Equatable {
  final int tournamentId;
  final String status;
  final int roundId;

  const StartTournamentResponseEntity({
    required this.tournamentId,
    required this.status,
    required this.roundId,
  });

  @override
  List<Object?> get props => [tournamentId, status, roundId];
}
