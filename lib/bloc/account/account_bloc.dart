import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_event.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(AccountInitialState()) {
    on<LoadAccountEvent>((event, emit) {
      // TODO: Implementar carga de cuenta
    });
  }
}
