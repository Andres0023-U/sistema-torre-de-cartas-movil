import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthBloc>().state.role;
    final isOrganizer = role == UserRole.organizer;
    final isAdmin = role == UserRole.admin;
    final canCreate = isOrganizer || isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneos'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear torneo',
              onPressed: () {
                context.push('/tournaments/create');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (canCreate)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/tournaments/create');
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Crear torneo'),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar torneo',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['Todos', 'Pendiente', 'En curso', 'Finalizado']
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTournamentCard(
                  context,
                  id: '1',
                  name: 'Torneo de Verano 2025',
                  status: 'En curso',
                  statusColor: Colors.amberAccent,
                  lineText: role == UserRole.player
                      ? 'Tu partida está lista'
                      : '2 partidas esperan resultado',
                  isPendiente: false,
                  role: role,
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  context,
                  id: '2',
                  name: 'Copa Desafío Nocturno',
                  status: 'Pendiente',
                  statusColor: Colors.blueAccent,
                  lineText: role == UserRole.player
                      ? 'Las inscripciones las hace el organizador'
                      : '5 de 8 inscritos',
                  isPendiente: true,
                  role: role,
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  context,
                  id: '3',
                  name: 'Liga de Leyendas 2024',
                  status: 'Finalizado',
                  statusColor: Colors.grey,
                  lineText: 'Torneo finalizado',
                  isPendiente: false,
                  role: role,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(
    BuildContext context, {
    required String id,
    required String name,
    required String status,
    required Color statusColor,
    required String lineText,
    required bool isPendiente,
    required UserRole? role,
  }) {
    final showOrganizerButtons = isPendiente && role == UserRole.organizer;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/tournaments/$id');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(status),
                    backgroundColor: statusColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lineText,
                style: const TextStyle(color: Colors.black87),
              ),
              if (showOrganizerButtons) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Inscribir jugador
                        },
                        child: const Text('Inscribir jugador'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Iniciar torneo
                        },
                        child: const Text('Iniciar torneo'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
