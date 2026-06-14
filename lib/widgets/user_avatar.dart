import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double size;
  final bool showOnline;

  const UserAvatar({
    super.key,
    required this.userId,
    this.size = 44,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = findUser(userId);
    if (user == null) {
      return _placeholder(size);
    }
    return _AvatarCircle(
      initials: user.initials,
      color: user.color,
      size: size,
      online: showOnline && user.online,
    );
  }
}

class GroupAvatar extends StatelessWidget {
  final Color color;
  final String initials;
  final double size;

  const GroupAvatar({
    super.key,
    required this.color,
    required this.initials,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return _AvatarCircle(
      initials: initials,
      color: color,
      size: size,
      online: false,
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final bool online;

  const _AvatarCircle({
    required this.initials,
    required this.color,
    required this.size,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

Widget _placeholder(double size) => Container(
  width: size,
  height: size,
  decoration: const BoxDecoration(
    color: AppColors.border,
    shape: BoxShape.circle,
  ),
);
