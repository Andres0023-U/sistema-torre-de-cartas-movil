import 'package:equatable/equatable.dart';
import '../../domain/entities/deck_entity.dart';

abstract class DecksState extends Equatable {
  const DecksState();

  @override
  List<Object?> get props => [];
}

class DecksInitial extends DecksState {
  const DecksInitial();
}

class DecksLoading extends DecksState {
  const DecksLoading();
}

class DecksLoaded extends DecksState {
  final List<DeckEntity> decks;
  final bool isCreating;
  final String? successMessage;
  final String? errorMessage;

  const DecksLoaded({
    required this.decks,
    this.isCreating = false,
    this.successMessage,
    this.errorMessage,
  });

  DecksLoaded copyWith({
    List<DeckEntity>? decks,
    bool? isCreating,
    String? successMessage,
    String? errorMessage,
  }) {
    return DecksLoaded(
      decks: decks ?? this.decks,
      isCreating: isCreating ?? this.isCreating,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [decks, isCreating, successMessage, errorMessage];
}

class DecksFailure extends DecksState {
  final String message;

  const DecksFailure(this.message);

  @override
  List<Object?> get props => [message];
}
