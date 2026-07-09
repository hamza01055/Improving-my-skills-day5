/// Keys for secure storage and Hive boxes.
class StorageKeys {
  StorageKeys._();

  // flutter_secure_storage
  static const String accessToken = 'access_token';

  // Hive
  static const String settingsBox = 'settings';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
}
