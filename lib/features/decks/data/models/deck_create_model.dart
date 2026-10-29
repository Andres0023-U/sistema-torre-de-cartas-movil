import '../../domain/entities/deck_create_entity.dart';

class DeckCreateModel extends DeckCreateEntity {
  const DeckCreateModel({
    required super.name,
  });

  factory DeckCreateModel.fromEntity(DeckCreateEntity entity) {
    return DeckCreateModel(name: entity.name);
  }

  factory DeckCreateModel.fromJson(Map<String, dynamic> json) {
    return DeckCreateModel(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
