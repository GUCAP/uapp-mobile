import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../widgets/user_avatar.dart';
import '../widgets/top_bar_actions.dart';
import 'chat_view_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChatThread> _threads = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _threads = List.from(kInitialThreads);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ChatThread> _filtered(String tab) {
    var list = _threads.where((t) {
      if (_searchQuery.isEmpty) return true;
      final name = _threadName(t).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    switch (tab) {
      case 'unread':
        list = list.where((t) => t.unreadCount > 0).toList();
        break;
      case 'groups':
        list = list.where((t) => t.isGroup).toList();
        break;
      case 'favourites':
        list = list.where((t) => t.isFavourite).toList();
        break;
    }

    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final at = a.lastMessage?.timestamp ?? DateTime(2000);
      final bt = b.lastMessage?.timestamp ?? DateTime(2000);
      return bt.compareTo(at);
    });
    return list;
  }

  String _threadName(ChatThread t) {
    if (t.isGroup) return t.groupName ?? 'Group';
    final otherId = t.participantIds.firstWhere(
      (id) => id != kCurrentUser.id,
      orElse: () => t.participantIds.first,
    );
    return findUser(otherId)?.name ?? otherId;
  }

  AppUser? _otherUser(ChatThread t) {
    if (t.isGroup) return null;
    final otherId = t.participantIds.firstWhere(
      (id) => id != kCurrentUser.id,
      orElse: () => t.participantIds.first,
    );
    return findUser(otherId);
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM').format(dt);
  }

  void _openChat(ChatThread thread) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatViewScreen(thread: thread)),
    );
    setState(() {
      final idx = _threads.indexWhere((t) => t.id == thread.id);
      if (idx != -1) {
        final old = _threads[idx];
        _threads[idx] = ChatThread(
          id: old.id,
          participantIds: old.participantIds,
          messages: old.messages,
          isGroup: old.isGroup,
          groupName: old.groupName,
          groupColor: old.groupColor,
          unreadCount: 0,
          isPinned: old.isPinned,
          isFavourite: old.isFavourite,
          isArchived: old.isArchived,
        );
      }
    });
  }

  void _dismissThread(ChatThread thread) {
    setState(() => _threads.removeWhere((t) => t.id == thread.id));
  }

  void _showCreateGroupModal() {
    final c = C(context);
    final nameCtrl = TextEditingController();
    final Set<String> selected = {};
    final candidates = kUsers.where((u) => u.type != UserType.student && u.id != kCurrentUser.id).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, ctrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('New Group', style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: nameCtrl,
                  onChanged: (_) => setSheet(() {}),
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    hintStyle: TextStyle(color: c.textMuted),
                  ),
                  style: TextStyle(color: c.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Add members', style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  itemCount: candidates.length,
                  itemBuilder: (_, i) {
                    final u = candidates[i];
                    final sel = selected.contains(u.id);
                    return CheckboxListTile(
                      value: sel,
                      onChanged: (v) => setSheet(() { v! ? selected.add(u.id) : selected.remove(u.id); }),
                      title: Text(u.name, style: TextStyle(color: c.textPrimary, fontSize: 14)),
                      subtitle: Text(u.role, style: TextStyle(color: c.textMuted, fontSize: 12)),
                      secondary: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: u.color, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      activeColor: AppColors.primary,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nameCtrl.text.trim().isNotEmpty && selected.isNotEmpty ? () {
                      final name = nameCtrl.text.trim();
                      final newThread = ChatThread(
                        id: 'group-${DateTime.now().millisecondsSinceEpoch}',
                        participantIds: [kCurrentUser.id, ...selected],
                        messages: [],
                        isGroup: true,
                        groupName: name,
                        groupColor: AppColors.primary,
                      );
                      setState(() => _threads.insert(0, newThread));
                      Navigator.pop(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Create Group (${selected.length} members)', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(c),
            _buildSearchBar(c),
            _buildTabs(c),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ThreadList(threads: _filtered('all'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel, onDismiss: _dismissThread),
                  _ThreadList(threads: _filtered('unread'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel, onDismiss: _dismissThread),
                  _ThreadList(threads: _filtered('groups'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel, onDismiss: _dismissThread),
                  _ThreadList(threads: _filtered('favourites'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel, onDismiss: _dismissThread),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (_, __) {
          if (_tabController.index == 2) {
            return FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showCreateGroupModal,
              child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
            );
          }
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {},
            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(AC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Text(
            'Messages',
            style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const TopBarActions(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AC c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: c.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search messages…',
          prefixIcon: Icon(Icons.search_rounded, color: c.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: c.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabs(AC c) {
    const tabs = [
      Tab(text: 'All'),
      Tab(text: 'Unread'),
      Tab(text: 'Groups'),
      Tab(text: 'Favourites'),
    ];
    return TabBar(
      controller: _tabController,
      tabs: tabs,
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: c.textMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: c.divider,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: (_) => setState(() {}),
    );
  }
}

class _ThreadList extends StatelessWidget {
  final List<ChatThread> threads;
  final void Function(ChatThread) onTap;
  final String Function(ChatThread) threadName;
  final AppUser? Function(ChatThread) otherUser;
  final String Function(DateTime) timeLabel;
  final void Function(ChatThread) onDismiss;

  const _ThreadList({
    required this.threads,
    required this.onTap,
    required this.threadName,
    required this.otherUser,
    required this.timeLabel,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    if (threads.isEmpty) {
      return Center(
        child: Text('No messages', style: TextStyle(color: c.textMuted, fontSize: 14)),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: threads.length,
        itemBuilder: (ctx, i) => Dismissible(
          key: Key(threads[i].id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.danger,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.archive_rounded, color: Colors.white),
          ),
          onDismissed: (_) => onDismiss(threads[i]),
          child: _ThreadTile(
            thread: threads[i],
            name: threadName(threads[i]),
            user: otherUser(threads[i]),
            time: threads[i].lastMessage != null ? timeLabel(threads[i].lastMessage!.timestamp) : '',
            onTap: () => onTap(threads[i]),
          ),
        ),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final ChatThread thread;
  final String name;
  final AppUser? user;
  final String time;
  final VoidCallback onTap;

  const _ThreadTile({
    required this.thread,
    required this.name,
    required this.user,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    final last = thread.lastMessage;
    final preview = last?.text ?? '';
    final hasUnread = thread.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.divider, width: 1)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                thread.isGroup
                    ? GroupAvatar(
                        color: thread.groupColor ?? AppColors.primary,
                        initials: (thread.groupName ?? 'G').substring(0, 1),
                        size: 50,
                      )
                    : user != null
                        ? UserAvatar(userId: user!.id, size: 50, showOnline: true)
                        : const SizedBox(width: 50, height: 50),
                if (thread.isPinned)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: c.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.push_pin_rounded, size: 10, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: hasUnread ? AppColors.primaryLight : c.textMuted,
                          fontSize: 11.5,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(
                            color: hasUnread ? c.textSecondary : c.textMuted,
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
