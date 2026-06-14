import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../widgets/user_avatar.dart';
import '../widgets/message_bubble.dart';
import 'schedule_call_screen.dart';

class ChatViewScreen extends StatefulWidget {
  final ChatThread thread;

  const ChatViewScreen({super.key, required this.thread});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  bool _showScheduleCard = false;
  String? _replyingToId;

  // Per-message reactions: { msgId: { emoji: count } }
  final Map<String, Map<String, int>> _reactions = {};
  // My reactions per message
  final Map<String, String?> _myReaction = {};

  AppUser? get _otherUser {
    if (widget.thread.isGroup) return null;
    final id = widget.thread.participantIds.firstWhere(
      (id) => id != kCurrentUser.id,
      orElse: () => widget.thread.participantIds.first,
    );
    return findUser(id);
  }

  String get _title {
    if (widget.thread.isGroup) return widget.thread.groupName ?? 'Group';
    return _otherUser?.name ?? 'Chat';
  }

  String get _subtitle {
    if (widget.thread.isGroup) return '${widget.thread.participantIds.length} members';
    return _otherUser?.online == true ? 'Active now' : _otherUser?.role ?? '';
  }

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.thread.messages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final replyTo = _replyingToId;
    setState(() {
      _messages.add(ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        senderId: kCurrentUser.id,
        text: replyTo != null ? 'Replying: $text' : text,
        timestamp: DateTime.now(),
      ));
      _showScheduleCard = false;
      _replyingToId = null;
      _inputController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _openScheduleCall() async {
    final other = _otherUser;
    if (other == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleCallScreen(
          withUser: other,
          onScheduled: (meeting) {
            setState(() {
              _messages.add(ChatMessage(
                id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
                senderId: kCurrentUser.id,
                text: 'Video call scheduled for ${DateFormat("EEE, dd MMM 'at' h:mm a").format(meeting.scheduledAt)}',
                timestamp: DateTime.now(),
                type: MessageType.callScheduled,
                scheduledCall: ScheduledCall(
                  id: meeting.id, scheduledAt: meeting.scheduledAt, callType: meeting.type.name,
                ),
              ));
              _showScheduleCard = false;
            });
          },
        ),
      ),
    );
  }

  void _reactToMessage(String msgId, String emoji) {
    setState(() {
      final prev = _myReaction[msgId];
      if (prev == emoji) {
        // Un-react
        _myReaction[msgId] = null;
        _reactions[msgId]?[emoji] = (_reactions[msgId]?[emoji] ?? 1) - 1;
        if ((_reactions[msgId]?[emoji] ?? 0) <= 0) _reactions[msgId]?.remove(emoji);
      } else {
        // Remove previous
        if (prev != null) {
          _reactions[msgId]?[prev] = (_reactions[msgId]?[prev] ?? 1) - 1;
          if ((_reactions[msgId]?[prev] ?? 0) <= 0) _reactions[msgId]?.remove(prev);
        }
        // Add new
        _myReaction[msgId] = emoji;
        _reactions.putIfAbsent(msgId, () => {})[emoji] = (_reactions[msgId]?[emoji] ?? 0) + 1;
      }
    });
  }

  void _showMessageMenu(ChatMessage msg, bool isOwn) {
    final reactionEmojis = ['👍', '💡', '🎉', '❤️', '😂'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick reactions row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: reactionEmojis.map((e) => GestureDetector(
                onTap: () { Navigator.pop(context); _reactToMessage(msg.id, e); },
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _myReaction[msg.id] == e ? AppColors.primaryFaint : AppColors.bg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(e, style: const TextStyle(fontSize: 26)),
                ),
              )).toList(),
            ),
          ),
          const Divider(color: AppColors.divider),
          _MenuAction(icon: Icons.reply_rounded, label: 'Reply', onTap: () {
            Navigator.pop(context);
            setState(() => _replyingToId = msg.id);
          }),
          _MenuAction(icon: Icons.copy_rounded, label: 'Copy', onTap: () {
            Navigator.pop(context);
            Clipboard.setData(ClipboardData(text: msg.text));
          }),
          if (isOwn) ...[
            _MenuAction(icon: Icons.edit_rounded, label: 'Edit', onTap: () {
              Navigator.pop(context);
              _inputController.text = msg.text;
            }),
            _MenuAction(icon: Icons.push_pin_rounded, label: 'Pin Message', onTap: () => Navigator.pop(context)),
            _MenuAction(icon: Icons.delete_rounded, label: 'Delete', color: AppColors.danger, onTap: () {
              Navigator.pop(context);
              setState(() => _messages.removeWhere((m) => m.id == msg.id));
            }),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_replyingToId != null) _buildReplyBanner(),
          if (_showScheduleCard) _buildScheduleCardArea(),
          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final other = _otherUser;
    return AppBar(
      backgroundColor: AppColors.surface,
      leadingWidth: 44,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textSecondary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          widget.thread.isGroup
              ? GroupAvatar(color: widget.thread.groupColor ?? AppColors.primary, initials: _title.substring(0, 1), size: 36)
              : (other != null ? UserAvatar(userId: other.id, size: 36, showOnline: true) : const SizedBox.shrink()),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(
                  _subtitle,
                  style: TextStyle(color: other?.online == true ? AppColors.online : AppColors.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.video_call_rounded, color: AppColors.primaryLight, size: 26), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call_rounded, color: AppColors.textSecondary, size: 22), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 22),
          onPressed: () => _showThreadOptions(),
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); setState(() => _replyingToId = null); },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: _messages.length,
        itemBuilder: (ctx, i) {
          final msg = _messages[i];
          final isOwn = msg.senderId == kCurrentUser.id;
          final showDate = i == 0 || !_isSameDay(_messages[i - 1].timestamp, msg.timestamp);
          final msgReactions = _reactions[msg.id];

          return Column(
            children: [
              if (showDate) _DateDivider(date: msg.timestamp),
              GestureDetector(
                onLongPress: () => _showMessageMenu(msg, isOwn),
                child: Column(
                  children: [
                    if (msg.type == MessageType.callScheduled && msg.scheduledCall != null)
                      ScheduledCallBubble(
                        scheduledAt: msg.scheduledCall!.scheduledAt,
                        callType: msg.scheduledCall!.callType,
                        onJoin: () {},
                      )
                    else if (msg.type == MessageType.callRequest)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 64, bottom: 4),
                          child: ScheduleCallCard(onSchedule: _openScheduleCall, onCallNow: () {}),
                        ),
                      )
                    else
                      MessageBubble(message: msg, isOwn: isOwn),
                    // Show reactions on message
                    if (msgReactions != null && msgReactions.isNotEmpty)
                      Align(
                        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                        child: _MessageReactions(reactions: msgReactions, onTap: (e) => _reactToMessage(msg.id, e)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyBanner() {
    final replyMsg = _messages.firstWhere((m) => m.id == _replyingToId, orElse: () => _messages.last);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: AppColors.surfaceElevated,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: AppColors.primary, margin: const EdgeInsets.only(right: 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Replying to', style: TextStyle(color: AppColors.primaryLight, fontSize: 11.5, fontWeight: FontWeight.w600)),
                Text(replyMsg.text, style: const TextStyle(color: AppColors.textMuted, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18), onPressed: () => setState(() => _replyingToId = null)),
        ],
      ),
    );
  }

  Widget _buildScheduleCardArea() => Container(
    color: AppColors.bg,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: ScheduleCallCard(
      onSchedule: _openScheduleCall,
      onCallNow: () => setState(() => _showScheduleCard = false),
    ),
  );

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textMuted, size: 24), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Type a message…',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryLight, size: 24),
            onPressed: () => setState(() => _showScheduleCard = !_showScheduleCard),
          ),
          IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.textMuted, size: 24), onPressed: () {}),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _showThreadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const Divider(color: AppColors.divider),
          _MenuAction(icon: Icons.search_rounded, label: 'Search in conversation', onTap: () => Navigator.pop(context)),
          _MenuAction(icon: Icons.push_pin_rounded, label: 'Pinned messages', onTap: () => Navigator.pop(context)),
          if (widget.thread.isGroup)
            _MenuAction(icon: Icons.group_rounded, label: 'View members', onTap: () => Navigator.pop(context)),
          _MenuAction(icon: Icons.archive_rounded, label: 'Archive chat', onTap: () => Navigator.pop(context)),
          _MenuAction(icon: Icons.notifications_off_rounded, label: 'Mute notifications', onTap: () => Navigator.pop(context)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MessageReactions extends StatelessWidget {
  final Map<String, int> reactions;
  final void Function(String) onTap;
  const _MessageReactions({required this.reactions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 2),
      child: Wrap(
        spacing: 4,
        children: reactions.entries.map((e) => GestureDetector(
          onTap: () => onTap(e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text('${e.value}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = DateUtils.isSameDay(date, now) ? 'Today'
        : DateUtils.isSameDay(date, now.subtract(const Duration(days: 1))) ? 'Yesterday'
        : DateFormat('EEEE, d MMMM').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w500)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ]),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _MenuAction({required this.icon, required this.label, required this.onTap, this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color, size: 20),
    title: Text(label, style: TextStyle(color: color == AppColors.textSecondary ? Colors.white : color, fontSize: 14.5)),
    onTap: onTap,
    dense: true,
  );
}
