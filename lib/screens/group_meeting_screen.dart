import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/meeting.dart';
import '../models/user.dart';

class GroupMeetingScreen extends StatefulWidget {
  final VoidCallback onCreated;
  const GroupMeetingScreen({super.key, required this.onCreated});

  @override
  State<GroupMeetingScreen> createState() => _GroupMeetingScreenState();
}

class _GroupMeetingScreenState extends State<GroupMeetingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final Set<String> _selectedParticipants = {};

  // Step 2
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Step 3
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late List<AppUser> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = kUsers.where((u) => u.type != UserType.student && u.id != kCurrentUser.id).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  bool get _step1Valid => _selectedParticipants.isNotEmpty;
  bool get _step2Valid => _date != null && _startTime != null && _endTime != null;
  bool get _step3Valid => _titleCtrl.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _createMeeting() {
    final d = _date!;
    final st = _startTime!;
    final scheduledAt = DateTime(d.year, d.month, d.day, st.hour, st.minute);
    final firstParticipant = _selectedParticipants.first;
    kMeetings.add(Meeting(
      id: 'meet-group-${DateTime.now().millisecondsSinceEpoch}',
      withUserId: firstParticipant,
      scheduledAt: scheduledAt,
      type: MeetingType.video,
      status: MeetingStatus.upcoming,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    ));
    widget.onCreated();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group meeting created!'), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        title: Text('New Group Meeting', style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: c.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepDots(c),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(c),
                _buildStep2(c),
                _buildStep3(c),
                _buildStep4(c),
              ],
            ),
          ),
          _buildNavButtons(c),
        ],
      ),
    );
  }

  Widget _buildStepDots(AC c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentStep ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i <= _currentStep ? AppColors.primary : c.border,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }

  Widget _buildStep1(AC c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Select Participants', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Choose who to invite to the meeting', style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 16),
        ..._candidates.map((u) {
          final sel = _selectedParticipants.contains(u.id);
          return CheckboxListTile(
            value: sel,
            onChanged: (v) => setState(() { v! ? _selectedParticipants.add(u.id) : _selectedParticipants.remove(u.id); }),
            title: Text(u.name, style: TextStyle(color: c.textPrimary, fontSize: 14.5)),
            subtitle: Text(u.role, style: TextStyle(color: c.textMuted, fontSize: 12)),
            secondary: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: u.color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            activeColor: AppColors.primary,
          );
        }),
      ],
    );
  }

  Widget _buildStep2(AC c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Date & Time', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Choose when the meeting takes place', style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        _DateTimeRow(
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: _date != null ? DateFormat('EEE, d MMMM yyyy').format(_date!) : 'Select date',
          onTap: _pickDate,
          c: c,
        ),
        const SizedBox(height: 12),
        _DateTimeRow(
          icon: Icons.schedule_rounded,
          label: 'Start Time',
          value: _startTime != null ? _startTime!.format(context) : 'Select start time',
          onTap: _pickStartTime,
          c: c,
        ),
        const SizedBox(height: 12),
        _DateTimeRow(
          icon: Icons.schedule_rounded,
          label: 'End Time',
          value: _endTime != null ? _endTime!.format(context) : 'Select end time',
          onTap: _pickEndTime,
          c: c,
        ),
      ],
    );
  }

  Widget _buildStep3(AC c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Meeting Details', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Add a title and agenda for the meeting', style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        TextField(
          controller: _titleCtrl,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: c.textPrimary),
          decoration: InputDecoration(
            labelText: 'Meeting Title *',
            labelStyle: TextStyle(color: c.textMuted),
            hintText: 'e.g. Q3 Sales Review',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationCtrl,
          style: TextStyle(color: c.textPrimary),
          decoration: InputDecoration(
            labelText: 'Location (optional)',
            labelStyle: TextStyle(color: c.textMuted),
            hintText: 'Zoom / Google Meet / Room 1',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesCtrl,
          style: TextStyle(color: c.textPrimary),
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Notes / Agenda (optional)',
            labelStyle: TextStyle(color: c.textMuted),
            hintText: 'Add meeting agenda here…',
          ),
        ),
      ],
    );
  }

  Widget _buildStep4(AC c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Confirm', style: TextStyle(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Check the details before creating', style: TextStyle(color: c.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(icon: Icons.title_rounded, label: 'Title', value: _titleCtrl.text.trim(), c: c),
                const SizedBox(height: 12),
                _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _date != null ? DateFormat('EEE, d MMMM yyyy').format(_date!) : '-',
                  c: c,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value: '${_startTime?.format(context) ?? '-'} – ${_endTime?.format(context) ?? '-'}',
                  c: c,
                ),
                if (_locationCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SummaryRow(icon: Icons.location_on_rounded, label: 'Location', value: _locationCtrl.text.trim(), c: c),
                ],
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.people_rounded, color: c.textMuted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Participants', style: TextStyle(color: c.textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: _selectedParticipants.map((id) {
                              final u = findUser(id);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.primaryFaint, borderRadius: BorderRadius.circular(12)),
                                child: Text(u?.name ?? id, style: const TextStyle(color: AppColors.primaryLight, fontSize: 11.5)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_notesCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SummaryRow(icon: Icons.notes_rounded, label: 'Notes', value: _notesCtrl.text.trim(), c: c),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createMeeting,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Meeting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(AC c) {
    final isLast = _currentStep == 3;
    final canNext = switch (_currentStep) {
      0 => _step1Valid,
      1 => _step2Valid,
      2 => _step3Valid,
      _ => false,
    };

    if (isLast) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: c.surface,
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.textSecondary,
                  side: BorderSide(color: c.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canNext ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: c.surfaceElevated,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentStep == 2 ? 'Review' : 'Next',
                style: TextStyle(fontWeight: FontWeight.w700, color: canNext ? Colors.white : c.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final AC c;
  const _DateTimeRow({required this.icon, required this.label, required this.value, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: c.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: c.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 18),
        ],
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AC c;
  const _SummaryRow({required this.icon, required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: c.textMuted, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: c.textMuted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: c.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    ],
  );
}
