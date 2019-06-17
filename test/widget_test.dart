import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rest/main.dart';

void main() {
  group('HomeWidget', () {
    testWidgets('Increments timer by 5 min', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.text('20:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('25:00'), findsOneWidget);
    });

    testWidgets('Decrements timer by 5 min', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());


      expect(find.text('20:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('15:00'), findsOneWidget);
    });

    testWidgets('Hide buttons after start timer', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.text('start'));
      await tester.pump();

      final bool Function(Widget w) buttonPredicate = (Widget w) => w is Visibility && !w.visible;
      expect(find.text('stop'), findsOneWidget);
      expect(find.byWidgetPredicate(buttonPredicate), findsNWidgets(2));
    });
  });
}
