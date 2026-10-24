import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? email}) {
    final roleStr = json['role'] as String? ?? 'pending';
    return UserModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: email,
      role: parseUserRole(roleStr),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      if (email != null) 'email': email,
      'role': role.name,
    };
  }
}
