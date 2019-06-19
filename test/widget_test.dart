import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rest/main.dart';

void main() {
  group('HomeWidget', () {
    testWidgets('Increases time by 5 minutes', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyHomePage(title: 'Rest', testMode: true,),
        ),
      ));

      expect(find.text('20:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('25:00'), findsOneWidget);
    });

    testWidgets('Decreases time by 5 minutes', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyHomePage(title: 'Rest', testMode: true,),
        ),
      ));
      expect(find.text('20:00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('15:00'), findsOneWidget);
    });

    testWidgets('Hide buttons after start timer', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyHomePage(title: 'Rest', testMode: true,),
        ),
      ));
      await tester.tap(find.text('start'));
      await tester.pump();

      final bool Function(Widget w) buttonPredicate = (Widget w) => w is Visibility && !w.visible;
      expect(find.text('stop'), findsOneWidget);
      expect(find.byWidgetPredicate(buttonPredicate), findsNWidgets(2));
    });
  });
}
