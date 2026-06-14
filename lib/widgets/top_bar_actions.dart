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

}
