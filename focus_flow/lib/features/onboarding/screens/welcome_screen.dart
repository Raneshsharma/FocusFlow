import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Wave illustration
              _WaveIllustration(),

              const Spacer(flex: 1),

              // Headline
              Text(
                'Work with your brain,\nnot against it',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 12),

              // Subtext
              Text(
                'FocusFlow helps you match tasks to your energy — not the other way around.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppColors.grey500,
                ),
              ),

              const Spacer(flex: 2),

              // Continue button
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 16),

              // Skip link
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.grey400,
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: const Text('Skip for now'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 140,
      child: CustomPaint(
        painter: _WavePainter(),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌊', style: TextStyle(fontSize: 28)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = AppColors.teal.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final navyPaint = Paint()
      ..color = AppColors.navy.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.28, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.72, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, tealPaint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.38, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.82, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, navyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}