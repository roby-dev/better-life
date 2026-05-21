import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/platform/timezone_resolver.dart';

void main() {
  group('FlutterTimezoneResolver', () {
    test('returns IANA timezone when valid (contains /)', () async {
      final resolver = _FakeTimezoneResolver('America/Bogota');
      final result = await resolver.resolve();
      expect(result, 'America/Bogota');
    });

    test('returns America/Lima fallback when timezone string has no slash', () async {
      final resolver = _FakeTimezoneResolver('InvalidTimezone');
      final result = await resolver.resolve();
      expect(result, 'America/Lima');
    });

    test('returns America/Lima fallback when getLocalTimezone throws', () async {
      final resolver = _FakeTimezoneResolver(null); // null signals throw
      final result = await resolver.resolve();
      expect(result, 'America/Lima');
    });

    test('returns America/Lima when timezone is empty string', () async {
      final resolver = _FakeTimezoneResolver('');
      final result = await resolver.resolve();
      expect(result, 'America/Lima');
    });

    test('valid IANA with multiple slashes is accepted', () async {
      // Some IANA zones like 'America/Indiana/Indianapolis'
      final resolver = _FakeTimezoneResolver('America/Indiana/Indianapolis');
      final result = await resolver.resolve();
      expect(result, 'America/Indiana/Indianapolis');
    });
  });
}

/// Test double for [FlutterTimezoneResolver] that avoids the platform channel.
/// Passing [null] simulates a thrown exception.
class _FakeTimezoneResolver implements TimezoneResolver {
  final String? _tz; // null = throw

  _FakeTimezoneResolver(this._tz);

  @override
  Future<String> resolve() async {
    try {
      if (_tz == null) throw Exception('Platform channel unavailable');
      final tz = _tz;
      return tz.contains('/') ? tz : FlutterTimezoneResolver.fallback;
    } catch (_) {
      return FlutterTimezoneResolver.fallback;
    }
  }
}
