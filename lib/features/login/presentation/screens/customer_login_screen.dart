import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      body: const Center(child: Text('CustomerLoginScreen: a reproduire')),
    );
  }
}
