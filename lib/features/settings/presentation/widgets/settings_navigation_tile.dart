import 'package:flutter/material.dart';

/// A navigation row for settings screens.
///
/// When [onTap] is null the tile renders disabled (used for the
/// coming-soon adhan sound entry). [onTap] is injectable so widget tests
/// can verify navigation without a router.
class SettingsNavigationTile extends StatelessWidget {
  /// Creates a navigation tile.
  const new({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    super.key,
  });

  /// Leading icon.
  final IconData icon;

  /// Row title (localized).
  final String title;

  /// Optional subtitle (localized).
  final String? subtitle;

  /// Tap handler, or null for a disabled tile.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right),
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}
