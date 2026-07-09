/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'AI Second Brain';

  /// Backend base URL.
  ///
  /// Override at build time:
  ///   flutter run --dart-define=API_BASE_URL=https://api.example.com
  ///
  /// Default targets the local FastAPI server. 10.0.2.2 maps to the host
  /// machine's localhost from inside the Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const Duration apiTimeout = Duration(seconds: 30);
}
