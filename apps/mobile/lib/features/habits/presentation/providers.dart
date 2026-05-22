import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:better_life_app/core/http/http_providers.dart';
import 'package:better_life_app/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:better_life_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/usecases/delete_habit_use_case.dart';
import 'package:better_life_app/features/habits/domain/usecases/get_categories_use_case.dart';
import 'package:better_life_app/features/habits/domain/usecases/get_habits_use_case.dart';
import 'package:better_life_app/features/habits/domain/usecases/upsert_habit_use_case.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_notifier.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

// ─────────────────────────────────────────────────── Data layer providers ──

/// Provides the Dio-backed [HabitRemoteDataSource].
final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>(
  (ref) => DioHabitRemoteDataSource(ref.watch(dioProvider)),
);

// ─────────────────────────────────────────── Domain / use-case providers ──

/// Provides the [IHabitRepository] implementation.
final habitRepositoryProvider = Provider<IHabitRepository>(
  (ref) => HabitRepositoryImpl(
    remote: ref.watch(habitRemoteDataSourceProvider),
  ),
);

/// Provides [GetHabitsUseCase] backed by the habit repository.
final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>(
  (ref) => GetHabitsUseCase(ref.watch(habitRepositoryProvider)),
);

/// Provides [UpsertHabitUseCase] backed by the habit repository.
final upsertHabitUseCaseProvider = Provider<UpsertHabitUseCase>(
  (ref) => UpsertHabitUseCase(ref.watch(habitRepositoryProvider)),
);

/// Provides [DeleteHabitUseCase] backed by the habit repository.
final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>(
  (ref) => DeleteHabitUseCase(ref.watch(habitRepositoryProvider)),
);

/// Provides [GetCategoriesUseCase] backed by the habit repository.
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>(
  (ref) => GetCategoriesUseCase(ref.watch(habitRepositoryProvider)),
);

/// Provides a [Uuid] instance for client-side ID generation.
final uuidProvider = Provider<Uuid>((_) => const Uuid());

// ─────────────────────────────────────────────────── State layer providers ──

/// Manages the habits state machine.
final habitsNotifierProvider =
    NotifierProvider<HabitsNotifier, HabitsState>(HabitsNotifier.new);

// ──────────────────────────────────────────────── Categories provider ──

/// Fetches categories from the API. Auto-refreshes on dependency change.
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(getCategoriesUseCaseProvider)();
});
