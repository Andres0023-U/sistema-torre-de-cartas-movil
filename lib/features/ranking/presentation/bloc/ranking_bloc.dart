import 'package:flutter_bloc/flutter_bloc.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  RankingBloc() : super(RankingInitialState()) {
    on<LoadRankingEvent>((event, emit) {
      // TODO: Implementar carga de ranking
    });
  }
}
