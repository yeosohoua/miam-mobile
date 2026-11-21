// PATCH-13
import 'package:flutter/material.dart';

import '../api/api_client.dart';

/// Image reseau avec emplacement conserve: tant que l'URL est absente (ou en
/// echec), on affiche seulement la couleur de fond. Il suffit de renseigner
/// l'URL venant du serveur pour que l'image apparaisse (fondu).
class NetImage extends StatelessWidget {
  const NetImage({super.key, required this.url, required this.placeholder, this.fit = BoxFit.cover});
  final String? url;
  final Color placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return ColoredBox(color: placeholder, child: const SizedBox.expand());
    return Image.network(
      u,
      headers: u.startsWith(ApiClient.baseUrl) ? ApiClient.instance.imageHeaders : null,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      frameBuilder: (_, child, frame, sync) => AnimatedOpacity(
        opacity: frame == null && !sync ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: child,
      ),
      errorBuilder: (_, __, ___) => ColoredBox(color: placeholder, child: const SizedBox.expand()),
    );
  }
}
