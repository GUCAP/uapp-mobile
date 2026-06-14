import 'package:flutter/material.dart';

enum MessageType { text, image, file, callRequest, callScheduled, system }

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final String? attachmentName;
  final String? attachmentUrl;
  final ScheduledCall? scheduledCall;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = true,
    this.attachmentName,
    this.attachmentUrl,
    this.scheduledCall,
  });
}

class ScheduledCall {
  final String id;
  final DateTime scheduledAt;
  final String callType; // video | audio | consultation
  final String status;   // upcoming | passed | canceled

  const ScheduledCall({
    required this.id,
    required this.scheduledAt,
    required this.callType,
    this.status = 'upcoming',
  });
}

class ChatThread {
  final String id;
  final bool isGroup;
  final String? groupName;
  final String? groupIconName;
  final Color? groupColor;
  final List<String> participantIds;
  final List<ChatMessage> messages;
  final int unreadCount;
  final bool isPinned;
  final bool isFavourite;
  final bool isArchived;

  ChatThread({
    required this.id,
    required this.participantIds,
    required this.messages,
    this.isGroup = false,
    this.groupName,
    this.groupIconName,
    this.groupColor,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isFavourite = false,
    this.isArchived = false,
  });

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String displayName(String currentUserId) {
    if (isGroup) return groupName ?? 'Group';
    final other = participantIds.firstWhere((id) => id != currentUserId, orElse: () => participantIds.first);
    return other;
  }
}
