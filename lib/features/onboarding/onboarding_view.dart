import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _buttonAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
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
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        _buildAppIcon(),

                        const SizedBox(height: 24),

                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6DB33F),
                              Color(0xFF3A7D1E),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Leafy',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              height: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF5A7A4A),
                            ),
                            children: [
                              TextSpan(
                                text: 'Deteksi ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: 'kesehatan daun tanamanmu\n',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: 'dengan mudah',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                FadeTransition(
                  opacity: _buttonAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 12),
                    child: Column(
                      children: [
                        _buildMulaiButton(context),

                        const SizedBox(height: 20),

                        _buildTermsText(context),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5A9A2E),
            Color(0xFF3D6B1A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7C3F).withOpacity(0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(56, 56),
          painter: _ScanLeafPainter(),
        ),
      ),
    );
  }

  Widget _buildMulaiButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.go('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 135, 86, 0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          shadowColor: const Color(0xFF3A7D1E).withOpacity(0.4),
        ),
        child: const Text(
          'Mulai Sekarang',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF7A9A6A),
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'Dengan melanjutkan, kamu menyetujui\n'),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: Color(0xFF3A7D1E),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF3A7D1E),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
              },
          ),
          const TextSpan(text: ' · '),
          TextSpan(
            text: 'Terms of service',
            style: const TextStyle(
              color: Color(0xFF3A7D1E),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF3A7D1E),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
              },
          ),
        ],
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
        opacity: 0.07,
        child: CustomPaint(
          painter: _WatermarkPainter(),
        ),
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
      cx + size.width * 0.42, cy - size.height * 0.42,
      cx + size.width * 0.42, cy + size.height * 0.12,
      cx, cy + size.height * 0.42,
    );
    leafPath.cubicTo(
      cx - size.width * 0.42, cy + size.height * 0.12,
      cx - size.width * 0.42, cy - size.height * 0.42,
      cx, cy - size.height * 0.42,
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

    canvas.drawLine(Offset(margin, margin + bracketLen), Offset(margin, margin), scanPaint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + bracketLen, margin), scanPaint);


    canvas.drawLine(Offset(size.width - margin - bracketLen, margin), Offset(size.width - margin, margin), scanPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + bracketLen), scanPaint);

    canvas.drawLine(Offset(margin, size.height - margin - bracketLen), Offset(margin, size.height - margin), scanPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + bracketLen, size.height - margin), scanPaint);

    canvas.drawLine(Offset(size.width - margin - bracketLen, size.height - margin), Offset(size.width - margin, size.height - margin), scanPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - bracketLen), scanPaint);

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