/// Whether a permission is granted, denied, or not required by Android.
enum PermissionStatus {
  /// The app has the requested permission.
  granted,

  /// The app does not have the requested permission.
  denied,

  /// The Android version does not require this permission.
  notApplicable,
}
