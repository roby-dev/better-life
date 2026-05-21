import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/error/failure.dart';

void main() {
  group('Failure sealed class hierarchy', () {
    test('NetworkFailure has default title', () {
      const f = NetworkFailure();
      expect(f.title, 'Sin conexión');
    });

    test('NetworkFailure with custom title', () {
      const f = NetworkFailure('No hay red');
      expect(f.title, 'No hay red');
    });

    test('ValidationFailure carries field errors map', () {
      const f = ValidationFailure(
        title: 'Validation failed',
        errors: {
          'email': ['Email already taken'],
          'name': ['Too short'],
        },
      );
      expect(f.title, 'Validation failed');
      expect(f.errors['email'], ['Email already taken']);
      expect(f.errors['name'], ['Too short']);
    });

    test('AuthFailure carries statusCode', () {
      const f = AuthFailure(title: 'Unauthorized', statusCode: 401);
      expect(f.title, 'Unauthorized');
      expect(f.statusCode, 401);
    });

    test('AuthFailure with 409', () {
      const f = AuthFailure(title: 'Conflict', statusCode: 409);
      expect(f.statusCode, 409);
    });

    test('ServerFailure carries statusCode', () {
      const f = ServerFailure(title: 'Internal Error', statusCode: 500);
      expect(f.title, 'Internal Error');
      expect(f.statusCode, 500);
    });

    test('UnknownFailure carries message', () {
      const f = UnknownFailure('Something went wrong');
      expect(f.title, 'Something went wrong');
    });

    test('sealed exhaustion — switch compiles over all subtypes', () {
      // This test verifies the switch is exhaustive at compile time.
      Failure f = const NetworkFailure();
      final String label = switch (f) {
        NetworkFailure()    => 'network',
        ValidationFailure() => 'validation',
        AuthFailure()       => 'auth',
        ServerFailure()     => 'server',
        UnknownFailure()    => 'unknown',
      };
      expect(label, 'network');
    });

    test('Failure subtypes are distinct', () {
      const Failure network = NetworkFailure();
      const Failure auth    = AuthFailure(title: 'Unauthorized', statusCode: 401);
      expect(network, isA<NetworkFailure>());
      expect(auth, isA<AuthFailure>());
      expect(network, isNot(isA<AuthFailure>()));
    });
  });
}
