import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  String _selectedTz = 'Europe/London (GMT+1)';

  final _timezones = [
    'Europe/London (GMT+1)',
    'Europe/Paris (GMT+2)',
    'Asia/Dhaka (GMT+6)',
    'America/New_York (GMT-4)',
    'America/Los_Angeles (GMT-7)',
    'Asia/Dubai (GMT+4)',
    'Asia/Kolkata (GMT+5:30)',
  ];

  final _dayLabels = {'Mon': 'Monday', 'Tue': 'Tuesday', 'Wed': 'Wednesday', 'Thu': 'Thursday', 'Fri': 'Friday', 'Sat': 'Saturday', 'Sun': 'Sunday'};

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
        title: const Text('Work Hours & Timezone', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Timezone
          _SectionLabel(label: 'TIMEZONE'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTz,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                iconEnabledColor: AppColors.textMuted,
                items: _timezones.map((tz) => DropdownMenuItem(value: tz, child: Text(tz))).toList(),
                onChanged: (v) => setState(() => _selectedTz = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'WORK HOURS'),
          const SizedBox(height: 8),
          ...kWorkHours.map((block) => _WorkHourRow(
            block: block,
            dayLabel: _dayLabels[block.dayKey] ?? block.dayKey,
            onToggle: () => setState(() {}),
            onEditFrom: () => _pickTime(context, block, true),
            onEditTo: () => _pickTime(context, block, false),
          )),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, AvailabilityBlock block, bool isFrom) async {
    final parts = (isFrom ? block.from : block.to).split(':');
    final init = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked != null) setState(() {});
  }
}

class _WorkHourRow extends StatelessWidget {
  final AvailabilityBlock block;
  final String dayLabel;
  final VoidCallback onToggle;
  final VoidCallback onEditFrom;
  final VoidCallback onEditTo;

  const _WorkHourRow({required this.block, required this.dayLabel, required this.onToggle, required this.onEditFrom, required this.onEditTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: block.active ? AppColors.border : AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(dayLabel, style: TextStyle(color: block.active ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (block.active) ...[
            GestureDetector(
              onTap: onEditFrom,
              child: _TimeChip(label: block.from),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('–', style: TextStyle(color: AppColors.textMuted))),
            GestureDetector(
              onTap: onEditTo,
              child: _TimeChip(label: block.to),
            ),
          ] else
            const Expanded(child: Text('Not available', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
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

class _TimeChip extends StatelessWidget {
  final String label;
  const _TimeChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
    ),
    child: Text(label, style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8));
}
