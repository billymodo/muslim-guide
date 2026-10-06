import 'package:hive_ce/hive.dart';

/// Current schema version for the settings box.
const currentSettingsVersion = 1;

/// Applies sequential schema migrations to [box].
Future<void> runMigrations(Box<dynamic> box) async {
  final schemaVersion = box.get('schemaVersion', defaultValue: 0);
  if (schemaVersion is! int) {
    throw FormatException(
      'Invalid schemaVersion in Hive box "${box.name}": $schemaVersion',
    );
  }
  if (schemaVersion > currentSettingsVersion) {
    throw StateError(
      'Hive box "${box.name}" uses unsupported schema version '
      '$schemaVersion (current: $currentSettingsVersion).',
    );
  }

  if (schemaVersion < 1) {
    // Version 1 introduces schema tracking; no existing values need conversion.
  }

  await box.put('schemaVersion', currentSettingsVersion);
}
