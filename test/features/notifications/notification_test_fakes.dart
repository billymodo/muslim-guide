import 'dart:async';

import 'package:muslim_guide/features/notifications/data/permission_service.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';

class FakePermissionService implements PermissionService {
  new({
    this.state = const PermissionState(
      notifications: PermissionStatus.granted,
      exactAlarms: PermissionStatus.granted,
    ),
    this.getStatusCompleter,
    this.failStatusReads = false,
  });

  PermissionState state;
  Completer<PermissionState>? getStatusCompleter;
  bool failStatusReads;
  int getStatusCalls = 0;
  int notificationRequests = 0;
  int exactAlarmRequests = 0;
  int notificationSettingsOpens = 0;

  @override
  Future<PermissionState> getStatus() async {
    getStatusCalls++;
    if (failStatusReads) throw StateError('status unavailable');
    final completer = getStatusCompleter;
    if (completer != null) return await completer.future;
    return state;
  }

  @override
  Future<bool> requestNotifications() async {
    notificationRequests++;
    state = PermissionState(
      notifications: PermissionStatus.granted,
      exactAlarms: state.exactAlarms,
    );
    return true;
  }

  @override
  Future<bool> requestExactAlarms() async {
    exactAlarmRequests++;
    state = PermissionState(
      notifications: state.notifications,
      exactAlarms: PermissionStatus.granted,
    );
    return true;
  }

  @override
  Future<bool> openNotificationSettings() async {
    notificationSettingsOpens++;
    state = PermissionState(
      notifications: PermissionStatus.granted,
      exactAlarms: state.exactAlarms,
    );
    return true;
  }
}
