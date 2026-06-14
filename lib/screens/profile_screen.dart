import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import '../core/translations.dart';
import '../data/mock_data.dart';
import '../models/user.dart';
import '../widgets/user_avatar.dart';
import 'notifications_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/timezone_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t('language'), style: TextStyle(color: C(context).textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            ...kLanguages.map((lang) {
              final selected = languageNotifier.value == lang['code'];
              return ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryFaint : C(context).surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(lang['native']!.substring(0, 1), style: TextStyle(color: selected ? AppColors.primaryLight : C(context).textMuted, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                title: Text(lang['label']!, style: TextStyle(color: C(context).textPrimary, fontSize: 15)),
                subtitle: Text(lang['native']!, style: TextStyle(color: C(context).textMuted, fontSize: 12)),
                trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
                onTap: () {
                  setLanguage(lang['code']!);
                  setState(() {});
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAccountSwitcher() {
    final nonStudents = kUsers.where((u) => u.type != UserType.student).take(5).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: C(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Switch Account', style: TextStyle(color: C(context).textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const Divider(),
            ...nonStudents.map((u) {
              final selected = currentUserIdNotifier.value == u.id;
              return ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: u.color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                title: Text(u.name, style: TextStyle(color: C(context).textPrimary, fontSize: 14.5)),
                subtitle: Text(u.role, style: TextStyle(color: C(context).textMuted, fontSize: 12)),
                trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
                onTap: () {
                  currentUserIdNotifier.value = u.id;
                  setState(() {});
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final user = kCurrentUser;
    final unread = kUnreadNotificationCount;
    final dark = isDarkMode;
    final currentLang = kLanguages.firstWhere((l) => l['code'] == languageNotifier.value);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (Navigator.canPop(context)) const SizedBox(width: 8),
                  Text(t('profile'), style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: c.textSecondary, size: 24),
                        onPressed: () => _push(const NotificationsScreen()),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: c.bg, width: 1.5)),
                            alignment: Alignment.center,
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  children: [
                    UserAvatar(userId: user.id, size: 72, showOnline: true),
                    const SizedBox(height: 14),
                    Text(user.name, style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.role, style: TextStyle(color: c.textMuted, fontSize: 13.5)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Chip(label: user.dept.name.toUpperCase(), color: AppColors.primary),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: AppColors.online),
                              SizedBox(width: 6),
                              Text('Active now', style: TextStyle(color: AppColors.online, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Section(label: 'ACCOUNT', c: c, items: [
                _Item(icon: Icons.person_outline_rounded, label: t('edit_profile'), c: c, onTap: () {}),
                _Item(icon: Icons.notifications_outlined, label: t('notifications_menu'), c: c, onTap: () => _push(const NotificationsScreen())),
                _Item(icon: Icons.lock_outline_rounded, label: t('privacy_security'), c: c, onTap: () {}),
              ]),
              const SizedBox(height: 16),
              _Section(label: 'PREFERENCES', c: c, items: [
                _Item(
                  icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  label: t('dark_mode'),
                  c: c,
                  onTap: () { toggleTheme(); setState(() {}); },
                  trailing: Switch.adaptive(
                    value: dark,
                    onChanged: (_) { toggleTheme(); setState(() {}); },
                    activeThumbColor: AppColors.primaryLight,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                _Item(
                  icon: Icons.language_rounded,
                  label: t('language'),
                  c: c,
                  onTap: _showLanguagePicker,
                  trailingLabel: currentLang['native'],
                ),
                _Item(icon: Icons.schedule_rounded, label: t('work_hours_tz'), c: c, onTap: () => _push(const TimezoneScreen())),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _push(const SettingsScreen()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_rounded, color: AppColors.primaryLight, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('settings'), style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                            Text('User management, permissions, webhooks, feed preferences', style: TextStyle(color: c.textMuted, fontSize: 11.5, height: 1.3)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Section(label: 'SUPPORT', c: c, items: [
                _Item(icon: Icons.help_outline_rounded, label: 'Help & Support', c: c, onTap: () {}),
                _Item(icon: Icons.info_outline_rounded, label: t('about'), c: c, onTap: () {}),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Text(t('sign_out'), style: const TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Account switcher — below Sign Out
              GestureDetector(
                onTap: _showAccountSwitcher,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: user.color, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(user.role, style: TextStyle(color: c.textMuted, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Text('Switch Account', style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryLight, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

}

class _Section extends StatelessWidget {
  final String label;
  final List<_Item> items;
  final AC c;
  const _Section({required this.label, required this.items, required this.c});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(label, style: TextStyle(color: c.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      ),
      Container(
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1) Divider(height: 1, indent: 52, color: c.divider),
            ],
          ],
        ),
      ),
    ],
  );
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingLabel;
  final Widget? trailing;
  final AC c;
  const _Item({required this.icon, required this.label, required this.onTap, required this.c, this.trailingLabel, this.trailing});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(color: c.textPrimary, fontSize: 14.5))),
          if (trailing != null) trailing!
          else if (trailingLabel != null) ...[
            Text(trailingLabel!, style: TextStyle(color: c.textMuted, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 18),
          ] else
            Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 18),
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
  );
}

