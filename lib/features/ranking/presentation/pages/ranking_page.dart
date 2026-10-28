import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/global_ranking_entry_entity.dart';
import '../bloc/ranking_bloc.dart';
import '../bloc/ranking_event.dart';
import '../bloc/ranking_state.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  void initState() {
    super.initState();
    context.read<RankingBloc>().add(RankingRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ranking global'),
          bottom: TabBar(
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
          child: TabBarView(
            children: [
              Center(
                child: Text(
                  'Próximamente',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    color: AppColors.muted,
                  ),
                ),
              ),
              BlocBuilder<RankingBloc, RankingState>(
                builder: (context, state) {
                  if (state is RankingLoading || state is RankingInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      ),
                    );
                  }

                  if (state is RankingFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
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
                                context.read<RankingBloc>().add(RankingRequested());
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is RankingLoaded) {
                    if (state.ranking.isEmpty) {
                      return Center(
                        child: Text(
                          'Aún no hay partidas jugadas',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            color: AppColors.muted,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.gold,
                      onRefresh: () async {
                        context.read<RankingBloc>().add(RankingRequested());
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.ranking.length,
                        itemBuilder: (context, index) {
                          final entry = state.ranking[index];
                          return _buildRankingCard(entry);
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingCard(GlobalRankingEntryEntity entry) {
    final bool isFirst = entry.position == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFirst
              ? AppColors.gold
              : AppColors.line.withValues(alpha: 0.5),
          width: isFirst ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFirst ? AppColors.gold : AppColors.navy,
              ),
              child: Center(
                child: Text(
                  '${entry.position}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isFirst ? AppColors.navy : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jugadas ${entry.played} · Ganadas ${entry.won} · Perdidas ${entry.lost}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.points}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  'pts',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
