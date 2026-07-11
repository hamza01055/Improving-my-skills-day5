/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'IntelliVault';

  /// Backend base URL.
  ///
  /// Override at build time:
  ///   flutter run --dart-define=API_BASE_URL=https://api.example.com
  ///
  /// Default targets the local FastAPI server on localhost (Windows/web/iOS
  /// simulator). Android emulator needs 10.0.2.2 instead:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration apiTimeout = Duration(seconds: 30);
}
