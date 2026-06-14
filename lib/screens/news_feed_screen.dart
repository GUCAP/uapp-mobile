import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/post.dart';
import '../widgets/user_avatar.dart';
import '../widgets/top_bar_actions.dart';
import 'post_composer_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<FeedPost> _filtered(String scope) {
    switch (scope) {
      case 'team':
        return kFeedPosts.where((p) => p.audience == PostAudience.sales || p.audience == PostAudience.admission).toList();
      case 'company':
        return kFeedPosts.where((p) => p.audience == PostAudience.all || p.audience == PostAudience.leadership).toList();
      case 'saved':
        return kFeedPosts.where((p) => p.isBookmarked).toList();
      default: // for_you
        final sorted = List<FeedPost>.from(kFeedPosts)
          ..sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            if (a.priority == PostPriority.high && b.priority != PostPriority.high) return -1;
            if (a.priority != PostPriority.high && b.priority == PostPriority.high) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });
        return sorted;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            _buildComposerBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PostList(posts: _filtered('for_you'), onUpdate: () => setState(() {})),
                  _PostList(posts: _filtered('team'), onUpdate: () => setState(() {})),
                  _PostList(posts: _filtered('company'), onUpdate: () => setState(() {})),
                  _PostList(posts: _filtered('saved'), onUpdate: () => setState(() {}), emptyLabel: 'No saved posts yet'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }

  void _showComposer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PostComposerScreen(
          onPost: (post) => setState(() => kFeedPosts.insert(0, post)),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        const Text('News Feed', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 22), onPressed: () {}),
        const SizedBox(width: 6),
        const TopBarActions(),
      ],
    ),
  );

  Widget _buildComposerBar() => GestureDetector(
    onTap: _showComposer,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: kCurrentUser.color, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(kCurrentUser.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("What's on your mind?", style: TextStyle(color: AppColors.textMuted, fontSize: 14.5)),
          ),
          const Icon(Icons.photo_library_outlined, color: AppColors.primaryLight, size: 22),
        ],
      ),
    ),
  );

  Widget _buildTabs() => TabBar(
    controller: _tabController,
    tabs: const [Tab(text: 'For You'), Tab(text: 'Team'), Tab(text: 'Company'), Tab(text: 'Saved')],
    labelColor: AppColors.primaryLight,
    unselectedLabelColor: AppColors.textMuted,
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontSize: 13),
    indicatorColor: AppColors.primary,
    indicatorWeight: 2,
    dividerColor: AppColors.divider,
  );
}

// ── Post List ─────────────────────────────────────────────────
class _PostList extends StatelessWidget {
  final List<FeedPost> posts;
  final VoidCallback onUpdate;
  final String? emptyLabel;

  const _PostList({required this.posts, required this.onUpdate, this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.newspaper_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(emptyLabel ?? 'No posts yet', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostCard(post: posts[i], onUpdate: onUpdate),
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onUpdate;
  const _PostCard({required this.post, required this.onUpdate});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _showComments = false;
  final _commentCtrl = TextEditingController();

  FeedPost get p => widget.post;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd MMM').format(dt);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _react(String type) {
    setState(() => p.toggleReaction(kCurrentUser.id, type));
    widget.onUpdate();
  }

  void _bookmark() {
    setState(() => p.isBookmarked = !p.isBookmarked);
    widget.onUpdate();
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      p.comments.add(PostComment(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        authorId: kCurrentUser.id,
        text: text,
        createdAt: DateTime.now(),
      ));
      _commentCtrl.clear();
    });
  }

  void _showReactionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('React to this post', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ReactionButton(emoji: '👍', label: 'Like', type: 'like', onTap: () { Navigator.pop(context); _react('like'); }),
                _ReactionButton(emoji: '💡', label: 'Insightful', type: 'insightful', onTap: () { Navigator.pop(context); _react('insightful'); }),
                _ReactionButton(emoji: '🎉', label: 'Celebrate', type: 'celebrate', onTap: () { Navigator.pop(context); _react('celebrate'); }),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = findCategory(p.categoryId);
    final author = findUser(p.authorId);
    final myReaction = p.reactions.where((r) => r.userId == kCurrentUser.id).firstOrNull?.type;
    final totalReactions = p.reactions.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.isPinned ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned banner
          if (p.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.push_pin_rounded, color: AppColors.primaryLight, size: 13),
                  SizedBox(width: 6),
                  Text('Pinned', style: TextStyle(color: AppColors.primaryLight, fontSize: 11.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    if (author != null) UserAvatar(userId: author.id, size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(author?.name ?? p.authorId, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${author?.role ?? ''} · ${_timeAgo(p.createdAt)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    if (cat != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(cat.icon, color: cat.color, size: 11),
                          const SizedBox(width: 4),
                          Text(cat.label, style: TextStyle(color: cat.color, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    const SizedBox(width: 6),
                    // Priority
                    if (p.priority == PostPriority.high)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('High', style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Body
                Text(p.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.55)),
                // Reaction summary
                if (totalReactions > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ReactionSummary(reactions: p.reactions),
                      const Spacer(),
                      Text('${p.comments.length} comment${p.comments.length == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 4),
                // Action row
                Row(
                  children: [
                    _FeedActionBtn(
                      emoji: myReaction == 'like' ? '👍' : myReaction == 'insightful' ? '💡' : myReaction == 'celebrate' ? '🎉' : null,
                      iconData: myReaction == null ? Icons.thumb_up_outlined : null,
                      label: myReaction != null ? 'Reacted' : 'React',
                      active: myReaction != null,
                      onTap: () => myReaction != null ? _react(myReaction) : _showReactionPicker(),
                    ),
                    const SizedBox(width: 4),
                    _FeedActionBtn(
                      iconData: Icons.chat_bubble_outline_rounded,
                      label: 'Comment',
                      onTap: () => setState(() => _showComments = !_showComments),
                    ),
                    const SizedBox(width: 4),
                    _FeedActionBtn(
                      iconData: Icons.reply_rounded,
                      label: 'Share',
                      onTap: () {},
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        p.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: p.isBookmarked ? AppColors.primaryLight : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: _bookmark,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Comments section
                if (_showComments) ...[
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 10),
                  ...p.comments.map((c) => _CommentTile(comment: c)),
                  // Add comment input
                  Row(
                    children: [
                      UserAvatar(userId: kCurrentUser.id, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          onSubmitted: (_) => _addComment(),
                          decoration: InputDecoration(
                            hintText: 'Add a comment…',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                            filled: true,
                            fillColor: AppColors.bg,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 18),
                              onPressed: _addComment,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionSummary extends StatelessWidget {
  final List<PostReaction> reactions;
  const _ReactionSummary({required this.reactions});

  @override
  Widget build(BuildContext context) {
    final types = {'like': 0, 'insightful': 0, 'celebrate': 0};
    for (final r in reactions) {
      types[r.type] = (types[r.type] ?? 0) + 1;
    }
    final emojis = {'like': '👍', 'insightful': '💡', 'celebrate': '🎉'};
    final shown = types.entries.where((e) => e.value > 0).take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...shown.map((e) => Text(emojis[e.key]!, style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 4),
        Text('${reactions.length}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final author = findUser(comment.authorId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(userId: comment.authorId, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author?.name ?? comment.authorId, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(comment.text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('h:mm a').format(comment.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedActionBtn extends StatelessWidget {
  final String? emoji;
  final IconData? iconData;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FeedActionBtn({this.emoji, this.iconData, required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryLight : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 16))
            else if (iconData != null) Icon(iconData, color: color, size: 17),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String type;
  final VoidCallback onTap;
  const _ReactionButton({required this.emoji, required this.label, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ── Post Composer ─────────────────────────────────────────────
class _PostComposerSheet extends StatefulWidget {
  final void Function(FeedPost) onPost;
  const _PostComposerSheet({required this.onPost});

  @override
  State<_PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<_PostComposerSheet> {
  final _ctrl = TextEditingController();
  String _categoryId = 'announcement';
  PostAudience _audience = PostAudience.all;
  PostPriority _priority = PostPriority.medium;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  final _audienceLabels = {
    PostAudience.all: 'Everyone',
    PostAudience.sales: 'Sales Team',
    PostAudience.admission: 'Admission Team',
    PostAudience.leadership: 'Leadership',
  };

  void _publish() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(FeedPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: kCurrentUser.id,
      body: text,
      createdAt: DateTime.now(),
      categoryId: _categoryId,
      audience: _audience,
      priority: _priority,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cat = findCategory(_categoryId)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('New Post', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton(
                  onPressed: _publish,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            UserAvatar(userId: kCurrentUser.id, size: 38),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                filled: false,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            // Meta chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _MetaChip(
                    icon: cat.icon,
                    label: cat.label,
                    color: cat.color,
                    onTap: () => _showCategoryPicker(),
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.group_rounded,
                    label: _audienceLabels[_audience]!,
                    color: AppColors.textSecondary,
                    onTap: () => _showAudiencePicker(),
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.flag_rounded,
                    label: _priority.name[0].toUpperCase() + _priority.name.substring(1),
                    color: _priority == PostPriority.high ? AppColors.danger : _priority == PostPriority.medium ? AppColors.warn : AppColors.textMuted,
                    onTap: () => _showPriorityPicker(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: kPostCategories.length,
        itemBuilder: (_, i) {
          final cat = kPostCategories[i];
          return ListTile(
            leading: Icon(cat.icon, color: cat.color),
            title: Text(cat.label, style: const TextStyle(color: Colors.white)),
            trailing: _categoryId == cat.id ? const Icon(Icons.check_rounded, color: AppColors.primaryLight) : null,
            onTap: () { setState(() => _categoryId = cat.id); Navigator.pop(context); },
          );
        },
      ),
    );
  }

  void _showAudiencePicker() {
    final opts = [PostAudience.all, PostAudience.sales, PostAudience.admission, PostAudience.leadership];
    final labels = {PostAudience.all: 'Everyone', PostAudience.sales: 'Sales Team', PostAudience.admission: 'Admission Team', PostAudience.leadership: 'Leadership'};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: opts.map((a) => ListTile(
          leading: const Icon(Icons.group_rounded, color: AppColors.textSecondary),
          title: Text(labels[a]!, style: const TextStyle(color: Colors.white)),
          trailing: _audience == a ? const Icon(Icons.check_rounded, color: AppColors.primaryLight) : null,
          onTap: () { setState(() => _audience = a); Navigator.pop(context); },
        )).toList(),
      ),
    );
  }

  void _showPriorityPicker() {
    final opts = [PostPriority.high, PostPriority.medium, PostPriority.low];
    final colors = {PostPriority.high: AppColors.danger, PostPriority.medium: AppColors.warn, PostPriority.low: AppColors.textMuted};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: opts.map((pri) => ListTile(
          leading: Icon(Icons.flag_rounded, color: colors[pri]),
          title: Text('${pri.name[0].toUpperCase()}${pri.name.substring(1)} Priority', style: const TextStyle(color: Colors.white)),
          trailing: _priority == pri ? const Icon(Icons.check_rounded, color: AppColors.primaryLight) : null,
          onTap: () { setState(() => _priority = pri); Navigator.pop(context); },
        )).toList(),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MetaChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 14),
      ]),
    ),
  );
}
