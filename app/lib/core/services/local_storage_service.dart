import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

/// Non-sensitive local flags and settings, backed by Hive.
class LocalStorageService {
  LocalStorageService._();

  static late Box<dynamic> _settings;

  static Future<void> init() async {
    _settings = await Hive.openBox<dynamic>(StorageKeys.settingsBox);
  }

  static bool get hasSeenOnboarding =>
      _settings.get(StorageKeys.hasSeenOnboarding, defaultValue: false)
          as bool;

  static Future<void> completeOnboarding() =>
      _settings.put(StorageKeys.hasSeenOnboarding, true);

  static String get themeMode =>
      _settings.get(StorageKeys.themeMode, defaultValue: 'system') as String;

  static Future<void> setThemeMode(String mode) =>
      _settings.put(StorageKeys.themeMode, mode);
}
