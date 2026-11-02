import 'package:equatable/equatable.dart';
import 'package:torre_de_cartas_movil/models/auth/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.name,
    this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}
