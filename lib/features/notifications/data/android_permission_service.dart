import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muslim_guide/features/notifications/data/permission_service.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';

/// Android permission methods used by [AndroidPermissionService].
abstract interface class AndroidNotificationPermissionApi {
  /// Returns whether the app can post notifications.
  Future<bool?> areNotificationsEnabled();

  /// Returns whether exact notifications can be scheduled.
  Future<bool?> canScheduleExactNotifications();

  /// Requests permission to post notifications.
  Future<bool?> requestNotificationsPermission();

  /// Requests exact-alarm access.
  Future<bool?> requestExactAlarmsPermission();

  /// Opens this app's notification settings.
  Future<bool?> openAppNotificationSettings();
}

/// Adapter for the Android implementation in `flutter_local_notifications`.
class FlutterLocalNotificationsPermissionApi
    implements AndroidNotificationPermissionApi {
  /// Creates the adapter.
  const new(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin get _androidPlugin {
    final implementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (implementation == null) {
      throw UnsupportedError(
        'Notification permissions are only supported on Android.',
      );
    }
    return implementation;
  }

  @override
  Future<bool?> areNotificationsEnabled() =>
      _androidPlugin.areNotificationsEnabled();

  @override
  Future<bool?> canScheduleExactNotifications() =>
      _androidPlugin.canScheduleExactNotifications();

  @override
  Future<bool?> requestNotificationsPermission() =>
      _androidPlugin.requestNotificationsPermission();

  @override
  Future<bool?> requestExactAlarmsPermission() =>
      _androidPlugin.requestExactAlarmsPermission();

  @override
  Future<bool?> openAppNotificationSettings() =>
      _androidPlugin.openAppNotificationSettings();
}

/// Implements Android notification and exact-alarm permission checks.
class AndroidPermissionService implements PermissionService {
  /// Creates the service with an SDK query and a plugin-backed permission API.
  new(this._getSdkVersion, this._permissionApi);

  /// Android API level where notification permission became runtime-gated.
  static const int notificationsPermissionApiLevel = 33;

  /// Android API level where exact-alarm access became user-controlled.
  static const int exactAlarmsPermissionApiLevel = 31;

  final Future<int?> Function() _getSdkVersion;
  final AndroidNotificationPermissionApi _permissionApi;

  @override
  Future<PermissionState> getStatus() async {
    final sdkVersion = await _getSdkVersion();
    if (sdkVersion == null) {
      return const PermissionState(
        notifications: PermissionStatus.notApplicable,
        exactAlarms: PermissionStatus.notApplicable,
      );
    }

    return PermissionState(
      notifications: sdkVersion < notificationsPermissionApiLevel
          ? PermissionStatus.notApplicable
          : _status(
              await _permissionApi.areNotificationsEnabled(),
              'notification permission status',
            ),
      exactAlarms: sdkVersion < exactAlarmsPermissionApiLevel
          ? PermissionStatus.notApplicable
          : _status(
              await _permissionApi.canScheduleExactNotifications(),
              'exact-alarm permission status',
            ),
    );
  }

  @override
  Future<bool> requestNotifications() async {
    final sdkVersion = await _getSdkVersion();
    if (sdkVersion == null ||
        sdkVersion < notificationsPermissionApiLevel) {
      return true;
    }
    return _requireResult(
      await _permissionApi.requestNotificationsPermission(),
      'notification permission request',
    );
  }

  @override
  Future<bool> requestExactAlarms() async {
    final sdkVersion = await _getSdkVersion();
    if (sdkVersion == null || sdkVersion < exactAlarmsPermissionApiLevel) {
      return true;
    }
    return _requireResult(
      await _permissionApi.requestExactAlarmsPermission(),
      'exact-alarm permission request',
    );
  }

  @override
  Future<bool> openNotificationSettings() async => _requireResult(
    await _permissionApi.openAppNotificationSettings(),
    'open notification settings',
  );

  static PermissionStatus _status(bool? granted, String operation) {
    if (granted == null) {
      throw StateError('Could not read $operation.');
    }
    return granted ? PermissionStatus.granted : PermissionStatus.denied;
  }

  static bool _requireResult(bool? result, String operation) {
    if (result == null) {
      throw StateError('Could not complete $operation.');
    }
    return result;
  }
}
