// PATCH-13
import 'package:flutter/material.dart';

/// Transition en fondu, identique pour tous les ecrans racines.
Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    );
