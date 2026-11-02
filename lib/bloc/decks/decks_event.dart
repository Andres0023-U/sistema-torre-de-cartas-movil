import 'package:equatable/equatable.dart';

abstract class DecksEvent extends Equatable {
  const DecksEvent();

  @override
  List<Object?> get props => [];
}

class DecksRequested extends DecksEvent {
  const DecksRequested();
}

class DeckCreateRequested extends DecksEvent {
  final String name;

  const DeckCreateRequested(this.name);

  @override
  List<Object?> get props => [name];
}
