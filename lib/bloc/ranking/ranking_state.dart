import 'package:equatable/equatable.dart';
import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';

class RankingState extends Equatable {
  final bool isGlobalLoading;
  final List<GlobalRankingEntryEntity> ranking;
  final String? globalError;
  final GlobalRankingEntryEntity? myRanking;

  final bool isTournamentsLoading;
  final List<TournamentEntity> tournaments;
  final String? tournamentsError;
  final int? selectedTournamentId;
  final bool isLocalRankingLoading;
  final TournamentRankingEntity? localRanking;
  final String? localRankingError;
  final bool isLocalForbidden;

  const RankingState({
    this.isGlobalLoading = true,
    this.ranking = const [],
    this.globalError,
    this.myRanking,
    this.isTournamentsLoading = true,
    this.tournaments = const [],
    this.tournamentsError,
    this.selectedTournamentId,
    this.isLocalRankingLoading = false,
    this.localRanking,
    this.localRankingError,
    this.isLocalForbidden = false,
  });

  bool isMyEntry({
    required int playerId,
    required String name,
    int? globalPosition,
    String? currentUserName,
  }) {
    final mine = myRanking;
    if (mine != null) {
      if (mine.playerId > 0 && playerId > 0) {
        return mine.playerId == playerId;
      }
      if (mine.name.trim().isNotEmpty && name.trim().isNotEmpty) {
        if (mine.name.trim().toLowerCase() == name.trim().toLowerCase()) {
          return true;
        }
      }
      if (globalPosition != null &&
          mine.position > 0 &&
          globalPosition > 0 &&
          mine.position == globalPosition) {
        return true;
      }
    }
    if (currentUserName != null &&
        currentUserName.trim().isNotEmpty &&
        name.trim().isNotEmpty) {
      return currentUserName.trim().toLowerCase() == name.trim().toLowerCase();
    }
    return false;
  }

  RankingState copyWith({
    bool? isGlobalLoading,
    List<GlobalRankingEntryEntity>? ranking,
    String? globalError,
    bool clearGlobalError = false,
    GlobalRankingEntryEntity? myRanking,
    bool clearMyRanking = false,
    bool? isTournamentsLoading,
    List<TournamentEntity>? tournaments,
    String? tournamentsError,
    bool clearTournamentsError = false,
    int? selectedTournamentId,
    bool clearSelectedTournament = false,
    bool? isLocalRankingLoading,
    TournamentRankingEntity? localRanking,
    bool clearLocalRanking = false,
    String? localRankingError,
    bool clearLocalRankingError = false,
    bool? isLocalForbidden,
  }) {
    return RankingState(
      isGlobalLoading: isGlobalLoading ?? this.isGlobalLoading,
      ranking: ranking ?? this.ranking,
      globalError: clearGlobalError ? null : (globalError ?? this.globalError),
      myRanking: clearMyRanking ? null : (myRanking ?? this.myRanking),
      isTournamentsLoading: isTournamentsLoading ?? this.isTournamentsLoading,
      tournaments: tournaments ?? this.tournaments,
      tournamentsError: clearTournamentsError
          ? null
          : (tournamentsError ?? this.tournamentsError),
      selectedTournamentId: clearSelectedTournament
          ? null
          : (selectedTournamentId ?? this.selectedTournamentId),
      isLocalRankingLoading:
          isLocalRankingLoading ?? this.isLocalRankingLoading,
      localRanking:
          clearLocalRanking ? null : (localRanking ?? this.localRanking),
      localRankingError: clearLocalRankingError
          ? null
          : (localRankingError ?? this.localRankingError),
      isLocalForbidden: isLocalForbidden ?? this.isLocalForbidden,
    );
  }

  @override
  List<Object?> get props => [
        isGlobalLoading,
        ranking,
        globalError,
        myRanking,
        isTournamentsLoading,
        tournaments,
        tournamentsError,
        selectedTournamentId,
        isLocalRankingLoading,
        localRanking,
        localRankingError,
        isLocalForbidden,
      ];
}
