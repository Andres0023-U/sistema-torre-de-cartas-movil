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
      roundId: json['roundId'] as int? ?? json['id'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundId': roundId,
      'tournamentId': tournamentId,
      'number': number,
      'name': name,
      if (status != null) 'status': status,
    };
  }
}
