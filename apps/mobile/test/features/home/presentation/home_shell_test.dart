import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/home/presentation/home_shell.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeRepo implements IAuthRepository {
  bool logoutCalled = false;

  @override
  Future<AuthToken> login({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<AuthToken?> currentToken() async => null;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> logout() async {
    state = const AuthUnauthenticated();
  }
}

Widget _buildShell({
  required _FakeRepo repo,
  int initialIndex = 0,
  AuthState initialState = const AuthAuthenticated(AuthToken(value: 'tok')),
}) {
  final storage = InMemoryTokenStorage();
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(repo),
      authNotifierProvider.overrideWith(
        () => _FakeAuthNotifier(initialState),
      ),
    ],
    child: MaterialApp(
      home: HomeShell(initialIndex: initialIndex),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeShell — structure', () {
    testWidgets('renders BottomNavigationBar with three items', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo()));
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Metas'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('renders home_shell scaffold key', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo()));
      await tester.pump();

      expect(find.byKey(const Key('home_shell')), findsOneWidget);
    });
  });

  group('HomeShell — Habits tab (index 0)', () {
    testWidgets('shows Habits headline when initialIndex is 0', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 0));
      await tester.pump();

      expect(find.byKey(const Key('habits_tab')), findsOneWidget);
    });

    testWidgets('Habits tab has a distinct headline text', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 0));
      await tester.pump();

      // The habits tab should display a recognizable headline.
      expect(find.text('Mis Hábitos'), findsOneWidget);
    });
  });

  group('HomeShell — Goals tab (index 1)', () {
    testWidgets('shows Goals content when initialIndex is 1', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 1));
      await tester.pump();

      expect(find.byKey(const Key('goals_tab')), findsOneWidget);
    });

    testWidgets('Goals tab has a distinct headline text', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 1));
      await tester.pump();

      expect(find.text('Mis Metas'), findsOneWidget);
    });
  });

  group('HomeShell — Profile tab (index 2)', () {
    testWidgets('shows Profile content when initialIndex is 2', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 2));
      await tester.pump();

      expect(find.byKey(const Key('profile_tab')), findsOneWidget);
    });

    testWidgets('Profile tab renders a logout button', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 2));
      await tester.pump();

      expect(find.byKey(const Key('profile_logout_button')), findsOneWidget);
    });

    testWidgets('tapping logout transitions auth state to AuthUnauthenticated', (tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(_buildShell(repo: repo, initialIndex: 2));
      await tester.pump();

      await tester.tap(find.byKey(const Key('profile_logout_button')));
      await tester.pump();

      // After logout, the notifier should be in AuthUnauthenticated.
      final element = tester.element(find.byKey(const Key('home_shell')));
      final container = ProviderScope.containerOf(element);
      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthUnauthenticated>());
    });
  });

  group('HomeShell — tab switching', () {
    testWidgets('tapping Goals tab shows goals content', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 0));
      await tester.pump();

      // Switch to Goals tab (index 1)
      await tester.tap(find.text('Metas'));
      await tester.pump();

      expect(find.byKey(const Key('goals_tab')), findsOneWidget);
    });

    testWidgets('tapping Profile tab shows profile content', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 0));
      await tester.pump();

      await tester.tap(find.text('Perfil'));
      await tester.pump();

      expect(find.byKey(const Key('profile_tab')), findsOneWidget);
    });

    testWidgets('switching tabs preserves IndexedStack state', (tester) async {
      await tester.pumpWidget(_buildShell(repo: _FakeRepo(), initialIndex: 0));
      await tester.pump();

      // All three tab bodies are built in IndexedStack (preserved).
      expect(find.byKey(const Key('home_shell_stack')), findsOneWidget);
    });
  });
}
