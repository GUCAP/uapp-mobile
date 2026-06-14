import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/post.dart';

class FeedPreferencesScreen extends StatefulWidget {
  const FeedPreferencesScreen({super.key});

  @override
  State<FeedPreferencesScreen> createState() => _FeedPreferencesScreenState();
}

class _FeedPreferencesScreenState extends State<FeedPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _seeMore = <String>{'admission', 'offer', 'university'};
  final _seeLess = <String>{'marketing', 'system_updates'};
  final _muted  = <String>{};
  bool _highPriorityOn = true;

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

  String _preferenceFor(String id) {
    if (_muted.contains(id)) return 'muted';
    if (_seeMore.contains(id)) return 'more';
    if (_seeLess.contains(id)) return 'less';
    return 'default';
  }

  void _setPreference(String id, String pref) {
    setState(() {
      _seeMore.remove(id);
      _seeLess.remove(id);
      _muted.remove(id);
      if (pref == 'more') _seeMore.add(id);
      if (pref == 'less') _seeLess.add(id);
      if (pref == 'muted') _muted.add(id);
    });
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
        title: const Text('Feed Preferences', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.divider,
          tabs: const [Tab(text: 'Topics'), Tab(text: 'Categories')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TopicsTab(
            seeMore: _seeMore, seeLess: _seeLess, muted: _muted,
            highPriorityOn: _highPriorityOn,
            preferenceFor: _preferenceFor, setPreference: _setPreference,
            onHighPriority: (v) => setState(() => _highPriorityOn = v),
          ),
          _CategoriesTab(),
        ],
      ),
    );
  }
}

class _TopicsTab extends StatelessWidget {
  final Set<String> seeMore;
  final Set<String> seeLess;
  final Set<String> muted;
  final bool highPriorityOn;
  final String Function(String) preferenceFor;
  final void Function(String, String) setPreference;
  final void Function(bool) onHighPriority;

  const _TopicsTab({
    required this.seeMore, required this.seeLess, required this.muted,
    required this.highPriorityOn, required this.preferenceFor,
    required this.setPreference, required this.onHighPriority,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // High priority toggle
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              const Icon(Icons.priority_high_rounded, color: AppColors.danger, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emphasise High Priority', style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                    Text('Show high-priority posts more prominently', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: highPriorityOn,
                onChanged: onHighPriority,
                activeThumbColor: AppColors.primaryLight,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionLabel(label: 'CATEGORY PREFERENCES'),
        const SizedBox(height: 10),
        ...kPostCategories.map((cat) => _CategoryPrefRow(
          category: cat,
          preference: preferenceFor(cat.id),
          onSet: (p) => setPreference(cat.id, p),
        )),
      ],
    );
  }
}

class _CategoryPrefRow extends StatelessWidget {
  final PostCategory category;
  final String preference;
  final void Function(String) onSet;

  const _CategoryPrefRow({required this.category, required this.preference, required this.onSet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: category.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Icon(category.icon, color: category.color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(category.label, style: const TextStyle(color: Colors.white, fontSize: 14))),
          _PrefChip(label: 'More', selected: preference == 'more', color: AppColors.online, onTap: () => onSet(preference == 'more' ? 'default' : 'more')),
          const SizedBox(width: 6),
          _PrefChip(label: 'Less', selected: preference == 'less', color: AppColors.warn, onTap: () => onSet(preference == 'less' ? 'default' : 'less')),
          const SizedBox(width: 6),
          _PrefChip(label: 'Mute', selected: preference == 'muted', color: AppColors.textMuted, onTap: () => onSet(preference == 'muted' ? 'default' : 'muted')),
        ],
      ),
    );
  }
}

class _PrefChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PrefChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : AppColors.border),
      ),
      child: Text(label, style: TextStyle(color: selected ? color : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
    ),
  );
}

class _CategoriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kPostCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final cat = kPostCategories[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Icon(cat.icon, color: cat.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.label, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                    Text(cat.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 18),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8));
}
