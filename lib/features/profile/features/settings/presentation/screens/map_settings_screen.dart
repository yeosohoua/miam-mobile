import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class MapSettingsScreen extends StatelessWidget {
  const MapSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Settings')),
      body: const Center(child: Text('MapSettingsScreen: a reproduire')),
    );
  }
}
