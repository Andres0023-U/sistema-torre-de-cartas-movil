import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthCheckRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });

    on<AuthLoginSubmitted>((event, emit) {
      emit(AuthState(
        status: AuthStatus.authenticated,
        role: event.role,
      ));
    });

    on<AuthLogoutRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
