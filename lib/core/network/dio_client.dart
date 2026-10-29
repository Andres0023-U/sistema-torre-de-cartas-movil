import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../di/injection_container.dart';
import '../storage/session_storage.dart';
import 'token_holder.dart';

class DioClient {
  final Dio dio;
  final TokenHolder tokenHolder;

  DioClient({Dio? dio, required this.tokenHolder})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: apiBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (!options.path.contains('/auth/login')) {
                if (tokenHolder.hasToken) {
                  options.headers['Authorization'] = 'Bearer ${tokenHolder.token}';
                }
              }
              return handler.next(options);
            },
            onError: (error, handler) async {
              final isLogin = error.requestOptions.path.contains('/auth/login');
              final statusCode = error.response?.statusCode;

              if (!isLogin && statusCode == 401) {
                tokenHolder.clear();
                try {
                  await sl<SessionStorage>().clear();
                } catch (_) {}
              }
              return handler.next(error);
            },
          ),
        );
  }
}
