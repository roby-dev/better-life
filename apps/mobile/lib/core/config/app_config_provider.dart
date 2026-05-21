import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (_) => throw UnimplementedError(
    'Override appConfigProvider in main() with AppConfig.fromEnvironment()',
  ),
);
