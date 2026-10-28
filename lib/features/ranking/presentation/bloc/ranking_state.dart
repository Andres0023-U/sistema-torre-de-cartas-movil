import 'package:equatable/equatable.dart';
import '../../domain/entities/global_ranking_entry_entity.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {
  final List<GlobalRankingEntryEntity> ranking;

  const RankingLoaded(this.ranking);

  @override
  List<Object?> get props => [ranking];
}

class RankingFailure extends RankingState {
  final String message;

  const RankingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
