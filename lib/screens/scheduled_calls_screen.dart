import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/meeting.dart';
import '../widgets/top_bar_actions.dart';
import '../widgets/user_avatar.dart';
import 'schedule_call_screen.dart';

class ScheduledCallsScreen extends StatefulWidget {
  const ScheduledCallsScreen({super.key});

  @override
  State<ScheduledCallsScreen> createState() => _ScheduledCallsScreenState();
}

class _ScheduledCallsScreenState extends State<ScheduledCallsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return kMeetings.where((m) => m.status == status).toList()
      ..sort((a, b) => status == MeetingStatus.upcoming
          ? a.scheduledAt.compareTo(b.scheduledAt)
          : b.scheduledAt.compareTo(a.scheduledAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.upcoming),
                    emptyLabel: 'No upcoming calls',
                    onCancel: _cancelMeeting,
                  ),
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.passed),
                    emptyLabel: 'No past calls',
                  ),
                  _MeetingList(
                    meetings: _meetings(MeetingStatus.canceled),
                    emptyLabel: 'No canceled calls',
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
    // Pick the first online user available (demo)
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            'Schedule a Call',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 6),
          const TopBarActions(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past'), Tab(text: 'Canceled')],
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: AppColors.divider,
    );
  }
}

class _MeetingList extends StatelessWidget {
  final List<Meeting> meetings;
  final String emptyLabel;
  final void Function(Meeting)? onCancel;

  const _MeetingList({
    required this.meetings,
    required this.emptyLabel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(emptyLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: meetings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _MeetingCard(meeting: meetings[i], onCancel: onCancel),
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
    final user = findUser(meeting.withUserId);
    final now = DateTime.now();
    final isNow = meeting.status == MeetingStatus.upcoming &&
        meeting.scheduledAt.difference(now).inMinutes.abs() < 10;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNow ? AppColors.orange.withValues(alpha: 0.5) : AppColors.border,
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
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role ?? '',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat("EEE, dd MMM yyyy").format(meeting.scheduledAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat("h:mm a").format(meeting.scheduledAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
