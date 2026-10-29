import '../../domain/entities/registration_entity.dart';

class RegistrationModel extends RegistrationEntity {
  const RegistrationModel({
    required super.tournamentRegistrationId,
    required super.tournamentId,
    required super.playerId,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      tournamentRegistrationId: json['tournament_registration_id'] as int? ?? 0,
      tournamentId: json['tournament_id'] as int? ?? 0,
      playerId: json['player_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_registration_id': tournamentRegistrationId,
      'tournament_id': tournamentId,
      'player_id': playerId,
    };
  }
}
