import 'package:torre_de_cartas_movil/services/core/token_holder.dart';
import 'package:torre_de_cartas_movil/services/core/session_storage.dart';

class LogoutUseCase {
  final TokenHolder tokenHolder;
  final SessionStorage sessionStorage;

  LogoutUseCase({
    required this.tokenHolder,
    required this.sessionStorage,
  });

  Future<void> call() async {
    tokenHolder.clear();
    await sessionStorage.clear();
  }
}
