import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class LoginShellScreen extends StatelessWidget {
  const LoginShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Shell')),
      body: const Center(child: Text('LoginShellScreen: a reproduire')),
    );
  }
}
