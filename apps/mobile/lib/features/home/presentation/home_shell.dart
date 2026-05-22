import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/screens/habits_list_screen.dart';

/// HomeShell — the root scaffold for authenticated screens.
///
/// Renders three tabs via [IndexedStack] so tab state is preserved on switch:
/// - 0: Habits
/// - 1: Goals
/// - 2: Profile (includes logout button)
///
/// Logout is delegated to [authNotifierProvider.notifier.logout()].
/// The router redirect (already wired in S9) handles navigation back to login.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  /// Which tab to show on first render (0 = Habits, 1 = Goals, 2 = Profile).
  final int initialIndex;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home_shell'),
      backgroundColor: BLColors.lightBgTop,
      body: IndexedStack(
        key: const Key('home_shell_stack'),
        index: _index,
        children: const [
          HabitsListScreen(),
          _GoalsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: BLColors.lavender500,
        unselectedItemColor: BLColors.lightTextMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── Tab bodies ────────────────────────────────────────────────────────────────

/// Goals tab — placeholder content.
class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('goals_tab'),
      child: Padding(
        padding: const EdgeInsets.all(BLSpacing.screenX),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Metas',
              style: BLType.h1.copyWith(color: BLColors.lightText),
            ),
            const SizedBox(height: 8),
            Text(
              'Define las metas que quieres alcanzar.',
              style: BLType.body.copyWith(color: BLColors.lightTextMuted),
            ),
            const Spacer(),
            Center(
              child: Icon(
                Icons.flag_outlined,
                size: 64,
                color: BLColors.lavender300,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Profile tab — shows user info placeholder and a logout button.
///
/// Tapping logout calls [authNotifierProvider.notifier.logout()].
/// The GoRouter redirect in [appRouterProvider] automatically redirects
/// to /login when [AuthState] becomes [AuthUnauthenticated].
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      key: const Key('profile_tab'),
      child: Padding(
        padding: const EdgeInsets.all(BLSpacing.screenX),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Perfil',
              style: BLType.h1.copyWith(color: BLColors.lightText),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu cuenta y preferencias.',
              style: BLType.body.copyWith(color: BLColors.lightTextMuted),
            ),
            const Spacer(),
            Center(
              child: Icon(
                Icons.person_outline,
                size: 64,
                color: BLColors.lavender300,
              ),
            ),
            const Spacer(),

            // ── Logout ────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('profile_logout_button'),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BLColors.danger,
                  side: BorderSide(color: BLColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: BLSpacing.screenBottom),
          ],
        ),
      ),
    );
  }
}
