import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = false,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.62, size * 0.62),
          painter: _SpeechBubbleCheckPainter(),
        ),
      ),
    );

    if (!showText && !showTagline) {
      return icon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        if (showText) ...[
          const SizedBox(height: 14),
          const Text(
            'Unmai',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          const Text(
            'Check before you share.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SpeechBubbleCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final checkPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw speech bubble with smooth rounded corners and small pointer
    final w = size.width;
    final h = size.height;
    final r = w * 0.22;

    final bubblePath = Path();
    bubblePath.moveTo(r, 0);
    bubblePath.lineTo(w - r, 0);
    bubblePath.quadraticBezierTo(w, 0, w, r);
    bubblePath.lineTo(w, h * 0.72 - r);
    bubblePath.quadraticBezierTo(w, h * 0.72, w - r, h * 0.72);
    // speech pointer on bottom-left
    bubblePath.lineTo(w * 0.44, h * 0.72);
    bubblePath.lineTo(w * 0.22, h * 0.96);
    bubblePath.lineTo(w * 0.26, h * 0.72);
    bubblePath.lineTo(r, h * 0.72);
    bubblePath.quadraticBezierTo(0, h * 0.72, 0, h * 0.72 - r);
    bubblePath.lineTo(0, r);
    bubblePath.quadraticBezierTo(0, 0, r, 0);
    bubblePath.close();

    canvas.drawPath(bubblePath, bubblePaint);

    // Draw check mark inside the bubble
    final checkPath = Path();
    checkPath.moveTo(w * 0.28, h * 0.38);
    checkPath.lineTo(w * 0.44, h * 0.54);
    checkPath.lineTo(w * 0.74, h * 0.24);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
