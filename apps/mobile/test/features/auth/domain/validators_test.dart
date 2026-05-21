import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/features/auth/domain/validators.dart';

void main() {
  // ---------------------------------------------------------------------------
  // nameValidator
  // ---------------------------------------------------------------------------
  group('nameValidator', () {
    test('returns null for a name with 2+ non-space characters', () {
      expect(nameValidator('Ana'), isNull);
    });

    test('returns null for a name that is exactly 2 characters after trimming', () {
      expect(nameValidator('  Jo  '), isNull);
    });

    test('returns error message for a single character (trimmed)', () {
      expect(nameValidator('A'), 'Demasiado corto');
    });

    test('returns error message for empty string', () {
      expect(nameValidator(''), 'Demasiado corto');
    });

    test('returns error message for null', () {
      expect(nameValidator(null), 'Demasiado corto');
    });

    test('returns error message for whitespace-only string', () {
      expect(nameValidator('   '), 'Demasiado corto');
    });
  });

  // ---------------------------------------------------------------------------
  // emailValidator
  // ---------------------------------------------------------------------------
  group('emailValidator', () {
    test('returns null for a valid email', () {
      expect(emailValidator('user@example.com'), isNull);
    });

    test('returns null for a valid email with subdomain', () {
      expect(emailValidator('user@mail.example.com'), isNull);
    });

    test('returns error for email without @', () {
      expect(emailValidator('notvalid'), 'Correo no válido');
    });

    test('returns error for email without domain', () {
      expect(emailValidator('user@'), 'Correo no válido');
    });

    test('returns error for empty string', () {
      expect(emailValidator(''), 'Correo no válido');
    });

    test('returns error for null', () {
      expect(emailValidator(null), 'Correo no válido');
    });

    test('returns error for email with spaces', () {
      expect(emailValidator('user @example.com'), 'Correo no válido');
    });

    test('returns null for typical test email', () {
      expect(emailValidator('test@test.com'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // strengthOf
  // ---------------------------------------------------------------------------
  group('strengthOf', () {
    test('empty string scores 0', () {
      expect(strengthOf(''), 0);
    });

    test('length < 8 lowercase-only scores 0 (no rule fires)', () {
      // 'abc' → length<8, no upper, no digit, no special, no length>=12.
      expect(strengthOf('abc'), 0);
    });

    test('length < 8 but with upper+digit+special still scores those 3 rules', () {
      // Spec: each rule is independent. 'Aa1!' → upper(+1), digit(+1), special(+1) = 3.
      // length<8 means +0 for that rule, but others still count.
      expect(strengthOf('Aa1!'), 3);
    });

    test('length >= 8 but only lowercase scores 1', () {
      // Only the length >= 8 rule fires.
      expect(strengthOf('abcdefgh'), 1);
    });

    test('length >= 8 + digit scores 2 (Aceptable)', () {
      expect(strengthOf('abcdefgh1'), 2);
    });

    test('length >= 8 + uppercase scores 2', () {
      expect(strengthOf('Abcdefgh'), 2);
    });

    test('length >= 8 + digit + uppercase scores 3 (Buena)', () {
      expect(strengthOf('Abcdefgh1'), 3);
    });

    test('length >= 8 + digit + uppercase + special scores 4 (Excelente)', () {
      expect(strengthOf('Abcdefg1!'), 4);
    });

    test('length >= 12 grants bonus: 4 criteria + length bonus = 4 (cap)', () {
      // length>=8(+1), uppercase(+1), digit(+1), special(+1), length>=12(+1) = 5 → capped 4
      expect(strengthOf('Aa1!secure99'), 4);
    });

    test('length >= 12 bonus can push score from 3 to 4', () {
      // lowercase only but length>=12: length>=8(+1), length>=12(+1) = 2... no, needs 3+1=4.
      // Example: 'abcdefghijkl' → length>=8(+1), length>=12(+1) = 2.
      // Use: 'Abcdefghijk1' (length 12, upper+digit+length>=8+length>=12) = 4.
      expect(strengthOf('Abcdefghijk1'), 4);
    });

    test('score is always capped at 4', () {
      expect(strengthOf('Aa1!secure9999'), 4);
    });

    test('score 1 → label Débil', () {
      expect(strengthLabels[strengthOf('abcdefgh')], 'Débil');
    });

    test('score 2 → label Aceptable', () {
      expect(strengthLabels[strengthOf('abcdefgh1')], 'Aceptable');
    });

    test('score 4 → label Excelente', () {
      expect(strengthLabels[strengthOf('Aa1!secure99')], 'Excelente');
    });
  });

  // ---------------------------------------------------------------------------
  // strengthLabels
  // ---------------------------------------------------------------------------
  group('strengthLabels', () {
    test('has 5 entries indexed 0-4', () {
      expect(strengthLabels.length, 5);
    });

    test('index 0 is empty (no password)', () {
      expect(strengthLabels[0], '');
    });

    test('index 1 is Débil', () {
      expect(strengthLabels[1], 'Débil');
    });

    test('index 2 is Aceptable', () {
      expect(strengthLabels[2], 'Aceptable');
    });

    test('index 3 is Buena', () {
      expect(strengthLabels[3], 'Buena');
    });

    test('index 4 is Excelente', () {
      expect(strengthLabels[4], 'Excelente');
    });
  });
}
