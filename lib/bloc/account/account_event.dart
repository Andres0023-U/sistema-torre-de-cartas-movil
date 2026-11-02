import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountEvent extends AccountEvent {
  final String? email;

  const LoadAccountEvent({this.email});

  @override
  List<Object?> get props => [email];
}

class LoadPlayerStatsEvent extends AccountEvent {
  final String? email;

  const LoadPlayerStatsEvent({this.email});

  @override
  List<Object?> get props => [email];
}

class ClearAccountErrorEvent extends AccountEvent {
  const ClearAccountErrorEvent();
}

class ClearPasswordStateEvent extends AccountEvent {
  const ClearPasswordStateEvent();
}

class UpdateAccountNameRequested extends AccountEvent {
  final String name;

  const UpdateAccountNameRequested(this.name);

  @override
  List<Object?> get props => [name];
}

class ChangePasswordRequested extends AccountEvent {
  final String currentPassword;
  final String newPassword;
  final String? email;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    this.email,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, email];
}
