import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/http/http_providers.dart';
import 'package:better_life_app/core/platform/timezone_providers.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:better_life_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/presentation/state/login_form_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/login_form_state.dart';
import 'package:better_life_app/features/auth/presentation/state/signup_form_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/signup_form_state.dart';

// ─────────────────────────────────────────────────── Data layer providers ──

/// Provides the Dio-backed [AuthRemoteDataSource].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => DioAuthRemoteDataSource(ref.watch(dioProvider)),
);

/// Provides the [IAuthRepository] implementation.
///
/// Depends on [authRemoteDataSourceProvider] and [tokenStorageProvider].
/// Override [tokenStorageProvider] with [InMemoryTokenStorage] in tests
/// to avoid platform channel calls.
final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    storage: ref.watch(tokenStorageProvider),
  ),
);

// ─────────────────────────────────────────── Domain / use-case providers ──

/// Provides [LoginUseCase] backed by the auth repository.
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

/// Provides [RegisterUseCase] backed by the auth repository and timezone resolver.
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(timezoneResolverProvider),
  ),
);

// ─────────────────────────────────────────────────── State layer providers ──

/// Manages the authentication state machine.
///
/// Override [authRepositoryProvider] with a fake in tests.
/// The notifier starts at [AuthInitial]; call [AuthNotifier.bootstrap] from
/// [SplashScreen.initState] to resolve to [AuthAuthenticated] / [AuthUnauthenticated].
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Manages local form state for the Sign Up screen.
final signUpFormProvider =
    NotifierProvider<SignUpFormNotifier, SignUpFormState>(SignUpFormNotifier.new);

/// Manages local form state for the Login screen.
final loginFormProvider =
    NotifierProvider<LoginFormNotifier, LoginFormState>(LoginFormNotifier.new);
