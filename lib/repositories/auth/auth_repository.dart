import 'package:torre_de_cartas_movil/models/auth/login_response_entity.dart';
import 'package:torre_de_cartas_movil/models/auth/user_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String email, String password);
  Future<UserEntity> getMe();
}
