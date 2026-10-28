import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/admin/presentation/pages/users_roles_page.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pending_account_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/decks/presentation/pages/my_decks_page.dart';
import '../../features/decks/presentation/pages/round_deck_page.dart';
import '../../features/ranking/presentation/pages/ranking_page.dart';
import '../../features/tournaments/presentation/pages/create_tournament_page.dart';
import '../../features/tournaments/presentation/pages/register_result_page.dart';
import '../../features/tournaments/presentation/pages/tournament_detail_page.dart';
import '../../features/tournaments/presentation/pages/tournaments_page.dart';
import 'main_shell_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String _getHomeRouteForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return '/admin/users';
    case UserRole.user:
      return '/pending-account';
    case UserRole.player:
    case UserRole.organizer:
    default:
      return '/tournaments';
  }
}

bool _isRouteAllowedForRole(String location, UserRole? role) {
  if (role == null) return false;

  final rules = <MapEntry<RegExp, List<UserRole>>>[
    // Specific routes first
    MapEntry(
      RegExp(r'^/tournaments/create$'),
      [UserRole.organizer, UserRole.admin],
    ),
    MapEntry(
      RegExp(r'^/tournaments/[^/]+/matches/[^/]+/result$'),
      [UserRole.organizer],
    ),
    MapEntry(
      RegExp(r'^/tournaments/[^/]+/rounds/[^/]+/deck$'),
      [UserRole.player],
    ),
    MapEntry(
      RegExp(r'^/tournaments/[^/]+$'),
      [UserRole.player, UserRole.organizer, UserRole.admin],
    ),
    MapEntry(
      RegExp(r'^/tournaments$'),
      [UserRole.player, UserRole.organizer, UserRole.admin],
    ),
    MapEntry(
      RegExp(r'^/decks(/.*)?$'),
      [UserRole.player],
    ),
    MapEntry(
      RegExp(r'^/ranking$'),
      [UserRole.player, UserRole.organizer],
    ),
    MapEntry(
      RegExp(r'^/admin/users$'),
      [UserRole.admin],
    ),
    MapEntry(
      RegExp(r'^/pending-account$'),
      [UserRole.user],
    ),
    MapEntry(
      RegExp(r'^/account(/.*)?$'),
      [UserRole.player, UserRole.organizer, UserRole.admin, UserRole.user],
    ),
  ];

  for (final rule in rules) {
    if (rule.key.hasMatch(location)) {
      return rule.value.contains(role);
    }
  }

  return false;
}

GoRouter createRouter(Listenable refreshListenable) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final role = authState.role;
      final isAuthenticated =
          authState.status == AuthStatus.authenticated && role != null;
      final isSplashRoute = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.initial) {
        return isSplashRoute ? null : '/splash';
      }

      if (isSplashRoute) {
        return isAuthenticated ? _getHomeRouteForRole(role) : '/login';
      }

      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      final homeRoute = _getHomeRouteForRole(role);
      if (isAuthRoute || state.matchedLocation == '/') {
        return homeRoute;
      }

      if (!_isRouteAllowedForRole(state.matchedLocation, role)) {
        return homeRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: '/tournaments',
            builder: (context, state) => const TournamentsPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTournamentPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => TournamentDetailPage(
                  tournamentId: state.pathParameters['id'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'matches/:matchId/result',
                    builder: (context, state) => RegisterResultPage(
                      tournamentId: state.pathParameters['id'] ?? '',
                      matchId: state.pathParameters['matchId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'rounds/:roundId/deck',
                    builder: (context, state) => RoundDeckPage(
                      tournamentId: state.pathParameters['id'] ?? '',
                      roundId: state.pathParameters['roundId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/decks',
            builder: (context, state) => const MyDecksPage(),
          ),
          GoRoute(
            path: '/ranking',
            builder: (context, state) => const RankingPage(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountPage(),
            routes: [
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const ChangePasswordPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/pending-account',
            builder: (context, state) => const PendingAccountPage(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersRolesPage(),
          ),
        ],
      ),
    ],
  );
}
