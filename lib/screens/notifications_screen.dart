import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../widgets/user_avatar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter tabs
  static const _filters = ['All', 'Unread', 'Mentions', 'Reactions', 'Meetings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    // Mark all as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() { for (final n in kNotifications) n.isRead = true; });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> _filtered(String tab) {
    switch (tab) {
      case 'Unread':    return kNotifications.where((n) => !n.isRead).toList();
      case 'Mentions':  return kNotifications.where((n) => n.type == 'mention').toList();
      case 'Reactions': return kNotifications.where((n) => n.type == 'reaction' || n.type == 'comment').toList();
      case 'Meetings':  return kNotifications.where((n) => n.type == 'meeting_invite').toList();
      default:          return List.from(kNotifications);
    }
  }

  // Group notifications by time period
  Map<String, List<AppNotification>> _grouped(List<AppNotification> list) {
    final now = DateTime.now();
    final groups = <String, List<AppNotification>>{};

    for (final n in list) {
      final diff = now.difference(n.createdAt);
      final String key;
      if (diff.inHours < 24 && now.day == n.createdAt.day) {
        key = 'Today';
      } else if (diff.inDays == 1 || (diff.inHours < 48 && now.day != n.createdAt.day)) {
        key = 'Yesterday';
      } else if (diff.inDays <= 6) {
        key = 'Earlier This Week';
      } else {
        key = 'This Month';
      }
      groups.putIfAbsent(key, () => []).add(n);
    }
    return groups;
  }

  final _groupOrder = ['Today', 'Yesterday', 'Earlier This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    final unreadCount = kNotifications.where((n) => !n.isRead).length;

    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(unreadCount),
            _buildFilterTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _filters.map((f) {
                  final list = _filtered(f);
                  if (list.isEmpty) return _buildEmpty(f);
                  final groups = _grouped(list);
                  return _buildList(groups);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unread) {
    final c = C(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textSecondary, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text('Notifications', style: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('$unread new', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () => setState(() { for (final n in kNotifications) n.isRead = true; }),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final c = C(context);
    return Container(
      color: c.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: c.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        dividerColor: c.divider,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _filters.map((f) {
          final count = _filtered(f).where((n) => !n.isRead).length;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f),
                if (count > 0 && f != 'All') ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(Map<String, List<AppNotification>> groups) {
    final sections = <Widget>[];
    for (final key in _groupOrder) {
      if (!groups.containsKey(key)) continue;
      sections.add(_SectionHeader(label: key));
      for (final n in groups[key]!) {
        sections.add(_NotifTile(
          notif: n,
          onTap: () => setState(() => n.isRead = true),
          onDismiss: () => setState(() => kNotifications.remove(n)),
        ));
      }
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: sections,
    );
  }

  Widget _buildEmpty(String filter) {
    final c = C(context);
    final (icon, label) = switch (filter) {
      'Unread'    => (Icons.mark_email_read_rounded,   'All caught up!'),
      'Mentions'  => (Icons.alternate_email_rounded,   'No mentions yet'),
      'Reactions' => (Icons.thumb_up_outlined,         'No reactions yet'),
      'Meetings'  => (Icons.calendar_today_rounded,    'No meeting notifications'),
      _           => (Icons.notifications_none_rounded,'No notifications'),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: c.textMuted, size: 40),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            filter == 'Unread' ? 'You\'ve read everything.' : 'Nothing here yet.',
            style: TextStyle(color: c.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: TextStyle(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Single notification tile ──────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({required this.notif, required this.onTap, required this.onDismiss});

  // Icon overlay config per type
  ({IconData icon, Color bg}) get _overlay => switch (notif.type) {
    'meeting_invite' => (icon: Icons.video_call_rounded,        bg: AppColors.primary),
    'mention'        => (icon: Icons.alternate_email_rounded,   bg: const Color(0xFF7C3AED)),
    'reaction'       => (icon: Icons.thumb_up_rounded,          bg: const Color(0xFF16A34A)),
    'comment'        => (icon: Icons.chat_bubble_rounded,       bg: AppColors.orange),
    _                => (icon: Icons.info_rounded,              bg: AppColors.textMuted),
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    if (diff.inDays    < 7)  return DateFormat('EEEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final ov = _overlay;
    final user = notif.fromUserId != null ? findUser(notif.fromUserId!) : null;

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.danger,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: notif.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + overlay icon
              SizedBox(
                width: 54, height: 54,
                child: Stack(
                  children: [
                    // Main avatar
                    user != null
                        ? UserAvatar(userId: user.id, size: 54)
                        : Builder(builder: (ctx) {
                            final c = C(ctx);
                            return Container(
                              width: 54, height: 54,
                              decoration: BoxDecoration(
                                color: c.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.campaign_rounded, color: c.textMuted, size: 26),
                            );
                          }),
                    // Type icon badge (bottom-right)
                    Positioned(
                      right: -2, bottom: -2,
                      child: Builder(builder: (ctx) {
                        final c = C(ctx);
                        return Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: ov.bg,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.bg, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Icon(ov.icon, color: Colors.white, size: 11),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Body text — sender bold, rest normal
                    _RichBody(notif: notif),
                    const SizedBox(height: 5),
                    // Time + action chips
                    Row(
                      children: [
                        Builder(builder: (ctx) {
                          final c = C(ctx);
                          return Text(
                            _timeAgo(notif.createdAt),
                            style: TextStyle(
                              color: notif.isRead ? c.textMuted : AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          );
                        }),
                        if (notif.type == 'meeting_invite' && !notif.isRead) ...[
                          const SizedBox(width: 10),
                          _ActionChip(label: 'Accept', color: AppColors.primary, onTap: onTap),
                          const SizedBox(width: 6),
                          _ActionChip(label: 'Decline', color: AppColors.textMuted, onTap: onTap),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Unread dot
              Column(
                children: [
                  const SizedBox(height: 4),
                  if (!notif.isRead)
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    )
                  else
                    const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Renders notification body with sender name in bold
class _RichBody extends StatelessWidget {
  final AppNotification notif;
  const _RichBody({required this.notif});

  @override
  Widget build(BuildContext context) {
    final user = notif.fromUserId != null ? findUser(notif.fromUserId!) : null;
    final senderName = user?.name ?? '';
    final body = notif.body;

    final c = C(context);
    if (senderName.isNotEmpty && body.startsWith(senderName)) {
      final rest = body.substring(senderName.length);
      return RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textSecondary),
          children: [
            TextSpan(text: senderName, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700)),
            TextSpan(text: rest),
          ],
        ),
      );
    }
    return Text(body, style: TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.4));
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
    ),
  );
}
