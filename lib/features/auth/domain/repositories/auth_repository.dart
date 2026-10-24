import '../entities/login_response_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String email, String password);
  Future<UserEntity> getMe();
}
