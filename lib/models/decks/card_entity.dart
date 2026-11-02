import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final int id;
  final String name;
  final String type;
  final int value;
  final String? effect;
  final int copiesAvailable;
  final String description;
  final String rarity;

  const CardEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.effect,
    required this.copiesAvailable,
    required this.description,
    required this.rarity,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        value,
        effect,
        copiesAvailable,
        description,
        rarity,
      ];
}
