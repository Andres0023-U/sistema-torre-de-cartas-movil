import '../../domain/entities/register_request_entity.dart';

class RegisterRequestModel extends RegisterRequestEntity {
  const RegisterRequestModel({
    required super.name,
    required super.email,
    required super.password,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
