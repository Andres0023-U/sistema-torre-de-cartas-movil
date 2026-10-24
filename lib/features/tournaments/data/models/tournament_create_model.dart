import '../../domain/entities/tournament_create_entity.dart';

class TournamentCreateModel extends TournamentCreateEntity {
  const TournamentCreateModel({
    required super.name,
    required super.date,
    required super.format,
    required super.numPlayers,
  });

  factory TournamentCreateModel.fromJson(Map<String, dynamic> json) {
    return TournamentCreateModel(
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      format: json['format'] as String? ?? '',
      numPlayers: json['numPlayers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'format': format,
      'numPlayers': numPlayers,
    };
  }
}
