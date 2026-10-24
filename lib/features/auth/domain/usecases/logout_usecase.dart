import '../../../../core/network/token_holder.dart';

class LogoutUseCase {
  final TokenHolder tokenHolder;

  LogoutUseCase({required this.tokenHolder});

  void call() {
    tokenHolder.clear();
  }
}
