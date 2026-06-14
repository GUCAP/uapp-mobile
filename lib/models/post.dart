import 'package:flutter/material.dart';

enum PostAudience { all, sales, admission, leadership }
enum PostPriority { high, medium, low }

class PostCategory {
  final String id;
  final String label;
  final Color color;
  final IconData icon;

  const PostCategory({required this.id, required this.label, required this.color, required this.icon});
}

const kPostCategories = [
  PostCategory(id: 'admission',      label: 'Admission',       color: Color(0xFF0EA5E9), icon: Icons.school_rounded),
  PostCategory(id: 'intake',         label: 'Intake',          color: Color(0xFF06B6D4), icon: Icons.inbox_rounded),
  PostCategory(id: 'deadline',       label: 'Deadline',        color: Color(0xFFE9445A), icon: Icons.timer_rounded),
  PostCategory(id: 'university',     label: 'University',      color: Color(0xFF7C3AED), icon: Icons.account_balance_rounded),
  PostCategory(id: 'partnership',    label: 'Partnership',     color: Color(0xFF8B5CF6), icon: Icons.handshake_rounded),
  PostCategory(id: 'sales',          label: 'Sales',           color: Color(0xFF0A6E6F), icon: Icons.trending_up_rounded),
  PostCategory(id: 'marketing',      label: 'Marketing',       color: Color(0xFF0A66C2), icon: Icons.campaign_rounded),
  PostCategory(id: 'documentation',  label: 'Documentation',   color: Color(0xFF64748B), icon: Icons.description_rounded),
  PostCategory(id: 'training',       label: 'Training',        color: Color(0xFFD946EF), icon: Icons.cast_for_education_rounded),
  PostCategory(id: 'announcement',   label: 'Announcement',    color: Color(0xFFFC7300), icon: Icons.announcement_rounded),
  PostCategory(id: 'urgent',         label: 'Urgent',          color: Color(0xFFDC2626), icon: Icons.warning_rounded),
  PostCategory(id: 'system_updates', label: 'System Updates',  color: Color(0xFF475569), icon: Icons.system_update_rounded),
  PostCategory(id: 'performance',    label: 'Performance',     color: Color(0xFFF59E0B), icon: Icons.bar_chart_rounded),
  PostCategory(id: 'offer',          label: 'Offer',           color: Color(0xFF16A34A), icon: Icons.local_offer_rounded),
  PostCategory(id: 'promotion',      label: 'Promotion',       color: Color(0xFFEC4899), icon: Icons.star_rounded),
];

PostCategory? findCategory(String id) {
  try {
    return kPostCategories.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

class PostReaction {
  final String userId;
  final String type; // like | insightful | celebrate

  const PostReaction({required this.userId, required this.type});
}

class PostComment {
  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;
  List<PostReaction> reactions;

  PostComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    List<PostReaction>? reactions,
  }) : reactions = reactions ?? [];
}

class FeedPost {
  final String id;
  final String authorId;
  String body;
  final DateTime createdAt;
  final String categoryId;
  final PostAudience audience;
  final PostPriority priority;
  bool isPinned;
  bool isBookmarked;
  List<PostReaction> reactions;
  List<PostComment> comments;

  FeedPost({
    required this.id,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.categoryId,
    this.audience = PostAudience.all,
    this.priority = PostPriority.medium,
    this.isPinned = false,
    this.isBookmarked = false,
    List<PostReaction>? reactions,
    List<PostComment>? comments,
  })  : reactions = reactions ?? [],
        comments = comments ?? [];

  int reactionCount(String type) => reactions.where((r) => r.type == type).length;
  bool hasReacted(String userId, String type) => reactions.any((r) => r.userId == userId && r.type == type);

  void toggleReaction(String userId, String type) {
    reactions.removeWhere((r) => r.userId == userId);
    if (!hasReacted(userId, type)) {
      reactions.add(PostReaction(userId: userId, type: type));
    }
  }
}
