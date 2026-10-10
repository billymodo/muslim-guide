import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_guide/features/notifications/data/android_permission_service.dart';
import 'package:muslim_guide/features/notifications/data/android_sdk_version_channel.dart';
import 'package:muslim_guide/features/notifications/data/permission_service.dart';
import 'package:muslim_guide/features/notifications/domain/permission_state.dart';

/// Provides the platform permission service.
final Provider<FlutterLocalNotificationsPlugin> notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
      (ref) => FlutterLocalNotificationsPlugin(),
    );

/// Provides the platform permission service.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final plugin = ref.watch(notificationPluginProvider);
  const sdkVersionChannel = AndroidSdkVersionChannel();
  return AndroidPermissionService(
    sdkVersionChannel.getSdkVersion,
    FlutterLocalNotificationsPermissionApi(plugin),
  );
});

/// Loads permission state and performs permission actions.
final AsyncNotifierProvider<PermissionStateNotifier, PermissionState>
permissionStateProvider =
    AsyncNotifierProvider<PermissionStateNotifier, PermissionState>(
      PermissionStateNotifier.new,
    );

/// Coordinates permission state refreshes and user actions.
class PermissionStateNotifier extends AsyncNotifier<PermissionState> {
  @override
  Future<PermissionState> build() {
    return ref.watch(permissionServiceProvider).getStatus();
  }

  /// Re-reads permission state.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(permissionServiceProvider).getStatus(),
    );
  }

  /// Requests notification permission and then re-reads its state.
  Future<void> requestNotifications() =>
      _perform((service) => service.requestNotifications());

  /// Requests exact-alarm access and then re-reads its state.
  Future<void> requestExactAlarms() =>
      _perform((service) => service.requestExactAlarms());

  /// Opens notification settings and then re-reads permission state.
  Future<void> openNotificationSettings() =>
      _perform((service) => service.openNotificationSettings());

  Future<void> _perform(Future<bool> Function(PermissionService) action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(permissionServiceProvider);
      await action(service);
      return await service.getStatus();
    });
  }
}
