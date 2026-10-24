import 'package:equatable/equatable.dart';

class PendingUserEntity extends Equatable {
  final int userId;
  final String name;
  final String email;

  const PendingUserEntity({
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, name, email];
}
