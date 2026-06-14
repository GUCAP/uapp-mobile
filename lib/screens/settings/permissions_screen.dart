import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  String _selectedSet = 'contributor';

  final _modules = {
    'Chats': ['chats_view', 'chats_create', 'chats_react', 'chats_pin', 'chats_archive', 'chats_delete', 'chats_manageMembers'],
    'Feed': ['feed_view', 'feed_create', 'feed_bookmark', 'feed_react', 'feed_share', 'feed_deleteOwn', 'feed_deleteAny'],
    'Schedule': ['schedule_view', 'schedule_create', 'schedule_edit', 'schedule_delete', 'schedule_recurring'],
    'Webhooks': ['webhooks_view', 'webhooks_create', 'webhooks_edit', 'webhooks_delete', 'webhooks_test'],
    'CRM': ['crm_view', 'crm_edit', 'crm_create', 'crm_delete'],
    'Promotions': ['promo_view', 'promo_create', 'promo_edit', 'promo_delete'],
  };

  String _labelFor(String key) {
    return key.replaceAll('_', ' ').split(' ').skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final current = kPermissionSets.firstWhere((s) => s.id == _selectedSet);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Permissions', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Role selector
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role / Permission Set', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kPermissionSets.map((s) {
                      final sel = s.id == _selectedSet;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSet = s.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? s.color : s.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? s.color : s.color.withValues(alpha: 0.3)),
                          ),
                          child: Text(s.label, style: TextStyle(color: sel ? Colors.white : s.color, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _modules.entries.map((entry) {
                return _ModuleSection(
                  module: entry.key,
                  permissions: entry.value,
                  grants: current.grants,
                  labelFor: _labelFor,
                  onToggle: (key) => setState(() {}),
                  readOnly: current.id == 'full_access',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  final String module;
  final List<String> permissions;
  final Map<String, bool> grants;
  final String Function(String) labelFor;
  final void Function(String) onToggle;
  final bool readOnly;

  const _ModuleSection({
    required this.module, required this.permissions, required this.grants,
    required this.labelFor, required this.onToggle, required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(module.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              for (int i = 0; i < permissions.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(labelFor(permissions[i]), style: const TextStyle(color: Colors.white, fontSize: 14))),
                      Switch.adaptive(
                        value: grants[permissions[i]] ?? false,
                        onChanged: readOnly ? null : (_) => onToggle(permissions[i]),
                        activeThumbColor: AppColors.primaryLight,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
                if (i < permissions.length - 1) const Divider(height: 1, indent: 16, color: AppColors.divider),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
