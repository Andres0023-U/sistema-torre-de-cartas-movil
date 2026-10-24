import '../../domain/entities/card_entity.dart';

class CardModel extends CardEntity {
  const CardModel({
    required super.id,
    required super.name,
    required super.type,
    required super.value,
    super.effect,
    required super.copiesAvailable,
    required super.description,
    required super.rarity,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as int? ?? json['cardId'] as int? ?? 0,
      name: json['name'] as String? ?? json['cardName'] as String? ?? '',
      type: json['type'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      effect: json['effect'] as String?,
      copiesAvailable: json['copiesAvailable'] as int? ?? json['maxQuantity'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      rarity: json['rarity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      if (effect != null) 'effect': effect,
      'copiesAvailable': copiesAvailable,
      'description': description,
      'rarity': rarity,
    };
  }
}
