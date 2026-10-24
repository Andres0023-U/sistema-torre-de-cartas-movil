import 'package:dio/dio.dart';
import '../config/app_config.dart';
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
          ),
        );
  }
}
