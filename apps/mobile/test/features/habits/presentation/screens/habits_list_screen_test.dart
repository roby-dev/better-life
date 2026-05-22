import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/screens/habits_list_screen.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_notifier.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

void main() {
  Widget makeWidget(HabitsNotifier notifier) {
    return ProviderScope(
      overrides: [
        habitsNotifierProvider.overrideWith(() => notifier),
      ],
      child: const MaterialApp(
        home: HabitsListScreen(),
      ),
    );
  }

  group('HabitsListScreen', () {
    testWidgets('shows loading indicator when state is HabitsLoading',
        (tester) async {
      final notifier = _TestNotifier(const HabitsLoading());
      await tester.pumpWidget(makeWidget(notifier));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when loaded with empty list',
        (tester) async {
      final notifier = _TestNotifier(const HabitsLoaded([]));
      await tester.pumpWidget(makeWidget(notifier));
      expect(find.text('No tienes hábitos todavía'), findsOneWidget);
    });

    testWidgets('shows habit names when loaded with data', (tester) async {
      final notifier = _TestNotifier(const HabitsLoaded([
        Habit(
          id: '1',
          userId: 'u1',
          categoryId: 'c1',
          name: 'Run',
          frequencyType: 0,
          weekDays: 0,
          status: 0,
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
        ),
      ]));
      await tester.pumpWidget(makeWidget(notifier));
      expect(find.text('Run'), findsOneWidget);
    });

    testWidgets('shows error and retry button on HabitsError', (tester) async {
      final notifier = _TestNotifier(const HabitsError(NetworkFailure()));
      await tester.pumpWidget(makeWidget(notifier));
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      final notifier = _TestNotifier(const HabitsLoaded([]));
      await tester.pumpWidget(makeWidget(notifier));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

class _TestNotifier extends HabitsNotifier {
  final HabitsState _fixedState;

  _TestNotifier(this._fixedState);

  @override
  HabitsState build() => _fixedState;

  @override
  Future<void> load() async {}
  @override
  Future<void> retry() async {}
  @override
  Future<void> delete(String id) async {}
}
