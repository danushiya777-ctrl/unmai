import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unmai/core/models/demo_data.dart';
import 'package:unmai/features/result/result_screen.dart';

void main() {
  group('ResultScreen Widget Tests', () {
    testWidgets('Renders all sections for false recycled photo report',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(investigation: DemoData.falsePhotoReport),
        ),
      );

      // Verify Demo banner
      expect(find.text('Demo data. Not a live finding.'), findsOneWidget);

      // Verify Verdict banner (False)
      expect(find.text('False'), findsAtLeastNWidgets(1));

      // Verify One-sentence plain reason
      expect(
        find.textContaining('This photo is from an accidental storage fire'),
        findsAtLeastNWidgets(1),
      );

      // Verify Correctness meter
      expect(find.text('Correctness meter'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('0 of 1')),
        findsOneWidget,
      );

      // Verify Media check card
      expect(find.text('Media check'), findsOneWidget);
      expect(find.text('Inconclusive'), findsOneWidget);

      // Verify "Why this is false" section & contradicting sources
      expect(find.text('Why this is false'), findsOneWidget);
      expect(find.text('Reuters Fact Check'), findsAtLeastNWidgets(1));

      // Verify Claim-by-claim analysis
      expect(find.text('Claim-by-claim analysis'), findsOneWidget);

      // Verify Share correction card button
      expect(find.text('Share correction card'), findsOneWidget);
    });

    testWidgets('Renders confirmed sources for true government announcement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(investigation: DemoData.trueGovReport),
        ),
      );

      // Verify True verdict
      expect(find.text('True'), findsAtLeastNWidgets(1));

      // Verify "Confirmed by" header and PIB source
      expect(find.text('Confirmed by'), findsOneWidget);
      expect(find.text('Press Information Bureau (PIB)'), findsAtLeastNWidgets(1));
    });
  });
}
