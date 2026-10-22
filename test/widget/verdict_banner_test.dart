import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unmai/core/theme/app_theme.dart';
import 'package:unmai/core/widgets/verdict_banner.dart';

void main() {
  group('VerdictBanner Widget Tests', () {
    testWidgets('Renders True verdict with check icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerdictBanner(verdict: VerdictType.true_),
          ),
        ),
      );

      expect(find.text('VERDICT'), findsOneWidget);
      expect(find.text('True'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Renders False verdict with cancel icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerdictBanner(verdict: VerdictType.false_),
          ),
        ),
      );

      expect(find.text('False'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('Renders Misleading verdict with warning icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerdictBanner(verdict: VerdictType.misleading),
          ),
        ),
      );

      expect(find.text('Misleading'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('Renders Can\'t verify verdict with help icon and label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerdictBanner(verdict: VerdictType.unverified),
          ),
        ),
      );

      expect(find.text("Can't verify"), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });
  });
}
