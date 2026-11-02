import 'package:equatable/equatable.dart';

class TournamentEntity extends Equatable {
  final int tournamentId;
  final String name;
  final DateTime date;
  final String format;
  final int numPlayers;
  final String status;
  final int organizerId;

  const TournamentEntity({
    required this.tournamentId,
    required this.name,
    required this.date,
    required this.format,
    required this.numPlayers,
    required this.status,
    required this.organizerId,
  });

  @override
  List<Object?> get props => [
        tournamentId,
        name,
        date,
        format,
        numPlayers,
        status,
        organizerId,
      ];
}
