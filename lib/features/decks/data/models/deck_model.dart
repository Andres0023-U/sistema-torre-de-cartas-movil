import '../../domain/entities/deck_entity.dart';

class DeckModel extends DeckEntity {
  const DeckModel({
    required super.deckId,
    required super.playerId,
    required super.name,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      deckId: json['deck_id'] as int? ?? json['deckId'] as int? ?? 0,
      playerId: json['player_id'] as int? ?? json['playerId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deck_id': deckId,
      'player_id': playerId,
      'name': name,
    };
  }
}
