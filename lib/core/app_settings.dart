// PATCH-24
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reglages d'affichage persistants: theme (systeme / clair / sombre) et langue.
class AppSettings {
  AppSettings._();
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<Locale?> locale = ValueNotifier(null); // null = systeme

  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      themeMode.value = switch (p.getString('theme_mode')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      final l = p.getString('locale');
      locale.value = (l == 'en' || l == 'fr') ? Locale(l!) : null;
    } catch (_) {}
  }

  static Future<void> setThemeMode(ThemeMode m) async {
    themeMode.value = m;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('theme_mode', m.name);
    } catch (_) {}
  }

  static Future<void> setLocale(Locale l) async {
    locale.value = l;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('locale', l.languageCode);
    } catch (_) {}
  }

  /// Langue effective (systeme limite a en / fr).
  static String effectiveLang(BuildContext context) {
    final l = locale.value ?? WidgetsBinding.instance.platformDispatcher.locale;
    return l.languageCode == 'fr' ? 'fr' : 'en';
  }
}
