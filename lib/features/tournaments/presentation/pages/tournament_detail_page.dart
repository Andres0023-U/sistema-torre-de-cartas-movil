import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/organizer_tournament_detail_view.dart';
import '../widgets/player_tournament_detail_view.dart';

class TournamentDetailPage extends StatelessWidget {
  final String tournamentId;

  const TournamentDetailPage({
    super.key,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthBloc>().state.role;

    Widget body;
    switch (role) {
      case UserRole.player:
        body = PlayerTournamentDetailView(tournamentId: tournamentId);
        break;
      case UserRole.organizer:
        body = OrganizerTournamentDetailView(
          tournamentId: tournamentId,
          readOnly: false,
        );
        break;
      case UserRole.admin:
        body = OrganizerTournamentDetailView(
          tournamentId: tournamentId,
          readOnly: true,
        );
        break;
      default:
        body = const Center(
          child: Text('Rol no autorizado'),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Torneo'),
      ),
      body: body,
    );
  }
}
