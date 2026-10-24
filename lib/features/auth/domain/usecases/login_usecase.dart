import '../../../../core/network/token_holder.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  final TokenHolder tokenHolder;

  LoginUseCase({
    required this.repository,
    required this.tokenHolder,
  });

  Future<UserEntity> call(String email, String password) async {
    final loginResponse = await repository.login(email, password);
    tokenHolder.setToken(loginResponse.accessToken);
    final user = await repository.getMe();
    return UserEntity(
      id: user.id,
      name: user.name,
      email: email,
      role: user.role,
    );
  }
}
