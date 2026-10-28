import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_ranking_usecase.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final GetRankingUseCase getRankingUseCase;

  RankingBloc({required this.getRankingUseCase}) : super(RankingInitial()) {
    on<RankingRequested>((event, emit) async {
      emit(RankingLoading());
      try {
        final ranking = await getRankingUseCase();
        emit(RankingLoaded(ranking));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(RankingFailure(message));
      }
    });
  }
}
