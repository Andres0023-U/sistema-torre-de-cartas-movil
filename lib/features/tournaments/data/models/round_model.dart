import '../../domain/entities/round_entity.dart';

class RoundModel extends RoundEntity {
  const RoundModel({
    required super.roundId,
    required super.tournamentId,
    required super.number,
    required super.name,
    super.status,
  });

  factory RoundModel.fromJson(Map<String, dynamic> json) {
    return RoundModel(
      roundId: json['round_id'] as int? ?? 0,
      tournamentId: json['tournament_id'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round_id': roundId,
      'tournament_id': tournamentId,
      'number': number,
      'name': name,
      if (status != null) 'status': status,
    };
  }
}
