import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timezone_resolver.dart';

final timezoneResolverProvider = Provider<TimezoneResolver>(
  (_) => const FlutterTimezoneResolver(),
);
