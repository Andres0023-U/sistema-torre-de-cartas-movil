import 'package:get_it/get_it.dart';
import '../../features/account/presentation/bloc/account_bloc.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/decks/presentation/bloc/decks_bloc.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../features/tournaments/presentation/bloc/tournaments_bloc.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc());

  sl.registerFactory<TournamentsBloc>(() => TournamentsBloc());
  sl.registerFactory<DecksBloc>(() => DecksBloc());
  sl.registerFactory<RankingBloc>(() => RankingBloc());
  sl.registerFactory<AccountBloc>(() => AccountBloc());
  sl.registerFactory<AdminBloc>(() => AdminBloc());
}
