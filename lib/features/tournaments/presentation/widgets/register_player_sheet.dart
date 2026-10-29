import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_with_user_entity.dart';
import '../bloc/tournament_detail_bloc.dart';
import '../bloc/tournament_detail_event.dart';
import '../bloc/tournament_detail_state.dart';

/// Hoja inferior para inscribir un jugador en el torneo.
/// Requiere un [TournamentDetailBloc] disponible en el contexto.
class RegisterPlayerSheet extends StatefulWidget {
  const RegisterPlayerSheet({super.key});

  /// Abre la hoja y pide los jugadores disponibles.
  static Future<void> show(BuildContext context) {
    final bloc = context.read<TournamentDetailBloc>();
    bloc.add(const AvailablePlayersRequested());
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.parchment,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider<TournamentDetailBloc>.value(
        value: bloc,
        child: const RegisterPlayerSheet(),
      ),
    );
  }

  @override
  State<RegisterPlayerSheet> createState() => _RegisterPlayerSheetState();
}

class _RegisterPlayerSheetState extends State<RegisterPlayerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: height,
        // El Scaffold propio permite que los SnackBar se vean sobre la hoja.
        child: Scaffold(
          backgroundColor: AppColors.parchment,
          body: SafeArea(
            child: BlocConsumer<TournamentDetailBloc, TournamentDetailState>(
              listenWhen: (previous, current) =>
                  current is TournamentDetailLoaded &&
                  current.successMessage != null,
              listener: (context, state) {
                Navigator.of(context).pop();
              },
              builder: (context, state) {
                if (state is! TournamentDetailLoaded) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Inscribir jugador',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre o correo',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _query = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildBody(context, state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.sourceSans3(fontSize: 16, color: AppColors.muted),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TournamentDetailLoaded state) {
    final error = state.availablePlayersError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                error,
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
                onPressed: () => context
                    .read<TournamentDetailBloc>()
                    .add(const AvailablePlayersRequested()),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final available = state.availablePlayers;
    if (state.isLoadingAvailablePlayers || available == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    // Se excluyen los ya inscritos usando la lista que el detalle ya tiene.
    final registeredIds = state.players.map((p) => p.playerId).toSet();
    final notRegistered =
        available.where((p) => !registeredIds.contains(p.playerId)).toList();

    if (notRegistered.isEmpty) {
      return _buildMessage('No hay jugadores disponibles para inscribir');
    }

    final filtered = _query.isEmpty
        ? notRegistered
        : notRegistered
            .where((p) =>
                p.name.toLowerCase().contains(_query) ||
                p.email.toLowerCase().contains(_query))
            .toList();

    if (filtered.isEmpty) {
      return _buildMessage('No hay jugadores que coincidan');
    }

    final busy = state.registeringPlayerId != null;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final player = filtered[index];
        return _buildPlayerRow(context, player, state, busy);
      },
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    PlayerWithUserEntity player,
    TournamentDetailLoaded state,
    bool busy,
  ) {
    final isThisOne = state.registeringPlayerId == player.playerId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        enabled: !busy,
        title: Text(
          player.name,
          style: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        subtitle: Text(
          player.email,
          style: GoogleFonts.sourceSans3(fontSize: 13, color: AppColors.muted),
        ),
        trailing: isThisOne
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              )
            : null,
        onTap: busy
            ? null
            : () => context
                .read<TournamentDetailBloc>()
                .add(PlayerRegistrationRequested(player)),
      ),
    );
  }
}

