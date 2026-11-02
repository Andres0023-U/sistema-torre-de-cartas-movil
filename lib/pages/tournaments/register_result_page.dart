import 'package:flutter/material.dart';

class RegisterResultPage extends StatelessWidget {
  final String tournamentId;
  final String matchId;

  const RegisterResultPage({
    super.key,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Resultado'),
      ),
      body: Center(
        child: Text('Registrar Resultado - Torneo ID: $tournamentId, Partida ID: $matchId'),
      ),
    );
  }
}
