import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import '../data/mock_data.dart';
import '../models/user.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController(text: 'shamim@uapp.uk');
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  bool _showSwitcher = false;

  // Map email → userId for demo accounts
  final _accounts = {
    'shamim@uapp.uk':   'u-shamim',
    'andreea@uapp.uk':  'u-andreea',
    'jennifer@uapp.uk': 'u-jennifer',
    'raj@uapp.uk':      'u-raj',
    'nur@uapp.uk':      'u-nur',
  };

  @override
  void dispose() {
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
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() { _error = 'Invalid email or password. Try one of the demo accounts below.'; _loading = false; });
    }
  }

  void _switchAccount(AppUser user) {
    currentUserIdNotifier.value = user.id;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ShellScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Teal header arc with logo ───────────────────────
              Stack(
                children: [
                  // Teal half-circle background
                  ClipPath(
                    clipper: _ArcClipper(),
                    child: Container(
                      width: size.width,
                      height: size.height * 0.42,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: 1.2,
                          colors: [const Color(0xFF00D4D4), AppColors.primary],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: _LogoWithCap(size: size.width * 0.28),
                      ),
                    ),
                  ),
                  // Go Back button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: Colors.white),
                        label: const Text('Go Back', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Form section ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log In to your Account',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email and password to log in',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    _Label('Email'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailCtrl,
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Password
                    _Label('Password'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _passwordCtrl,
                      hint: 'Enter Password',
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.4), size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text('Forgot Password ?',
                            style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    ],

                    const SizedBox(height: 28),

                    // Log In button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Or divider
                    Row(children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('Or', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
                    ]),
                    const SizedBox(height: 18),

                    // Sign up
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                            children: const [
                              TextSpan(text: "Don't Have An Account?  "),
                              TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Account switcher ─────────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _showSwitcher = !_showSwitcher),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryLight, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('Switch Account', style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                            ),
                            AnimatedRotation(
                              turns: _showSwitcher ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.4), size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: _showSwitcher
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                ...kUsers
                                    .where((u) => u.type != UserType.student)
                                    .take(6)
                                    .map((u) => _AccountTile(
                                          user: u,
                                          isActive: currentUserIdNotifier.value == u.id,
                                          onTap: () => _switchAccount(u),
                                        )),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
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

// ── Supporting widgets ────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13.5, fontWeight: FontWeight.w600));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;

  const _InputField({
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
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffix,
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final AppUser user;
  final bool isActive;
  final VoidCallback onTap;
  const _AccountTile({required this.user, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: user.color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(user.role, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11.5)),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 20)
            else
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.25), size: 14),
          ],
        ),
      ),
    );
  }
}

class _LogoWithCap extends StatelessWidget {
  final double size;
  const _LogoWithCap({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size * 1.1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(bottom: 0, child: _UShapeWhite(width: size * 0.6, height: size * 0.5)),
          Positioned(top: 0, child: _CapOrange(width: size * 0.7)),
        ],
      ),
    );
  }
}

class _UShapeWhite extends StatelessWidget {
  final double width, height;
  const _UShapeWhite({required this.width, required this.height});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, height), painter: _UPainter());
}

class _UPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = s.width * 0.15..strokeCap = StrokeCap.round;
    c.drawPath(Path()
      ..moveTo(s.width * 0.12, 0)
      ..lineTo(s.width * 0.12, s.height * 0.55)
      ..arcToPoint(Offset(s.width * 0.88, s.height * 0.55), radius: Radius.circular(s.width * 0.4), clockwise: false)
      ..lineTo(s.width * 0.88, 0), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _CapOrange extends StatelessWidget {
  final double width;
  const _CapOrange({required this.width});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(width, width * 0.5), painter: _CapPainter());
}

class _CapPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawPath(
      Path()..moveTo(0, s.height * 0.45)..lineTo(s.width/2, 0)..lineTo(s.width, s.height * 0.45)..lineTo(s.width/2, s.height * 0.9)..close(),
      Paint()..color = AppColors.orange..style = PaintingStyle.fill,
    );
    c.drawCircle(Offset(s.width/2, s.height * 0.45), s.width * 0.06, Paint()..color = Colors.white);
    final t = Paint()..color = AppColors.orange..strokeWidth = s.width * 0.045..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    c.drawLine(Offset(s.width * 0.82, s.height * 0.45), Offset(s.width * 0.82, s.height * 0.95), t);
    c.drawCircle(Offset(s.width * 0.82, s.height), s.width * 0.05, Paint()..color = AppColors.orange);
  }
  @override bool shouldRepaint(_) => false;
}

class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height + 30, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_) => false;
}
