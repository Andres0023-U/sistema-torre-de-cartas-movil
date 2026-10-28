import '../../domain/entities/tournament_entity.dart';

class TournamentModel extends TournamentEntity {
  const TournamentModel({
    required super.tournamentId,
    required super.name,
    required super.date,
    required super.format,
    required super.numPlayers,
    required super.status,
    required super.organizerId,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] as String? ?? '');
    } catch (_) {
      parsedDate = DateTime(2000);
    }

    return TournamentModel(
      tournamentId: json['tournament_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      date: parsedDate,
      format: json['format'] as String? ?? '',
      numPlayers: json['num_players'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      organizerId: json['organizer_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'name': name,
      'date': date.toIso8601String(),
      'format': format,
      'num_players': numPlayers,
      'status': status,
      'organizer_id': organizerId,
    };
  }
}
