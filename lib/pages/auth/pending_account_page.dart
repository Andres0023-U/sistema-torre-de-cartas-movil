import 'package:flutter/material.dart';

class PendingAccountPage extends StatelessWidget {
  const PendingAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de Cuenta'),
      ),
      body: const Center(
        child: Text('Pantalla de Cuenta Pendiente de Aprobación'),
      ),
    );
  }
}
