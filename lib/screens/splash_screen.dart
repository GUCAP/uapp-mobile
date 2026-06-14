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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.90, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
          // ── Background gradient (dark teal) ──────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001A1C), Color(0xFF000A0A)],
              ),
            ),
          ),

          // ── Background shape overlay (barely visible) ─────────
          Positioned.fill(
            child: Opacity(
              opacity: 0.13,
              child: CustomPaint(painter: _ShapeOverlayPainter()),
            ),
          ),

          // ── Beam — from top, full height ──────────────────────
          Positioned(
            top: 0,
            child: FadeTransition(
              opacity: _fade,
              child: Image.asset(
                'assets/images/beam.png',
                width: size.width * 0.36,
                height: size.height * 0.58,
                fit: BoxFit.fill,
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Offset up so logo sits over beam base
                  SizedBox(height: size.height * 0.04),

                  // Real UAPP app icon (sp_logo) — centred
                  Image.asset(
                    'assets/images/sp_logo.png',
                    width: size.width * 0.42,
                    height: size.width * 0.42,
                  ),

                  const SizedBox(height: 28),

                  // UAPP wordmark
                  const Text(
                    'UAPP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline in brand teal
                  const Text(
                    'Global University College\nApplications Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF019088),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.65,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom domain ──────────────────────────────────────
          Positioned(
            bottom: size.height * 0.07,
            child: FadeTransition(
              opacity: _fade,
              child: Text(
                'uapp.uk',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.20),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Subtle background shape — approximates the spalshScreen_shape.svg star/snowflake
class _ShapeOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.40;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Concentric rings (matches the SVG's circular motion)
    for (final r in [s.width * 0.18, s.width * 0.36, s.width * 0.54, s.width * 0.72]) {
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // 12 radial spokes
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      canvas.drawLine(
        Offset(cx + s.width * 0.18 * math.cos(angle), cy + s.width * 0.18 * math.sin(angle)),
        Offset(cx + s.width * 0.72 * math.cos(angle), cy + s.width * 0.72 * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
