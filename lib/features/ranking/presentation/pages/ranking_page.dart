import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ranking'),
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Local'),
              Tab(text: 'Global'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Pantalla de Ranking Local')),
            Center(child: Text('Pantalla de Ranking Global')),
          ],
        ),
      ),
    );
  }
}
