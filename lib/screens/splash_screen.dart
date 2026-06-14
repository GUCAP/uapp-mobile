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
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
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
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1C1C1C), Color(0xFF0D1A1A)],
                  ),
                ),
              ),

              // Centre logo
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Teal circle with logo
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
                        ],
                      ),
                      child: const _UAPPLogoMark(size: 72),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'UAPP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Discover Your Path to the\nWorld\'s Best Universities',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8ECFCF),
                        fontSize: 14,
                        height: 1.55,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom brand mark
              Positioned(
                bottom: h * 0.08,
                left: 0, right: 0,
                child: Column(
                  children: [
                    const _InfinityMark(),
                    const SizedBox(height: 10),
                    Text(
                      'uapp.uk',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// UAPP mortarboard + U logo mark used inside the teal circle
class _UAPPLogoMark extends StatelessWidget {
  final double size;
  const _UAPPLogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // U shape
          Positioned(
            bottom: size * 0.04,
            child: _UShape(width: size * 0.62, height: size * 0.52),
          ),
          // Mortarboard cap
          Positioned(
            top: size * 0.04,
            child: _MortarBoard(width: size * 0.72),
          ),
        ],
      ),
    );
  }
}

class _UShape extends StatelessWidget {
  final double width;
  final double height;
  const _UShape({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _UShapePainter(),
    );
  }
}

class _UShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.16
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(s.width * 0.12, 0)
      ..lineTo(s.width * 0.12, s.height * 0.55)
      ..arcToPoint(Offset(s.width * 0.88, s.height * 0.55),
          radius: Radius.circular(s.width * 0.4), clockwise: false)
      ..lineTo(s.width * 0.88, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MortarBoard extends StatelessWidget {
  final double width;
  const _MortarBoard({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.52,
      child: CustomPaint(painter: _MortarBoardPainter()),
    );
  }
}

class _MortarBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final orange = Paint()..color = AppColors.orange..style = PaintingStyle.fill;
    final white  = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // Board (orange flat top)
    final board = Path()
      ..moveTo(0, s.height * 0.38)
      ..lineTo(s.width / 2, 0)
      ..lineTo(s.width, s.height * 0.38)
      ..lineTo(s.width / 2, s.height * 0.76)
      ..close();
    canvas.drawPath(board, orange);

    // Center button
    canvas.drawCircle(Offset(s.width / 2, s.height * 0.38), s.width * 0.07, white);

    // Tassel
    final tasselPaint = Paint()..color = AppColors.orange..strokeWidth = s.width * 0.04..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width * 0.82, s.height * 0.38), Offset(s.width * 0.82, s.height * 0.85), tasselPaint);
    canvas.drawCircle(Offset(s.width * 0.82, s.height * 0.9), s.width * 0.05, orange);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Bottom decorative infinity / UAPP brand mark
class _InfinityMark extends StatelessWidget {
  const _InfinityMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 80,
      child: CustomPaint(painter: _InfinityPainter()),
    );
  }
}

class _InfinityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.height * 0.38;

    path.addOval(Rect.fromCircle(center: Offset(cx - r * 1.1, cy), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(cx + r * 1.1, cy), radius: r));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
