import 'package:dio/dio.dart';
import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';
import 'package:torre_de_cartas_movil/services/api/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> updateMyName(String name) async {
    try {
      return await remoteDataSource.updateMyName(name);
    } on NameAlreadyTakenException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(_translateNameError(e));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: email,
      );
    } catch (e) {
      throw Exception(_translatePasswordError(e));
    }
  }

  @override
  Future<MyStatsEntity> getMyStats({String? email}) async {
    try {
      return await remoteDataSource.getMyStats(email: email);
    } catch (e) {
      throw Exception('No se pudieron obtener las estadísticas.');
    }
  }

  @override
  Future<List<HistoryEntryEntity>> getMyHistory() async {
    try {
      return await remoteDataSource.getMyHistory();
    } catch (e) {
      return [];
    }
  }

  String _translateNameError(Object error) {
    if (error is NameAlreadyTakenException) {
      return error.message;
    }
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 409) {
        return 'Ese nombre ya está en uso. Elige otro nombre.';
      }
      if (error.response?.data is Map) {
        final data = Map<String, dynamic>.from(error.response!.data as Map);
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          final lower = detail.toLowerCase();
          if (lower.contains('unique') ||
              lower.contains('duplicate') ||
              lower.contains('already')) {
            return 'Ese nombre ya está en uso. Elige otro nombre.';
          }
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
      if (statusCode == 401) {
        return 'Tu sesión expiró. Inicia sesión de nuevo.';
      }
      if (statusCode == 403) {
        return 'No tienes permisos para cambiar el nombre.';
      }
      if (statusCode == 422) {
        return 'El nombre ingresado no es válido.';
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
    return 'No se pudo actualizar el nombre. Intenta de nuevo.';
  }

  String _translatePasswordError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (error.response?.data is Map) {
        final data = Map<String, dynamic>.from(error.response!.data as Map);
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
      if (statusCode == 400) {
        return 'La contraseña actual es incorrecta o los datos no son válidos.';
      }
      if (statusCode == 401) {
        return 'Tu sesión expiró. Inicia sesión de nuevo.';
      }
      if (statusCode == 422) {
        return 'La contraseña ingresada no cumple con el formato requerido.';
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
    final msg = error.toString().replaceAll('Exception: ', '').trim();
    if (msg.isNotEmpty && !msg.startsWith('DioException')) {
      return msg;
    }
    return 'No se pudo actualizar la contraseña. Intenta de nuevo.';
  }
}
