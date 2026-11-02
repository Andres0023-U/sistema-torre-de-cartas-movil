import 'package:torre_de_cartas_movil/services/core/token_holder.dart';
import 'package:torre_de_cartas_movil/services/core/session_storage.dart';
import 'package:torre_de_cartas_movil/models/auth/user_entity.dart';
import 'package:torre_de_cartas_movil/repositories/auth/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;
  final TokenHolder tokenHolder;
  final SessionStorage sessionStorage;

  RestoreSessionUseCase({
    required this.repository,
    required this.tokenHolder,
    required this.sessionStorage,
  });

  Future<UserEntity?> call() async {
    final token = await sessionStorage.readToken();
    final email = await sessionStorage.readEmail();

    if (token == null || token.isEmpty) {
      return null;
    }

    tokenHolder.setToken(token);

    try {
      final user = await repository.getMe();
      return UserEntity(
        id: user.id,
        name: user.name,
        email: email,
        role: user.role,
      );
    } catch (e) {
      rethrow;
    }
  }
}
