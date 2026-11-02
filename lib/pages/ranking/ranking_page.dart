import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torre_de_cartas_movil/bloc/auth/auth_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_event.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_state.dart';
import 'package:torre_de_cartas_movil/models/auth/user_role.dart';
import 'package:torre_de_cartas_movil/models/ranking/global_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/ranking/tournament_ranking_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/tournaments/tournament_entity.dart';
import 'package:torre_de_cartas_movil/services/core/tournament_formatters.dart';
import 'package:torre_de_cartas_movil/widgets/theme/app_colors.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _statusFilters = <String>[
    'Todos',
    'En curso',
    'Pendiente',
    'Finalizado',
  ];

  static const Map<String, String> _statusKeyByLabel = <String, String>{
    'Pendiente': 'pending',
    'En curso': 'in_progress',
    'Finalizado': 'finished',
  };

  static const List<String> _globalFiltersBase = <String>[
    'Todos',
    'Top 3',
    'Top 10',
  ];

  late final TabController _tabController;
  final TextEditingController _localSearchController = TextEditingController();
  final TextEditingController _globalSearchController = TextEditingController();

  String _selectedStatusFilter = 'Todos';
  String _localSearchQuery = '';

  String _selectedGlobalFilter = 'Todos';
  String _globalSearchQuery = '';

  bool get _isPlayer =>
      context.read<AuthBloc>().state.role == UserRole.player;

  String? get _currentUserName =>
      _isPlayer ? context.read<AuthBloc>().state.name : null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
    _loadInitialData();
  }

  void _loadInitialData() {
    final bloc = context.read<RankingBloc>();
    bloc.add(const LocalTournamentsRequested());
    bloc.add(
      RankingRequested(
        isPlayer: _isPlayer,
        currentUserName: _currentUserName,
      ),
    );
  }

  void _onTabChanged() {
    if (!mounted || _tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      final state = context.read<RankingBloc>().state;
      if (!state.isGlobalLoading &&
          (state.ranking.isEmpty || state.globalError != null)) {
        _refreshGlobal();
      }
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _localSearchController.dispose();
    _globalSearchController.dispose();
    super.dispose();
  }

  void _refreshGlobal() {
    context.read<RankingBloc>().add(
          RankingRequested(
            isPlayer: _isPlayer,
            currentUserName: _currentUserName,
          ),
        );
  }

  void _refreshLocal(RankingState state) {
    final bloc = context.read<RankingBloc>();
    if (state.tournaments.isEmpty || state.tournamentsError != null) {
      bloc.add(const LocalTournamentsRequested());
    } else if (state.selectedTournamentId != null) {
      bloc.add(LocalTournamentSelected(state.selectedTournamentId!));
    } else {
      bloc.add(const LocalTournamentsRequested());
    }
  }

  List<TournamentEntity> _filterTournaments(List<TournamentEntity> all) {
    var filtered = all;
    if (_selectedStatusFilter != 'Todos') {
      final targetStatus = _statusKeyByLabel[_selectedStatusFilter];
      filtered = filtered.where((t) => t.status == targetStatus).toList();
    }
    if (_localSearchQuery.isNotEmpty) {
      final q = _localSearchQuery.toLowerCase();
      filtered =
          filtered.where((t) => t.name.toLowerCase().contains(q)).toList();
    }
    return filtered;
  }

  List<GlobalRankingEntryEntity> _filterGlobalEntries(
    RankingState state,
    List<GlobalRankingEntryEntity> all,
  ) {
    var filtered = all;
    if (_selectedGlobalFilter == 'Top 3') {
      filtered = filtered
          .where((e) => e.position > 0 && e.position <= 3)
          .toList();
    } else if (_selectedGlobalFilter == 'Top 10') {
      filtered = filtered
          .where((e) => e.position > 0 && e.position <= 10)
          .toList();
    } else if (_selectedGlobalFilter == 'Mi posición') {
      filtered = filtered
          .where(
            (e) => state.isMyEntry(
              playerId: e.playerId,
              name: e.name,
              globalPosition: e.position,
              currentUserName: _currentUserName,
            ),
          )
          .toList();
    }

    if (_globalSearchQuery.isNotEmpty) {
      final q = _globalSearchQuery.toLowerCase();
      filtered =
          filtered.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    return filtered;
  }

  void _onFilterOrSearchChanged(
    List<TournamentEntity> allTournaments,
    int? currentSelectedId,
  ) {
    final filtered = _filterTournaments(allTournaments);
    if (filtered.isNotEmpty) {
      final stillPresent = currentSelectedId != null &&
          filtered.any((t) => t.tournamentId == currentSelectedId);
      if (!stillPresent) {
        context
            .read<RankingBloc>()
            .add(LocalTournamentSelected(filtered.first.tournamentId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Local'),
            Tab(text: 'Global'),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<RankingBloc, RankingState>(
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildLocalTab(state),
                _buildGlobalTab(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocalTab(RankingState state) {
    if (state.isTournamentsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    if (state.tournamentsError != null) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshLocal(state),
        child: _buildErrorView(
          icon: Icons.error_outline,
          message: state.tournamentsError!,
          onRetry: () => _refreshLocal(state),
        ),
      );
    }

    if (state.tournaments.isEmpty) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshLocal(state),
        child: Text(
          'No hay torneos disponibles',
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
      );
    }

    final filteredTournaments = _filterTournaments(state.tournaments);

    return Column(
      children: [
        _buildTournamentFilterPanel(state, filteredTournaments),
        Expanded(
          child: filteredTournaments.isEmpty
              ? _buildScrollableMessage(
                  onRefresh: () async => _refreshLocal(state),
                  child: Text(
                    'No hay torneos que coincidan con la búsqueda o el estado seleccionado',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),
                )
              : _buildLocalRankingContent(state),
        ),
      ],
    );
  }

  Widget _buildTournamentFilterPanel(
    RankingState state,
    List<TournamentEntity> filteredTournaments,
  ) {
    final selectedId = state.selectedTournamentId;
    final dropdownValue =
        filteredTournaments.any((t) => t.tournamentId == selectedId)
            ? selectedId
            : (filteredTournaments.isNotEmpty
                ? filteredTournaments.first.tournamentId
                : null);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        border: Border(
          bottom: BorderSide(
            color: AppColors.line.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _localSearchController,
            decoration: InputDecoration(
              hintText: 'Buscar torneo por nombre...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _localSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _localSearchController.clear();
                        setState(() {
                          _localSearchQuery = '';
                        });
                        _onFilterOrSearchChanged(
                          state.tournaments,
                          state.selectedTournamentId,
                        );
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _localSearchQuery = value.trim();
              });
              _onFilterOrSearchChanged(
                state.tournaments,
                state.selectedTournamentId,
              );
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((filter) {
                final isSelected = _selectedStatusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.ink,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.navy,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : AppColors.line,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    onSelected: (selected) {
                      if (selected && _selectedStatusFilter != filter) {
                        setState(() {
                          _selectedStatusFilter = filter;
                        });
                        _onFilterOrSearchChanged(
                          state.tournaments,
                          state.selectedTournamentId,
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          if (filteredTournaments.isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              key: ValueKey<int?>(dropdownValue),
              initialValue: dropdownValue,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.emoji_events_outlined,
                  size: 18,
                  color: AppColors.navy,
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
              items: filteredTournaments.map((t) {
                final statusLabel = tournamentStatusLabel(t.status);
                final statusBg = tournamentStatusColor(t.status);
                final statusFg = tournamentStatusTextColor(t.status);
                return DropdownMenuItem<int>(
                  value: t.tournamentId,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newId) {
                if (newId != null && newId != state.selectedTournamentId) {
                  context
                      .read<RankingBloc>()
                      .add(LocalTournamentSelected(newId));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalRankingContent(RankingState state) {
    if (state.isLocalRankingLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    if (state.localRankingError != null) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshLocal(state),
        child: _buildErrorView(
          icon: state.isLocalForbidden
              ? Icons.lock_outline
              : Icons.error_outline,
          message: state.localRankingError!,
          onRetry: () => _refreshLocal(state),
        ),
      );
    }

    final entries = state.localRanking?.ranking ?? const [];
    if (entries.isEmpty) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshLocal(state),
        child: Text(
          'Aún no hay partidas jugadas en este torneo',
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildScoreboardHeader(showLifeColumn: true),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => _refreshLocal(state),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isMine = state.isMyEntry(
                  playerId: entry.playerId,
                  name: entry.name,
                  currentUserName: _currentUserName,
                );
                return _buildTournamentTableRow(
                  entry,
                  index: index,
                  isMine: isMine,
                );
              },
            ),
          ),
        ),
        _buildScoreboardLegend(showLifeColumn: true),
      ],
    );
  }

  Widget _buildGlobalTab(RankingState state) {
    if (state.isGlobalLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    if (state.globalError != null) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshGlobal(),
        child: _buildErrorView(
          icon: Icons.error_outline,
          message: state.globalError!,
          onRetry: _refreshGlobal,
        ),
      );
    }

    if (state.ranking.isEmpty) {
      return _buildScrollableMessage(
        onRefresh: () async => _refreshGlobal(),
        child: Text(
          'Aún no hay partidas jugadas',
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
      );
    }

    final filteredGlobal = _filterGlobalEntries(state, state.ranking);

    return Column(
      children: [
        _buildGlobalFilterPanel(state),
        _buildScoreboardHeader(showLifeColumn: false),
        Expanded(
          child: filteredGlobal.isEmpty
              ? _buildScrollableMessage(
                  onRefresh: () async => _refreshGlobal(),
                  child: Text(
                    'No se encontraron jugadores con ese criterio en el ranking global',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async => _refreshGlobal(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredGlobal.length,
                    itemBuilder: (context, index) {
                      final entry = filteredGlobal[index];
                      final effectivePosition =
                          entry.position > 0 ? entry.position : index + 1;
                      final isMine = state.isMyEntry(
                        playerId: entry.playerId,
                        name: entry.name,
                        globalPosition: effectivePosition,
                        currentUserName: _currentUserName,
                      );
                      return _buildGlobalTableRow(
                        entry,
                        index: index,
                        effectivePosition: effectivePosition,
                        isMine: isMine,
                      );
                    },
                  ),
                ),
        ),
        _buildScoreboardLegend(showLifeColumn: false),
      ],
    );
  }

  Widget _buildGlobalFilterPanel(RankingState state) {
    final filters = <String>[
      ..._globalFiltersBase,
      if (_isPlayer) 'Mi posición',
    ];
    final myStats = _isPlayer ? state.myRanking : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        border: Border(
          bottom: BorderSide(
            color: AppColors.line.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (myStats != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      myStats.position > 0
                          ? 'Tu puesto global: #${myStats.position}'
                          : 'Tus estadísticas globales',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'PJ ${myStats.played} · PG ${myStats.won} · PP ${myStats.lost} · ${myStats.points} PTS',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _globalSearchController,
            decoration: InputDecoration(
              hintText: 'Buscar jugador por nombre...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _globalSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _globalSearchController.clear();
                        setState(() {
                          _globalSearchQuery = '';
                        });
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _globalSearchQuery = value.trim();
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = _selectedGlobalFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.ink,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.navy,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : AppColors.line,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    onSelected: (selected) {
                      if (selected && _selectedGlobalFilter != filter) {
                        setState(() {
                          _selectedGlobalFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardHeader({required bool showLifeColumn}) {
    final headerStyle = GoogleFonts.sourceSans3(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
      color: AppColors.gold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 2.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text('#', textAlign: TextAlign.center, style: headerStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('JUGADOR', style: headerStyle),
          ),
          SizedBox(
            width: 32,
            child: Text('PJ', textAlign: TextAlign.center, style: headerStyle),
          ),
          SizedBox(
            width: 32,
            child: Text('PG', textAlign: TextAlign.center, style: headerStyle),
          ),
          SizedBox(
            width: 32,
            child: Text('PP', textAlign: TextAlign.center, style: headerStyle),
          ),
          if (showLifeColumn)
            SizedBox(
              width: 44,
              child: Text(
                'VIDA',
                textAlign: TextAlign.center,
                style: headerStyle,
              ),
            ),
          SizedBox(
            width: 48,
            child: Text('PTS', textAlign: TextAlign.right, style: headerStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardLegend({required bool showLifeColumn}) {
    final legendText = showLifeColumn
        ? 'PJ: Jugadas · PG: Ganadas · PP: Perdidas · VIDA: Vida restante · PTS: Puntos'
        : 'PJ: Jugadas · PG: Ganadas · PP: Perdidas · PTS: Puntos';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        border: Border(
          top: BorderSide(color: AppColors.line.withValues(alpha: 0.7)),
        ),
      ),
      child: Text(
        legendText,
        textAlign: TextAlign.center,
        style: GoogleFonts.sourceSans3(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Widget _buildGlobalTableRow(
    GlobalRankingEntryEntity entry, {
    required int index,
    required int effectivePosition,
    required bool isMine,
  }) {
    return _buildScoreboardRowLayout(
      index: index,
      position: effectivePosition,
      name: entry.name,
      played: entry.played,
      won: entry.won,
      lost: entry.lost,
      points: entry.points,
      isMine: isMine,
    );
  }

  Widget _buildTournamentTableRow(
    TournamentRankingEntryEntity entry, {
    required int index,
    required bool isMine,
  }) {
    final effectivePosition = entry.position > 0 ? entry.position : index + 1;
    return _buildScoreboardRowLayout(
      index: index,
      position: effectivePosition,
      name: entry.name,
      played: entry.played,
      won: entry.won,
      lost: entry.lost,
      life: entry.life,
      eliminatedRound: entry.eliminatedRound,
      points: entry.points,
      isMine: isMine,
    );
  }

  Widget _buildScoreboardRowLayout({
    required int index,
    required int position,
    required String name,
    required int played,
    required int won,
    required int lost,
    int? life,
    int? eliminatedRound,
    required int points,
    required bool isMine,
  }) {
    final Color rowBg;
    if (isMine) {
      rowBg = AppColors.goldSoft.withValues(alpha: 0.65);
    } else if (position == 1) {
      rowBg = AppColors.goldSoft.withValues(alpha: 0.25);
    } else {
      rowBg = index.isEven ? Colors.white : AppColors.parchment;
    }

    final statStyle = GoogleFonts.sourceSans3(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(
          left: BorderSide(
            color: isMine
                ? AppColors.navy
                : (position == 1 ? AppColors.gold : Colors.transparent),
            width: 4,
          ),
          bottom: BorderSide(
            color: AppColors.line.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(child: _buildRankBadge(position)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          fontWeight:
                              isMine || position <= 3
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TÚ',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (eliminatedRound != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Eliminado en ronda $eliminatedRound',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$played',
              textAlign: TextAlign.center,
              style: statStyle,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$won',
              textAlign: TextAlign.center,
              style: statStyle.copyWith(color: const Color(0xFF2E7D32)),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$lost',
              textAlign: TextAlign.center,
              style: statStyle.copyWith(color: AppColors.error),
            ),
          ),
          if (life != null)
            SizedBox(
              width: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 12,
                    color: life > 0 ? AppColors.error : AppColors.muted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$life',
                    style: statStyle.copyWith(
                      color: life > 0 ? AppColors.ink : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$points',
                textAlign: TextAlign.right,
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int position) {
    Color bg;
    Color fg;
    if (position == 1) {
      bg = AppColors.gold;
      fg = AppColors.navy;
    } else if (position == 2) {
      bg = const Color(0xFFB0BEC5);
      fg = AppColors.navy;
    } else if (position == 3) {
      bg = const Color(0xFFCD7F32);
      fg = Colors.white;
    } else {
      bg = AppColors.navy.withValues(alpha: 0.12);
      fg = AppColors.navy;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: position <= 3
            ? Border.all(color: AppColors.navy.withValues(alpha: 0.25))
            : null,
      ),
      child: Center(
        child: Text(
          '$position',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableMessage({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView({
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 15,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
          ),
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}
