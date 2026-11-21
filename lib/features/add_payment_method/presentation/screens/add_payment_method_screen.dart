import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment Method')),
      body: const Center(child: Text('AddPaymentMethodScreen: a reproduire')),
    );
  }
}
