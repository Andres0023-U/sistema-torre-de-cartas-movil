import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import 'tournament_detail_content.dart';

class OrganizerTournamentDetailView extends StatelessWidget {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;
  final bool readOnly;
  final Future<void> Function() onRefresh;

  const OrganizerTournamentDetailView({
    super.key,
    required this.tournament,
    required this.players,
    required this.rounds,
    required this.readOnly,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (readOnly)
          Container(
            color: AppColors.goldSoft,
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            child: const Text(
              'Vista de consulta: solo el organizador gestiona rondas y resultados.',
              style: TextStyle(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: TournamentDetailContent(
            tournament: tournament,
            players: players,
            rounds: rounds,
            onRefresh: onRefresh,
          ),
        ),
      ],
    );
  }
}
