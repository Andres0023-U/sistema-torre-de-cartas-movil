import 'package:equatable/equatable.dart';

abstract class TournamentsState extends Equatable {
  const TournamentsState();

  @override
  List<Object?> get props => [];
}

class TournamentsInitialState extends TournamentsState {}
