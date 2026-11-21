import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class SettingsNotificationsScreen extends StatelessWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Notifications')),
      body: const Center(child: Text('SettingsNotificationsScreen: a reproduire')),
    );
  }
}
