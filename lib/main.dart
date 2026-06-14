import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'data/mock_data.dart';
import 'screens/news_feed_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/scheduled_calls_screen.dart';
import 'screens/availability_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: AppColors.surface,
  ));
  runApp(const UAppMobile());
}

class UAppMobile extends StatelessWidget {
  const UAppMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UAPP',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _tab = 0;

  static const _screens = [
    NewsFeedScreen(),
    ChatListScreen(),
    ScheduledCallsScreen(),
    AvailabilityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final msgUnread = kInitialThreads.fold<int>(0, (s, t) => s + t.unreadCount);

    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        msgUnread: msgUnread,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Bottom navigation — 4 tabs ────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int msgUnread;
  final void Function(int) onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.msgUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(icon: Icons.newspaper_outlined,         activeIcon: Icons.newspaper_rounded,           label: 'Feed',         selected: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded,        label: 'Messages',     selected: currentIndex == 1, onTap: () => onTap(1), badge: msgUnread > 0 ? msgUnread : null),
              _NavItem(icon: Icons.calendar_month_outlined,    activeIcon: Icons.calendar_month_rounded,      label: 'Schedule',     selected: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.access_time_outlined,       activeIcon: Icons.access_time_filled_rounded,  label: 'Availability', selected: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryLight : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    selected ? activeIcon : icon,
                    key: ValueKey(selected),
                    color: color,
                    size: 26,
                  ),
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -10, top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge! > 99 ? '99+' : '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
