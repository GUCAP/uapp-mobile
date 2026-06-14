import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/user.dart';
import 'user_management_screen.dart';
import 'permissions_screen.dart';
import 'templates_screen.dart';
import 'webhooks_screen.dart';
import 'feed_preferences_screen.dart';
import 'timezone_screen.dart';
import 'promotions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = kCurrentUser.type == UserType.admin;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAdmin) ...[
                      _SectionHeader(label: 'TEAM ADMINISTRATION'),
                      _SettingsCard(items: [
                        _SettingsItem(
                          icon: Icons.people_rounded,
                          label: 'User Management',
                          description: 'Manage staff, consultants, and students',
                          color: const Color(0xFF0EA5E9),
                          onTap: () => _push(context, const UserManagementScreen()),
                        ),
                        _SettingsItem(
                          icon: Icons.shield_rounded,
                          label: 'Permissions',
                          description: 'Role-based access control per module',
                          color: const Color(0xFF7C3AED),
                          onTap: () => _push(context, const PermissionsScreen()),
                        ),
                        _SettingsItem(
                          icon: Icons.dashboard_customize_rounded,
                          label: 'Group Templates',
                          description: 'Fields shown in application group banners',
                          color: const Color(0xFF0A6E6F),
                          onTap: () => _push(context, const TemplatesScreen()),
                        ),
                        _SettingsItem(
                          icon: Icons.webhook_rounded,
                          label: 'Webhooks & Events',
                          description: 'Integrate external services and automations',
                          color: const Color(0xFF16A34A),
                          onTap: () => _push(context, const WebhooksScreen()),
                          trailingBadge: '${kWebhooks.where((w) => w.installed).length} active',
                        ),
                        _SettingsItem(
                          icon: Icons.campaign_rounded,
                          label: 'Promotions & Commissions',
                          description: 'Manage university promotion campaigns and commission rates',
                          color: AppColors.orange,
                          onTap: () => _push(context, const PromotionsScreen()),
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ],
                    _SectionHeader(label: 'CONTENT & FEED'),
                    _SettingsCard(items: [
                      _SettingsItem(
                        icon: Icons.tune_rounded,
                        label: 'Feed Preferences',
                        description: 'Manage categories, topics, and audience filters',
                        color: const Color(0xFFFC7300),
                        onTap: () => _push(context, const FeedPreferencesScreen()),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _SectionHeader(label: 'WORKSPACE'),
                    _SettingsCard(items: [
                      _SettingsItem(
                        icon: Icons.schedule_rounded,
                        label: 'Work Hours & Timezone',
                        description: 'Set your availability and local timezone',
                        color: const Color(0xFF0A6E6F),
                        onTap: () => _push(context, const TimezoneScreen()),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    if (isAdmin) ...[
                      _SectionHeader(label: 'SYSTEM'),
                      _SettingsCard(items: [
                        _SettingsItem(
                          icon: Icons.history_rounded,
                          label: 'Login History',
                          description: 'Audit log of all user sign-ins',
                          color: const Color(0xFF64748B),
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.bug_report_rounded,
                          label: 'System Logs',
                          description: 'Webhook execution and error logs',
                          color: const Color(0xFF64748B),
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 20),
                    ],
                    _SectionHeader(label: 'APP'),
                    _SettingsCard(items: [
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About UAPP',
                        description: 'Version, licenses, and terms',
                        color: const Color(0xFF64748B),
                        onTap: () => _showAbout(context),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('UAPP Mobile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('Communication Hub for UAPP — UK\'s student recruitment platform.', style: TextStyle(color: AppColors.textMuted, height: 1.5)),
            SizedBox(height: 12),
            Text('© 2026 UAPP Ltd · uapp.uk', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: AppColors.primaryLight))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const Divider(height: 1, indent: 56, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final String? trailingBadge;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                  Text(description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(trailingBadge!, style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
