import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import '../utils/tournament_formatters.dart';

/// Cabecera + pestañas "Inscritos" y "Rondas" compartidas por las vistas
/// de jugador, organizador y admin.
class TournamentDetailContent extends StatelessWidget {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;
  final Future<void> Function() onRefresh;

  /// Widget opcional que se muestra al final de la pestaña "Rondas".
  final Widget? roundsFooter;

  /// Widget opcional que se muestra al inicio de la pestaña "Inscritos".
  final Widget? playersHeader;

  const TournamentDetailContent({
    super.key,
    required this.tournament,
    required this.players,
    required this.rounds,
    required this.onRefresh,
    this.roundsFooter,
    this.playersHeader,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildHeader(),
          const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.navy,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(text: 'Inscritos'),
              Tab(text: 'Rondas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPlayersTab(),
                _buildRoundsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final status = tournament.status;
    return Container(
      width: double.infinity,
      color: AppColors.parchment,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  tournament.name,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: tournamentStatusLabel(status),
                background: tournamentStatusColor(status),
                foreground: tournamentStatusTextColor(status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _InfoItem(
                icon: Icons.calendar_today,
                text: formatTournamentDate(tournament.date),
              ),
              _InfoItem(icon: Icons.style, text: tournament.format),
              _InfoItem(
                icon: Icons.people,
                text: 'Inscritos: ${players.length} de ${tournament.numPlayers}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersTab() {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (playersHeader != null) ...[
            playersHeader!,
            const SizedBox(height: 12),
          ],
          if (players.isEmpty)
            _buildEmptyMessage('Aún no hay jugadores inscritos')
          else
            for (final player in players)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: AppColors.parchment,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.line.withValues(alpha: 0.6),
                  ),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.navy,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    player.name,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildRoundsTab() {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (rounds.isEmpty)
            _buildEmptyMessage('El torneo aún no ha iniciado')
          else
            for (final round in rounds) _buildRoundCard(round),
          if (roundsFooter != null) ...[
            const SizedBox(height: 4),
            roundsFooter!,
          ],
        ],
      ),
    );
  }

  Widget _buildRoundCard(RoundEntity round) {
    final status = round.status;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                round.name,
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              _StatusChip(
                label: tournamentStatusLabel(
                  status,
                  finishedLabel: 'Finalizada',
                ),
                background: tournamentStatusColor(status),
                foreground: tournamentStatusTextColor(status),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      backgroundColor: background,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      side: BorderSide.none,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.sourceSans3(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}

