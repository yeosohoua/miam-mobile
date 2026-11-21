// PATCH-13: donnees d'affichage de l'accueil. Les champs `imageUrl`/`logoUrl`
// restent null tant que le serveur ne les fournit pas (emplacement conserve).
import 'package:flutter/material.dart';

class HomeUser {
  const HomeUser({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;
}

class HomeOrdersSummary {
  const HomeOrdersSummary({required this.count, required this.next, required this.progress, required this.vendorColors, required this.more});
  final int count;
  final String next;
  final double progress;
  final List<Color> vendorColors;
  final int more;
}

class HomeCategory {
  const HomeCategory(this.name, {this.imageUrl});
  final String name;
  final String? imageUrl;
}

class HomeVendor {
  const HomeVendor({
    required this.name,
    required this.description,
    required this.eta,
    required this.logoColor,
    this.rating,
    this.ratingCount,
    this.express = true,
    this.imageUrl,
    this.logoUrl,
  });
  final String name;
  final String description;
  final String eta;
  final Color logoColor;
  final double? rating;
  final int? ratingCount;
  final bool express;
  final String? imageUrl;
  final String? logoUrl;
}

class HomeOffer {
  const HomeOffer({
    required this.discount,
    required this.vendor,
    required this.vendorColor,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    this.imageUrl,
    this.vendorLogoUrl,
  });
  final String discount;
  final String vendor;
  final Color vendorColor;
  final String name;
  final String description;
  final String price;
  final String oldPrice;
  final String? imageUrl;
  final String? vendorLogoUrl;
}

/// Contenu de demonstration (releve sur les captures), a remplacer par l'API.
class HomeDemoData {
  const HomeDemoData._();

  static const user = HomeUser(name: 'Grace Mitchell');
  static const address = '30 Rue de la Décence';

  // Visiteur ("Skip for now"): pas de nom, pas de photo, position détectée.
  static const guestUser = HomeUser(name: '');
  static const guestAddress = '729 Rue J69';

  static const orders = HomeOrdersSummary(
    count: 8,
    next: 'The Laurel Room',
    progress: 0.65,
    vendorColors: [Color(0xFF1E1B3A), Color(0xFF3A1D49), Color(0xFF15130F)],
    more: 4,
  );

  static const categories = [
    HomeCategory('Restaurant'),
    HomeCategory('Coffee Shop'),
    HomeCategory('Bakery'),
    HomeCategory('Grocery'),
    HomeCategory('Ice Cream'),
    HomeCategory('Cosmetics'),
    HomeCategory('Pet Shop'),
    HomeCategory('Pharmacy'),
    HomeCategory('Meat & Fish'),
    HomeCategory('Flowers'),
  ];

  static const popularVendors = [
    HomeVendor(
      name: 'Hollis & Fern',
      description: "A florist's studio — garden roses, peonies and seasonal stems, hand-tied and delivered the same day.",
      eta: '25 - 50 min',
      logoColor: Color(0xFFF1D9D2),
      rating: 4.9,
      ratingCount: 3,
    ),
    HomeVendor(
      name: 'Whitlock Apothecary',
      description: 'A London skincare, wellness and apothecary shop.',
      eta: '5 - 15 min',
      logoColor: Color(0xFFE7F1EC),
      rating: 4.8,
      ratingCount: 5,
    ),
  ];

  static const offers = [
    HomeOffer(
      discount: '20% Off',
      vendor: 'Atelier Nuit',
      vendorColor: Color(0xFF1E1B3A),
      name: 'Feuille de Figuier Room Spray',
      description: 'Fig leaf and green sap for linen and rooms, in a 100 ml bottle.',
      price: '\$33.28',
      oldPrice: '\$41.60',
    ),
    HomeOffer(
      discount: '15% Off',
      vendor: 'Fjell Coffee',
      vendorColor: Color(0xFFD9D9D9),
      name: 'Nyamasheke, Rwanda',
      description: 'Red Bourbon from Lake Kivu. Red apple, caramel, ripe cherry.',
      price: '\$15.17',
      oldPrice: '\$17.85',
    ),
  ];

  static const closestVendors = [
    HomeVendor(
      name: 'Tamarind Hall',
      description: 'Modern Indian — tandoor-roasted meats, coastal curries, and seasonal chaat.',
      eta: '15 - 55 min',
      logoColor: Color(0xFF3A1D49),
    ),
    HomeVendor(
      name: 'Tasca Brava',
      description: 'Spanish tapas, grilled seafood and paella from the coast.',
      eta: '10 - 35 min',
      logoColor: Color(0xFF7A1F2B),
    ),
  ];
}
