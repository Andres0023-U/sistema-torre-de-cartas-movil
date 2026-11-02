import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';

class UpdateNameUseCase {
  final AccountRepository repository;

  UpdateNameUseCase({required this.repository});

  Future<String> call(String name) async {
    return await repository.updateMyName(name);
  }
}

