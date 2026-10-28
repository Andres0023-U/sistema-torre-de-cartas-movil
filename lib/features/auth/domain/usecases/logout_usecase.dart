import '../../../../core/network/token_holder.dart';
import '../../../../core/storage/session_storage.dart';

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
