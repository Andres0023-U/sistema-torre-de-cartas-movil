import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/tournament_entity.dart';
import '../bloc/tournaments_bloc.dart';
import '../bloc/tournaments_event.dart';
import '../bloc/tournaments_state.dart';
import '../utils/tournament_formatters.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TournamentsBloc>().add(const TournamentsRequested());
  }

  /// Filtra la lista completa según búsqueda y chip seleccionado.
  List<TournamentEntity> _applyFilters(List<TournamentEntity> all) {
    var filtered = all;

    if (_selectedFilter != 'Todos') {
      final statusMap = {
        'Pendiente': 'pending',
        'En curso': 'in_progress',
        'Finalizado': 'finished',
      };
      final targetStatus = statusMap[_selectedFilter];
      filtered = filtered
          .where((t) => t.status == targetStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered =
          filtered.where((t) => t.name.toLowerCase().contains(q)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthBloc>().state.role;
    final isOrganizer = role == UserRole.organizer;
    final isAdmin = role == UserRole.admin;
    final canCreate = isOrganizer || isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneos'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear torneo',
              onPressed: () => context.push('/tournaments/create'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Botón "Crear torneo" para organizer/admin
            if (canCreate)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/tournaments/create'),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Crear torneo'),
                  ),
                ),
              ),

            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar torneo',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Chips de filtro
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Todos', 'Pendiente', 'En curso', 'Finalizado']
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Contenido principal
            Expanded(
              child: BlocBuilder<TournamentsBloc, TournamentsState>(
                builder: (context, state) {
                  if (state is TournamentsInitial ||
                      state is TournamentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    );
                  }

                  if (state is TournamentsFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
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
                              onPressed: () {
                                context
                                    .read<TournamentsBloc>()
                                    .add(const TournamentsRequested());
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TournamentsLoaded) {
                    final filtered = _applyFilters(state.tournaments);

                    if (state.tournaments.isEmpty) {
                      final emptyMsg = role == UserRole.player
                          ? 'Aún no estás inscrito en ningún torneo'
                          : 'Aún no hay torneos';
                      return RefreshIndicator(
                        color: AppColors.gold,
                        onRefresh: () async {
                          context
                              .read<TournamentsBloc>()
                              .add(const TournamentsRequested());
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Text(
                                  emptyMsg,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return RefreshIndicator(
                        color: AppColors.gold,
                        onRefresh: () async {
                          context
                              .read<TournamentsBloc>()
                              .add(const TournamentsRequested());
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Text(
                                  'No hay torneos que coincidan',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.gold,
                      onRefresh: () async {
                        context
                            .read<TournamentsBloc>()
                            .add(const TournamentsRequested());
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _TournamentCardItem(
                            tournament: filtered[index],
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentCardItem extends StatelessWidget {
  final TournamentEntity tournament;

  const _TournamentCardItem({required this.tournament});

  static final _titleStyle = GoogleFonts.sourceSans3(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static final _metaStyle = GoogleFonts.sourceSans3(
    fontSize: 13,
    color: AppColors.muted,
  );

  static final _chipStyleLight = GoogleFonts.sourceSans3(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final _chipStyleDark = GoogleFonts.sourceSans3(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
  );

  @override
  Widget build(BuildContext context) {
    final label = tournamentStatusLabel(tournament.status);
    final chipBg = tournamentStatusColor(tournament.status);
    final isDarkText = tournament.status == 'in_progress';
    final chipTextStyle = isDarkText ? _chipStyleDark : _chipStyleLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.line.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tournaments/${tournament.tournamentId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre + chip de estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: _titleStyle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: chipTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fecha, formato y jugadores
              Wrap(
                spacing: 16,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        formatTournamentDate(tournament.date),
                        style: _metaStyle,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.style, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        tournament.format,
                        style: _metaStyle,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.numPlayers} jugadores',
                        style: _metaStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
