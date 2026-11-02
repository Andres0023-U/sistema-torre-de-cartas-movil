import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torre_de_cartas_movil/bloc/account/account_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_event.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_state.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_bloc.dart';
import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';
import 'package:torre_de_cartas_movil/services/core/injection_container.dart';
import 'package:torre_de_cartas_movil/widgets/account/spider_chart_widget.dart';
import 'package:torre_de_cartas_movil/widgets/theme/app_colors.dart';

class PlayerStatsPage extends StatefulWidget {
  const PlayerStatsPage({super.key});

  @override
  State<PlayerStatsPage> createState() => _PlayerStatsPageState();
}

class _PlayerStatsPageState extends State<PlayerStatsPage> {
  late final AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    final authEmail = context.read<AuthBloc>().state.email;
    _accountBloc = sl<AccountBloc>()
      ..add(LoadPlayerStatsEvent(email: authEmail));
  }

  @override
  void dispose() {
    _accountBloc.close();
    super.dispose();
  }

  List<SpiderChartAxis> _buildSpiderAxes(MyStatsEntity stats) {
    final played = stats.played;
    final won = stats.won;
    final lost = stats.lost;
    final points = stats.points;
    final tournamentsWon = stats.tournamentsWon;

    // 1. Tasa de victorias (0% a 100%)
    final winRate = played > 0 ? (won / played) : 0.0;

    // 2. Efectividad en puntos (media normalizada, 2.5 pts = 100%)
    final pointsRatio = played > 0
        ? ((points / (played * 2.5)).clamp(0.12, 1.0))
        : (points > 0 ? 0.3 : 0.1);

    // 3. Torneos ganados (1 = 65%, 2+ = 100%)
    final tournamentRatio = tournamentsWon >= 2
        ? 1.0
        : (tournamentsWon == 1 ? 0.65 : 0.15);

    // 4. Supervivencia (% de no derrotas)
    final survivalRatio =
        played > 0 ? ((1.0 - (lost / played)).clamp(0.12, 1.0)) : 0.2;

    // 5. Experiencia (partidas jugadas respecto a 15)
    final expRatio = (played / 15.0).clamp(0.15, 1.0);

    return [
      SpiderChartAxis(
        label: 'Victorias',
        value: winRate,
        displayValue: '${(winRate * 100).toStringAsFixed(0)}%',
      ),
      SpiderChartAxis(
        label: 'Puntuación',
        value: pointsRatio,
        displayValue: '$points pts',
      ),
      SpiderChartAxis(
        label: 'Torneos',
        value: tournamentRatio,
        displayValue: '$tournamentsWon ganados',
      ),
      SpiderChartAxis(
        label: 'Supervivencia',
        value: survivalRatio,
        displayValue: '${(survivalRatio * 100).toStringAsFixed(0)}%',
      ),
      SpiderChartAxis(
        label: 'Experiencia',
        value: expRatio,
        displayValue: '$played PJ',
      ),
    ];
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.sourceSans3(
                fontSize: 11.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HistoryEntryEntity h) {
    final formattedDate =
        h.date.length >= 10 ? h.date.substring(0, 10) : h.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: h.won
                  ? Colors.green.withValues(alpha: 0.12)
                  : AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              h.won ? Icons.emoji_events : Icons.close,
              size: 20,
              color: h.won ? Colors.green[800] : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.tournamentName.isNotEmpty ? h.tournamentName : 'Torneo',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'vs ${h.opponentName ?? 'Rival'} · ${h.roundName}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: h.won
                      ? Colors.green.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  h.won ? 'Victoria' : 'Derrota',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: h.won ? Colors.green[800] : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${h.points} pts',
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas del Jugador'),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        bloc: _accountBloc,
        builder: (context, state) {
          if (state.isLoadingStats && state.stats == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Cargando estadísticas de combate...',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          if (state.statsErrorMessage != null && state.stats == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.statsErrorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final authEmail = context.read<AuthBloc>().state.email;
                        _accountBloc
                            .add(LoadPlayerStatsEvent(email: authEmail));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = state.stats ??
              const MyStatsEntity(
                playerId: 0,
                played: 0,
                won: 0,
                lost: 0,
                points: 0,
                tournamentsWon: 0,
              );

          final spiderAxes = _buildSpiderAxes(stats);

          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.navy,
            onRefresh: () async {
              final authEmail = context.read<AuthBloc>().state.email;
              _accountBloc.add(LoadPlayerStatsEvent(email: authEmail));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grilla de métricas clave 2x2
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          label: 'Posición Global',
                          value: stats.position != null
                              ? '#${stats.position}'
                              : '—',
                          subtitle: 'Ranking oficial',
                          icon: Icons.leaderboard,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          label: 'Puntos Totales',
                          value: '${stats.points}',
                          subtitle: 'Acumulados',
                          icon: Icons.stars,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          label: 'Partidas',
                          value: '${stats.played}',
                          subtitle: '${stats.won}V · ${stats.lost}D',
                          icon: Icons.style,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          label: 'Torneos Ganados',
                          value: '${stats.tournamentsWon}',
                          subtitle: 'Campeonatos',
                          icon: Icons.emoji_events,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta con el Gráfico de Araña
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.parchment,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Gráfico de Habilidades',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Equilibrio y destreza en el campo de batalla',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SpiderChartWidget(
                          axes: spiderAxes,
                          size: 300,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Historial de Partidas
                  Row(
                    children: [
                      const Icon(Icons.history, color: AppColors.navy, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Historial de Partidas',
                        style: GoogleFonts.cinzel(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.history.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Center(
                        child: Text(
                          'Aún no tienes partidas con resultado registrado.',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.history.map(_buildHistoryItem),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

