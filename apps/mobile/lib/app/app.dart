import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/app/router/app_router.dart';
import 'package:better_life_app/core/theme/bl_theme.dart';

/// Root application widget.
///
/// [BetterLifeApp] is a [ConsumerWidget] so it can read [appRouterProvider]
/// from the nearest [ProviderScope]. [main.dart] wraps it in a [ProviderScope]
/// with the production [AppConfig] override.
class BetterLifeApp extends ConsumerWidget {
  const BetterLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Better Life',
      debugShowCheckedModeBanner: false,
      theme: BLTheme.light(),
      // darkTheme intentionally omitted — NFR-009: light-only this cycle.
      routerConfig: router,
    );
  }
}
