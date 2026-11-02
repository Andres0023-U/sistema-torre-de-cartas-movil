import 'package:torre_de_cartas_movil/core/network/token_holder.dart';
import 'package:torre_de_cartas_movil/core/storage/session_storage.dart';
import 'package:torre_de_cartas_movil/models/auth/user_entity.dart';
import 'package:torre_de_cartas_movil/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  final TokenHolder tokenHolder;
  final SessionStorage sessionStorage;

  LoginUseCase({
    required this.repository,
    required this.tokenHolder,
    required this.sessionStorage,
  });

  Future<UserEntity> call(String email, String password) async {
    final loginResponse = await repository.login(email, password);
    tokenHolder.setToken(loginResponse.accessToken);
    await sessionStorage.saveSession(loginResponse.accessToken, email);
    final user = await repository.getMe();
    return UserEntity(
      id: user.id,
      name: user.name,
      email: email,
      role: user.role,
    );
  }
}
