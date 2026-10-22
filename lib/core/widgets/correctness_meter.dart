import 'package:flutter/material.dart';
import '../models/investigation.dart';
import '../theme/app_theme.dart';

class CorrectnessMeter extends StatelessWidget {
  final ScoreInfo scoreInfo;

  const CorrectnessMeter({super.key, required this.scoreInfo});

  Color _strengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'strong':
        return AppColors.trueGreen;
      case 'medium':
        return AppColors.misleadingAmber;
      case 'weak':
      case 'insufficient':
      default:
        return AppColors.unverifiedSlate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughEvidence = scoreInfo.isReliable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Correctness meter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (hasEnoughEvidence)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _strengthColor(
                        scoreInfo.evidenceStrength,
                      ).withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _strengthColor(
                          scoreInfo.evidenceStrength,
                        ).withAlpha(60),
                      ),
                    ),
                    child: Text(
                      '${scoreInfo.evidenceStrength} evidence',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _strengthColor(scoreInfo.evidenceStrength),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (!hasEnoughEvidence) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.unverifiedSlateLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.unverifiedSlateBorder),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.unverifiedSlate,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Not enough evidence for a reliable score.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.unverifiedSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${scoreInfo.supportedClaims} of ${scoreInfo.totalClaims} ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                          text: 'claims supported',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${scoreInfo.percentage.toInt()}% of claims',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _strengthColor(scoreInfo.evidenceStrength),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: scoreInfo.totalClaims > 0
                      ? scoreInfo.supportedClaims / scoreInfo.totalClaims
                      : 0.0,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    scoreInfo.supportedClaims == scoreInfo.totalClaims
                        ? AppColors.trueGreen
                        : scoreInfo.supportedClaims > 0
                        ? AppColors.misleadingAmber
                        : AppColors.falseRed,
                  ),
                  minHeight: 8,
                ),
              ),
              if (scoreInfo.explanation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  scoreInfo.explanation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
