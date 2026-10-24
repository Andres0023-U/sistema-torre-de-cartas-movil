import 'package:equatable/equatable.dart';

abstract class DecksEvent extends Equatable {
  const DecksEvent();

  @override
  List<Object?> get props => [];
}

class LoadDecksEvent extends DecksEvent {}
