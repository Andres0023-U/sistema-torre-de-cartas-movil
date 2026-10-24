import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitialState()) {
    on<LoadAdminEvent>((event, emit) {
      // TODO: Implementar gestión de usuarios y roles
    });
  }
}
