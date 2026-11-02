import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final int userId;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const AdminUserEntity({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, name, email, role, isActive];
}
