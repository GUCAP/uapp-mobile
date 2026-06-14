import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Dark teal gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001A1C), Color(0xFF000A0A)],
              ),
            ),
          ),

          // Decorative background snowflake rings
          Opacity(
            opacity: 0.12,
            child: CustomPaint(
              size: Size(size.width, size.height),
              painter: _RingsPainter(),
            ),
          ),

          // Vertical beam (real asset from CRM app)
          FadeTransition(
            opacity: _fade,
            child: Image.asset(
              'assets/images/beam.png',
              width: size.width * 0.38,
              height: size.height * 0.65,
              fit: BoxFit.fill,
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.06),

                  // Real app splash icon from CRM APK
                  Image.asset(
                    'assets/images/sp_logo.png',
                    width: size.width * 0.46,
                    height: size.width * 0.46,
                  ),

                  const SizedBox(height: 30),

                  // UAPP wordmark
                  const Text(
                    'UAPP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Real tagline from CRM app
                  const Text(
                    'Global University College\nApplications Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF019088),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom domain
          Positioned(
            bottom: size.height * 0.07,
            child: FadeTransition(
              opacity: _fade,
              child: Text(
                'uapp.uk',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.22),
                  fontSize: 12,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative concentric rings (from spalshScreen_shape styling)
class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.44;
    final paint = Paint()
      ..color = const Color(0xFF045D5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final r in [80.0, 160.0, 240.0, 320.0]) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Radial lines
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      canvas.drawLine(
        Offset(cx + 80 * math.cos(angle), cy + 80 * math.sin(angle)),
        Offset(cx + 320 * math.cos(angle), cy + 320 * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
