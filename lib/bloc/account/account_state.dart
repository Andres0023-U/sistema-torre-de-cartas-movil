import 'package:equatable/equatable.dart';

class AccountState extends Equatable {
  final bool isUpdatingName;
  final String? updatedName;
  final String? successMessage;
  final String? errorMessage;
  final bool isChangingPassword;
  final bool passwordChangedSuccessfully;
  final String? passwordErrorMessage;
  final String? passwordSuccessMessage;

  const AccountState({
    this.isUpdatingName = false,
    this.updatedName,
    this.successMessage,
    this.errorMessage,
    this.isChangingPassword = false,
    this.passwordChangedSuccessfully = false,
    this.passwordErrorMessage,
    this.passwordSuccessMessage,
  });

  AccountState copyWith({
    bool? isUpdatingName,
    String? updatedName,
    bool clearUpdatedName = false,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
    bool? isChangingPassword,
    bool? passwordChangedSuccessfully,
    String? passwordErrorMessage,
    bool clearPasswordError = false,
    String? passwordSuccessMessage,
    bool clearPasswordSuccess = false,
  }) {
    return AccountState(
      isUpdatingName: isUpdatingName ?? this.isUpdatingName,
      updatedName:
          clearUpdatedName ? null : (updatedName ?? this.updatedName),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordChangedSuccessfully:
          passwordChangedSuccessfully ?? this.passwordChangedSuccessfully,
      passwordErrorMessage: clearPasswordError
          ? null
          : (passwordErrorMessage ?? this.passwordErrorMessage),
      passwordSuccessMessage: clearPasswordSuccess
          ? null
          : (passwordSuccessMessage ?? this.passwordSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        isUpdatingName,
        updatedName,
        successMessage,
        errorMessage,
        isChangingPassword,
        passwordChangedSuccessfully,
        passwordErrorMessage,
        passwordSuccessMessage,
      ];
}
