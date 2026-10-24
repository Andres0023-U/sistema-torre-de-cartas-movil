import 'package:equatable/equatable.dart';

class RoundEntity extends Equatable {
  final int roundId;
  final int tournamentId;
  final int number;
  final String name;
  final String? status;

  const RoundEntity({
    required this.roundId,
    required this.tournamentId,
    required this.number,
    required this.name,
    this.status,
  });

  @override
  List<Object?> get props => [roundId, tournamentId, number, name, status];
}
