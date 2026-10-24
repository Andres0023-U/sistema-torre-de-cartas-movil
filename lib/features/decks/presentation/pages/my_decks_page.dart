import 'package:flutter/material.dart';

class MyDecksPage extends StatelessWidget {
  const MyDecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mazos'),
      ),
      body: const Center(
        child: Text('Pantalla de Mis Mazos'),
      ),
    );
  }
}
