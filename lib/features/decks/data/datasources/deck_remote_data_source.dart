import '../../../../core/network/dio_client.dart';
import '../models/card_model.dart';
import '../models/deck_card_model.dart';
import '../models/deck_create_model.dart';
import '../models/deck_model.dart';

abstract class DeckRemoteDataSource {
  Future<List<DeckModel>> getMyDecks();
  Future<DeckModel> createDeck(DeckCreateModel data);
  Future<DeckModel> getDeck(int deckId);
  Future<List<DeckCardModel>> getDeckCards(int deckId);
  Future<List<CardModel>> getCatalog();
  Future<DeckCardModel> addCardToDeck(int deckId, int cardId, int quantity);
  Future<DeckCardModel> updateCardQuantity(
    int deckId,
    int cardId,
    int quantity,
  );
  Future<void> removeCardFromDeck(int deckId, int cardId);
}

class DeckRemoteDataSourceImpl implements DeckRemoteDataSource {
  final DioClient dioClient;

  DeckRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DeckModel>> getMyDecks() async {
    final response = await dioClient.dio.get('/decks/me');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => DeckModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeckModel> createDeck(DeckCreateModel data) async {
    final response = await dioClient.dio.post(
      '/decks/',
      data: data.toJson(),
    );
    return DeckModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DeckModel> getDeck(int deckId) async {
    final response = await dioClient.dio.get('/decks/$deckId');
    return DeckModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<DeckCardModel>> getDeckCards(int deckId) async {
    final response = await dioClient.dio.get('/decks/$deckId/cards');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => DeckCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CardModel>> getCatalog() async {
    final response = await dioClient.dio.get('/cards/');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeckCardModel> addCardToDeck(
    int deckId,
    int cardId,
    int quantity,
  ) async {
    final response = await dioClient.dio.post(
      '/decks/$deckId/cards',
      data: {
        'card_id': cardId,
        'quantity': quantity,
      },
    );
    return DeckCardModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DeckCardModel> updateCardQuantity(
    int deckId,
    int cardId,
    int quantity,
  ) async {
    final response = await dioClient.dio.put(
      '/decks/$deckId/cards/$cardId',
      data: {
        'card_id': cardId,
        'quantity': quantity,
      },
    );
    return DeckCardModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeCardFromDeck(int deckId, int cardId) async {
    await dioClient.dio.delete('/decks/$deckId/cards/$cardId');
  }
}
