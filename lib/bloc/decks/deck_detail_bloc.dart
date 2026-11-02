import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/add_card_to_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_cards_catalog_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_deck_by_id_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_deck_cards_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/remove_card_from_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/update_card_quantity_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/decks/deck_detail_event.dart';
import 'package:torre_de_cartas_movil/bloc/decks/deck_detail_state.dart';

class DeckDetailBloc extends Bloc<DeckDetailEvent, DeckDetailState> {
  final GetDeckByIdUseCase getDeckByIdUseCase;
  final GetDeckCardsUseCase getDeckCardsUseCase;
  final GetCardsCatalogUseCase getCardsCatalogUseCase;
  final AddCardToDeckUseCase addCardToDeckUseCase;
  final UpdateCardQuantityUseCase updateCardQuantityUseCase;
  final RemoveCardFromDeckUseCase removeCardFromDeckUseCase;

  DeckDetailBloc({
    required this.getDeckByIdUseCase,
    required this.getDeckCardsUseCase,
    required this.getCardsCatalogUseCase,
    required this.addCardToDeckUseCase,
    required this.updateCardQuantityUseCase,
    required this.removeCardFromDeckUseCase,
  }) : super(const DeckDetailInitial()) {
    on<DeckDetailRequested>((event, emit) async {
      emit(const DeckDetailLoading());
      try {
        final results = await Future.wait([
          getDeckByIdUseCase(event.deckId),
          getDeckCardsUseCase(event.deckId),
          getCardsCatalogUseCase(),
        ]);

        emit(DeckDetailLoaded(
          deck: results[0] as dynamic,
          deckCards: results[1] as dynamic,
          catalog: results[2] as dynamic,
        ));
      } catch (e) {
        emit(DeckDetailFailure(_messageOf(e)));
      }
    });

    on<DeckAddCardRequested>((event, emit) async {
      final current = state;
      if (current is! DeckDetailLoaded || current.isUpdating) return;

      if (current.totalCards + event.quantity >
          DeckDetailLoaded.maxDeckCards) {
        emit(current.copyWith(errorMessage: _limitMessage));
        return;
      }

      emit(current.copyWith(isUpdating: true));
      final deckId = current.deck.deckId;

      try {
        await addCardToDeckUseCase(deckId, event.cardId, event.quantity);
        final freshCards = await getDeckCardsUseCase(deckId);
        emit(current.copyWith(
          deckCards: freshCards,
          isUpdating: false,
          successMessage: 'Carta agregada al mazo',
        ));
      } catch (e) {
        emit(current.copyWith(
          isUpdating: false,
          errorMessage: _messageOf(e),
        ));
      }
    });

    on<DeckUpdateCardQuantityRequested>((event, emit) async {
      final current = state;
      if (current is! DeckDetailLoaded || current.isUpdating) return;

      final delta = event.quantity - current.getQuantityFor(event.cardId);
      if (delta > 0 &&
          current.totalCards + delta > DeckDetailLoaded.maxDeckCards) {
        emit(current.copyWith(errorMessage: _limitMessage));
        return;
      }

      emit(current.copyWith(isUpdating: true));
      final deckId = current.deck.deckId;

      try {
        if (event.quantity <= 0) {
          await removeCardFromDeckUseCase(deckId, event.cardId);
        } else {
          await updateCardQuantityUseCase(deckId, event.cardId, event.quantity);
        }
        final freshCards = await getDeckCardsUseCase(deckId);
        emit(current.copyWith(
          deckCards: freshCards,
          isUpdating: false,
        ));
      } catch (e) {
        emit(current.copyWith(
          isUpdating: false,
          errorMessage: _messageOf(e),
        ));
      }
    });

    on<DeckRemoveCardRequested>((event, emit) async {
      final current = state;
      if (current is! DeckDetailLoaded || current.isUpdating) return;

      emit(current.copyWith(isUpdating: true));
      final deckId = current.deck.deckId;

      try {
        await removeCardFromDeckUseCase(deckId, event.cardId);
        final freshCards = await getDeckCardsUseCase(deckId);
        emit(current.copyWith(
          deckCards: freshCards,
          isUpdating: false,
          successMessage: 'Carta eliminada del mazo',
        ));
      } catch (e) {
        emit(current.copyWith(
          isUpdating: false,
          errorMessage: _messageOf(e),
        ));
      }
    });
  }

  static const String _limitMessage =
      'El mazo no puede tener más de ${DeckDetailLoaded.maxDeckCards} cartas';

  String _messageOf(Object e) => e.toString().replaceAll('Exception: ', '');
}

