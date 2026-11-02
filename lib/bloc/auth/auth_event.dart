import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthUserNameUpdated extends AuthEvent {
  final String name;

  const AuthUserNameUpdated(this.name);

  @override
  List<Object?> get props => [name];
}

class AuthLogoutRequested extends AuthEvent {}
