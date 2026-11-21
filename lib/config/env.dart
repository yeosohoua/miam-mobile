/// Les valeurs ne sont PAS recopiees depuis l'APK.
/// Lance avec: flutter run --dart-define=API_URL=https://... --dart-define=API_KEY=...
class Env {
  const Env._();
  static const apiUrl = String.fromEnvironment('API_URL');
  static const apiKey = String.fromEnvironment('API_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT', defaultValue: 'dev');
}
