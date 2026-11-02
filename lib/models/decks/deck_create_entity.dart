import 'package:equatable/equatable.dart';

class DeckCreateEntity extends Equatable {
  final String name;

  const DeckCreateEntity({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}
