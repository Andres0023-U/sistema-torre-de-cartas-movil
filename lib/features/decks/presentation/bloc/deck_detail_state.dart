import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/deck_card_entity.dart';
import '../../domain/entities/deck_entity.dart';

abstract class DeckDetailState extends Equatable {
  const DeckDetailState();

  @override
  List<Object?> get props => [];
}

class DeckDetailInitial extends DeckDetailState {
  const DeckDetailInitial();
}

class DeckDetailLoading extends DeckDetailState {
  const DeckDetailLoading();
}

class DeckDetailLoaded extends DeckDetailState {
  final DeckEntity deck;
  final List<DeckCardEntity> deckCards;
  final List<CardEntity> catalog;
  final bool isUpdating;
  final String? successMessage;
  final String? errorMessage;

  const DeckDetailLoaded({
    required this.deck,
    required this.deckCards,
    required this.catalog,
    this.isUpdating = false,
    this.successMessage,
    this.errorMessage,
  });

  /// Cantidad máxima de cartas que puede tener un mazo.
  static const int maxDeckCards = 20;

  int get totalCards => deckCards.fold(0, (sum, c) => sum + c.quantity);

  /// El mazo es válido para torneo cuando llega a [maxDeckCards].
  bool get isValidForTournament => totalCards >= maxDeckCards;

  /// Espacios libres antes de llegar al límite.
  int get remainingSlots => maxDeckCards - totalCards;

  bool get isFull => totalCards >= maxDeckCards;

  Map<int, CardEntity> get catalogMap => {for (final c in catalog) c.id: c};

  int getQuantityFor(int cardId) {
    for (final dc in deckCards) {
      if (dc.cardId == cardId) return dc.quantity;
    }
    return 0;
  }

  DeckDetailLoaded copyWith({
    DeckEntity? deck,
    List<DeckCardEntity>? deckCards,
    List<CardEntity>? catalog,
    bool? isUpdating,
    String? successMessage,
    String? errorMessage,
  }) {
    return DeckDetailLoaded(
      deck: deck ?? this.deck,
      deckCards: deckCards ?? this.deckCards,
      catalog: catalog ?? this.catalog,
      isUpdating: isUpdating ?? this.isUpdating,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        deck,
        deckCards,
        catalog,
        isUpdating,
        successMessage,
        errorMessage,
      ];
}

class DeckDetailFailure extends DeckDetailState {
  final String message;

  const DeckDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

