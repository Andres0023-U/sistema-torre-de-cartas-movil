import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
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
        final message = e.toString().replaceFirst('Exception: ', '');
        emit(AuthState(
          status: AuthStatus.failure,
          errorMessage: message,
        ));
      }
    });

    on<AuthLogoutRequested>((event, emit) {
      logoutUseCase();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
