import 'package:flutter/material.dart';
import '../../core/theme.dart';

class _TemplateField {
  final String id;
  final String label;
  final String type;
  final IconData icon;
  bool visible;

  _TemplateField({required this.id, required this.label, required this.type, required this.icon, this.visible = true});
}

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _appFields = [
    _TemplateField(id: 'app_id',     label: 'Application ID', type: 'id',   icon: Icons.tag_rounded),
    _TemplateField(id: 'status',     label: 'Status',          type: 'pill', icon: Icons.circle_rounded),
    _TemplateField(id: 'university', label: 'University',      type: 'text', icon: Icons.account_balance_rounded),
    _TemplateField(id: 'program',    label: 'Program',         type: 'text', icon: Icons.school_rounded),
    _TemplateField(id: 'intake',     label: 'Intake',          type: 'text', icon: Icons.calendar_month_rounded),
    _TemplateField(id: 'visa',       label: 'Visa Status',     type: 'pill', icon: Icons.card_membership_rounded, visible: false),
  ];

  final _teamFields = [
    _TemplateField(id: 'lead',           label: 'Team Lead',       type: 'text', icon: Icons.person_rounded),
    _TemplateField(id: 'quarter_target', label: 'Quarter Target',  type: 'text', icon: Icons.flag_rounded),
    _TemplateField(id: 'quarter_actual', label: 'Quarter Actual',  type: 'text', icon: Icons.trending_up_rounded),
    _TemplateField(id: 'department',     label: 'Department',      type: 'text', icon: Icons.business_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Group Templates', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.divider,
          tabs: const [Tab(text: 'Application Groups'), Tab(text: 'Team Groups')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FieldList(fields: _appFields, onToggle: (f) => setState(() => f.visible = !f.visible)),
          _FieldList(fields: _teamFields, onToggle: (f) => setState(() => f.visible = !f.visible)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Field', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onPressed: () => _showAddField(context),
      ),
    );
  }

  void _showAddField(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Field', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Field label'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Field type'),
              items: ['text', 'id', 'pill', 'date'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _FieldList extends StatelessWidget {
  final List<_TemplateField> fields;
  final void Function(_TemplateField) onToggle;

  const _FieldList({required this.fields, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: fields.length,
      onReorder: (_, __) {},
      itemBuilder: (_, i) {
        final f = fields[i];
        return Container(
          key: ValueKey(f.id),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: f.visible ? AppColors.border : AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: (f.visible ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(f.icon, color: f.visible ? AppColors.primaryLight : AppColors.textMuted, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.label, style: TextStyle(color: f.visible ? Colors.white : AppColors.textMuted, fontSize: 14.5, fontWeight: FontWeight.w500)),
                    Text(f.type, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: f.visible,
                onChanged: (_) => onToggle(f),
                activeColor: AppColors.primaryLight,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
