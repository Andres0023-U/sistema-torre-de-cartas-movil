import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrganizerTournamentDetailView extends StatelessWidget {
  final String tournamentId;
  final bool readOnly;

  const OrganizerTournamentDetailView({
    super.key,
    required this.tournamentId,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (readOnly)
            Container(
              color: Colors.amber.shade100,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                'Vista de consulta: solo el organizador gestiona rondas y resultados.',
                style: TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          const TabBar(
            tabs: [
              Tab(text: 'Ronda 2'),
              Tab(text: 'Inscritos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRoundTab(context),
                _buildPlayersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: const Text('Mesa 1'),
              subtitle: const Text('Jugador A vs Jugador B (Resultado: 2-0)'),
              trailing: const Chip(
                label: Text('Finalizada'),
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Mesa 2'),
              subtitle: const Text('Jugador C vs Jugador D'),
              trailing: !readOnly
                  ? ElevatedButton(
                      onPressed: () {
                        context.push('/tournaments/$tournamentId/matches/1/result');
                      },
                      child: const Text('Registrar resultado'),
                    )
                  : const Chip(
                      label: Text('Pendiente'),
                      backgroundColor: Colors.amberAccent,
                    ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Mesa 3'),
              subtitle: const Text('Jugador E vs Jugador F'),
              trailing: !readOnly
                  ? ElevatedButton(
                      onPressed: () {
                        context.push('/tournaments/$tournamentId/matches/2/result');
                      },
                      child: const Text('Registrar resultado'),
                    )
                  : const Chip(
                      label: Text('Pendiente'),
                      backgroundColor: Colors.amberAccent,
                    ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Mesa 4'),
              subtitle: const Text('Jugador G vs Jugador H'),
              trailing: !readOnly
                  ? ElevatedButton(
                      onPressed: () {
                        context.push('/tournaments/$tournamentId/matches/3/result');
                      },
                      child: const Text('Registrar resultado'),
                    )
                  : const Chip(
                      label: Text('Pendiente'),
                      backgroundColor: Colors.amberAccent,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (!readOnly) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Crear partida manual
                },
                child: const Text('Crear partida manual'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Generar emparejamientos automáticos
                },
                child: const Text('Generar emparejamientos automáticos'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // TODO: Siguiente ronda
                },
                child: const Text('Siguiente ronda'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersTab() {
    final players = List.generate(8, (index) => 'Jugador ${index + 1}');

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: players.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(players[index]),
            subtitle: const Text('Estado: Inscripto'),
          ),
        );
      },
    );
  }
}
