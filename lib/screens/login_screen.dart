import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController(text: 'rahman@gmail.com');
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late AnimationController _entryCtrl;
  late Animation<double>   _entryAnim;

  // Each user has their own email — no Switch Account needed
  static const _accounts = {
    // Shamim Rahman (CEO / System Admin)
    'rahman@gmail.com':   'u-shamim',
    // Olivia Becker (Acme CEO)
    'olivia@gmail.com':   'u-acme-admin',
    // Md Shamim (Branch Manager Sales)
    'shamim@gmail.com':   'u-md-shamim',
    // Andreea Cinpoi (Sales Manager)
    'andreea@gmail.com':  'u-andreea',
    // Laura Tomova (Sales Team Leader)
    'laura@gmail.com':    'u-laura',
    // Tousif Sadman (Consultant)
    'tousif@gmail.com':   'u-tousif',
    // Riad Hossain (Consultant)
    'riad@gmail.com':     'u-riad',
    // Mihadul Islam (Consultant)
    'mihadul@gmail.com':  'u-mihadul',
    // Asad Fahad (Consultant)
    'asad@gmail.com':     'u-asad',
    // Jennifer Aboje (Branch Manager Admission)
    'jennifer@gmail.com': 'u-jennifer',
    // Raj Ahmed (Global Admission Manager)
    'raj@gmail.com':      'u-raj',
    // Nur Mohammad (Admission Manager)
    'nur@gmail.com':      'u-nur',
    // Md Siam (Admission Officer)
    'siam@gmail.com':     'u-siam',
    // Md Rakib (Admission Officer)
    'rakib@gmail.com':    'u-rakib',
    // Nadia Ahmed (Admission Officer)
    'nadia@gmail.com':    'u-nadia',
    // Thomas Fletcher (Admission Officer)
    'thomas@gmail.com':   'u-testa',
    // Md Roni (Admission Officer)
    'roni@gmail.com':     'u-roni',
  };

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    final userId = _accounts[_emailCtrl.text.trim().toLowerCase()];
    if (userId != null) {
      currentUserIdNotifier.value = userId;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ShellScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() { _error = 'Invalid email. Try rahman@gmail.com for the CEO account.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _entryAnim,
        child: Stack(
          children: [
            // ── Background gradient ───────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF001A1A), Colors.black],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
            // Blurred cyan glow top-right
            Positioned(
              top: -80,
              right: -60,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00FCFF).withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Go Back
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white54),
                        label: const Text('Go Back',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ),

                    // Logo + student image header area
                    SizedBox(
                      width: w,
                      height: h * 0.32,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Student image — right side, extends from top, behind logo
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: 0.65,
                              child: Image.asset(
                                'assets/images/login_image_men.png',
                                width: w * 0.48,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Real UAPP logo (orange cap + white U) — left-centre
                          Positioned(
                            left: w * 0.08,
                            bottom: 10,
                            child: Image.asset(
                              'assets/images/logo_color.png',
                              width: w * 0.42,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log In to your Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email and password to log in',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
                          ),
                          const SizedBox(height: 32),

                          // Email
                          _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _emailCtrl,
                            hint: 'rifatsf101@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),

                          // Password
                          _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _passwordCtrl,
                            hint: 'Enter Password',
                            obscure: _obscure,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white.withValues(alpha: 0.35),
                                size: 20,
                              ),
                            ),
                          ),

                          // Error
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                          ],

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                              child: const Text('Forgot Password ?',
                                  style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Log In button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.orange.withValues(alpha: 0.7), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: AppColors.orange.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 0),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.55),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Or divider
                          Row(children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Or', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13)),
                            ),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                          ]),
                          const SizedBox(height: 20),

                          // Don't have account
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 14),
                                  children: [
                                    TextSpan(text: "Don't Have An Account?  ", style: TextStyle(color: Colors.white54)),
                                    TextSpan(text: 'Sign In',
                                        style: TextStyle(color: Color(0xFF00D4D4), fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── UAPP 3D Logo ──────────────────────────────────────────────
class _UAPPLogo3D extends StatelessWidget {
  const _UAPPLogo3D();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // U shape — metallic silver (bottom portion)
          Positioned(
            bottom: 10,
            child: CustomPaint(size: const Size(130, 100), painter: _MetallicUPainter()),
          ),
          // Mortarboard — orange (top portion)
          Positioned(
            top: 0,
            child: CustomPaint(size: const Size(160, 80), painter: _MortarboardPainter()),
          ),
        ],
      ),
    );
  }
}

class _MetallicUPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD0D0D0), Color(0xFFA0A0A0), Color(0xFFE8E8E8), Color(0xFF888888)],
      stops: [0.0, 0.3, 0.65, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, s.width, s.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(s.width * 0.1, 0)
      ..lineTo(s.width * 0.1, s.height * 0.52)
      ..arcToPoint(
        Offset(s.width * 0.9, s.height * 0.52),
        radius: Radius.circular(s.width * 0.42),
        clockwise: false,
      )
      ..lineTo(s.width * 0.9, 0);

    canvas.drawPath(path, paint);

    // Inner highlight on U
    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.6), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, highlight);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MortarboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // Main board — orange gradient
    final orangeGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF9900), Color(0xFFE65C00)],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));

    final board = Path()
      ..moveTo(0, s.height * 0.42)
      ..lineTo(s.width * 0.5, 0)
      ..lineTo(s.width, s.height * 0.42)
      ..lineTo(s.width * 0.5, s.height * 0.84)
      ..close();
    canvas.drawPath(board, orangeGrad);

    // Top highlight
    final hlPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, s.width * 0.5, s.height * 0.42));
    final highlight = Path()
      ..moveTo(0, s.height * 0.42)
      ..lineTo(s.width * 0.5, 0)
      ..lineTo(s.width * 0.5, s.height * 0.84)
      ..close();
    canvas.drawPath(highlight, hlPaint);

    // Center button
    canvas.drawCircle(
      Offset(s.width * 0.5, s.height * 0.42),
      s.width * 0.055,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    // Tassel line
    final tassel = Paint()
      ..color = const Color(0xFFFF9900)
      ..strokeWidth = s.width * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(s.width * 0.82, s.height * 0.42),
      Offset(s.width * 0.82, s.height * 0.92),
      tassel,
    );
    canvas.drawCircle(
      Offset(s.width * 0.82, s.height * 0.97),
      s.width * 0.045,
      Paint()..color = const Color(0xFFFF9900),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Form helpers ──────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13.5, fontWeight: FontWeight.w600),
  );
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;

  const _LoginField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00D4D4), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 14), child: suffix) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}

