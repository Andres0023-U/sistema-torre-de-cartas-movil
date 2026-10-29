import 'package:dio/dio.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/deck_card_entity.dart';
import '../../domain/entities/deck_create_entity.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../datasources/deck_remote_data_source.dart';
import '../models/deck_create_model.dart';

class DeckRepositoryImpl implements DeckRepository {
  final DeckRemoteDataSource remoteDataSource;

  DeckRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeckEntity>> getMyDecks() async {
    try {
      return await remoteDataSource.getMyDecks();
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<DeckEntity> createDeck(DeckCreateEntity data) async {
    try {
      return await remoteDataSource.createDeck(DeckCreateModel.fromEntity(data));
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<DeckEntity> getDeck(int deckId) async {
    try {
      return await remoteDataSource.getDeck(deckId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<List<DeckCardEntity>> getDeckCards(int deckId) async {
    try {
      return await remoteDataSource.getDeckCards(deckId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<List<CardEntity>> getCatalog() async {
    try {
      return await remoteDataSource.getCatalog();
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<DeckCardEntity> addCardToDeck(
    int deckId,
    int cardId,
    int quantity,
  ) async {
    try {
      return await remoteDataSource.addCardToDeck(deckId, cardId, quantity);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<DeckCardEntity> updateCardQuantity(
    int deckId,
    int cardId,
    int quantity,
  ) async {
    try {
      return await remoteDataSource.updateCardQuantity(deckId, cardId, quantity);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<void> removeCardFromDeck(int deckId, int cardId) async {
    try {
      await remoteDataSource.removeCardFromDeck(deckId, cardId);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  String _translateError(Object error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response?.data as Map;
        final detail = data['detail'];
        if (detail is String) {
          return detail;
        }
        if (detail != null) {
          return 'Revisa los datos ingresados.';
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'El servidor tardó en responder. Intenta de nuevo.';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return 'No se pudo conectar con el servidor. Revisa tu internet e intenta de nuevo.';
      }
    }
    return 'Ocurrió un error inesperado.';
  }
}
