import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';

class WebhooksScreen extends StatefulWidget {
  const WebhooksScreen({super.key});

  @override
  State<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends State<WebhooksScreen>
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
        title: const Text('Webhooks & Events', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.divider,
          tabs: const [Tab(text: 'Apps'), Tab(text: 'Logs'), Tab(text: 'Retry Queue')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AppsTab(onToggle: (id) => setState(() {
            final wh = kWebhooks.firstWhere((w) => w.id == id);
            wh.installed = !wh.installed;
          })),
          _LogsTab(),
          _RetryTab(),
        ],
      ),
    );
  }
}

class _AppsTab extends StatelessWidget {
  final void Function(String) onToggle;
  const _AppsTab({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kWebhooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final wh = kWebhooks[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: wh.installed ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: (wh.installed ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.webhook_rounded, color: wh.installed ? AppColors.primaryLight : AppColors.textMuted, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wh.name, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                        Text(wh.eventKey, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: wh.installed,
                    onChanged: (_) => onToggle(wh.id),
                    activeColor: AppColors.primaryLight,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(wh.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              if (wh.installed) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.link_rounded, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text(wh.url, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5), overflow: TextOverflow.ellipsis)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        _StatChip(label: '${wh.successCount} ok', color: AppColors.online),
                        const SizedBox(width: 8),
                        _StatChip(label: '${wh.failureCount} failed', color: wh.failureCount > 0 ? AppColors.danger : AppColors.textMuted),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  _ActionBtn(label: 'Test', icon: Icons.play_circle_rounded, onTap: () {}),
                  const SizedBox(width: 8),
                  _ActionBtn(label: 'View Logs', icon: Icons.list_alt_rounded, onTap: () {}),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LogsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logs = [
      (event: 'application.status.changed', status: 200, time: '2m ago', ok: true),
      (event: 'application.status.changed', status: 200, time: '8m ago', ok: true),
      (event: 'student.enrolled',           status: 200, time: '1h ago', ok: true),
      (event: 'application.status.changed', status: 500, time: '2h ago', ok: false),
      (event: 'application.status.changed', status: 200, time: '3h ago', ok: true),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final l = logs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: l.ok ? AppColors.border : AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: l.ok ? AppColors.online : AppColors.danger, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(l.event, style: const TextStyle(color: Colors.white, fontSize: 13))),
              Text('${l.status}', style: TextStyle(color: l.ok ? AppColors.online : AppColors.danger, fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Text(l.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            ],
          ),
        );
      },
    );
  }
}

class _RetryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.online, size: 48),
          SizedBox(height: 12),
          Text('No failed deliveries', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          SizedBox(height: 4),
          Text('All webhooks delivered successfully', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.primaryLight, size: 14),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

