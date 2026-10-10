import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads Android's SDK integer through the app's small native platform bridge.
class AndroidSdkVersionChannel {
  /// Creates the SDK version channel.
  const new({
    this.channel = const MethodChannel('com.muslimguide.app/android_sdk'),
  });

  /// Method channel used to query Android's `Build.VERSION.SDK_INT`.
  final MethodChannel channel;

  /// Returns the Android SDK version, or null on non-Android platforms.
  Future<int?> getSdkVersion() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    final version = await channel.invokeMethod<int>('getSdkInt');
    if (version == null || version <= 0) {
      throw StateError('Android returned an invalid SDK version: $version.');
    }
    return version;
  }
}
