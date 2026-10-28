import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class MainShellPage extends StatelessWidget {
  final Widget child;

  const MainShellPage({
    super.key,
    required this.child,
  });

  List<NavigationItem> _getItemsForRole(UserRole? role) {
    switch (role) {
      case UserRole.player:
        return const [
          NavigationItem(label: 'Torneos', icon: Icons.emoji_events, route: '/tournaments'),
          NavigationItem(label: 'Mazos', icon: Icons.style, route: '/decks'),
          NavigationItem(label: 'Ranking', icon: Icons.leaderboard, route: '/ranking'),
          NavigationItem(label: 'Cuenta', icon: Icons.person, route: '/account'),
        ];
      case UserRole.organizer:
        return const [
          NavigationItem(label: 'Torneos', icon: Icons.emoji_events, route: '/tournaments'),
          NavigationItem(label: 'Ranking', icon: Icons.leaderboard, route: '/ranking'),
          NavigationItem(label: 'Cuenta', icon: Icons.person, route: '/account'),
        ];
      case UserRole.admin:
        return const [
          NavigationItem(label: 'Usuarios', icon: Icons.supervisor_account, route: '/admin/users'),
          NavigationItem(label: 'Torneos', icon: Icons.emoji_events, route: '/tournaments'),
          NavigationItem(label: 'Ranking', icon: Icons.leaderboard, route: '/ranking'),
          NavigationItem(label: 'Cuenta', icon: Icons.person, route: '/account'),
        ];
      case UserRole.user:
        return const [
          NavigationItem(label: 'Estado', icon: Icons.hourglass_empty, route: '/pending-account'),
          NavigationItem(label: 'Cuenta', icon: Icons.person, route: '/account'),
        ];
      default:
        return const [
          NavigationItem(label: 'Torneos', icon: Icons.emoji_events, route: '/tournaments'),
          NavigationItem(label: 'Cuenta', icon: Icons.person, route: '/account'),
        ];
    }
  }

  int _calculateSelectedIndex(BuildContext context, List<NavigationItem> items) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final items = _getItemsForRole(state.role);
        final selectedIndex = _calculateSelectedIndex(context, items);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              context.go(items[index].route);
            },
            items: items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
