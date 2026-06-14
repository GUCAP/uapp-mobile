import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../widgets/user_avatar.dart';

class NewMeetingScreen extends StatefulWidget {
  final void Function(Meeting) onCreated;

  const NewMeetingScreen({super.key, required this.onCreated});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Online — link generated automatically');

  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  MeetingType _type = MeetingType.video;
  final List<String> _participants = [];
  bool _isRecurring = false;
  String _recurrence = 'Weekly';
  // Weekly day-of-week selection (0=Mon … 6=Sun)
  final Set<int> _weekDays = {0, 1, 2, 3, 4}; // Mon–Fri default
  // End condition
  String _endType = 'never'; // never | after | on
  int _endAfter = 10;
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));

  bool get _canCreate =>
      _titleCtrl.text.trim().isNotEmpty && _participants.isNotEmpty;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (!_canCreate) return;
    final scheduled = DateTime(
      _date.year, _date.month, _date.day,
      _startTime.hour, _startTime.minute,
    );
    final meeting = Meeting(
      id: 'meet-${DateTime.now().millisecondsSinceEpoch}',
      withUserId: _participants.first,
      scheduledAt: scheduled,
      type: _type,
      status: MeetingStatus.upcoming,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    kMeetings.add(meeting);
    widget.onCreated(meeting);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto-set end to +30 min
          final totalMin = picked.hour * 60 + picked.minute + 30;
          _endTime = TimeOfDay(hour: totalMin ~/ 60 % 24, minute: totalMin % 60);
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _pickParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.7,
          builder: (_, ctrl) {
            final others = kUsers.where((u) => u.id != kCurrentUser.id && u.type != UserType.student).toList();
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Text('Add participants', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${_participants.length} selected', style: const TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                ]),
              ),
              const Divider(color: AppColors.divider),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  itemCount: others.length,
                  itemBuilder: (_, i) {
                    final u = others[i];
                    final sel = _participants.contains(u.id);
                    return ListTile(
                      leading: UserAvatar(userId: u.id, size: 40, showOnline: true),
                      title: Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
                      subtitle: Text(u.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      trailing: Checkbox(
                        value: sel,
                        onChanged: (_) => setSheet(() { setState(() { sel ? _participants.remove(u.id) : _participants.add(u.id); }); }),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: AppColors.textMuted),
                      ),
                      onTap: () => setSheet(() { setState(() { sel ? _participants.remove(u.id) : _participants.add(u.id); }); }),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
                child: SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Confirm ${_participants.length} participant${_participants.length == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                )),
              ),
            ]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ),
        centerTitle: true,
        title: const Text('New Meeting', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _canCreate ? _create : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canCreate ? AppColors.primary : AppColors.surfaceElevated,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Create', style: TextStyle(fontWeight: FontWeight.w700, color: _canCreate ? Colors.white : AppColors.textMuted)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _SectionLabel('Meeting title'),
            TextField(
              controller: _titleCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(hintText: 'e.g. Q3 Review, Student Onboarding'),
            ),
            const SizedBox(height: 20),

            // Participants
            _SectionLabel('Participants'),
            GestureDetector(
              onTap: _pickParticipants,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _participants.isNotEmpty ? AppColors.primaryBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    if (_participants.isEmpty) ...[
                      const Icon(Icons.person_add_rounded, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 10),
                      const Text('Add people', style: TextStyle(color: AppColors.textMuted, fontSize: 14.5)),
                    ] else ...[
                      // Stack of avatars
                      SizedBox(
                        height: 36,
                        width: (_participants.length * 26.0).clamp(36, 110),
                        child: Stack(
                          children: _participants.take(4).toList().asMap().entries.map((e) => Positioned(
                            left: e.key * 24.0,
                            child: UserAvatar(userId: e.value, size: 36),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${_participants.length} participant${_participants.length == 1 ? '' : 's'}',
                          style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                    ],
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time
            _SectionLabel('Date & Time'),
            Row(children: [
              Expanded(child: _TapField(
                icon: Icons.calendar_today_rounded,
                label: DateFormat('EEE, d MMM yyyy').format(_date),
                onTap: _pickDate,
              )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _TapField(
                icon: Icons.access_time_rounded,
                label: _startTime.format(context),
                onTap: () => _pickTime(true),
              )),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('to', style: TextStyle(color: AppColors.textMuted))),
              Expanded(child: _TapField(
                icon: Icons.access_time_rounded,
                label: _endTime.format(context),
                onTap: () => _pickTime(false),
              )),
            ]),
            const SizedBox(height: 20),

            // Meeting type
            _SectionLabel('Meeting type'),
            Row(children: [
              _TypeChip(icon: Icons.video_call_rounded,  label: 'Video',        sel: _type == MeetingType.video,        onTap: () => setState(() => _type = MeetingType.video),        color: AppColors.primary),
              const SizedBox(width: 10),
              _TypeChip(icon: Icons.call_rounded,        label: 'Voice Call',   sel: _type == MeetingType.audio,        onTap: () => setState(() => _type = MeetingType.audio),        color: const Color(0xFF3A7BD5)),
              const SizedBox(width: 10),
              _TypeChip(icon: Icons.people_rounded,      label: 'Consultation', sel: _type == MeetingType.consultation, onTap: () => setState(() => _type = MeetingType.consultation), color: AppColors.orange),
            ]),
            const SizedBox(height: 20),

            // Location
            _SectionLabel('Location'),
            TextField(
              controller: _locationCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Recurring toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.repeat_rounded, color: AppColors.primaryLight, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Recurring meeting', style: TextStyle(color: Colors.white, fontSize: 14.5))),
                      Switch.adaptive(
                        value: _isRecurring,
                        onChanged: (v) => setState(() => _isRecurring = v),
                        activeThumbColor: AppColors.primaryLight,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  if (_isRecurring) ...[
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 10),

                    // Frequency chips
                    const Text('Repeats', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Daily', 'Weekly', 'Monthly'].map((r) {
                        final sel = _recurrence == r;
                        return GestureDetector(
                          onTap: () => setState(() => _recurrence = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(r, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        );
                      }).toList(),
                    ),

                    // Weekly day-of-week picker
                    if (_recurrence == 'Weekly') ...[
                      const SizedBox(height: 14),
                      const Text('Repeat on', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final sel = _weekDays.contains(i);
                          return GestureDetector(
                            onTap: () => setState(() { sel ? _weekDays.remove(i) : _weekDays.add(i); }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: sel ? AppColors.primary : AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(labels[i], style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          );
                        }),
                      ),
                    ],

                    // End condition
                    const SizedBox(height: 14),
                    const Text('Ends', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        _EndOption(label: 'Never', value: 'never', group: _endType, onTap: () => setState(() => _endType = 'never')),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: _EndOption(label: 'After', value: 'after', group: _endType, onTap: () => setState(() => _endType = 'after'))),
                            if (_endType == 'after') ...[
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
                                  controller: TextEditingController(text: '$_endAfter'),
                                  onChanged: (v) => setState(() => _endAfter = int.tryParse(v) ?? _endAfter),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('occurrences', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: _EndOption(label: 'On date', value: 'on', group: _endType, onTap: () => setState(() => _endType = 'on'))),
                            if (_endType == 'on') ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  final d = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)));
                                  if (d != null) setState(() => _endDate = d);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryBorder)),
                                  child: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            _SectionLabel('Notes (optional)'),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              decoration: const InputDecoration(hintText: 'Agenda, preparation notes…'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
  );
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TapField({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(icon, color: AppColors.primaryLight, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ]),
    ),
  );
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool sel;
  final VoidCallback onTap;
  final Color color;
  const _TypeChip({required this.icon, required this.label, required this.sel, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? color : AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: sel ? color : AppColors.textMuted, size: 22),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: sel ? color : AppColors.textMuted, fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

class _EndOption extends StatelessWidget {
  final String label;
  final String value;
  final String group;
  final VoidCallback onTap;
  const _EndOption({required this.label, required this.value, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sel = value == group;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: sel ? AppColors.primary : AppColors.textMuted, width: 2),
              color: sel ? AppColors.primary : Colors.transparent,
            ),
            child: sel ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 13.5)),
        ],
      ),
    );
  }
}
