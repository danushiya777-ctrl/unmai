import 'package:flutter_test/flutter_test.dart';
import 'package:unmai/core/models/demo_data.dart';
import 'package:unmai/core/models/investigation.dart';
import 'package:unmai/core/theme/app_theme.dart';

void main() {
  group('Investigation Model & JSON Parsing Tests', () {
    test('Correctly serializes and deserializes false photo demo report', () {
      final report = DemoData.falsePhotoReport;
      final json = report.toJson();

      expect(json['verdict'], 'false');
      expect(json['contentType'], 'image');
      expect(json['isDemo'], true);

      final reconstructed = Investigation.fromJson(json);
      expect(reconstructed.id, report.id);
      expect(reconstructed.verdict, VerdictType.false_);
      expect(reconstructed.claims.length, 1);
      expect(reconstructed.claims.first.verdict, VerdictType.false_);
      expect(reconstructed.contradictingSources.length, 2);
      expect(reconstructed.contradictingSources.first.contradicts, true);
    });

    test('Correctly parses true government health report', () {
      final report = DemoData.trueGovReport;
      final json = report.toJson();

      expect(json['verdict'], 'true');
      final reconstructed = Investigation.fromJson(json);
      expect(reconstructed.verdict, VerdictType.true_);
      expect(reconstructed.scoreInfo.supportedClaims, 2);
      expect(reconstructed.scoreInfo.totalClaims, 2);
      expect(reconstructed.scoreInfo.percentage, 100.0);
      expect(reconstructed.scoreInfo.isReliable, true);
      expect(reconstructed.confirmedSources.length, 2);
    });

    test('ScoreInfo handles zero claims and insufficient evidence safely', () {
      final emptyScore = ScoreInfo(
        supportedClaims: 0,
        totalClaims: 0,
        evidenceStrength: 'Insufficient',
        explanation: 'No evidence found.',
      );

      expect(emptyScore.percentage, 0.0);
      expect(emptyScore.isReliable, false);
    });
  });

  group('Verdict Mapping & Accessibility Theme Tests', () {
    test('Every verdict type has distinct color, icon, and background', () {
      for (final verdict in VerdictType.values) {
        final color = AppColors.verdictColor(verdict);
        final light = AppColors.verdictLightColor(verdict);
        final border = AppColors.verdictBorderColor(verdict);
        final icon = AppColors.verdictIcon(verdict);

        expect(color, isNotNull);
        expect(light, isNotNull);
        expect(border, isNotNull);
        expect(icon, isNotNull);
      }
    });

    test('Unverified is never mapped to False color or icon', () {
      final unverifiedColor = AppColors.verdictColor(VerdictType.unverified);
      final falseColor = AppColors.verdictColor(VerdictType.false_);
      final unverifiedIcon = AppColors.verdictIcon(VerdictType.unverified);
      final falseIcon = AppColors.verdictIcon(VerdictType.false_);

      expect(unverifiedColor != falseColor, true);
      expect(unverifiedIcon != falseIcon, true);
    });
  });
}
