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
    return TournamentModel(
      tournamentId: json['tournamentId'] as int? ?? json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      format: json['format'] as String? ?? '',
      numPlayers: json['numPlayers'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      organizerId: json['organizerId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'name': name,
      'date': date,
      'format': format,
      'numPlayers': numPlayers,
      'status': status,
      'organizerId': organizerId,
    };
  }
}
