import 'package:flutter/material.dart';

class CreateTournamentPage extends StatelessWidget {
  const CreateTournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Torneo'),
      ),
      body: const Center(
        child: Text('Pantalla de Creación de Torneo'),
      ),
    );
  }
}
