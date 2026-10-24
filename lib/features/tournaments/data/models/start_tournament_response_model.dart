import '../../domain/entities/start_tournament_response_entity.dart';

class StartTournamentResponseModel extends StartTournamentResponseEntity {
  const StartTournamentResponseModel({
    required super.tournamentId,
    required super.status,
    required super.roundId,
  });

  factory StartTournamentResponseModel.fromJson(Map<String, dynamic> json) {
    return StartTournamentResponseModel(
      tournamentId: json['tournamentId'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      roundId: json['roundId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'status': status,
      'roundId': roundId,
    };
  }
}
