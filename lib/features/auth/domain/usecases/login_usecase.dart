import '../../../../core/network/token_holder.dart';
import '../../../../core/storage/session_storage.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

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
