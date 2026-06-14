import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/post.dart';
import '../widgets/top_bar_actions.dart';
import '../widgets/user_avatar.dart';

// ── Promotion campaign model ──────────────────────────────────
class _Campaign {
  final String id;
  final String university;
  final String universityCode;
  final Color universityColor;
  final String commission;
  final int minStudents;
  final String intake;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String description;

  const _Campaign({
    required this.id,
    required this.university,
    required this.universityCode,
    required this.universityColor,
    required this.commission,
    required this.minStudents,
    required this.intake,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.description,
  });
}

final _campaigns = [
  _Campaign(
    id: 'c1',
    university: 'Middlesex University',
    universityCode: 'MDX',
    universityColor: const Color(0xFF7C3AED),
    commission: '£1,500',
    minStudents: 3,
    intake: 'September 2026',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 8, 30),
    isActive: true,
    description: 'Earn £1,500 per enrolled student for the September 2026 intake across all undergraduate and postgraduate programmes.',
  ),
  _Campaign(
    id: 'c2',
    university: 'Anglia Ruskin University',
    universityCode: 'ARU',
    universityColor: const Color(0xFF0A6E6F),
    commission: '£1,200',
    minStudents: 2,
    intake: 'January 2026',
    startDate: DateTime(2026, 5, 15),
    endDate: DateTime(2026, 11, 30),
    isActive: true,
    description: 'Special January intake commission offer — minimum 2 students. Business, Computing and Health courses included.',
  ),
  _Campaign(
    id: 'c3',
    university: 'University of Hertfordshire',
    universityCode: 'UH',
    universityColor: const Color(0xFF0EA5E9),
    commission: '£900',
    minStudents: 1,
    intake: 'Sep 2026 / Jan 2027',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 12, 31),
    isActive: true,
    description: 'No minimum requirement — earn £900 per student for any intake. All subjects eligible including nursing and engineering.',
  ),
  _Campaign(
    id: 'c4',
    university: 'University of East London',
    universityCode: 'UEL',
    universityColor: const Color(0xFFDC2626),
    commission: '£1,100',
    minStudents: 2,
    intake: 'May 2026',
    startDate: DateTime(2026, 3, 1),
    endDate: DateTime(2026, 4, 30),
    isActive: false,
    description: 'May intake special rate. Campaign has now ended.',
  ),
];

class PromotionsFeedScreen extends StatefulWidget {
  const PromotionsFeedScreen({super.key});

  @override
  State<PromotionsFeedScreen> createState() => _PromotionsFeedScreenState();
}

class _PromotionsFeedScreenState extends State<PromotionsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  List<FeedPost> get _promoNews => kFeedPosts
      .where((p) => p.categoryId == 'promotion' || p.categoryId == 'partnership' || p.categoryId == 'offer')
      .toList();

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final active = _campaigns.where((c) => c.isActive).length;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promotions', style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
                      Text('$active active campaigns', style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  const TopBarActions(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Active campaign banner (top pick)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TopCampaignBanner(campaign: _campaigns.first, c: c),
            ),
            const SizedBox(height: 12),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.orange,
              unselectedLabelColor: c.textMuted,
              indicatorColor: AppColors.orange,
              dividerColor: c.divider,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: 'All Campaigns (${_campaigns.length})'),
                Tab(text: 'News (${_promoNews.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CampaignList(campaigns: _campaigns),
                  _NewsList(posts: _promoNews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top banner ────────────────────────────────────────────────
class _TopCampaignBanner extends StatelessWidget {
  final _Campaign campaign;
  final AC c;
  const _TopCampaignBanner({required this.campaign, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [campaign.universityColor.withValues(alpha: 0.9), campaign.universityColor.withValues(alpha: 0.5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('🔥 TOP PICK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 8),
                Text(campaign.university, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(campaign.commission + ' per student', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Min ${campaign.minStudents} student${campaign.minStudents > 1 ? 's' : ''} · ${campaign.intake}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(campaign.universityCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: campaign.universityColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Campaign list ─────────────────────────────────────────────
class _CampaignList extends StatelessWidget {
  final List<_Campaign> campaigns;
  const _CampaignList({required this.campaigns});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: campaigns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _CampaignCard(campaign: campaigns[i], c: c),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final _Campaign campaign;
  final AC c;
  const _CampaignCard({required this.campaign, required this.c});

  @override
  Widget build(BuildContext context) {
    final daysLeft = campaign.endDate.difference(DateTime.now()).inDays;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: campaign.isActive ? campaign.universityColor.withValues(alpha: 0.3) : c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: campaign.universityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(campaign.universityCode, style: TextStyle(color: campaign.universityColor, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.university, style: TextStyle(color: c.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                    Text(campaign.intake, style: TextStyle(color: c.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (campaign.isActive ? AppColors.online : c.textMuted).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  campaign.isActive ? 'Active' : 'Ended',
                  style: TextStyle(color: campaign.isActive ? AppColors.online : c.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(label: campaign.commission, sub: 'per student', color: AppColors.orange),
              const SizedBox(width: 10),
              _StatChip(label: '${campaign.minStudents} min', sub: 'students', color: campaign.universityColor),
              if (campaign.isActive && daysLeft > 0) ...[
                const SizedBox(width: 10),
                _StatChip(label: '$daysLeft days', sub: 'remaining', color: AppColors.warn),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(campaign.description, style: TextStyle(color: c.textSecondary, fontSize: 12.5, height: 1.45)),
          if (campaign.isActive) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: campaign.universityColor,
                    side: BorderSide(color: campaign.universityColor.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Apply Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _StatChip({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(color: color, fontSize: 13.5, fontWeight: FontWeight.w800)),
      Text(sub, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
    ]),
  );
}

// ── News list ─────────────────────────────────────────────────
class _NewsList extends StatelessWidget {
  final List<FeedPost> posts;
  const _NewsList({required this.posts});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    if (posts.isEmpty) {
      return Center(child: Text('No promotion news yet', style: TextStyle(color: c.textMuted, fontSize: 14)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = posts[i];
        final author = findUser(p.authorId);
        final cat = findCategory(p.categoryId);
        final diff = DateTime.now().difference(p.createdAt);
        final ago = diff.inHours < 24 ? '${diff.inHours}h ago' : '${diff.inDays}d ago';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (author != null) UserAvatar(userId: author.id, size: 36),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(author?.name ?? '', style: TextStyle(color: c.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                Text('$ago', style: TextStyle(color: c.textMuted, fontSize: 11)),
              ])),
              if (cat != null) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(cat.icon, color: cat.color, size: 11),
                  const SizedBox(width: 4),
                  Text(cat.label, style: TextStyle(color: cat.color, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Text(p.body, style: TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    );
  }
}
