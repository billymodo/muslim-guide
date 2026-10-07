import 'package:hive_ce/hive.dart';

/// Reads and writes persisted application settings.
class SettingsRepository {
  /// Creates a repository backed by a Hive settings box.
  new(this._settingsBox);

  final Box<dynamic>? _settingsBox;

  /// Returns the saved language, or Arabic when no value is stored.
  Future<String> getLanguage() async {
    final value = _boxOrNull?.get('language', defaultValue: 'ar') ?? 'ar';
    if (value is! String || (value != 'ar' && value != 'en')) {
      throw FormatException('Invalid stored language value: $value');
    }
    return value;
  }

  /// Saves the interface language.
  Future<void> setLanguage(String language) async {
    if (language != 'ar' && language != 'en') {
      throw ArgumentError.value(language, 'language', 'Expected "ar" or "en".');
    }
    await _box.put('language', language);
  }

  /// Returns whether onboarding has been completed.
  Future<bool> isOnboardingCompleted() async {
    final value =
        _boxOrNull?.get('onboarding_completed', defaultValue: false) ?? false;
    if (value is! bool) {
      throw FormatException(
        'Invalid stored onboarding_completed value: $value',
      );
    }
    return value;
  }

  /// Saves whether onboarding has been completed.
  // ignore: avoid_positional_boolean_parameters // Keep the documented bool setter API.
  Future<void> setOnboardingCompleted(bool completed) async {
    await _box.put('onboarding_completed', completed);
  }

  /// Returns the saved theme, or system when no value is stored.
  Future<String> getTheme() async {
    final value = _boxOrNull?.get('theme', defaultValue: 'system') ?? 'system';
    if (value is! String ||
        (value != 'light' && value != 'dark' && value != 'system')) {
      throw FormatException('Invalid stored theme value: $value');
    }
    return value;
  }

  /// Saves the selected theme.
  Future<void> setTheme(String theme) async {
    if (theme != 'light' && theme != 'dark' && theme != 'system') {
      throw ArgumentError.value(
        theme,
        'theme',
        'Expected "light", "dark", or "system".',
      );
    }
    await _box.put('theme', theme);
  }

  Box<dynamic>? get _boxOrNull =>
      (_settingsBox?.isOpen ?? false) ? _settingsBox : null;

  Box<dynamic> get _box =>
      _boxOrNull ?? (throw StateError('Hive settings storage is unavailable.'));
}
