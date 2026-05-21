import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLTextField', () {
    testWidgets('renders label and placeholder', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'tucorreo@ejemplo.com',
          onChanged: (_) {},
        ),
      ));
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('tucorreo@ejemplo.com'), findsOneWidget);
    });

    testWidgets('renders leading icon', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'tucorreo@ejemplo.com',
          leadingIcon: Icons.mail_outline,
          onChanged: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    });

    testWidgets('shows valid badge when isValid is true and no trailing', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'p',
          isValid: true,
          onChanged: (_) {},
        ),
      ));
      // Valid badge is a Container with a check icon inside
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('shows error text when errorText is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'p',
          errorText: 'Correo no válido',
          onChanged: (_) {},
        ),
      ));
      expect(find.text('Correo no válido'), findsOneWidget);
    });

    testWidgets('does not show valid badge when errorText is set', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'p',
          isValid: true,
          errorText: 'Correo no válido',
          onChanged: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('shows trailing widget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Password',
          placeholder: 'p',
          trailing: const Icon(Icons.visibility, key: Key('eye')),
          onChanged: (_) {},
        ),
      ));
      expect(find.byKey(const Key('eye')), findsOneWidget);
    });

    testWidgets('hides valid badge when trailing is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Password',
          placeholder: 'p',
          isValid: true,
          trailing: const Icon(Icons.visibility),
          onChanged: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('calls onChanged with new value', (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'p',
          onChanged: (v) => captured = v,
        ),
      ));
      await tester.enterText(find.byType(TextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Password',
          placeholder: 'p',
          obscureText: true,
          onChanged: (_) {},
        ),
      ));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.obscureText, isTrue);
    });

    testWidgets('uses email keyboard type when specified', (tester) async {
      await tester.pumpWidget(_wrap(
        BLTextField(
          label: 'Email',
          placeholder: 'p',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {},
        ),
      ));
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.keyboardType, TextInputType.emailAddress);
    });
  });
}
