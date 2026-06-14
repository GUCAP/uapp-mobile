import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/user.dart';
import '../models/meeting.dart';
import '../widgets/user_avatar.dart';

class ScheduleCallScreen extends StatefulWidget {
  final AppUser withUser;
  final void Function(Meeting)? onScheduled;

  const ScheduleCallScreen({
    super.key,
    required this.withUser,
    this.onScheduled,
  });

  @override
  State<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends State<ScheduleCallScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  TimeSlot? _selectedSlot;
  MeetingType _callType = MeetingType.video;

  List<int> get _daysInMonth {
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    return List.generate(last.day, (i) => i + 1);
  }

  int get _firstWeekday => DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

  bool _isToday(int day) {
    final now = DateTime.now();
    return _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month &&
        day == now.day;
  }

  bool _isPast(int day) {
    final now = DateTime.now();
    final d = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    return d.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool _isSelected(int day) {
    return _selectedDate?.year == _focusedMonth.year &&
        _selectedDate?.month == _focusedMonth.month &&
        _selectedDate?.day == day;
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      _selectedDate = null;
      _selectedSlot = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      _selectedDate = null;
      _selectedSlot = null;
    });
  }

  void _confirmSchedule() {
    if (_selectedDate == null || _selectedSlot == null) return;
    final timeParts = _selectedSlot!.label.split(' ');
    final hm = timeParts[0].split(':');
    int hour = int.parse(hm[0]);
    final min = int.parse(hm[1]);
    if (timeParts[1] == 'PM' && hour != 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      min,
    );

    final meeting = Meeting(
      id: 'meet-${DateTime.now().millisecondsSinceEpoch}',
      withUserId: widget.withUser.id,
      scheduledAt: scheduledAt,
      type: _callType,
    );

    kMeetings.add(meeting);

    _showConfirmation(meeting);
  }

  void _showConfirmation(Meeting meeting) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CallScheduledDialog(
        meeting: meeting,
        withUser: widget.withUser,
        onDone: () {
          Navigator.pop(context); // close dialog
          widget.onScheduled?.call(meeting);
          Navigator.pop(context); // back to chat
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Schedule a Call', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWithCard(),
                  const SizedBox(height: 20),
                  _buildCallTypeRow(),
                  const SizedBox(height: 20),
                  _buildCalendar(),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 20),
                    _buildTimeSlots(),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildWithCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          UserAvatar(userId: widget.withUser.id, size: 46, showOnline: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.withUser.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.withUser.role,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.withUser.online ? AppColors.online.withValues(alpha: 0.15) : AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: widget.withUser.online ? AppColors.online : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.withUser.online ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.withUser.online ? AppColors.online : AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTypeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Call type', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            _TypeChip(
              icon: Icons.video_call_rounded,
              label: 'Video Call',
              selected: _callType == MeetingType.video,
              onTap: () => setState(() => _callType = MeetingType.video),
            ),
            const SizedBox(width: 10),
            _TypeChip(
              icon: Icons.call_rounded,
              label: 'Voice Call',
              selected: _callType == MeetingType.audio,
              onTap: () => setState(() => _callType = MeetingType.audio),
            ),
            const SizedBox(width: 10),
            _TypeChip(
              icon: Icons.people_rounded,
              label: 'Consultation',
              selected: _callType == MeetingType.consultation,
              onTap: () => setState(() => _callType = MeetingType.consultation),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Row(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_focusedMonth),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 26),
              onPressed: _prevMonth,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 26),
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Day labels
        Row(
          children: days.map((d) => Expanded(
            child: Center(
              child: Text(d, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: _firstWeekday + _daysInMonth.length,
          itemBuilder: (ctx, i) {
            if (i < _firstWeekday) return const SizedBox.shrink();
            final day = i - _firstWeekday + 1;
            final past = _isPast(day);
            final selected = _isSelected(day);
            final today = _isToday(day);

            return GestureDetector(
              onTap: past ? null : () {
                setState(() {
                  _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  _selectedSlot = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : today
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: past
                        ? AppColors.textHint
                        : selected
                            ? Colors.white
                            : today
                                ? AppColors.primaryLight
                                : Colors.white,
                    fontSize: 14,
                    fontWeight: selected || today ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available times — ${DateFormat("EEE, dd MMM").format(_selectedDate!)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: kTimeSlots.length,
          itemBuilder: (ctx, i) {
            final slot = kTimeSlots[i];
            final selected = _selectedSlot?.label == slot.label;
            final unavailable = !slot.available;

            return GestureDetector(
              onTap: unavailable ? null : () => setState(() => _selectedSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: unavailable
                      ? AppColors.surface.withValues(alpha: 0.5)
                      : selected
                          ? AppColors.primary
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot.label,
                  style: TextStyle(
                    color: unavailable
                        ? AppColors.textHint
                        : selected
                            ? Colors.white
                            : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    decoration: unavailable ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final canConfirm = _selectedDate != null && _selectedSlot != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          if (_selectedDate != null && _selectedSlot != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${DateFormat("EEE, dd MMM").format(_selectedDate!)}  •  ${_selectedSlot!.label}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canConfirm ? _confirmSchedule : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm ? AppColors.orange : AppColors.border,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Confirm Schedule a Call',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : AppColors.textMuted, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Call Scheduled confirmation dialog ────────────────────────
class _CallScheduledDialog extends StatelessWidget {
  final Meeting meeting;
  final AppUser withUser;
  final VoidCallback onDone;

  const _CallScheduledDialog({
    required this.meeting,
    required this.withUser,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Call Scheduled!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Your ${meeting.type.name} call has been scheduled with ${withUser.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                DateFormat("EEE, dd MMM yyyy 'at' h:mm a").format(meeting.scheduledAt),
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
