import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';

class ChangePasswordUseCase {
  final AccountRepository repository;

  ChangePasswordUseCase({required this.repository});

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      email: email,
    );
  }
}

