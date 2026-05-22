import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/screens/habit_form_screen.dart';

void main() {
  Widget makeWidget({String? habitId}) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref) async => [
              const Category(
                id: 'cat-1',
                name: 'Salud',
                color: '#E26D5A',
                icon: 'heart',
              ),
              const Category(
                id: 'cat-2',
                name: 'Productividad',
                color: '#5A9EE2',
                icon: 'briefcase',
              ),
            ]),
      ],
      child: MaterialApp(
        home: HabitFormScreen(habitId: habitId),
      ),
    );
  }

  group('HabitFormScreen', () {
    testWidgets('renders name field', (tester) async {
      await tester.pumpWidget(makeWidget());
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('save button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pumpAndSettle();
      final button = find.widgetWithText(ElevatedButton, 'Guardar');
      expect(button, findsOneWidget);
      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNull);
    });

    testWidgets('category chips render from provider', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('Productividad'), findsOneWidget);
    });

    testWidgets('selecting a category chip enables save', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salud'));
      await tester.pumpAndSettle();

      // Enter name so save is valid
      await tester.enterText(find.byType(TextFormField).first, 'Run');
      await tester.pumpAndSettle();

      final button = find.widgetWithText(ElevatedButton, 'Guardar');
      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNotNull);
    });
  });
}
