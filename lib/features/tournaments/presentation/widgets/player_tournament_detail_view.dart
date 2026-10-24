import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerTournamentDetailView extends StatelessWidget {
  final String tournamentId;

  const PlayerTournamentDetailView({
    super.key,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección "Tu partida"
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu partida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ronda 2 · Mesa 3',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/tournaments/$tournamentId/rounds/1/deck');
                    },
                    child: const Text('Cambiar mazo de la ronda'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sección "Rondas"
          const Text(
            'Rondas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              title: Text('Ronda 1'),
              subtitle: Text('Victoria 2-1'),
              trailing: Chip(
                label: Text('Finalizada'),
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Ronda 2'),
              subtitle: Text('Mesa 3'),
              trailing: Chip(
                label: Text('En curso'),
                backgroundColor: Colors.amberAccent,
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Ronda 3'),
              subtitle: Text('Por comenzar'),
              trailing: Chip(
                label: Text('Pendiente'),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sección "Puntos por partida"
          const Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Puntos por partida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Victoria en tiempo normal: 3 pts.'),
                  SizedBox(height: 4),
                  Text('Victoria en presión por tiempo con vida mayor a 0: 2 pts.'),
                  SizedBox(height: 4),
                  Text('Victoria en presión por tiempo con vida de 0 o menos: 1 pt.'),
                  SizedBox(height: 4),
                  Text('Derrota: 0 pts.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
