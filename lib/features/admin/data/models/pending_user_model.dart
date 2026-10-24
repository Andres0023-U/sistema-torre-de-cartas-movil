import '../../domain/entities/pending_user_entity.dart';

class PendingUserModel extends PendingUserEntity {
  const PendingUserModel({
    required super.userId,
    required super.name,
    required super.email,
  });

  factory PendingUserModel.fromJson(Map<String, dynamic> json) {
    return PendingUserModel(
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}
