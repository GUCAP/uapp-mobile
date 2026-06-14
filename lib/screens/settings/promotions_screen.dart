import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  static final List<Map<String, dynamic>> _campaigns = [
    {
      'university': 'University of Hertfordshire',
      'commission': '£150',
      'status': 'Active',
      'dates': '1 Jun 2026 – 30 Sep 2026',
      'minStudents': 5,
    },
    {
      'university': 'Middlesex University',
      'commission': '£200',
      'status': 'Active',
      'dates': '15 Jun 2026 – 31 Dec 2026',
      'minStudents': 3,
    },
    {
      'university': 'London Metropolitan University',
      'commission': '£120',
      'status': 'Draft',
      'dates': '1 Aug 2026 – 31 Jan 2027',
      'minStudents': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, c),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _campaigns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _CampaignCard(campaign: _campaigns[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('New Campaign', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign creation coming soon!'), backgroundColor: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: c.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Promotions & Commissions', style: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final isActive = campaign['status'] == 'Active';
    final statusColor = isActive ? AppColors.online : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(campaign['university'], style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              // Commission badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(campaign['commission'], style: const TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(campaign['status'], style: TextStyle(color: statusColor, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: c.textMuted, size: 13),
              const SizedBox(width: 6),
              Text(campaign['dates'], style: TextStyle(color: c.textSecondary, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.people_rounded, color: c.textMuted, size: 13),
              const SizedBox(width: 6),
              Text('Min. ${campaign['minStudents']} students', style: TextStyle(color: c.textSecondary, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: BorderSide(color: AppColors.primaryBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.archive_rounded, size: 14),
                  label: const Text('Archive', style: TextStyle(fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textSecondary,
                    side: BorderSide(color: c.border),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
