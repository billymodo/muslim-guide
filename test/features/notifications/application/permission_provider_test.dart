import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/features/notifications/application/permission_provider.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';
import 'package:muslim_guide/features/notifications/domain/permission_status.dart';

import '../notification_test_fakes.dart';

void main() {
  test('loads the initial permission state from the service', () async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.granted,
      ),
    );
    final container = ProviderContainer(
      overrides: [permissionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final state = await container.read(permissionStateProvider.future);

    expect(state.notifications, PermissionStatus.denied);
    expect(state.exactAlarms, PermissionStatus.granted);
    expect(service.getStatusCalls, 1);
  });

  test('refresh re-reads permission state', () async {
    final service = FakePermissionService();
    final container = ProviderContainer(
      overrides: [permissionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(permissionStateProvider, (_, _) {});
    await container.read(permissionStateProvider.future);

    await container.read(permissionStateProvider.notifier).refresh();

    expect(service.getStatusCalls, 2);
  });

  test('request action runs and then refreshes the state', () async {
    final service = FakePermissionService(
      state: const PermissionState(
        notifications: PermissionStatus.denied,
        exactAlarms: PermissionStatus.denied,
      ),
    );
    final container = ProviderContainer(
      overrides: [permissionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(permissionStateProvider, (_, _) {});
    await container.read(permissionStateProvider.future);

    await container
        .read(permissionStateProvider.notifier)
        .requestNotifications();
    final state = await container.read(permissionStateProvider.future);

    expect(service.notificationRequests, 1);
    expect(state.notifications, PermissionStatus.granted);
    expect(service.getStatusCalls, 2);
  });
}
