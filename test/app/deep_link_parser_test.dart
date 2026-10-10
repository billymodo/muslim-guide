import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_guide/app/deep_link_parser.dart';

void main() {
  group('DeepLinkParser.parse', () {
    test('resolves the prayer deep link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://prayer/now')),
        '/prayer',
      );
    });

    test('resolves the qibla deep link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://qibla/show')),
        '/qibla',
      );
    });

    test('resolves the location picker deep link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://location/pick')),
        '/location-picker',
      );
    });

    test('resolves the legacy prayer deep link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://test/prayer')),
        '/prayer',
      );
    });

    test('resolves the legacy qibla deep link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://test/qibla')),
        '/qibla',
      );
    });

    test('returns null for an unknown host', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://unknown/now')),
        isNull,
      );
    });

    test('returns null for an unknown path', () {
      expect(
        DeepLinkParser.parse(Uri.parse('muslimguide://prayer/later')),
        isNull,
      );
    });

    test('returns null for an unsupported scheme', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://prayer/now')),
        isNull,
      );
    });
  });
}
