import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/post.dart';
import '../models/message.dart';
import '../widgets/user_avatar.dart';
import '../widgets/top_bar_actions.dart';
import '../widgets/floating_reaction_picker.dart';
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
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c),
            _buildTabs(c),
            _buildComposerBar(c),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PostList(posts: _filtered('for_you'), onUpdate: () => setState(() {})),
                  _PostList(posts: _filtered('team'), onUpdate: () => setState(() {})),
                  _PostList(posts: _filtered('company'), onUpdate: () => setState(() {})),
                  _PostList(
                    posts: _filtered('saved'),
                    onUpdate: () => setState(() {}),
                    emptyLabel: 'Nothing saved yet',
                    emptySubtitle: 'Tap the 🔖 on any post',
                    emptyIcon: Icons.bookmark_border_rounded,
                  ),
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

  Widget _buildHeader(AC c) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
    child: Row(
      children: [
        Text('News Feed', style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
        const Spacer(),
        const TopBarActions(),
      ],
    ),
  );

  Widget _buildComposerBar(AC c) => GestureDetector(
    onTap: _showComposer,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
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
          Expanded(
            child: Text("What's on your mind?", style: TextStyle(color: c.textMuted, fontSize: 14.5)),
          ),
          Icon(Icons.photo_library_outlined, color: AppColors.primaryLight, size: 22),
        ],
      ),
    ),
  );

  Widget _buildTabs(AC c) => TabBar(
    controller: _tabController,
    tabs: const [Tab(text: 'For You'), Tab(text: 'Team'), Tab(text: 'Company'), Tab(text: 'Saved')],
    labelColor: AppColors.primaryLight,
    unselectedLabelColor: c.textMuted,
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontSize: 13),
    indicatorColor: AppColors.primary,
    indicatorWeight: 2,
    dividerColor: c.divider,
  );
}

// ── Post List ─────────────────────────────────────────────────
class _PostList extends StatelessWidget {
  final List<FeedPost> posts;
  final VoidCallback onUpdate;
  final String? emptyLabel;
  final String? emptySubtitle;
  final IconData? emptyIcon;

  const _PostList({
    required this.posts,
    required this.onUpdate,
    this.emptyLabel,
    this.emptySubtitle,
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: c.surfaceElevated, borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.center,
            child: Icon(emptyIcon ?? Icons.newspaper_rounded, color: c.textMuted, size: 40),
          ),
          const SizedBox(height: 16),
          Text(emptyLabel ?? 'No posts yet', style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          if (emptySubtitle != null) ...[
            const SizedBox(height: 6),
            Text(emptySubtitle!, style: TextStyle(color: c.textMuted, fontSize: 13)),
          ],
        ]),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _PostCard(post: posts[i], onUpdate: onUpdate),
      ),
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

  void _shareToChat(FeedPost post) {
    final threads = kInitialThreads;
    String? selectedThreadId;
    final captionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: C(context).surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          builder: (_, ctrl) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Share to', style: TextStyle(color: C(context).textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    itemCount: threads.length,
                    itemBuilder: (_, i) {
                      final t = threads[i];
                      final name = t.isGroup ? (t.groupName ?? 'Group') : (() {
                        final otherId = t.participantIds.firstWhere((id) => id != kCurrentUser.id, orElse: () => t.participantIds.first);
                        return findUser(otherId)?.name ?? otherId;
                      })();
                      final sel = selectedThreadId == t.id;
                      return ListTile(
                        leading: t.isGroup
                            ? GroupAvatar(color: t.groupColor ?? AppColors.primary, initials: (t.groupName ?? 'G').substring(0, 1), size: 40)
                            : UserAvatar(userId: t.participantIds.firstWhere((id) => id != kCurrentUser.id, orElse: () => t.participantIds.first), size: 40),
                        title: Text(name, style: TextStyle(color: C(context).textPrimary, fontSize: 14)),
                        trailing: sel ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
                        onTap: () => setSheet(() => selectedThreadId = t.id),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: captionCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add a caption...',
                      hintStyle: TextStyle(color: C(context).textMuted),
                    ),
                    style: TextStyle(color: C(context).textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedThreadId == null ? null : () {
                        final thread = threads.firstWhere((t) => t.id == selectedThreadId);
                        final caption = captionCtrl.text.trim();
                        final shareText = '📢 Shared a post: "${post.body.substring(0, post.body.length > 60 ? 60 : post.body.length)}..."${caption.isNotEmpty ? '\n$caption' : ''}';
                        thread.messages.add(ChatMessage(
                          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
                          senderId: kCurrentUser.id,
                          text: shareText,
                          timestamp: DateTime.now(),
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post shared!'), backgroundColor: AppColors.primary),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Share', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Key attached to the React button so we can position the floating picker
  final _reactBtnKey = GlobalKey();

  void _showReactionPicker() {
    final box = _reactBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    showFloatingReactions(
      context: context,
      triggerBox: box,
      reactions: buildReactions(onReact: _react),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final cat = findCategory(p.categoryId);
    final author = findUser(p.authorId);
    final myReaction = p.reactions.where((r) => r.userId == kCurrentUser.id).firstOrNull?.type;
    final totalReactions = p.reactions.length;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.isPinned ? AppColors.primary.withValues(alpha: 0.4) : c.border),
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
                          Text(author?.name ?? p.authorId, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${author?.role ?? ''} · ${_timeAgo(p.createdAt)}', style: TextStyle(color: c.textMuted, fontSize: 11.5)),
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
                Text(p.body, style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.55)),
                // Reaction summary
                if (totalReactions > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ReactionSummary(reactions: p.reactions),
                      const Spacer(),
                      Text('${p.comments.length} comment${p.comments.length == 1 ? '' : 's'}', style: TextStyle(color: c.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Divider(color: c.divider),
                const SizedBox(height: 4),
                // Action row
                Row(
                  children: [
                    _FeedActionBtn(
                      key: _reactBtnKey,
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
                      onTap: () => _shareToChat(p),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        p.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: p.isBookmarked ? AppColors.primaryLight : c.textMuted,
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
                  Divider(color: c.divider),
                  const SizedBox(height: 10),
                  ...p.comments.map((cm) => _CommentTile(comment: cm)),
                  // Add comment input
                  Row(
                    children: [
                      UserAvatar(userId: kCurrentUser.id, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: TextStyle(color: c.textPrimary, fontSize: 13.5),
                          onSubmitted: (_) => _addComment(),
                          decoration: InputDecoration(
                            hintText: 'Add a comment…',
                            hintStyle: TextStyle(color: c.textMuted, fontSize: 13.5),
                            filled: true,
                            fillColor: c.bg,
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
    final c = C(context);
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
        Text('${reactions.length}', style: TextStyle(color: c.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostComment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
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
                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author?.name ?? comment.authorId, style: TextStyle(color: c.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(comment.text, style: TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('h:mm a').format(comment.createdAt), style: TextStyle(color: c.textMuted, fontSize: 11)),
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

  const _FeedActionBtn({super.key, this.emoji, this.iconData, required this.label, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final color = active ? AppColors.primaryLight : c.textMuted;
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
  Widget build(BuildContext context) {
    final c = C(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
