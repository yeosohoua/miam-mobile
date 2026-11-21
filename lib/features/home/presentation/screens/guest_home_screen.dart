// PATCH-23
import 'package:flutter/material.dart';

import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';
import 'home_screen.dart';

/// Accueil visiteur ("Skip for now"): meme ecran que l'accueil, mais sans barre
/// de navigation du bas, sans photo d'avatar, avec le bouton panier flottant
/// en bas a droite (16 dp des bords). L'avatar renvoie vers la connexion.
class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const HomeScreen(guest: true),
        Positioned(
          right: 16,
          bottom: 16,
          child: CartButton(onTap: () => showCartSheet(context)),
        ),
      ],
    );
  }
}
