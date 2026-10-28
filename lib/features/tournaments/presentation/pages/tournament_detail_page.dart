import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/tournament_detail_bloc.dart';
import '../bloc/tournament_detail_event.dart';
import '../bloc/tournament_detail_state.dart';
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
    return BlocProvider<TournamentDetailBloc>(
      create: (_) => sl<TournamentDetailBloc>(),
      child: _TournamentDetailBody(tournamentId: tournamentId),
    );
  }
}

class _TournamentDetailBody extends StatefulWidget {
  final String tournamentId;

  const _TournamentDetailBody({required this.tournamentId});

  @override
  State<_TournamentDetailBody> createState() => _TournamentDetailBodyState();
}

class _TournamentDetailBodyState extends State<_TournamentDetailBody> {
  int? get _id => int.tryParse(widget.tournamentId);

  @override
  void initState() {
    super.initState();
    _request();
  }

  void _request() {
    final id = _id;
    if (id != null) {
      context.read<TournamentDetailBloc>().add(TournamentDetailRequested(id));
    }
  }

  Future<void> _refresh() async {
    _request();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthBloc>().state.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Torneo'),
      ),
      body: SafeArea(
        child: _id == null
            ? _buildMessage('No se encontró el torneo')
            : BlocListener<TournamentDetailBloc, TournamentDetailState>(
                listenWhen: (previous, current) =>
                    current is TournamentDetailLoaded &&
                    previous != current &&
                    (current.successMessage != null ||
                        current.errorMessage != null),
                listener: (context, state) {
                  if (state is! TournamentDetailLoaded) return;
                  final isError = state.errorMessage != null;
                  final message = state.errorMessage ?? state.successMessage!;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor:
                            isError ? AppColors.error : AppColors.navy,
                      ),
                    );
                },
                child: BlocBuilder<TournamentDetailBloc, TournamentDetailState>(
                builder: (context, state) {
                  if (state is TournamentDetailInitial ||
                      state is TournamentDetailLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    );
                  }

                  if (state is TournamentDetailFailure) {
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
                              onPressed: _request,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is TournamentDetailLoaded) {
                    switch (role) {
                      case UserRole.player:
                        return PlayerTournamentDetailView(
                          tournament: state.tournament,
                          players: state.players,
                          rounds: state.rounds,
                          onRefresh: _refresh,
                        );
                      case UserRole.organizer:
                        return OrganizerTournamentDetailView(
                          tournament: state.tournament,
                          players: state.players,
                          rounds: state.rounds,
                          readOnly: false,
                          isStarting: state.isStarting,
                          onRefresh: _refresh,
                        );
                      case UserRole.admin:
                        return OrganizerTournamentDetailView(
                          tournament: state.tournament,
                          players: state.players,
                          rounds: state.rounds,
                          readOnly: true,
                          onRefresh: _refresh,
                        );
                      default:
                        return _buildMessage('Rol no autorizado');
                    }
                  }

                  return const SizedBox.shrink();
                },
              ),
              ),
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.sourceSans3(fontSize: 16, color: AppColors.muted),
      ),
    );
  }
}
