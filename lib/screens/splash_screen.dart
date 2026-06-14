import 'package:flutter/material.dart';
import '../core/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
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
    final iconSize = size.width * 0.515;  // 226/440 ≈ 51.5%
    final iconTop  = size.height * 0.196; // 189/968 ≈ 19.6%

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // ── Diagonal stripe pattern (#8BDA09 @ 25%) ──────────
            Positioned.fill(
              child: CustomPaint(painter: _DiagonalStripesPainter()),
            ),

            // ── Large teal circle glow behind icon ────────────────
            Positioned(
              left: size.width / 2 - size.width * 0.348,
              top: iconTop + iconSize / 2 - size.width * 0.348,
              child: Container(
                width: size.width * 0.696,
                height: size.width * 0.696,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF045D5E).withValues(alpha: 0.85),
                      const Color(0xFF045D5E).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Light beam ellipses above icon (god rays) ─────────
            // Outer wide beam
            Positioned(
              left: size.width * 0.15,
              top: 0,
              child: Container(
                width: size.width * 0.7,
                height: iconTop + iconSize * 0.55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF00D4D4).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            // Narrow bright inner beam
            Positioned(
              left: size.width * 0.35,
              top: 0,
              child: Container(
                width: size.width * 0.3,
                height: iconTop + iconSize * 0.45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),

            // ── Rounded square app icon ───────────────────────────
            Positioned(
              left: size.width * 0.241, // 106/440
              top: iconTop,
              child: _AppIcon(size: iconSize),
            ),

            // ── Tagline text ──────────────────────────────────────
            Positioned(
              left: 0, right: 0,
              top: iconTop + iconSize + size.height * 0.048,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Discover Your Path to the\nWorld\'s Best Universities',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Diagonal stripe background ────────────────────────────────
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8BDA09).withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gap = 3.47; // ~3.47px matches SVG line density
    final diag = size.width + size.height;
    for (double d = -diag; d < diag; d += gap) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── App icon (rounded square with teal bg + logo inside) ──────
class _AppIcon extends StatelessWidget {
  final double size;
  const _AppIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.141; // 31.8/225.6 ≈ 14.1%

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            Color(0xFF067A7B),
            Color(0xFF045D5E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF045D5E).withValues(alpha: 0.6),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFF00D4D4).withValues(alpha: 0.25),
            blurRadius: 60,
            spreadRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner diagonal stripe texture on the icon
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: CustomPaint(
              size: Size(size, size),
              painter: _DiagonalStripesPainter(),
            ),
          ),
          // Radial overlay (brighter center)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Logo: cap + U
          Center(
            child: SizedBox(
              width: size * 0.62,
              height: size * 0.72,
              child: CustomPaint(painter: _IconLogoPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon logo — flat cyan cap + white U ───────────────────────
class _IconLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // ── Graduation cap ──────────────────────────────────────
    final capColor = const Color(0xFF00D4D4);
    final capPaint = Paint()..color = capColor..style = PaintingStyle.fill;

    // Board (diamond/rhombus)
    final board = Path()
      ..moveTo(s.width * 0.5, 0)
      ..lineTo(s.width * 0.95, s.height * 0.2)
      ..lineTo(s.width * 0.5, s.height * 0.4)
      ..lineTo(s.width * 0.05, s.height * 0.2)
      ..close();
    canvas.drawPath(board, capPaint);

    // Cap top highlight
    final hlPaint = Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.fill;
    final hl = Path()
      ..moveTo(s.width * 0.5, 0)
      ..lineTo(s.width * 0.95, s.height * 0.2)
      ..lineTo(s.width * 0.5, s.height * 0.4)
      ..close();
    canvas.drawPath(hl, hlPaint);

    // Center button
    canvas.drawCircle(
      Offset(s.width * 0.5, s.height * 0.2),
      s.width * 0.045,
      Paint()..color = Colors.white,
    );

    // Tassel line
    final tasselPaint = Paint()
      ..color = capColor
      ..strokeWidth = s.width * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(s.width * 0.84, s.height * 0.2),
      Offset(s.width * 0.84, s.height * 0.42),
      tasselPaint,
    );
    // Tassel ball
    canvas.drawCircle(
      Offset(s.width * 0.84, s.height * 0.46),
      s.width * 0.04,
      Paint()..color = capColor,
    );

    // ── U shape (white) ─────────────────────────────────────
    final uPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final uPath = Path()
      ..moveTo(s.width * 0.15, s.height * 0.42)
      ..lineTo(s.width * 0.15, s.height * 0.72)
      ..arcToPoint(
        Offset(s.width * 0.85, s.height * 0.72),
        radius: Radius.circular(s.width * 0.38),
        clockwise: false,
      )
      ..lineTo(s.width * 0.85, s.height * 0.42);

    canvas.drawPath(uPath, uPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
