import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/data/android_permission_service.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';

class _FakePermissionApi implements AndroidNotificationPermissionApi {
  bool? notificationsEnabled = true;
  bool? exactAlarmsEnabled = true;
  bool? notificationRequestResult = true;
  bool? exactAlarmRequestResult = true;
  bool? openSettingsResult = true;
  int notificationStatusCalls = 0;
  int exactAlarmStatusCalls = 0;
  int notificationRequestCalls = 0;
  int exactAlarmRequestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<bool?> areNotificationsEnabled() async {
    notificationStatusCalls++;
    return notificationsEnabled;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async {
    exactAlarmStatusCalls++;
    return exactAlarmsEnabled;
  }

  @override
  Future<bool?> requestNotificationsPermission() async {
    notificationRequestCalls++;
    return notificationRequestResult;
  }

  @override
  Future<bool?> requestExactAlarmsPermission() async {
    exactAlarmRequestCalls++;
    return exactAlarmRequestResult;
  }

  @override
  Future<bool?> openAppNotificationSettings() async {
    openSettingsCalls++;
    return openSettingsResult;
  }
}

AndroidPermissionService _service(int? sdkVersion, _FakePermissionApi api) {
  return AndroidPermissionService(() async => sdkVersion, api);
}

void main() {
  test(
    'reports both permissions as not applicable before their API levels',
    () async {
      final api = _FakePermissionApi();
      final state = await _service(30, api).getStatus();

      expect(state.notifications, PermissionStatus.notApplicable);
      expect(state.exactAlarms, PermissionStatus.notApplicable);
      expect(api.notificationStatusCalls, 0);
      expect(api.exactAlarmStatusCalls, 0);
    },
  );

  test('checks exact alarms but not notifications on API 32', () async {
    final api = _FakePermissionApi()
      ..notificationsEnabled = false
      ..exactAlarmsEnabled = false;
    final state = await _service(32, api).getStatus();

    expect(state.notifications, PermissionStatus.notApplicable);
    expect(state.exactAlarms, PermissionStatus.denied);
    expect(api.notificationStatusCalls, 0);
    expect(api.exactAlarmStatusCalls, 1);
  });

  test('maps enabled plugin results to granted', () async {
    final state = await _service(33, _FakePermissionApi()).getStatus();

    expect(state.notifications, PermissionStatus.granted);
    expect(state.exactAlarms, PermissionStatus.granted);
  });

  test('maps disabled plugin results to denied', () async {
    final api = _FakePermissionApi()
      ..notificationsEnabled = false
      ..exactAlarmsEnabled = false;
    final state = await _service(33, api).getStatus();

    expect(state.notifications, PermissionStatus.denied);
    expect(state.exactAlarms, PermissionStatus.denied);
  });

  test('does not invoke notification request below API 33', () async {
    final api = _FakePermissionApi();

    expect(await _service(32, api).requestNotifications(), isTrue);
    expect(api.notificationRequestCalls, 0);
  });

  test('requests notification permission on API 33+', () async {
    final api = _FakePermissionApi()..notificationRequestResult = false;

    expect(await _service(33, api).requestNotifications(), isFalse);
    expect(api.notificationRequestCalls, 1);
  });

  test('does not invoke exact-alarm request below API 31', () async {
    final api = _FakePermissionApi();

    expect(await _service(30, api).requestExactAlarms(), isTrue);
    expect(api.exactAlarmRequestCalls, 0);
  });

  test('requests exact-alarm access on API 31+', () async {
    final api = _FakePermissionApi()..exactAlarmRequestResult = false;

    expect(await _service(31, api).requestExactAlarms(), isFalse);
    expect(api.exactAlarmRequestCalls, 1);
  });

  test('fails explicitly when permission status is unavailable', () async {
    final api = _FakePermissionApi()..notificationsEnabled = null;

    await expectLater(_service(33, api).getStatus(), throwsStateError);
  });

  test('fails explicitly when a request has no result', () async {
    final api = _FakePermissionApi()..notificationRequestResult = null;

    await expectLater(
      _service(33, api).requestNotifications(),
      throwsStateError,
    );
  });

  test('opens notification settings using the plugin API', () async {
    final api = _FakePermissionApi();

    expect(await _service(33, api).openNotificationSettings(), isTrue);
    expect(api.openSettingsCalls, 1);
  });

  test('treats a non-Android platform as not applicable', () async {
    final api = _FakePermissionApi();

    final state = await _service(null, api).getStatus();

    expect(state.notifications, PermissionStatus.notApplicable);
    expect(state.exactAlarms, PermissionStatus.notApplicable);
  });
}
