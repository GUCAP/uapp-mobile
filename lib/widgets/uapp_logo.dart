import 'package:flutter/material.dart';
import '../core/theme.dart';

/// The UAPP "U" mortar-board logo used in the bottom nav.
class UAppLogo extends StatelessWidget {
  final double size;
  final Color color;

  const UAppLogo({super.key, this.size = 28, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ULogoP(color: color)),
    );
  }
}

class _ULogoP extends CustomPainter {
  final Color color;
  const _ULogoP({required this.color});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.1
      ..strokeCap = StrokeCap.round;

    // Mortar board hat brim (horizontal flat cap)
    final brimH = s.height * 0.28;
    final brimW = s.width;
    final brimY = s.height * 0.18;
    final rrect = RRect.fromLTRBR(0, brimY - brimH / 2, brimW, brimY + brimH / 2, Radius.circular(brimH * 0.3));
    canvas.drawRRect(rrect, p);

    // Center top knob
    canvas.drawCircle(Offset(s.width / 2, brimY - brimH / 2 - s.height * 0.05), s.width * 0.06, p);

    // "U" shape body (below brim)
    final uTop = brimY + brimH / 2 + s.height * 0.02;
    final uBot = s.height * 0.88;
    final uL = s.width * 0.2;
    final uR = s.width * 0.8;
    final uPath = Path()
      ..moveTo(uL, uTop)
      ..lineTo(uL, uBot - s.height * 0.14)
      ..arcToPoint(Offset(uR, uBot - s.height * 0.14), radius: Radius.circular(s.width * 0.3), clockwise: false)
      ..lineTo(uR, uTop);
    canvas.drawPath(uPath, stroke);

    // Tassel line from brim right side going down
    final tx = s.width * 0.82;
    canvas.drawLine(Offset(tx, brimY), Offset(tx, s.height * 0.68), stroke..strokeWidth = s.width * 0.07);
    // Tassel ball
    canvas.drawCircle(Offset(tx, s.height * 0.74), s.width * 0.08, p);
  }

  @override
  bool shouldRepaint(_ULogoP old) => old.color != color;
}

/// The custom bottom navigation bar matching the UAPP design.
/// Active tab floats upward in a dark rounded-rectangle pill with a green dot.
class UAppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const UAppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      color: const Color(0xFF030D0F),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            _NavTab(index: 0, current: currentIndex, icon: const _SearchIcon(), label: 'Search',   onTap: onTap),
            _NavTab(index: 1, current: currentIndex, icon: const _AppsIcon(),   label: 'Apply',    onTap: onTap),
            _NavTab(index: 2, current: currentIndex, icon: const _HomeUIcon(),  label: 'Home',     onTap: onTap, isCenter: true),
            _NavTab(index: 3, current: currentIndex, icon: const _MsgIcon(),    label: 'Messages', onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final int index;
  final int current;
  final Widget icon;
  final String label;
  final void Function(int) onTap;
  final bool isCenter;

  const _NavTab({
    required this.index,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                bottom: active ? 8 : 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: active ? 0 : 0.55,
                  child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ),
              ),
              if (active)
                Positioned(
                  top: -2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Green dot indicator
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0x5500E676), blurRadius: 6, spreadRadius: 2)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Elevated dark pill
                      Container(
                        width: isCenter ? 68 : 60,
                        height: isCenter ? 62 : 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D2426),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        alignment: Alignment.center,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          child: icon,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Positioned(
                  top: 14,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: 0.35), BlendMode.srcIn),
                    child: icon,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Icon widgets ──────────────────────────────────────────────

class _SearchIcon extends StatelessWidget {
  const _SearchIcon();
  @override
  Widget build(BuildContext context) => const Icon(Icons.travel_explore_rounded, size: 24, color: Colors.white);
}

class _AppsIcon extends StatelessWidget {
  const _AppsIcon();
  @override
  Widget build(BuildContext context) => const Icon(Icons.description_rounded, size: 24, color: Colors.white);
}

class _HomeUIcon extends StatelessWidget {
  const _HomeUIcon();
  @override
  Widget build(BuildContext context) => const UAppLogo(size: 28, color: Colors.white);
}

class _MsgIcon extends StatelessWidget {
  const _MsgIcon();
  @override
  Widget build(BuildContext context) => const Icon(Icons.chat_bubble_rounded, size: 24, color: Colors.white);
}
