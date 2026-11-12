import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FlousLogo extends StatelessWidget {
  final double size;
  final bool showSlogan;
  const FlousLogo({super.key, this.size = 72, this.showSlogan = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size(size, size), painter: _FlousLogoPainter()),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'FLOUS', style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              TextSpan(text: '.COM', style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
        ),
        if (showSlogan) ...[
          const SizedBox(height: 6),
          const Text('المصروف عليك و الباقي علينا', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

class _FlousLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width, h = size.height;
    final Paint bluePaint = Paint()
      ..shader = const LinearGradient(colors: [AppColors.secondary, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.12, w * 0.22, h * 0.76), Radius.circular(w * 0.1)), bluePaint);

    final Path topPath = Path()
      ..moveTo(w * 0.18, h * 0.12)..lineTo(w * 0.78, h * 0.12)
      ..quadraticBezierTo(w * 0.88, h * 0.12, w * 0.88, h * 0.26)
      ..quadraticBezierTo(w * 0.88, h * 0.36, w * 0.76, h * 0.36)..lineTo(w * 0.40, h * 0.36)..close();
    canvas.drawPath(topPath, bluePaint);

    final Path midPath = Path()
      ..moveTo(w * 0.18, h * 0.44)..lineTo(w * 0.62, h * 0.44)
      ..quadraticBezierTo(w * 0.70, h * 0.44, w * 0.70, h * 0.54)
      ..quadraticBezierTo(w * 0.70, h * 0.64, w * 0.60, h * 0.64)..lineTo(w * 0.40, h * 0.64)..close();
    canvas.drawPath(midPath, bluePaint);

    canvas.drawCircle(Offset(w * 0.80, h * 0.54), w * 0.09, Paint()..color = AppColors.income);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
