/// Shared test harness for S12 integration / smoke tests.
///
/// Builds a [ProviderScope] wrapping the full [BetterLifeApp] with the
/// minimal set of overrides that make widget-level integration tests possible
/// without touching platform channels or real HTTP:
///
///  - [tokenStorageProvider]           → [InMemoryTokenStorage] (no Keystore)
///  - [appConfigProvider]              → [AppConfig] pointing at a test base URL
///  - [timezoneResolverProvider]       → [FakeTimezoneResolver] → "America/Lima"
///  - [authRemoteDataSourceProvider]   → [FakeAuthRemoteDataSource] so tests
///                                       can stub login/register without Dio.
///
/// Rationale for using [FakeAuthRemoteDataSource] over [DioAdapter]:
/// [http_mock_adapter ^0.6.1] requires exact `data` match when the [Dio]
/// instance has custom `BaseOptions.headers`. Since integration tests drive
/// the real form → notifier pipeline, the exact body isn't known up front.
/// A fake datasource is simpler, faster, and avoids this coupling.
// ignore_for_file: unnecessary_library_name
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/app/app.dart';
import 'package:better_life_app/core/config/app_config.dart';
import 'package:better_life_app/core/config/app_config_provider.dart';
import 'package:better_life_app/core/platform/timezone_providers.dart';
import 'package:better_life_app/core/platform/timezone_resolver.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/dtos/auth_response_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/core/error/failure.dart';

// ── Fake timezone resolver ────────────────────────────────────────────────────

/// Always returns "America/Lima" — avoids flutter_timezone platform channel.
class FakeTimezoneResolver implements TimezoneResolver {
  @override
  Future<String> resolve() async => 'America/Lima';
}

// ── Fake remote data source ───────────────────────────────────────────────────

/// Configurable fake for [AuthRemoteDataSource].
///
/// Call [succeedWith] or [failWith] before the test to configure the response.
/// Defaults to success for both login and register.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _defaultToken = 'test-jwt-token-integration';

  Failure? _loginFailure;
  Failure? _registerFailure;
  String _accessToken = _defaultToken;

  /// Configures a successful login/register response with [token].
  void succeedWith([String token = _defaultToken]) {
    _loginFailure = null;
    _registerFailure = null;
    _accessToken = token;
  }

  /// Configures login to fail with [failure].
  void failLoginWith(Failure failure) => _loginFailure = failure;

  /// Configures register to fail with [failure].
  void failRegisterWith(Failure failure) => _registerFailure = failure;

  @override
  Future<AuthResponseDto> login(LoginRequestDto dto) async {
    if (_loginFailure != null) throw _loginFailure!;
    return AuthResponseDto(accessToken: _accessToken);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto dto) async {
    if (_registerFailure != null) throw _registerFailure!;
    return AuthResponseDto(accessToken: _accessToken);
  }
}

// ── Harness ───────────────────────────────────────────────────────────────────

/// Test fixture that owns an [InMemoryTokenStorage] and a
/// [FakeAuthRemoteDataSource] so integration tests can pre-seed storage
/// and stub HTTP responses without touching Dio or network stacks.
class IntegrationHarness {
  static const accessToken = 'test-jwt-token-integration';

  final InMemoryTokenStorage tokenStorage = InMemoryTokenStorage();
  final FakeAuthRemoteDataSource fakeDataSource = FakeAuthRemoteDataSource();

  // ── HTTP stubs (delegated to FakeAuthRemoteDataSource) ─────────────────────

  /// Stubs login + register to return a valid token (default behaviour).
  void mockLoginSuccess() => fakeDataSource.succeedWith();

  /// Stubs login to fail with an [AuthFailure] (e.g., 401).
  void mockLoginFailure(int statusCode, String title) {
    fakeDataSource.failLoginWith(
      AuthFailure(title: title, statusCode: statusCode),
    );
  }

  /// Stubs register to return a valid token.
  void mockRegisterSuccess() => fakeDataSource.succeedWith();

  /// Stubs register to fail with an [AuthFailure] (e.g., 409).
  void mockRegisterFailure(int statusCode, String title) {
    fakeDataSource.failRegisterWith(
      AuthFailure(title: title, statusCode: statusCode),
    );
  }

  // ── Widget factory ──────────────────────────────────────────────────────────

  /// Returns a fully-wired [ProviderScope] + [BetterLifeApp] widget.
  Widget build() {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(apiBaseUrl: 'http://test.local'),
        ),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        authRemoteDataSourceProvider.overrideWithValue(fakeDataSource),
        timezoneResolverProvider.overrideWithValue(FakeTimezoneResolver()),
      ],
      child: const BetterLifeApp(),
    );
  }
}

// ── Pump helpers ──────────────────────────────────────────────────────────────

/// Drains the deferred gate timer + the 2500ms splash floor.
///
/// Call after [tester.pumpWidget] to advance past the splash screen.
/// Uses 6 seconds to comfortably clear the 2500ms minimum gate.
Future<void> pumpPastSplash(WidgetTester tester) async {
  // Drain the Future<void>(_runGate) deferred scheduling.
  await tester.pump(Duration.zero);
  // Drain the 2500ms floor + any remaining timer.
  await tester.pump(const Duration(seconds: 6));
}
