import 'dart:developer' as developer;

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:muslim_guide/data/storage/migrations.dart';

/// Initializes Hive and manages the app's settings box.
class HiveStore {
  Box<dynamic>? _settingsBox;

  /// Whether the settings box was opened successfully.
  bool get isAvailable => _settingsBox?.isOpen ?? false;

  /// The settings box, or `null` when initialization failed or is incomplete.
  Box<dynamic>? get settingsBox => isAvailable ? _settingsBox : null;

  /// Initializes Hive, opens the settings box, and migrates its schema.
  Future<void> init() async {
    if (isAvailable) return;

    Box<dynamic>? openedBox;
    try {
      await Hive.initFlutter();
      openedBox = await Hive.openBox<dynamic>('settings');
      await runMigrations(openedBox);
      _settingsBox = openedBox;
    } on Object catch (error, stackTrace) {
      if (openedBox?.isOpen ?? false) {
        try {
          await openedBox!.close();
        } on Object catch (closeError, closeStackTrace) {
          developer.log(
            'Failed to close the settings box after initialization failed.',
            name: 'muslim_guide.storage',
            error: closeError,
            stackTrace: closeStackTrace,
          );
        }
      }
      _settingsBox = null;
      developer.log(
        'Hive initialization failed; storage is unavailable.',
        name: 'muslim_guide.storage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Closes the settings box when it is open.
  Future<void> close() async {
    final box = _settingsBox;
    _settingsBox = null;
    if (box == null || !box.isOpen) return;

    try {
      await box.close();
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to close the settings box.',
        name: 'muslim_guide.storage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
