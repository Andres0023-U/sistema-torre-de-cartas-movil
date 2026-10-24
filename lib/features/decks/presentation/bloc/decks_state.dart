import 'package:equatable/equatable.dart';

abstract class DecksState extends Equatable {
  const DecksState();

  @override
  List<Object?> get props => [];
}

class DecksInitialState extends DecksState {}
