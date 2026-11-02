import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_event.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_state.dart';
import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';
import 'package:torre_de_cartas_movil/repositories/ranking/ranking_repository_impl.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_my_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/ranking/get_tournament_ranking_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/tournaments/get_tournaments_usecase.dart';

class _AggregatedPlayerStats {
  final int playerId;
  String name;
  int played = 0;
  int won = 0;
  int lost = 0;
  int points = 0;

  _AggregatedPlayerStats({
    required this.playerId,
    required this.name,
  });
}

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final GetRankingUseCase getRankingUseCase;
  final GetMyRankingUseCase getMyRankingUseCase;
  final GetTournamentRankingUseCase getTournamentRankingUseCase;
  final GetTournamentsUseCase getTournamentsUseCase;

  RankingBloc({
    required this.getRankingUseCase,
    required this.getMyRankingUseCase,
    required this.getTournamentRankingUseCase,
    required this.getTournamentsUseCase,
  }) : super(const RankingState()) {
    on<RankingRequested>(_onRankingRequested);
    on<LocalTournamentsRequested>(_onLocalTournamentsRequested);
    on<LocalTournamentSelected>(_onLocalTournamentSelected);
  }

  Future<void> _onRankingRequested(
    RankingRequested event,
    Emitter<RankingState> emit,
  ) async {
    emit(state.copyWith(isGlobalLoading: true, clearGlobalError: true));

    List<GlobalRankingEntryEntity>? ranking;
    Object? primaryError;

    try {
      ranking = await getRankingUseCase();
    } catch (e) {
      primaryError = e;
    }

    // Si GET /ranking/ falla o agota el tiempo en el servidor, construimos el
    // ranking global agregando los rankings de los torneos disponibles.
    if (ranking == null) {
      try {
        ranking = await _buildGlobalRankingFromTournaments();
      } catch (_) {
        final message = primaryError
                ?.toString()
                .replaceAll('Exception: ', '') ??
            'No se pudo cargar el ranking global.';
        emit(
          state.copyWith(
            isGlobalLoading: false,
            globalError: message,
          ),
        );
        return;
      }
    }

    // Emitir el ranking global de inmediato para no bloquear la interfaz
    // esperando a GET /ranking/me.
    final fallbackMine = _findMyEntryInGlobal(
      ranking,
      currentUserName: event.currentUserName,
      currentMyRanking: state.myRanking,
    );

    emit(
      state.copyWith(
        isGlobalLoading: false,
        ranking: ranking,
        myRanking: event.isPlayer ? (state.myRanking ?? fallbackMine) : null,
        clearMyRanking: !event.isPlayer,
        clearGlobalError: true,
      ),
    );

    if (event.isPlayer) {
      final remoteMine = await getMyRankingUseCase();
      final resolvedMine = _mergeMyRanking(
        remoteMine: remoteMine,
        globalList: ranking,
        currentUserName: event.currentUserName,
      );
      emit(
        state.copyWith(
          myRanking: resolvedMine,
          clearMyRanking: resolvedMine == null,
        ),
      );
    }
  }

  GlobalRankingEntryEntity? _findMyEntryInGlobal(
    List<GlobalRankingEntryEntity> globalList, {
    String? currentUserName,
    GlobalRankingEntryEntity? currentMyRanking,
  }) {
    if (currentMyRanking != null && currentMyRanking.playerId > 0) {
      for (final entry in globalList) {
        if (entry.playerId == currentMyRanking.playerId) {
          return entry;
        }
      }
    }
    if (currentUserName != null && currentUserName.trim().isNotEmpty) {
      final target = currentUserName.trim().toLowerCase();
      for (final entry in globalList) {
        if (entry.name.trim().toLowerCase() == target) {
          return entry;
        }
      }
    }
    return null;
  }

  GlobalRankingEntryEntity? _mergeMyRanking({
    required GlobalRankingEntryEntity? remoteMine,
    required List<GlobalRankingEntryEntity> globalList,
    required String? currentUserName,
  }) {
    final fromList = _findMyEntryInGlobal(
      globalList,
      currentUserName: currentUserName,
      currentMyRanking: remoteMine,
    );
    if (remoteMine == null) {
      return fromList;
    }
    if (fromList == null) {
      return remoteMine;
    }
    return GlobalRankingEntryEntity(
      position:
          remoteMine.position > 0 ? remoteMine.position : fromList.position,
      playerId:
          remoteMine.playerId > 0 ? remoteMine.playerId : fromList.playerId,
      name: remoteMine.name.trim().isNotEmpty ? remoteMine.name : fromList.name,
      played: remoteMine.played > 0 ? remoteMine.played : fromList.played,
      won: remoteMine.won > 0 ? remoteMine.won : fromList.won,
      lost: remoteMine.lost > 0 ? remoteMine.lost : fromList.lost,
      points: remoteMine.points > 0 ? remoteMine.points : fromList.points,
      lastResultDate: remoteMine.lastResultDate ?? fromList.lastResultDate,
    );
  }

  Future<List<GlobalRankingEntryEntity>>
      _buildGlobalRankingFromTournaments() async {
    List<TournamentEntity> tournaments = state.tournaments;
    if (tournaments.isEmpty) {
      tournaments = await getTournamentsUseCase();
    }
    if (tournaments.isEmpty) {
      return const [];
    }

    final activeOrFinished =
        tournaments.where((t) => t.status != 'pending').toList();
    final candidates =
        activeOrFinished.isNotEmpty ? activeOrFinished : tournaments;

    final Map<String, _AggregatedPlayerStats> statsByKey = {};

    for (final tournament in candidates) {
      try {
        final tRanking = (state.selectedTournamentId ==
                    tournament.tournamentId &&
                state.localRanking != null)
            ? state.localRanking!
            : await getTournamentRankingUseCase(tournament.tournamentId);

        for (final entry in tRanking.ranking) {
          final key = entry.playerId > 0
              ? 'id:${entry.playerId}'
              : 'name:${entry.name.trim().toLowerCase()}';
          final agg = statsByKey.putIfAbsent(
            key,
            () => _AggregatedPlayerStats(
              playerId: entry.playerId,
              name: entry.name,
            ),
          );
          if (agg.name.isEmpty && entry.name.isNotEmpty) {
            agg.name = entry.name;
          }
          agg.played += entry.played;
          agg.won += entry.won;
          agg.lost += entry.lost;
          agg.points += entry.points;
        }
      } catch (_) {
        // Ignoramos torneos sin permiso (403) o con error puntual
      }
    }

    final list = statsByKey.values.toList();
    list.sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      if (byPoints != 0) return byPoints;
      final byWon = b.won.compareTo(a.won);
      if (byWon != 0) return byWon;
      final byLost = a.lost.compareTo(b.lost);
      if (byLost != 0) return byLost;
      final byPlayed = b.played.compareTo(a.played);
      if (byPlayed != 0) return byPlayed;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return List<GlobalRankingEntryEntity>.generate(list.length, (index) {
      final item = list[index];
      return GlobalRankingEntryEntity(
        position: index + 1,
        playerId: item.playerId,
        name: item.name,
        played: item.played,
        won: item.won,
        lost: item.lost,
        points: item.points,
      );
    });
  }

  Future<void> _onLocalTournamentsRequested(
    LocalTournamentsRequested event,
    Emitter<RankingState> emit,
  ) async {
    emit(
      state.copyWith(
        isTournamentsLoading: true,
        clearTournamentsError: true,
        clearLocalRankingError: true,
        isLocalForbidden: false,
      ),
    );
    try {
      final tournaments = await getTournamentsUseCase();
      if (tournaments.isEmpty) {
        emit(
          state.copyWith(
            isTournamentsLoading: false,
            tournaments: const [],
            clearSelectedTournament: true,
            clearLocalRanking: true,
            isLocalRankingLoading: false,
          ),
        );
        return;
      }

      final currentSelected = state.selectedTournamentId;
      final hasCurrent = currentSelected != null &&
          tournaments.any((t) => t.tournamentId == currentSelected);
      final targetId =
          hasCurrent ? currentSelected : tournaments.first.tournamentId;

      emit(
        state.copyWith(
          isTournamentsLoading: false,
          tournaments: tournaments,
          selectedTournamentId: targetId,
          isLocalRankingLoading: true,
          clearLocalRankingError: true,
          isLocalForbidden: false,
        ),
      );

      await _loadTournamentRanking(targetId, emit);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          isTournamentsLoading: false,
          tournamentsError: message,
          isLocalRankingLoading: false,
        ),
      );
    }
  }

  Future<void> _onLocalTournamentSelected(
    LocalTournamentSelected event,
    Emitter<RankingState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTournamentId: event.tournamentId,
        isLocalRankingLoading: true,
        clearLocalRankingError: true,
        isLocalForbidden: false,
      ),
    );
    await _loadTournamentRanking(event.tournamentId, emit);
  }

  Future<void> _loadTournamentRanking(
    int tournamentId,
    Emitter<RankingState> emit,
  ) async {
    try {
      final ranking = await getTournamentRankingUseCase(tournamentId);
      emit(
        state.copyWith(
          isLocalRankingLoading: false,
          localRanking: ranking,
          clearLocalRankingError: true,
          isLocalForbidden: false,
        ),
      );
    } on RankingForbiddenException catch (e) {
      emit(
        state.copyWith(
          isLocalRankingLoading: false,
          clearLocalRanking: true,
          localRankingError: e.message,
          isLocalForbidden: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(
        state.copyWith(
          isLocalRankingLoading: false,
          clearLocalRanking: true,
          localRankingError: message,
          isLocalForbidden: false,
        ),
      );
    }
  }
}
