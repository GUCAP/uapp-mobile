import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar_actions.dart';
import 'new_meeting_screen.dart';
import '../models/meeting.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _weekStart = _mondayOf(DateTime.now());

  static DateTime _mondayOf(DateTime d) {
    final wd = d.weekday;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
  }

  List<DateTime> get _weekDays => List.generate(7, (i) => _weekStart.add(Duration(days: i)));

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

  void _openNewMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NewMeetingScreen(onCreated: (_) => setState(() {})),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('New Meeting', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        onPressed: _openNewMeeting,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AgendaView(weekDays: _weekDays, meetings: kMeetings),
                  _WorkHoursView(),
                  _AwayView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final c = C(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Text('My Schedule', style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: c.textSecondary, size: 24),
            onPressed: () => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
            padding: EdgeInsets.zero,
          ),
          Text(
            '${DateFormat('d MMM').format(_weekDays.first)}–${DateFormat('d MMM').format(_weekDays.last)}',
            style: TextStyle(color: c.textSecondary, fontSize: 12),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: c.textSecondary, size: 24),
            onPressed: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
            padding: EdgeInsets.zero,
          ),
          // Today chip
          GestureDetector(
            onTap: () => setState(() => _weekStart = _mondayOf(DateTime.now())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Today', style: TextStyle(color: AppColors.primaryLight, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 6),
          const TopBarActions(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final c = C(context);
    return TabBar(
      controller: _tabController,
      tabs: const [Tab(text: 'Agenda'), Tab(text: 'Work Hours'), Tab(text: 'Away')],
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

// ── Agenda view ───────────────────────────────────────────────
class _AgendaView extends StatelessWidget {
  final List<DateTime> weekDays;
  final List<Meeting> meetings;

  const _AgendaView({required this.weekDays, required this.meetings});

  List<Meeting> _meetingsOn(DateTime day) => meetings.where((m) {
    final d = m.scheduledAt;
    return d.year == day.year && d.month == day.month && d.day == day.day;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final today = DateTime.now();

    return Column(
      children: [
        // Week strip
        Container(
          color: c.surface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: weekDays.map((day) {
              final isToday = DateUtils.isSameDay(day, today);
              return Expanded(
                child: Column(
                  children: [
                    Text(DateFormat('EEE').format(day), style: TextStyle(color: isToday ? AppColors.primaryLight : c.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${day.day}', style: TextStyle(color: isToday ? Colors.white : c.textSecondary, fontSize: 14, fontWeight: isToday ? FontWeight.w700 : FontWeight.normal)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: _meetingsOn(day).isNotEmpty ? AppColors.orange : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Divider(height: 1, color: c.border),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weekDays.length,
            itemBuilder: (_, i) {
              final day = weekDays[i];
              final dayMeetings = _meetingsOn(day);
              final isToday = DateUtils.isSameDay(day, today);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM').format(day),
                          style: TextStyle(
                            color: isToday ? AppColors.primaryLight : c.textSecondary,
                            fontSize: 13, fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (dayMeetings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('No meetings', style: TextStyle(color: c.textMuted, fontSize: 13)),
                    )
                  else
                    ...dayMeetings.map((m) => _AgendaMeetingTile(meeting: m)),
                  if (i < weekDays.length - 1)
                    Divider(color: c.divider),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgendaMeetingTile extends StatelessWidget {
  final Meeting meeting;
  const _AgendaMeetingTile({required this.meeting});

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

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final user = findUser(meeting.withUserId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: _typeColor.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 44,
            decoration: BoxDecoration(color: _typeColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Icon(_typeIcon, color: _typeColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? meeting.withUserId, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(DateFormat('h:mm a').format(meeting.scheduledAt), style: TextStyle(color: c.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (meeting.status == MeetingStatus.upcoming)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(8)),
              child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ── Work Hours tab ────────────────────────────────────────────
class _WorkHoursView extends StatefulWidget {
  @override
  State<_WorkHoursView> createState() => _WorkHoursViewState();
}

class _WorkHoursViewState extends State<_WorkHoursView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Your weekly availability pattern', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ),
        ...kWorkHours.map((block) => _WorkHourTile(
          block: block,
          onToggle: () => setState(() {}),
        )),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _WorkHourTile extends StatelessWidget {
  final AvailabilityBlock block;
  final VoidCallback onToggle;

  const _WorkHourTile({required this.block, required this.onToggle});

  static const _days = {'Mon': 'Monday', 'Tue': 'Tuesday', 'Wed': 'Wednesday', 'Thu': 'Thursday', 'Fri': 'Friday', 'Sat': 'Saturday', 'Sun': 'Sunday'};

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: block.active ? c.border : c.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(_days[block.dayKey] ?? block.dayKey, style: TextStyle(color: block.active ? c.textPrimary : c.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (block.active) ...[
            _TimeTag(block.from),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('–', style: TextStyle(color: c.textMuted))),
            _TimeTag(block.to),
          ] else
            Text('Not available', style: TextStyle(color: c.textMuted, fontSize: 13)),
          const Spacer(),
          Switch.adaptive(
            value: block.active,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.primaryLight,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  final String time;
  const _TimeTag(this.time);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(time, style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

// ── Away view ─────────────────────────────────────────────────
class _AwayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Away / Out-of-Office', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Block time when you\'re unavailable for meetings', style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Away Period', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Upcoming away periods', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          const Center(
            child: Column(
              children: [
                Icon(Icons.beach_access_rounded, color: AppColors.textMuted, size: 40),
                SizedBox(height: 10),
                Text('No away periods set', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
