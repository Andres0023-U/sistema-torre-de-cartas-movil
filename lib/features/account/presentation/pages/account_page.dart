import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: const Center(
        child: Text('Pantalla de Cuenta (Editar nombre, Estadísticas e Historial de partidas)'),
      ),
    );
  }
}
