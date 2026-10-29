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
import '../../features/decks/data/datasources/deck_remote_data_source.dart';
import '../../features/decks/data/repositories/deck_repository_impl.dart';
import '../../features/decks/domain/repositories/deck_repository.dart';
import '../../features/decks/domain/usecases/add_card_to_deck_usecase.dart';
import '../../features/decks/domain/usecases/create_deck_usecase.dart';
import '../../features/decks/domain/usecases/get_cards_catalog_usecase.dart';
import '../../features/decks/domain/usecases/get_deck_by_id_usecase.dart';
import '../../features/decks/domain/usecases/get_deck_cards_usecase.dart';
import '../../features/decks/domain/usecases/get_decks_usecase.dart';
import '../../features/decks/domain/usecases/remove_card_from_deck_usecase.dart';
import '../../features/decks/domain/usecases/update_card_quantity_usecase.dart';
import '../../features/decks/presentation/bloc/deck_detail_bloc.dart';
import '../../features/decks/presentation/bloc/decks_bloc.dart';
import '../../features/ranking/data/datasources/ranking_remote_data_source.dart';
import '../../features/ranking/data/repositories/ranking_repository_impl.dart';
import '../../features/ranking/domain/repositories/ranking_repository.dart';
import '../../features/ranking/domain/usecases/get_ranking_usecase.dart';
import '../../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../../features/tournaments/data/datasources/tournament_remote_data_source.dart';
import '../../features/tournaments/data/repositories/tournament_repository_impl.dart';
import '../../features/tournaments/domain/repositories/tournament_repository.dart';
import '../../features/tournaments/domain/usecases/create_tournament_usecase.dart';
import '../../features/tournaments/domain/usecases/get_available_players_usecase.dart';
import '../../features/tournaments/domain/usecases/register_player_usecase.dart';
import '../../features/tournaments/domain/usecases/get_tournament_players_usecase.dart';
import '../../features/tournaments/domain/usecases/get_tournament_rounds_usecase.dart';
import '../../features/tournaments/domain/usecases/get_tournaments_usecase.dart';
import '../../features/tournaments/domain/usecases/start_tournament_usecase.dart';
import '../../features/tournaments/presentation/bloc/create_tournament_bloc.dart';
import '../../features/tournaments/presentation/bloc/tournament_detail_bloc.dart';
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

  // Ranking data & domain
  sl.registerLazySingleton<RankingRemoteDataSource>(
    () => RankingRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<RankingRepository>(
    () => RankingRepositoryImpl(remoteDataSource: sl<RankingRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetRankingUseCase>(
    () => GetRankingUseCase(repository: sl<RankingRepository>()),
  );

  // Tournaments data & domain
  sl.registerLazySingleton<TournamentRemoteDataSource>(
    () => TournamentRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<TournamentRepository>(
    () => TournamentRepositoryImpl(
        remoteDataSource: sl<TournamentRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetTournamentsUseCase>(
    () => GetTournamentsUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<GetTournamentPlayersUseCase>(
    () => GetTournamentPlayersUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<GetTournamentRoundsUseCase>(
    () => GetTournamentRoundsUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<StartTournamentUseCase>(
    () => StartTournamentUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<CreateTournamentUseCase>(
    () => CreateTournamentUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<GetAvailablePlayersUseCase>(
    () => GetAvailablePlayersUseCase(repository: sl<TournamentRepository>()),
  );
  sl.registerLazySingleton<RegisterPlayerUseCase>(
    () => RegisterPlayerUseCase(repository: sl<TournamentRepository>()),
  );

  // Decks data & domain
  sl.registerLazySingleton<DeckRemoteDataSource>(
    () => DeckRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(remoteDataSource: sl<DeckRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetDecksUseCase>(
    () => GetDecksUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<CreateDeckUseCase>(
    () => CreateDeckUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<GetDeckByIdUseCase>(
    () => GetDeckByIdUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<GetDeckCardsUseCase>(
    () => GetDeckCardsUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<GetCardsCatalogUseCase>(
    () => GetCardsCatalogUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<AddCardToDeckUseCase>(
    () => AddCardToDeckUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<UpdateCardQuantityUseCase>(
    () => UpdateCardQuantityUseCase(repository: sl<DeckRepository>()),
  );
  sl.registerLazySingleton<RemoveCardFromDeckUseCase>(
    () => RemoveCardFromDeckUseCase(repository: sl<DeckRepository>()),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      restoreSessionUseCase: sl<RestoreSessionUseCase>(),
    ),
  );

  sl.registerFactory<TournamentsBloc>(
    () => TournamentsBloc(getTournamentsUseCase: sl<GetTournamentsUseCase>()),
  );
  sl.registerFactory<TournamentDetailBloc>(
    () => TournamentDetailBloc(
      getTournamentsUseCase: sl<GetTournamentsUseCase>(),
      getTournamentPlayersUseCase: sl<GetTournamentPlayersUseCase>(),
      getTournamentRoundsUseCase: sl<GetTournamentRoundsUseCase>(),
      startTournamentUseCase: sl<StartTournamentUseCase>(),
      getAvailablePlayersUseCase: sl<GetAvailablePlayersUseCase>(),
      registerPlayerUseCase: sl<RegisterPlayerUseCase>(),
    ),
  );
  sl.registerFactory<CreateTournamentBloc>(
    () => CreateTournamentBloc(
      createTournamentUseCase: sl<CreateTournamentUseCase>(),
    ),
  );
  sl.registerFactory<DecksBloc>(
    () => DecksBloc(
      getDecksUseCase: sl<GetDecksUseCase>(),
      createDeckUseCase: sl<CreateDeckUseCase>(),
    ),
  );
  sl.registerFactory<DeckDetailBloc>(
    () => DeckDetailBloc(
      getDeckByIdUseCase: sl<GetDeckByIdUseCase>(),
      getDeckCardsUseCase: sl<GetDeckCardsUseCase>(),
      getCardsCatalogUseCase: sl<GetCardsCatalogUseCase>(),
      addCardToDeckUseCase: sl<AddCardToDeckUseCase>(),
      updateCardQuantityUseCase: sl<UpdateCardQuantityUseCase>(),
      removeCardFromDeckUseCase: sl<RemoveCardFromDeckUseCase>(),
    ),
  );
  sl.registerFactory<RankingBloc>(
    () => RankingBloc(getRankingUseCase: sl<GetRankingUseCase>()),
  );
  sl.registerFactory<AccountBloc>(() => AccountBloc());
  sl.registerFactory<AdminBloc>(() => AdminBloc());
}
