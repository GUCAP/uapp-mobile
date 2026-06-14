import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/meeting.dart';
import '../widgets/top_bar_actions.dart';
import '../widgets/user_avatar.dart';
import 'schedule_call_screen.dart';
import 'group_meeting_screen.dart';

class ScheduledCallsScreen extends StatefulWidget {
  const ScheduledCallsScreen({super.key});

  @override
  State<ScheduledCallsScreen> createState() => _ScheduledCallsScreenState();
}

class _ScheduledCallsScreenState extends State<ScheduledCallsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MeetingType? _filterType; // null = All

  // Mock pending invites
  List<Meeting> _pendingInvites = [
    Meeting(
      id: 'invite-1',
      withUserId: 'u-andreea',
      scheduledAt: DateTime.now().add(const Duration(hours: 3)),
      type: MeetingType.consultation,
      status: MeetingStatus.upcoming,
    ),
    Meeting(
      id: 'invite-2',
      withUserId: 'u-raj',
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
      type: MeetingType.video,
      status: MeetingStatus.upcoming,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Meeting> _meetings(MeetingStatus status) {
    return kMeetings.where((m) => m.status == status && (_filterType == null || m.type == _filterType)).toList()
      ..sort((a, b) => status == MeetingStatus.upcoming
          ? a.scheduledAt.compareTo(b.scheduledAt)
          : b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c),
            _buildTabs(c),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.upcoming),
                    status: MeetingStatus.upcoming,
                    onCancel: _cancelMeeting,
                    pendingInvites: _pendingInvites,
                    onAccept: _acceptInvite,
                    onDecline: _declineInvite,
                  ),
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.passed),
                    status: MeetingStatus.passed,
                  ),
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.canceled),
                    status: MeetingStatus.canceled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Schedule Call', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        onPressed: _openScheduleNew,
      ),
    );
  }

  void _openScheduleNew() {
    final target = kUsers.firstWhere(
      (u) => u.id != kCurrentUser.id && u.online,
      orElse: () => kUsers[1],
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleCallScreen(
          withUser: target,
          onScheduled: (_) => setState(() {}),
        ),
      ),
    );
  }

  void _cancelMeeting(Meeting m) {
    setState(() {
      final idx = kMeetings.indexWhere((x) => x.id == m.id);
      if (idx != -1) kMeetings[idx] = m.copyWith(status: MeetingStatus.canceled);
    });
  }

  void _acceptInvite(Meeting invite) {
    setState(() {
      _pendingInvites.removeWhere((m) => m.id == invite.id);
      kMeetings.add(invite);
    });
  }

  void _declineInvite(Meeting invite) {
    setState(() => _pendingInvites.removeWhere((m) => m.id == invite.id));
  }

  Widget _buildHeader(AC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Text(
            'Schedule a Call',
            style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          PopupMenuButton<MeetingType?>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filterType != null ? AppColors.primaryLight : c.textSecondary,
              size: 22,
            ),
            color: c.surface,
            tooltip: 'Filter by type',
            onSelected: (v) => setState(() => _filterType = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: _FilterRow(icon: Icons.all_inclusive_rounded, label: 'All types', sel: _filterType == null, c: c)),
              PopupMenuItem(value: MeetingType.video, child: _FilterRow(icon: Icons.video_call_rounded, label: 'Video Call', sel: _filterType == MeetingType.video, c: c)),
              PopupMenuItem(value: MeetingType.audio, child: _FilterRow(icon: Icons.call_rounded, label: 'Voice Call', sel: _filterType == MeetingType.audio, c: c)),
              PopupMenuItem(value: MeetingType.consultation, child: _FilterRow(icon: Icons.people_rounded, label: 'Consultation', sel: _filterType == MeetingType.consultation, c: c)),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: c.textSecondary, size: 22),
            color: c.surface,
            onSelected: (value) {
              if (value == 'group_meeting') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupMeetingScreen(onCreated: () => setState(() {})),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'group_meeting',
                child: Row(
                  children: [
                    const Icon(Icons.group_add_rounded, color: AppColors.primaryLight, size: 18),
                    const SizedBox(width: 10),
                    Text('New Group Meeting', style: TextStyle(color: c.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const TopBarActions(),
        ],
      ),
    );
  }

  Widget _buildTabs(AC c) {
    return TabBar(
      controller: _tabController,
      tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past'), Tab(text: 'Canceled')],
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: c.textMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: c.divider,
    );
  }
}

class _MeetingList extends StatelessWidget {
  final List<Meeting> meetings;
  final MeetingStatus status;
  final void Function(Meeting)? onCancel;
  final List<Meeting> pendingInvites;
  final void Function(Meeting)? onAccept;
  final void Function(Meeting)? onDecline;

  const _MeetingList({
    required this.meetings,
    required this.status,
    this.onCancel,
    this.pendingInvites = const [],
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final hasPending = pendingInvites.isNotEmpty && status == MeetingStatus.upcoming;

    if (meetings.isEmpty && !hasPending) {
      final (icon, title, subtitle) = switch (status) {
        MeetingStatus.passed   => (Icons.history_rounded, 'No past calls', 'Completed calls will appear here'),
        MeetingStatus.canceled => (Icons.cancel_outlined, 'No canceled calls', 'Canceled meetings will appear here'),
        _                      => (Icons.calendar_today_rounded, 'No upcoming calls', 'Schedule a call to get started'),
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: c.surfaceElevated, borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: Icon(icon, color: c.textMuted, size: 40),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: c.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: meetings.length + (hasPending ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        if (hasPending && i == 0) {
          return _PendingInvitesBanner(
            invites: pendingInvites,
            onAccept: onAccept ?? (_) {},
            onDecline: onDecline ?? (_) {},
          );
        }
        final idx = hasPending ? i - 1 : i;
        return _MeetingCard(meeting: meetings[idx], onCancel: onCancel);
      },
    );
  }
}

class _PendingInvitesBanner extends StatelessWidget {
  final List<Meeting> invites;
  final void Function(Meeting) onAccept;
  final void Function(Meeting) onDecline;
  const _PendingInvitesBanner({required this.invites, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline_rounded, color: AppColors.primaryLight, size: 16),
              const SizedBox(width: 6),
              Text('Pending Invites (${invites.length})', style: const TextStyle(color: AppColors.primaryLight, fontSize: 13.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...invites.map((invite) {
            final user = findUser(invite.withUserId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (user != null) UserAvatar(userId: user.id, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? invite.withUserId, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(DateFormat("EEE, d MMM 'at' h:mm a").format(invite.scheduledAt), style: TextStyle(color: c.textMuted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onAccept(invite),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => onDecline(invite),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final void Function(Meeting)? onCancel;

  const _MeetingCard({required this.meeting, this.onCancel});

  Color get _typeColor {
    switch (meeting.type) {
      case MeetingType.video: return AppColors.primary;
      case MeetingType.audio: return const Color(0xFF3A7BD5);
      case MeetingType.consultation: return AppColors.orange;
    }
  }

  IconData get _typeIcon {
    switch (meeting.type) {
      case MeetingType.video: return Icons.video_call_rounded;
      case MeetingType.audio: return Icons.call_rounded;
      case MeetingType.consultation: return Icons.people_rounded;
    }
  }

  String get _typeLabel {
    switch (meeting.type) {
      case MeetingType.video: return 'Video Call';
      case MeetingType.audio: return 'Voice Call';
      case MeetingType.consultation: return 'Consultation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final user = findUser(meeting.withUserId);
    final now = DateTime.now();
    final isNow = meeting.status == MeetingStatus.upcoming &&
        meeting.scheduledAt.difference(now).inMinutes.abs() < 10;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNow ? AppColors.orange.withValues(alpha: 0.5) : c.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                if (user != null)
                  UserAvatar(userId: user.id, size: 48, showOnline: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? meeting.withUserId,
                        style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role ?? '',
                        style: TextStyle(color: c.textMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, color: _typeColor, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        _typeLabel,
                        style: TextStyle(color: _typeColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: c.textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat("EEE, dd MMM yyyy").format(meeting.scheduledAt),
                    style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_rounded, color: c.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat("h:mm a").format(meeting.scheduledAt),
                    style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            if (meeting.status == MeetingStatus.upcoming) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onCancel?.call(meeting),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Call Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (meeting.status == MeetingStatus.canceled)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Canceled',
                    style: TextStyle(color: AppColors.danger, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool sel;
  final AC c;
  const _FilterRow({required this.icon, required this.label, required this.sel, required this.c});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: sel ? AppColors.primaryLight : c.textMuted, size: 18),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: sel ? AppColors.primaryLight : c.textPrimary, fontSize: 14, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
      if (sel) ...[const Spacer(), const Icon(Icons.check_rounded, color: AppColors.primaryLight, size: 16)],
    ],
  );
}
