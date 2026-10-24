import 'package:equatable/equatable.dart';

class TournamentCreateEntity extends Equatable {
  final String name;
  final String date;
  final String format;
  final int numPlayers;

  const TournamentCreateEntity({
    required this.name,
    required this.date,
    required this.format,
    required this.numPlayers,
  });

  @override
  List<Object?> get props => [name, date, format, numPlayers];
}
