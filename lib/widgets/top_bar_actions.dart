import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';

/// Notification bell + profile avatar — placed in the top-right of every
/// main screen. Tapping the bell opens the notification panel; tapping the
/// avatar pushes ProfileScreen.
class TopBarActions extends StatefulWidget {
  const TopBarActions({super.key});

  @override
  State<TopBarActions> createState() => _TopBarActionsState();
}

class _TopBarActionsState extends State<TopBarActions> {
  @override
  Widget build(BuildContext context) {
    final unread = kUnreadNotificationCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notification bell
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => setState(() {})),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
              ),
              if (unread > 0)
                Positioned(
                  right: -3, top: -3,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Profile avatar
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: kCurrentUser.color,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              kCurrentUser.initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          builder: (_, ctrl) => Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Row(
                  children: [
                    const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheet(() { for (final n in kNotifications) n.isRead = true; });
                        setState(() {});
                      },
                      child: const Text('Mark all read', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: kNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final n = kNotifications[i];
                    return GestureDetector(
                      onTap: () {
                        setSheet(() => n.isRead = true);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: n.isRead ? Colors.transparent : AppColors.primaryFaint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: n.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _NotifIcon(type: n.type),
                            const SizedBox(width: 12),
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
                              Container(
                                width: 8, height: 8,
                                margin: const EdgeInsets.only(top: 4, left: 6),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
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
      'meeting_invite' => (Icons.video_call_rounded,        AppColors.primary),
      'mention'        => (Icons.alternate_email_rounded,   AppColors.primaryLight),
      'reaction'       => (Icons.thumb_up_rounded,          AppColors.online),
      _                => (Icons.notifications_rounded,     AppColors.textMuted),
    };
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 18),
    );
  }
}
