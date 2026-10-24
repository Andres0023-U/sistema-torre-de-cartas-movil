import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole? role;
  final String? name;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.name,
    this.email,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, role, name, email, errorMessage];
}
