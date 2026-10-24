import 'package:equatable/equatable.dart';

abstract class TournamentsEvent extends Equatable {
  const TournamentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTournamentsEvent extends TournamentsEvent {}
