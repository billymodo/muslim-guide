/// Resolves supported external application URIs to internal route locations.
abstract final class DeepLinkParser {
  /// The application URI scheme.
  static const String scheme = 'muslimguide';

  /// Resolves a supported deep link, or returns null when it is unknown.
  static String? parse(Uri uri) {
    if (uri.scheme != scheme) return null;

    return switch ((uri.host, uri.path)) {
      ('prayer', '/now') || ('test', '/prayer') => '/prayer',
      ('qibla', '/show') || ('test', '/qibla') => '/qibla',
      ('location', '/pick') => '/location-picker',
      _ => null,
    };
  }
}

// TODO(phase-04-task-8): Add the notifications settings deep link.
// URI: muslimguide://notifications/settings → /settings/notifications
