import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VerdictBanner extends StatelessWidget {
  final VerdictType verdict;
  final String? customLabel;
  final bool isLarge;

  const VerdictBanner({
    super.key,
    required this.verdict,
    this.customLabel,
    this.isLarge = true,
  });

  String _defaultLabel(VerdictType type) {
    switch (type) {
      case VerdictType.true_:
        return 'True';
      case VerdictType.false_:
        return 'False';
      case VerdictType.misleading:
        return 'Misleading';
      case VerdictType.unverified:
        return "Can't verify";
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.verdictColor(verdict);
    final bgColor = AppColors.verdictLightColor(verdict);
    final borderColor = AppColors.verdictBorderColor(verdict);
    final icon = AppColors.verdictIcon(verdict);
    final label = customLabel ?? _defaultLabel(verdict);

    if (!isLarge) {
      // Compact badge for lists and cards
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'VERDICT',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
