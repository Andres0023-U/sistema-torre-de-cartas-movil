import 'package:flutter/material.dart';

class UsersRolesPage extends StatelessWidget {
  const UsersRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios y Roles'),
      ),
      body: const Center(
        child: Text('Pantalla de Gestión de Usuarios y Roles'),
      ),
    );
  }
}
