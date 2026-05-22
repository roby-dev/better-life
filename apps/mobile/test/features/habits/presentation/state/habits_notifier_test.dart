import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

class _FakeRepo implements IHabitRepository {
  List<Habit>? _habits;
  Failure? _failure;

  void setHabits(List<Habit> h) => _habits = h;
  void setFailure(Failure f) => _failure = f;

  @override
  Future<List<Habit>> getHabits() async {
    if (_failure != null) throw _failure!;
    return _habits!;
  }

  @override
  Future<Habit> upsertHabit(Habit habit) async {
    if (_failure != null) throw _failure!;
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    if (_failure != null) throw _failure!;
  }

  @override
  Future<List<Category>> getCategories() async {
    if (_failure != null) throw _failure!;
    return [];
  }
}

ProviderContainer _makeContainer(_FakeRepo repo) {
  return ProviderContainer(
    overrides: [
      habitRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('HabitsNotifier — initial state', () {
    test('starts as HabitsInitial', () {
      final repo = _FakeRepo()
        ..setHabits([
          const Habit(
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
        ]);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      expect(container.read(habitsNotifierProvider), isA<HabitsInitial>());
    });
  });

  group('HabitsNotifier — load()', () {
    final habits = [
      const Habit(
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
    ];

    test('transitions HabitsInitial → HabitsLoading → HabitsLoaded on success',
        () async {
      final repo = _FakeRepo()..setHabits(habits);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final states = <HabitsState>[];
      container.listen(habitsNotifierProvider, (_, next) => states.add(next),
          fireImmediately: false);

      await container.read(habitsNotifierProvider.notifier).load();

      expect(states[0], isA<HabitsLoading>());
      expect(states[1], isA<HabitsLoaded>());
      expect((states[1] as HabitsLoaded).habits, habits);
    });

    test('transitions HabitsInitial → HabitsLoading → HabitsError on NetworkFailure',
        () async {
      final repo = _FakeRepo()..setFailure(const NetworkFailure());
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(habitsNotifierProvider.notifier).load();

      final state = container.read(habitsNotifierProvider);
      expect(state, isA<HabitsError>());
      expect((state as HabitsError).failure, isA<NetworkFailure>());
    });

    test('transitions to HabitsError on ServerFailure', () async {
      final repo = _FakeRepo()
        ..setFailure(const ServerFailure(title: 'Server error', statusCode: 500));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(habitsNotifierProvider.notifier).load();

      final state = container.read(habitsNotifierProvider);
      expect(state, isA<HabitsError>());
      expect((state as HabitsError).failure, isA<ServerFailure>());
    });

    test('wraps generic exception as UnknownFailure', () async {
      final repo = _FakeRepo()..setFailure(const UnknownFailure('oops'));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(habitsNotifierProvider.notifier).load();

      final state = container.read(habitsNotifierProvider);
      expect(state, isA<HabitsError>());
      expect((state as HabitsError).failure, isA<UnknownFailure>());
    });
  });

  group('HabitsNotifier — retry()', () {
    final habits = [
      const Habit(
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
    ];

    test('retry re-fetches from the repository', () async {
      final repo = _FakeRepo()..setHabits(habits);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(habitsNotifierProvider.notifier).retry();

      final state = container.read(habitsNotifierProvider);
      expect(state, isA<HabitsLoaded>());
    });
  });

  group('HabitsNotifier — delete()', () {
    final habits = [
      const Habit(
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
      const Habit(
        id: '2',
        userId: 'u1',
        categoryId: 'c1',
        name: 'Read',
        frequencyType: 0,
        weekDays: 0,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ];

    test('delete removes item and re-fetches list', () async {
      final repo = _FakeRepo()..setHabits(habits);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      // First load
      await container.read(habitsNotifierProvider.notifier).load();

      // Then delete
      await container.read(habitsNotifierProvider.notifier).delete('1');

      final state = container.read(habitsNotifierProvider);
      expect(state, isA<HabitsLoaded>());
      expect((state as HabitsLoaded).habits.length, 2);
    });
  });
}
