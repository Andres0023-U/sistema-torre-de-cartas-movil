import 'package:equatable/equatable.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitialState extends RankingState {}
