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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ThreadList(threads: _filtered('all'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel),
                  _ThreadList(threads: _filtered('unread'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel),
                  _ThreadList(threads: _filtered('groups'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel),
                  _ThreadList(threads: _filtered('favourites'), onTap: _openChat, threadName: _threadName, otherUser: _otherUser, timeLabel: _timeLabel),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            'Messages',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const TopBarActions(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search messages…',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
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

  Widget _buildTabs() {
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
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      dividerColor: AppColors.divider,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _ThreadList extends StatelessWidget {
  final List<ChatThread> threads;
  final void Function(ChatThread) onTap;
  final String Function(ChatThread) threadName;
  final AppUser? Function(ChatThread) otherUser;
  final String Function(DateTime) timeLabel;

  const _ThreadList({
    required this.threads,
    required this.onTap,
    required this.threadName,
    required this.otherUser,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(
        child: Text('No messages', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: threads.length,
      itemBuilder: (ctx, i) => _ThreadTile(
        thread: threads[i],
        name: threadName(threads[i]),
        user: otherUser(threads[i]),
        time: threads[i].lastMessage != null ? timeLabel(threads[i].lastMessage!.timestamp) : '',
        onTap: () => onTap(threads[i]),
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
    final last = thread.lastMessage;
    final preview = last?.text ?? '';
    final hasUnread = thread.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
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
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
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
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: hasUnread ? AppColors.primaryLight : AppColors.textMuted,
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
                            color: hasUnread ? AppColors.textSecondary : AppColors.textMuted,
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
