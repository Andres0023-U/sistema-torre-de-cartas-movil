import 'package:flutter/material.dart';

class RoundDeckPage extends StatelessWidget {
  final String tournamentId;
  final String roundId;

  const RoundDeckPage({
    super.key,
    required this.tournamentId,
    required this.roundId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mazo de la Ronda'),
      ),
      body: Center(
        child: Text('Mazo de la Ronda - Torneo ID: $tournamentId, Ronda ID: $roundId'),
      ),
    );
  }
}
