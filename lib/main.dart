import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:torre_de_cartas_movil/services/core/injection_container.dart' as di;
import 'package:torre_de_cartas_movil/services/core/injection_container.dart' show sl;
import 'package:torre_de_cartas_movil/services/core/app_router.dart';
import 'package:torre_de_cartas_movil/widgets/theme/app_theme.dart';
import 'package:torre_de_cartas_movil/bloc/account/account_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/admin/admin_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_event.dart';
import 'package:torre_de_cartas_movil/bloc/auth/auth_state.dart';
import 'package:torre_de_cartas_movil/bloc/decks/decks_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/ranking/ranking_bloc.dart';
import 'package:torre_de_cartas_movil/bloc/tournaments/tournaments_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouterRefreshStream _refreshStream;
  late final GoRouter _router;
  int _sessionCounter = 0;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    _refreshStream = GoRouterRefreshStream(_authBloc.stream);
    _router = createRouter(_refreshStream);
  }

  @override
  void dispose() {
    _refreshStream.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status == AuthStatus.authenticated &&
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) {
          setState(() {
            _sessionCounter++;
          });
        },
        child: MultiBlocProvider(
          key: ValueKey(_sessionCounter),
          providers: [
            BlocProvider<TournamentsBloc>(create: (_) => sl<TournamentsBloc>()),
            BlocProvider<DecksBloc>(create: (_) => sl<DecksBloc>()),
            BlocProvider<RankingBloc>(create: (_) => sl<RankingBloc>()),
            BlocProvider<AccountBloc>(create: (_) => sl<AccountBloc>()),
            BlocProvider<AdminBloc>(create: (_) => sl<AdminBloc>()),
          ],
          child: MaterialApp.router(
            title: 'Torre de Cartas Móvil',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
