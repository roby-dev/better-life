import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/http/http_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';

// Minimal Dio for provider tests — no interceptors needed here.
Dio _buildTestDio() => Dio(BaseOptions(baseUrl: 'http://localhost'));

void main() {
  group('Data layer providers', () {
    test('authRemoteDataSourceProvider resolves as DioAuthRemoteDataSource', () {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWith((ref) => _buildTestDio()),
        ],
      );
      addTearDown(container.dispose);

      final ds = container.read(authRemoteDataSourceProvider);
      expect(ds, isA<DioAuthRemoteDataSource>());
    });

    test('authRepositoryProvider resolves as AuthRepositoryImpl', () {
      final storage = InMemoryTokenStorage();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWith((ref) => _buildTestDio()),
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<AuthRepositoryImpl>());
    });

    test('authRepositoryProvider uses the overridden tokenStorage', () async {
      final storage = InMemoryTokenStorage();
      await storage.write('pre-existing-token');

      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWith((ref) => _buildTestDio()),
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      final token = await repo.currentToken();
      expect(token?.value, 'pre-existing-token');
    });
  });
}
