import '../../../../core/network/token_holder.dart';
import '../../../../core/storage/session_storage.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

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
