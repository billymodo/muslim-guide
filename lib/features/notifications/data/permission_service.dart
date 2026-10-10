import 'package:muslim_guide/features/notifications/domain/permission_state.dart';

/// Reads and requests notification-related permissions.
abstract interface class PermissionService {
  /// Reads current OS permission status.
  Future<PermissionState> getStatus();

  /// Requests notification permission where Android requires it.
  Future<bool> requestNotifications();

  /// Requests exact-alarm access where Android requires it.
  Future<bool> requestExactAlarms();

  /// Opens this app's notification settings.
  Future<bool> openNotificationSettings();
}
