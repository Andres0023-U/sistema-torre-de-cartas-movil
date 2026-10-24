import 'package:equatable/equatable.dart';

class RegistrationEntity extends Equatable {
  final int tournamentRegistrationId;
  final int tournamentId;
  final int playerId;

  const RegistrationEntity({
    required this.tournamentRegistrationId,
    required this.tournamentId,
    required this.playerId,
  });

  @override
  List<Object?> get props => [
        tournamentRegistrationId,
        tournamentId,
        playerId,
      ];
}
