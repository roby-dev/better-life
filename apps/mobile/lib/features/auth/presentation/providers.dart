import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/http/http_providers.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';

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

// ─────────────────────────────────────────────────────────── S5 providers ──
// loginUseCaseProvider, registerUseCaseProvider, authNotifierProvider,
// signUpFormProvider, loginFormProvider — added in Slice S5.
