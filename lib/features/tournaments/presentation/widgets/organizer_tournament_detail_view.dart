import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/round_entity.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/entities/tournament_player_entity.dart';
import '../bloc/tournament_detail_bloc.dart';
import '../bloc/tournament_detail_event.dart';
import 'register_player_sheet.dart';
import 'tournament_detail_content.dart';

class OrganizerTournamentDetailView extends StatelessWidget {
  final TournamentEntity tournament;
  final List<TournamentPlayerEntity> players;
  final List<RoundEntity> rounds;
  final bool readOnly;
  final bool isStarting;
  final Future<void> Function() onRefresh;

  const OrganizerTournamentDetailView({
    super.key,
    required this.tournament,
    required this.players,
    required this.rounds,
    required this.readOnly,
    required this.onRefresh,
    this.isStarting = false,
  });

  Future<void> _confirmStart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Iniciar el torneo?'),
        content: const Text(
          'Se cerrarán las inscripciones y se creará la primera ronda. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TournamentDetailBloc>().add(const TournamentStartRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final isOwnerOrganizer = !readOnly &&
        auth.role == UserRole.organizer &&
        tournament.status == 'pending' &&
        auth.userId != null &&
        auth.userId == tournament.organizerId;
    final canStart = isOwnerOrganizer;
    final canRegister = isOwnerOrganizer && players.length < tournament.numPlayers;

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
        if (canStart)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                ),
                onPressed: isStarting ? null : () => _confirmStart(context),
                child: isStarting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      )
                    : const Text('Iniciar torneo'),
              ),
            ),
          ),
        Expanded(
          child: TournamentDetailContent(
            tournament: tournament,
            players: players,
            rounds: rounds,
            onRefresh: onRefresh,
            playersHeader: canRegister
                ? SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isStarting
                          ? null
                          : () => RegisterPlayerSheet.show(context),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Inscribir jugador'),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
