package com.muslimguide.app.muslim_guide

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.muslimguide.app/android_sdk",
        ).setMethodCallHandler { call, result ->
            if (call.method == "getSdkInt") {
                result.success(android.os.Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }
    }
}
