import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_event.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_state.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/change_password_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/update_name_usecase.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UpdateNameUseCase updateNameUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  AccountBloc({
    required this.updateNameUseCase,
    required this.changePasswordUseCase,
  }) : super(const AccountState()) {
    on<LoadAccountEvent>((event, emit) {});
    on<ClearAccountErrorEvent>((event, emit) {
      if (state.errorMessage != null || state.successMessage != null) {
        emit(state.copyWith(clearError: true, clearSuccess: true));
      }
    });
    on<ClearPasswordStateEvent>((event, emit) {
      emit(
        state.copyWith(
          clearPasswordError: true,
          clearPasswordSuccess: true,
          passwordChangedSuccessfully: false,
        ),
      );
    });
    on<UpdateAccountNameRequested>(_onUpdateAccountNameRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onUpdateAccountNameRequested(
    UpdateAccountNameRequested event,
    Emitter<AccountState> emit,
  ) async {
    final trimmed = event.name.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          isUpdatingName: false,
          errorMessage: 'El nombre no puede estar vacío.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isUpdatingName: true,
        clearError: true,
        clearSuccess: true,
        clearUpdatedName: true,
      ),
    );

    try {
      final newName = await updateNameUseCase(trimmed);
      emit(
        state.copyWith(
          isUpdatingName: false,
          updatedName: newName,
          successMessage: 'Nombre actualizado correctamente',
          clearError: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          isUpdatingName: false,
          errorMessage: message,
          clearSuccess: true,
          clearUpdatedName: true,
        ),
      );
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AccountState> emit,
  ) async {
    final currentPassword = event.currentPassword.trim();
    final newPassword = event.newPassword.trim();

    if (currentPassword.isEmpty) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: 'Ingresa tu contraseña actual.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    if (newPassword.isEmpty) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: 'Ingresa la nueva contraseña.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: 'Debe tener al menos 8 caracteres.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(newPassword)) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: 'Debe incluir al menos una letra.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: 'Debe incluir al menos un número.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    if (currentPassword == newPassword) {
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage:
              'La nueva contraseña debe ser diferente a la actual.',
          passwordChangedSuccessfully: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isChangingPassword: true,
        clearPasswordError: true,
        clearPasswordSuccess: true,
        passwordChangedSuccessfully: false,
      ),
    );

    try {
      await changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: event.email,
      );
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordChangedSuccessfully: true,
          passwordSuccessMessage: 'Contraseña actualizada correctamente',
          clearPasswordError: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '').trim();
      emit(
        state.copyWith(
          isChangingPassword: false,
          passwordErrorMessage: message,
          passwordChangedSuccessfully: false,
          clearPasswordSuccess: true,
        ),
      );
    }
  }
}
