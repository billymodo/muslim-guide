import 'package:muslim_guide/features/notifications/domain/permission_status.dart';

/// Current notification and exact-alarm permission states.
class PermissionState {
  /// Creates a permission state.
  const new({
    required this.notifications,
    required this.exactAlarms,
  });

  /// Permission to post notifications.
  final PermissionStatus notifications;

  /// Permission to schedule exact alarms.
  final PermissionStatus exactAlarms;

  /// Whether posting notifications is allowed.
  bool get notificationsGranted => notifications == PermissionStatus.granted;

  /// Whether exact alarms can be scheduled.
  bool get exactAlarmsGranted => exactAlarms == PermissionStatus.granted;
}
