import 'package:dio/dio.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthExpiredException implements Exception {
  final String message;
  AuthExpiredException([this.message = "Tu sesión expiró. Inicia sesión de nuevo."]);

  @override
  String toString() => message;
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LoginResponseEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.login(email, password);
    } catch (e) {
      throw Exception(_translateError(e));
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      return await remoteDataSource.getMe();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw AuthExpiredException();
      }
      throw Exception(_translateError(e));
    }
  }

  String _translateError(Object error) {
    if (error is DioException) {
      final isLogin = error.requestOptions.path.contains('/auth/login');
      final statusCode = error.response?.statusCode;

      if (error.response?.data is Map) {
        final data = error.response?.data as Map<String, dynamic>;
        if (data['detail'] != null) {
          return data['detail'].toString();
        }
      }

      if (!isLogin && statusCode == 401) {
        return "Tu sesión expiró. Inicia sesión de nuevo.";
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return "El servidor tardó en responder. Intenta de nuevo.";
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return "No se pudo conectar con el servidor. Revisa tu internet e intenta de nuevo.";
      }
    }
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception: ', '');
      if (msg == 'Rol desconocido') {
        return msg;
      }
    }
    return "Ocurrió un error inesperado.";
  }
}
