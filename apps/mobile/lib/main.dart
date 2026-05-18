import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/app/app.dart';
import 'package:better_life_app/core/config/app_config.dart';
import 'package:better_life_app/core/config/app_config_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.fromEnvironment()),
      ],
      child: const BetterLifeApp(),
    ),
  );
}
