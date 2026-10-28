import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>((event, emit) async {
      try {
        final user = await restoreSessionUseCase();
        if (user == null) {
          emit(const AuthState(status: AuthStatus.unauthenticated));
        } else {
          emit(AuthState(
            status: AuthStatus.authenticated,
            role: user.role,
            name: user.name,
            email: user.email,
          ));
        }
      } on AuthExpiredException catch (_) {
        await logoutUseCase();
        emit(const AuthState(
          status: AuthStatus.failure,
          errorMessage: "Tu sesión expiró. Inicia sesión de nuevo.",
        ));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(AuthState(
          status: AuthStatus.failure,
          errorMessage: message,
        ));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.loading));
      try {
        final user = await loginUseCase(event.email, event.password);
        emit(AuthState(
          status: AuthStatus.authenticated,
          role: user.role,
          name: user.name,
          email: user.email,
        ));
      } catch (e) {
        final message = e.toString().replaceAll('Exception: ', '');
        emit(AuthState(
          status: AuthStatus.failure,
          errorMessage: message,
        ));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await logoutUseCase();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
