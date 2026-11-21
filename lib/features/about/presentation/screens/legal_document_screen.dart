import 'package:flutter/material.dart';

/// A reproduire d'apres les captures d'ecran (voir docs/ECRANS.md).
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Document')),
      body: const Center(child: Text('LegalDocumentScreen: a reproduire')),
    );
  }
}
