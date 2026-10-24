import 'package:flutter_bloc/flutter_bloc.dart';
import 'decks_event.dart';
import 'decks_state.dart';

class DecksBloc extends Bloc<DecksEvent, DecksState> {
  DecksBloc() : super(DecksInitialState()) {
    on<LoadDecksEvent>((event, emit) {
      // TODO: Implementar carga de mazos
    });
  }
}
