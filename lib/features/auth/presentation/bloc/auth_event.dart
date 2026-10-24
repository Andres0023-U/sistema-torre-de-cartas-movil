import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final UserRole role;

  const AuthLoginSubmitted(this.role);

  @override
  List<Object?> get props => [role];
}

class AuthLogoutRequested extends AuthEvent {}
