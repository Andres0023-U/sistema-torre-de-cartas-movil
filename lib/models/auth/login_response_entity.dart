import 'package:equatable/equatable.dart';

class LoginResponseEntity extends Equatable {
  final String accessToken;
  final String tokenType;
  final String role;

  const LoginResponseEntity({
    required this.accessToken,
    required this.tokenType,
    required this.role,
  });

  @override
  List<Object?> get props => [accessToken, tokenType, role];
}
