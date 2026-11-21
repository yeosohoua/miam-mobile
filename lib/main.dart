// PATCH-27
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_settings.dart';
import 'core/auth/auth_service.dart';
import 'core/locator/locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await setupLocator();
  await AppSettings.load();
  await AuthService.instance.init();
  runApp(const ShopCustomerApp());
}

class ShopCustomerApp extends StatelessWidget {
  const ShopCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppSettings.themeMode, AppSettings.locale]),
      builder: (context, _) => MaterialApp(
      title: 'Miam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Suit automatiquement le mode clair / sombre du telephone, avec fondu.
      themeMode: AppSettings.themeMode.value,
      locale: AppSettings.locale.value,
      themeAnimationDuration: const Duration(milliseconds: 400),
      themeAnimationCurve: Curves.easeInOut,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('fr'), Locale('en')],
      // Taille de texte identique a l'app d'origine, quelle que soit la
      // taille de police reglee dans Android (sinon les titres passent a la ligne).
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child ?? const SizedBox.shrink(),
      ),
      routes: AppRouter.routes,
      initialRoute: AppRouter.initialRoute,
    ));
  }
}
