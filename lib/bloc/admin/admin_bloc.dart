import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/admin/admin_event.dart';
import 'package:torre_de_cartas_movil/bloc/admin/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitialState()) {
    on<LoadAdminEvent>((event, emit) {
      // TODO: Implementar gestión de usuarios y roles
    });
  }
}
