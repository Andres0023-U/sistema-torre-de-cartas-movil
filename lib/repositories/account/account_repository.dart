abstract class AccountRepository {
  Future<String> updateMyName(String name);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  });
}
