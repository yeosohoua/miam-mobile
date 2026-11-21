// PATCH-15
import 'package:flutter/widgets.dart';

/// Permet aux ecrans enfants de changer d'onglet (ex: avatar -> Profile).
class NavigatorScope extends InheritedWidget {
  const NavigatorScope({super.key, required this.select, required super.child});
  final void Function(int slot) select;

  static NavigatorScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<NavigatorScope>();

  @override
  bool updateShouldNotify(NavigatorScope old) => false;
}
