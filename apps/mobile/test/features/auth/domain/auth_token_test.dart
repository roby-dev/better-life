import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

void main() {
  group('AuthToken', () {
    const token = AuthToken(value: 'abc.def.ghi');

    test('stores the raw JWT string', () {
      expect(token.value, 'abc.def.ghi');
    });

    test('two tokens with the same value are equal', () {
      const other = AuthToken(value: 'abc.def.ghi');
      expect(token, equals(other));
    });

    test('two tokens with different values are not equal', () {
      const other = AuthToken(value: 'xxx.yyy.zzz');
      expect(token, isNot(equals(other)));
    });

    test('hashCode is consistent with equality', () {
      const other = AuthToken(value: 'abc.def.ghi');
      expect(token.hashCode, equals(other.hashCode));
    });

    test('value is never empty when constructed with a non-empty string', () {
      expect(token.value.isNotEmpty, isTrue);
    });
  });
}
