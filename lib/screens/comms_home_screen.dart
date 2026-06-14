import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/meeting.dart';
import '../widgets/user_avatar.dart';

class CommsHomeScreen extends StatelessWidget {
  const CommsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = kCurrentUser;
    final unreadMessages = kInitialThreads.fold<int>(0, (s, t) => s + t.unreadCount);
    final upcomingMeetings = kMeetings.where((m) => m.status == MeetingStatus.upcoming).length;
    final unreadNotifs = kUnreadNotificationCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good ${_greeting()},', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Spacer(),
                  UserAvatar(userId: user.id, size: 44, showOnline: true),
                ],
              ),
              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  _StatCard(label: 'Unread\nMessages', value: '$unreadMessages', icon: Icons.chat_bubble_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Upcoming\nMeetings', value: '$upcomingMeetings', icon: Icons.calendar_month_rounded, color: AppColors.orange),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Notifications', value: '$unreadNotifs', icon: Icons.notifications_rounded, color: const Color(0xFF7C3AED)),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
                children: const [
                  _QuickAction(icon: Icons.edit_rounded,            label: 'New Message',     color: AppColors.primary),
                  _QuickAction(icon: Icons.video_call_rounded,      label: 'Schedule Call',   color: AppColors.orange),
                  _QuickAction(icon: Icons.newspaper_rounded,       label: 'Post to Feed',    color: Color(0xFF7C3AED)),
                  _QuickAction(icon: Icons.people_rounded,          label: 'View Team',       color: Color(0xFF0EA5E9)),
                ],
              ),
              const SizedBox(height: 24),

              // Recent activity
              const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...kInitialThreads.take(4).map((t) {
                final last = t.lastMessage;
                if (last == null) return const SizedBox.shrink();
                final otherId = t.isGroup ? null : t.participantIds.firstWhere((id) => id != kCurrentUser.id, orElse: () => t.participantIds.first);
                final name = t.isGroup ? (t.groupName ?? 'Group') : (findUser(otherId ?? '')?.name ?? '');
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      t.isGroup
                          ? GroupAvatar(color: t.groupColor ?? AppColors.primary, initials: name.substring(0, 1), size: 38)
                          : UserAvatar(userId: otherId ?? '', size: 38, showOnline: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                            Text(last.text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (t.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.badgeBg, borderRadius: BorderRadius.circular(999)),
                          child: Text('${t.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
