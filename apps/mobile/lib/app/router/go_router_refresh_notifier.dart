import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// A [ChangeNotifier] that bridges Riverpod's [authNotifierProvider] to
/// GoRouter's [GoRouter.refreshListenable].
///
/// When [AuthState] changes, [notifyListeners] is called so GoRouter
/// re-evaluates its redirect function.
///
/// Dispose via [dispose] (called automatically by [appRouterProvider]'s
/// [Ref.onDispose] hook).
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
