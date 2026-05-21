import 'package:flutter_timezone/flutter_timezone.dart';

abstract class TimezoneResolver {
  Future<String> resolve();
}

/// Production implementation that calls [FlutterTimezone.getLocalTimezone()].
/// Falls back to [fallback] if the platform channel throws or returns a
/// non-IANA string (i.e., one without a `/`).
class FlutterTimezoneResolver implements TimezoneResolver {
  static const fallback = 'America/Lima';

  const FlutterTimezoneResolver();

  @override
  Future<String> resolve() async {
    try {
      final tz = await FlutterTimezone.getLocalTimezone();
      return tz.contains('/') ? tz : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
