import '../../domain/entities/registration_entity.dart';

class RegistrationModel extends RegistrationEntity {
  const RegistrationModel({
    required super.tournamentRegistrationId,
    required super.tournamentId,
    required super.playerId,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      tournamentRegistrationId: json['tournamentRegistrationId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      playerId: json['playerId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentRegistrationId': tournamentRegistrationId,
      'tournamentId': tournamentId,
      'playerId': playerId,
    };
  }
}
