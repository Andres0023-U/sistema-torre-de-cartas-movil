import 'package:get_it/get_it.dart';
import '../../features/account/presentation/bloc/account_bloc.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/decks/presentation/bloc/decks_bloc.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../features/tournaments/presentation/bloc/tournaments_bloc.dart';
import '../network/dio_client.dart';
import '../network/token_holder.dart';
import '../storage/session_storage.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerLazySingleton<TokenHolder>(() => TokenHolder());
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage());
  sl.registerLazySingleton<DioClient>(
    () => DioClient(tokenHolder: sl<TokenHolder>()),
  );

  // Auth data & domain
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      repository: sl<AuthRepository>(),
      tokenHolder: sl<TokenHolder>(),
      sessionStorage: sl<SessionStorage>(),
    ),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      tokenHolder: sl<TokenHolder>(),
      sessionStorage: sl<SessionStorage>(),
    ),
  );
  sl.registerLazySingleton<RestoreSessionUseCase>(
    () => RestoreSessionUseCase(
      repository: sl<AuthRepository>(),
      tokenHolder: sl<TokenHolder>(),
      sessionStorage: sl<SessionStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      restoreSessionUseCase: sl<RestoreSessionUseCase>(),
    ),
  );

  sl.registerFactory<TournamentsBloc>(() => TournamentsBloc());
  sl.registerFactory<DecksBloc>(() => DecksBloc());
  sl.registerFactory<RankingBloc>(() => RankingBloc());
  sl.registerFactory<AccountBloc>(() => AccountBloc());
  sl.registerFactory<AdminBloc>(() => AdminBloc());
}
