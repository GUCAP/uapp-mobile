import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../widgets/user_avatar.dart';
import 'settings/settings_screen.dart';
import 'settings/timezone_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = true;

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final user = kCurrentUser;
    final unread = kUnreadNotificationCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 24),
                        onPressed: () => _showNotifications(),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 1.5)),
                            alignment: Alignment.center,
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Avatar card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    UserAvatar(userId: user.id, size: 72, showOnline: true),
                    const SizedBox(height: 14),
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
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
              _Section(label: 'ACCOUNT', items: [
                _Item(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () {}),
                _Item(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => _showNotifications()),
                _Item(icon: Icons.lock_outline_rounded, label: 'Privacy & Security', onTap: () {}),
              ]),
              const SizedBox(height: 16),
              _Section(label: 'PREFERENCES', items: [
                _Item(
                  icon: _darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  label: 'Dark Mode',
                  onTap: () {},
                  trailing: Switch.adaptive(
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                    activeThumbColor: AppColors.primaryLight,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                _Item(icon: Icons.language_rounded, label: 'Language', onTap: () {}, trailingLabel: 'English'),
                _Item(icon: Icons.schedule_rounded, label: 'Work Hours & Timezone', onTap: () => _push(const TimezoneScreen())),
              ]),
              const SizedBox(height: 16),
              // Full settings button
              GestureDetector(
                onTap: () => _push(const SettingsScreen()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.settings_rounded, color: AppColors.primaryLight, size: 22),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Settings', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            Text('User management, permissions, webhooks, feed preferences', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.3)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Section(label: 'SUPPORT', items: [
                _Item(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                _Item(icon: Icons.info_outline_rounded, label: 'About UAPP', onTap: () {}),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                      SizedBox(width: 8),
                      Text('Sign Out', style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600)),
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

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () { setState(() { for (final n in kNotifications) n.isRead = true; }); },
                    child: const Text('Mark all read', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.divider),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: kNotifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final n = kNotifications[i];
                  return GestureDetector(
                    onTap: () => setState(() { n.isRead = true; }),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: n.isRead ? Colors.transparent : AppColors.primaryFaint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: n.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotifIcon(type: n.type),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(n.body, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.4)),
                              ],
                            ),
                          ),
                          if (!n.isRead)
                            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  final String type;
  const _NotifIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'meeting_invite' => (Icons.video_call_rounded, AppColors.primary),
      'mention' => (Icons.alternate_email_rounded, AppColors.primaryLight),
      'reaction' => (Icons.thumb_up_rounded, AppColors.online),
      _ => (Icons.notifications_rounded, AppColors.textMuted),
    };
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<_Item> items;
  const _Section({required this.label, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      ),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1) const Divider(height: 1, indent: 52, color: AppColors.divider),
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
  const _Item({required this.icon, required this.label, required this.onTap, this.trailingLabel, this.trailing});

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
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14.5))),
          if (trailing != null) trailing!
          else if (trailingLabel != null) ...[
            Text(trailingLabel!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ] else
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
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

