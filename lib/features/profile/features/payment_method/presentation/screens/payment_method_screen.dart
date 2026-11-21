import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: const Center(child: Text('PaymentMethodScreen: a reproduire')),
    );
  }
}
