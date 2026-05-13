import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leafy_app/data/services/session_service.dart';
import 'dart:async';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

    _animController.forward();

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final isLoggedIn = SessionService().isLoggedIn;
        if (isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F0),
      body: Stack(
        children: [
          const _BackgroundWatermark(),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppIcon(),

                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6DB33F), Color(0xFF3A7D1E)],
                      ).createShader(bounds),
                      child: const Text(
                        'Leafy',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          height: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Deteksi kesehatan daun tanamanmu\ndengan mudah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF5A7A4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A9A2E), Color(0xFF3D6B1A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7C3F).withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(64, 64),
          painter: _ScanLeafPainter(),
        ),
      ),
    );
  }
}

class _BackgroundWatermark extends StatelessWidget {
  const _BackgroundWatermark();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(painter: _WatermarkPainter()),
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A7D1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final positions = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.80, size.height * 0.08),
      Offset(size.width * 0.05, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.38),
      Offset(size.width * 0.25, size.height * 0.78),
      Offset(size.width * 0.70, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.92),
      Offset(size.width * 0.92, size.height * 0.65),
      Offset(size.width * 0.10, size.height * 0.88),
    ];

    final scales = [1.2, 0.9, 1.5, 1.0, 1.3, 0.8, 1.1, 0.7, 1.4];
    final rotations = [0.0, 0.5, -0.3, 0.8, -0.6, 0.2, -0.9, 0.4, -0.2];

    for (int i = 0; i < positions.length; i++) {
      canvas.save();
      canvas.translate(positions[i].dx, positions[i].dy);
      canvas.rotate(rotations[i]);
      canvas.scale(scales[i]);

      final path = Path();
      path.moveTo(0, -28);
      path.cubicTo(22, -28, 22, 8, 0, 28);
      path.cubicTo(-22, 8, -22, -28, 0, -28);
      path.close();

      canvas.drawPath(path, paint);

      canvas.drawLine(
        const Offset(0, -22),
        const Offset(0, 22),
        paint..strokeWidth = 1.0,
      );
      paint.strokeWidth = 1.8;
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final leafPaint = Paint()
      ..color = const Color(0xFF8AB83A)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(cx, cy - size.height * 0.42);
    leafPath.cubicTo(
      cx + size.width * 0.42,
      cy - size.height * 0.42,
      cx + size.width * 0.42,
      cy + size.height * 0.12,
      cx,
      cy + size.height * 0.42,
    );
    leafPath.cubicTo(
      cx - size.width * 0.42,
      cy + size.height * 0.12,
      cx - size.width * 0.42,
      cy - size.height * 0.42,
      cx,
      cy - size.height * 0.42,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    final scanPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const double margin = 8.0;
    const double bracketLen = 10.0;

    canvas.drawLine(
      Offset(margin, margin + bracketLen),
      Offset(margin, margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + bracketLen, margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin - bracketLen, margin),
      Offset(size.width - margin, margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketLen),
      scanPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin - bracketLen),
      Offset(margin, size.height - margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketLen, size.height - margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin - bracketLen, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      scanPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketLen),
      scanPaint,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.16,
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      3.0,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill,
    );

    canvas.drawLine(
      Offset(cx, cy - size.height * 0.35),
      Offset(cx, cy + size.height * 0.35),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
