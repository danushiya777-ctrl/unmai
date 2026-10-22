import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressSteps extends StatelessWidget {
  final int currentStep; // 0: Reading, 1: Searching, 2: Checking media, 3: Result

  const ProgressSteps({
    super.key,
    required this.currentStep,
  });

  static const List<String> steps = [
    'Reading content',
    'Searching sources',
    'Checking media',
    'Preparing result',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verifying information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.trueGreen
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : isCurrent
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 24,
                        color: isCompleted
                            ? AppColors.trueGreen
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : isCompleted
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color: isCurrent
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
