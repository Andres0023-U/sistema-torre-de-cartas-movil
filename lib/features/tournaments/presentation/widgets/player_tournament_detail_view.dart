import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import 'tournament_detail_content.dart';

class PlayerTournamentDetailView extends StatelessWidget {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;
  final Future<void> Function() onRefresh;

  const PlayerTournamentDetailView({
    super.key,
    required this.tournament,
    required this.players,
    required this.rounds,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return TournamentDetailContent(
      tournament: tournament,
      players: players,
      rounds: rounds,
      onRefresh: onRefresh,
      roundsFooter: _buildPointsCard(),
    );
  }

  // Sección fija "Puntos por partida"
  Widget _buildPointsCard() {
    final bodyStyle = GoogleFonts.sourceSans3(
      fontSize: 14,
      color: AppColors.ink,
    );
    return Card(
      color: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puntos por partida',
              style: GoogleFonts.sourceSans3(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text('Victoria en tiempo normal: 3 pts.', style: bodyStyle),
            const SizedBox(height: 4),
            Text(
              'Victoria en presión por tiempo con vida mayor a 0: 2 pts.',
              style: bodyStyle,
            ),
            const SizedBox(height: 4),
            Text(
              'Victoria en presión por tiempo con vida de 0 o menos: 1 pt.',
              style: bodyStyle,
            ),
            const SizedBox(height: 4),
            Text('Derrota: 0 pts.', style: bodyStyle),
          ],
        ),
      ),
    );
  }
}
