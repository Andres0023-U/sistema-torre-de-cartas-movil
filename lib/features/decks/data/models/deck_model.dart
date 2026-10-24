import '../../domain/entities/deck_entity.dart';

class DeckModel extends DeckEntity {
  const DeckModel({
    required super.deckId,
    required super.playerId,
    required super.name,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      deckId: json['deckId'] as int? ?? 0,
      playerId: json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'playerId': playerId,
      'name': name,
    };
  }
}
