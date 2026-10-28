import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole? role;
  final int? userId;
  final String? name;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.userId,
    this.name,
    this.email,
    this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [status, role, userId, name, email, errorMessage];
}
