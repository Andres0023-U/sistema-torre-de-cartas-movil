import '../../domain/entities/next_round_response_entity.dart';

class NextRoundResponseModel extends NextRoundResponseEntity {
  const NextRoundResponseModel({
    required super.status,
    super.roundId,
    super.championDeckId,
    super.championPlayerId,
  });

  factory NextRoundResponseModel.fromJson(Map<String, dynamic> json) {
    return NextRoundResponseModel(
      status: json['status'] as String? ?? '',
      roundId: json['roundId'] as int?,
      championDeckId: json['championDeckId'] as int?,
      championPlayerId: json['championPlayerId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (roundId != null) 'roundId': roundId,
      if (championDeckId != null) 'championDeckId': championDeckId,
      if (championPlayerId != null) 'championPlayerId': championPlayerId,
    };
  }
}
