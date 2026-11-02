import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/models/decks/deck_create_entity.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/create_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_decks_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/decks/decks_event.dart';
import 'package:torre_de_cartas_movil/bloc/decks/decks_state.dart';

class DecksBloc extends Bloc<DecksEvent, DecksState> {
  final GetDecksUseCase getDecksUseCase;
  final CreateDeckUseCase createDeckUseCase;

  DecksBloc({
    required this.getDecksUseCase,
    required this.createDeckUseCase,
  }) : super(const DecksInitial()) {
    on<DecksRequested>((event, emit) async {
      emit(const DecksLoading());
      try {
        final decks = await getDecksUseCase();
        emit(DecksLoaded(decks: decks));
      } catch (e) {
        emit(DecksFailure(_messageOf(e)));
      }
    });

    on<DeckCreateRequested>((event, emit) async {
      final current = state;
      final currentDecks = current is DecksLoaded ? current.decks : null;

      if (current is DecksLoaded) {
        emit(current.copyWith(isCreating: true));
      }

      try {
        await createDeckUseCase(DeckCreateEntity(name: event.name));
        final updatedDecks = await getDecksUseCase();
        emit(DecksLoaded(
          decks: updatedDecks,
          isCreating: false,
          successMessage: 'Mazo creado correctamente',
        ));
      } catch (e) {
        final errorMsg = _messageOf(e);
        if (currentDecks != null) {
          emit(DecksLoaded(
            decks: currentDecks,
            isCreating: false,
            errorMessage: errorMsg,
          ));
        } else {
          emit(DecksFailure(errorMsg));
        }
      }
    });
  }

  String _messageOf(Object e) => e.toString().replaceAll('Exception: ', '');
}
