import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/translations.dart';
import '../data/mock_data.dart';
import 'news_feed_screen.dart';
import 'chat_list_screen.dart';
import 'promotions_feed_screen.dart';
import 'scheduled_calls_screen.dart';
import 'availability_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;

  static const _screens = [
    NewsFeedScreen(),
    ChatListScreen(),
    PromotionsFeedScreen(),
    ScheduledCallsScreen(),
    AvailabilityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final msgUnread = kInitialThreads.fold<int>(0, (s, x) => s + x.unreadCount);

    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: Icons.newspaper_outlined,          activeIcon: Icons.newspaper_rounded,           label: t('nav_feed'),         selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded,         label: t('nav_messages'),     selected: _tab == 1, onTap: () => setState(() => _tab = 1), badge: msgUnread > 0 ? msgUnread : null),
                _NavItem(icon: Icons.campaign_outlined,           activeIcon: Icons.campaign_rounded,            label: 'Promotions',          selected: _tab == 2, onTap: () => setState(() => _tab = 2), accentColor: AppColors.orange),
                _NavItem(icon: Icons.calendar_month_outlined,     activeIcon: Icons.calendar_month_rounded,      label: t('nav_schedule'),     selected: _tab == 3, onTap: () => setState(() => _tab = 3)),
                _NavItem(icon: Icons.access_time_outlined,        activeIcon: Icons.access_time_filled_rounded,  label: t('nav_availability'), selected: _tab == 4, onTap: () => setState(() => _tab = 4)),
              ],
            ),
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
  final Color? accentColor;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.selected, required this.onTap, this.badge, this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primaryLight;
    final color = selected ? accent : C(context).textMuted;
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
                  child: Icon(selected ? activeIcon : icon, key: ValueKey(selected), color: color, size: 24),
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -10, top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(999)),
                      child: Text(badge! > 99 ? '99+' : '$badge', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
