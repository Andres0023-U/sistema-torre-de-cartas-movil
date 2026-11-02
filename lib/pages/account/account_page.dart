import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torre_de_cartas_movil/bloc/account/account_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_event.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_state.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_event.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_state.dart';
import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';
import 'package:torre_de_cartas_movil/models/auth/user_role.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository_impl.dart';
import 'package:torre_de_cartas_movil/services/api/account_remote_data_source.dart';
import 'package:torre_de_cartas_movil/services/core/dio_client.dart';
import 'package:torre_de_cartas_movil/services/core/injection_container.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/change_password_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/get_account_usecase.dart';
import 'package:torre_de_cartas_movil/services/usecases/account/update_name_usecase.dart';
import 'package:torre_de_cartas_movil/widgets/account/spider_chart_widget.dart';
import 'package:torre_de_cartas_movil/widgets/theme/app_colors.dart';

void _ensureAccountDependenciesRegistered() {
  if (!sl.isRegistered<AccountRemoteDataSource>()) {
    sl.registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<AccountRepository>()) {
    sl.registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: sl<AccountRemoteDataSource>(),
      ),
    );
  }
  if (!sl.isRegistered<UpdateNameUseCase>()) {
    sl.registerLazySingleton<UpdateNameUseCase>(
      () => UpdateNameUseCase(repository: sl<AccountRepository>()),
    );
  }
  if (!sl.isRegistered<ChangePasswordUseCase>()) {
    sl.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(repository: sl<AccountRepository>()),
    );
  }
  if (!sl.isRegistered<GetAccountUseCase>()) {
    sl.registerLazySingleton<GetAccountUseCase>(
      () => GetAccountUseCase(repository: sl<AccountRepository>()),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    _ensureAccountDependenciesRegistered();
    _accountBloc = AccountBloc(
      updateNameUseCase: sl<UpdateNameUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
      getAccountUseCase: sl<GetAccountUseCase>(),
    )..add(const LoadPlayerStatsEvent());
  }

  @override
  void dispose() {
    _accountBloc.close();
    super.dispose();
  }

  String _roleToString(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.organizer:
        return 'Organizador';
      case UserRole.player:
        return 'Jugador';
      case UserRole.user:
      default:
        return 'Cuenta pendiente';
    }
  }

  Future<void> _showChangeNameDialog(String currentName) async {
    _accountBloc.add(const ClearAccountErrorEvent());
    final updatedName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ChangeNameDialog(
          accountBloc: _accountBloc,
          initialName: currentName,
        );
      },
    );

    if (!mounted || updatedName == null) return;

    context.read<AuthBloc>().add(AuthUserNameUpdated(updatedName));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Nombre actualizado correctamente'),
          backgroundColor: AppColors.navy,
        ),
      );
  }

  Future<void> _showChangePasswordDialog(String? email) async {
    _accountBloc.add(const ClearPasswordStateEvent());
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ChangePasswordDialog(
          accountBloc: _accountBloc,
          email: email,
        );
      },
    );

    if (!mounted || success != true) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          backgroundColor: AppColors.navy,
        ),
      );
  }

  List<SpiderChartAxis> _buildSpiderAxes(MyStatsEntity stats) {
    final played = stats.played;
    final won = stats.won;
    final lost = stats.lost;
    final points = stats.points;
    final tournamentsWon = stats.tournamentsWon;

    // 1. Tasa de victorias
    final winRate = played > 0 ? (won / played) : 0.0;

    // 2. Efectividad en puntos (media normalizada, 3 pts por partida = 100%)
    final pointsRatio = played > 0
        ? ((points / (played * 2.5)).clamp(0.12, 1.0))
        : (points > 0 ? 0.3 : 0.1);

    // 3. Torneos ganados (1 = 60%, 2+ = 100%)
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
    final formattedDate = h.date.length >= 10 ? h.date.substring(0, 10) : h.date;

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

  Widget _buildPlayerStatsSection(AccountState state) {
    if (state.isLoadingStats && state.stats == null) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
              SizedBox(height: 12),
              Text(
                'Cargando estadísticas del jugador...',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (state.statsErrorMessage != null && state.stats == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 36),
            const SizedBox(height: 10),
            Text(
              state.statsErrorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _accountBloc.add(const LoadPlayerStatsEvent()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título de la sección
        Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.gold, size: 24),
            const SizedBox(width: 8),
            Text(
              'Estadísticas del Jugador',
              style: GoogleFonts.cinzel(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grilla 2x2 de métricas clave
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                label: 'Posición Global',
                value: stats.position != null ? '#${stats.position}' : '—',
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

        // Tarjeta con el Gráfico de Araña (Spider / Radar Chart)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
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
                  fontSize: 17,
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
                size: 290,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.history.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
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
          ...state.history.take(6).map(_buildHistoryItem),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<AccountBloc, AccountState>(
            bloc: _accountBloc,
            builder: (context, accountState) {
              final name =
                  accountState.updatedName ?? authState.name ?? 'Usuario';
              final email = authState.email;
              final roleStr = _roleToString(authState.role);
              final isPlayer = authState.role == UserRole.player;

              return RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.navy,
                onRefresh: () async {
                  if (isPlayer) {
                    _accountBloc.add(const LoadPlayerStatsEvent());
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta de perfil
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppColors.parchment,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sesión iniciada correctamente',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: AppColors.navy3,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppColors.navy,
                                  ),
                                  tooltip: 'Cambiar nombre',
                                  onPressed: () => _showChangeNameDialog(name),
                                ),
                              ],
                            ),
                            if (email != null && email.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: AppColors.navy3,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.navy3,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Rol: $roleStr',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.navy3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botones de acción de cuenta
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          backgroundColor: AppColors.parchment,
                          side: const BorderSide(
                            color: AppColors.gold,
                            width: 1.4,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showChangeNameDialog(name),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: const Text(
                          'Cambiar nombre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          backgroundColor: AppColors.parchment,
                          side: const BorderSide(
                            color: AppColors.gold,
                            width: 1.4,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showChangePasswordDialog(email),
                        icon: const Icon(Icons.lock_outline, size: 20),
                        label: const Text(
                          'Cambiar contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Sección de Estadísticas del Jugador (solo para rol jugador)
                      if (isPlayer) ...[
                        _buildPlayerStatsSection(accountState),
                        const SizedBox(height: 28),
                      ],

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChangeNameDialog extends StatefulWidget {
  final AccountBloc accountBloc;
  final String initialName;

  const _ChangeNameDialog({
    required this.accountBloc,
    required this.initialName,
  });

  @override
  State<_ChangeNameDialog> createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<_ChangeNameDialog> {
  late final TextEditingController _controller;
  String? _localValidationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() {
        _localValidationError = 'El nombre no puede estar vacío.';
      });
      return;
    }
    if (newName == widget.initialName.trim()) {
      Navigator.of(context).pop();
      return;
    }
    widget.accountBloc.add(UpdateAccountNameRequested(newName));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      bloc: widget.accountBloc,
      listenWhen: (previous, current) =>
          previous.isUpdatingName && !current.isUpdatingName,
      listener: (context, accountState) {
        if (accountState.updatedName != null &&
            accountState.errorMessage == null) {
          Navigator.of(context).pop(accountState.updatedName);
        }
      },
      builder: (context, accountState) {
        final isSaving = accountState.isUpdatingName;
        final errorText = _localValidationError ?? accountState.errorMessage;

        return AlertDialog(
          backgroundColor: AppColors.parchment,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Text(
            'Cambiar nombre',
            style: GoogleFonts.cinzel(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ingresa el nuevo nombre que se mostrará en tu perfil y en los torneos:',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                enabled: !isSaving,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Tu nombre',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.navy,
                  ),
                  errorText: errorText,
                  errorMaxLines: 3,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
                onChanged: (_) {
                  if (_localValidationError != null) {
                    setState(() {
                      _localValidationError = null;
                    });
                  }
                  if (accountState.errorMessage != null) {
                    widget.accountBloc.add(const ClearAccountErrorEvent());
                  }
                },
                onSubmitted: (_) {
                  if (!isSaving) {
                    _submit();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.sourceSans3(
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AccountBloc accountBloc;
  final String? email;

  const _ChangePasswordDialog({
    required this.accountBloc,
    this.email,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final ScrollController _scrollController;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentError;
  String? _newError;
  String? _confirmError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_currentError != null ||
        _newError != null ||
        _confirmError != null ||
        _generalError != null) {
      setState(() {
        _currentError = null;
        _newError = null;
        _confirmError = null;
        _generalError = null;
      });
    }
    if (widget.accountBloc.state.passwordErrorMessage != null) {
      widget.accountBloc.add(const ClearPasswordStateEvent());
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _submit() {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? currentErr;
    String? newErr;
    String? confirmErr;

    // 1. Validar contraseña actual
    if (currentPassword.isEmpty) {
      currentErr = 'Ingresa tu contraseña actual.';
    }

    // 2. Validar nueva contraseña (guiado por el registro de usuario)
    if (newPassword.isEmpty) {
      newErr = 'Este campo es obligatorio.';
    } else if (newPassword.length < 8) {
      newErr = 'Debe tener al menos 8 caracteres.';
    } else if (!RegExp(r'[a-zA-Z]').hasMatch(newPassword)) {
      newErr = 'Debe incluir al menos una letra.';
    } else if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      newErr = 'Debe incluir al menos un número.';
    } else if (currentPassword.isNotEmpty && newPassword == currentPassword) {
      newErr = 'La nueva contraseña debe ser diferente a la actual.';
    }

    // 3. Validar confirmación de contraseña
    if (confirmPassword.isEmpty) {
      confirmErr = 'Confirma la nueva contraseña.';
    } else if (newPassword.isNotEmpty && confirmPassword != newPassword) {
      confirmErr = 'Las contraseñas no coinciden.';
    }

    if (currentErr != null || newErr != null || confirmErr != null) {
      FocusScope.of(context).unfocus();
      setState(() {
        _currentError = currentErr;
        _newError = newErr;
        _confirmError = confirmErr;
        _generalError = null;
      });
      _scrollToBottom();
      return;
    }

    FocusScope.of(context).unfocus();
    widget.accountBloc.add(
      ChangePasswordRequested(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: widget.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      bloc: widget.accountBloc,
      listenWhen: (previous, current) =>
          previous.isChangingPassword && !current.isChangingPassword,
      listener: (context, accountState) {
        if (accountState.passwordChangedSuccessfully) {
          Navigator.of(context).pop(true);
        } else if (accountState.passwordErrorMessage != null) {
          FocusScope.of(context).unfocus();
          setState(() {
            _generalError = accountState.passwordErrorMessage;
          });
          _scrollToBottom();
        }
      },
      builder: (context, accountState) {
        final isSaving = accountState.isChangingPassword;
        final generalError =
            _generalError ?? accountState.passwordErrorMessage;

        return AlertDialog(
          backgroundColor: AppColors.parchment,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Text(
            'Cambiar contraseña',
            style: GoogleFonts.cinzel(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ingresa tu contraseña actual y luego escribe la nueva contraseña:',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPasswordController,
                  enabled: !isSaving,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    hintText: 'Ingresa tu clave actual',
                    errorText: _currentError,
                    errorMaxLines: 3,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.navy,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.navy,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                  onChanged: (_) => _clearErrors(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _newPasswordController,
                  enabled: !isSaving,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    hintText: 'Mínimo 8 caracteres, 1 letra y 1 número',
                    errorText: _newError,
                    errorMaxLines: 3,
                    prefixIcon: const Icon(
                      Icons.vpn_key_outlined,
                      color: AppColors.navy,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.navy,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                  onChanged: (_) => _clearErrors(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !isSaving,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    hintText: 'Repite la nueva contraseña',
                    errorText: _confirmError,
                    errorMaxLines: 3,
                    prefixIcon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.navy,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.navy,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                  onChanged: (_) => _clearErrors(),
                  onSubmitted: (_) {
                    if (!isSaving) {
                      _submit();
                    }
                  },
                ),
                if (generalError != null && generalError.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            generalError,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.sourceSans3(
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
