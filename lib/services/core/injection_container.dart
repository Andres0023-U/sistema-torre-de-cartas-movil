import 'package:get_it/get_it.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/admin/admin_bloc.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository_impl.dart';
import 'package:torre_de_cartas_movil/services/api/account_remote_data_source.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/change_password_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/update_name_usecase.dart';
import 'package:torre_de_cartas_movil/services/api/auth_remote_data_source.dart';
import 'package:torre_de_cartas_movil/repositories/auth/auth_repository_impl.dart';
import 'package:torre_de_cartas_movil/repositories/auth/auth_repository.dart';
import 'package:torre_de_cartas_movil/services/usecases/auth/login_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/auth/logout_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/auth/restore_session_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_bloc.dart';
import 'package:torre_de_cartas_movil/services/api/deck_remote_data_source.dart';
import 'package:torre_de_cartas_movil/repositories/decks/deck_repository_impl.dart';
import 'package:torre_de_cartas_movil/repositories/decks/deck_repository.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/add_card_to_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/create_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_cards_catalog_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_deck_by_id_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_deck_cards_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/get_decks_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/remove_card_from_deck_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/decks/update_card_quantity_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/decks/deck_detail_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/decks/decks_bloc.dart';
import 'package:torre_de_cartas_movil/services/api/ranking_remote_data_source.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository_impl.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_my_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_tournament_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_bloc.dart';
import 'package:torre_de_cartas_movil/services/api/tournament_remote_data_source.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository_impl.dart';
import 'package:torre_de_cartas_movil/repositories/tournaments/tournament_repository.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/create_tournament_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/get_available_players_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/register_player_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/get_tournament_players_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/get_tournament_rounds_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/get_tournaments_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/start_tournament_usecase.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/create_tournament_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/tournament_detail_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/tournaments_bloc.dart';
import 'package:torre_de_cartas_movil/services/core/dio_client.dart';
import 'package:torre_de_cartas_movil/services/core/token_holder.dart';
import 'package:torre_de_cartas_movil/services/core/session_storage.dart';

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
  sl.registerLazySingleton<GetMyRankingUseCase>(
    () => GetMyRankingUseCase(repository: sl<RankingRepository>()),
  );
  sl.registerLazySingleton<GetTournamentRankingUseCase>(
    () => GetTournamentRankingUseCase(repository: sl<RankingRepository>()),
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

  // Account data & domain
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl<AccountRemoteDataSource>()),
  );
  sl.registerLazySingleton<UpdateNameUseCase>(
    () => UpdateNameUseCase(repository: sl<AccountRepository>()),
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
    () => RankingBloc(
      getRankingUseCase: sl<GetRankingUseCase>(),
      getMyRankingUseCase: sl<GetMyRankingUseCase>(),
      getTournamentRankingUseCase: sl<GetTournamentRankingUseCase>(),
      getTournamentsUseCase: sl<GetTournamentsUseCase>(),
    ),
  );
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(repository: sl<AccountRepository>()),
  );
  sl.registerFactory<AccountBloc>(
    () => AccountBloc(
      updateNameUseCase: sl<UpdateNameUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
    ),
  );
  sl.registerFactory<AdminBloc>(() => AdminBloc());
}
