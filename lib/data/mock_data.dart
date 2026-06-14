import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../models/meeting.dart';
import '../models/post.dart';

// ── Users (mirrors the web app's USERS array) ─────────────────
final List<AppUser> kUsers = [
  const AppUser(
    id: 'u-shamim', name: 'Shamim Rahman', role: 'CEO / System Admin',
    dept: UserDept.system, level: 1, type: UserType.admin,
    initials: 'SR', color: Color(0xFFE9445A), online: true,
  ),
  const AppUser(
    id: 'u-md-shamim', name: 'Md Shamim', role: 'Branch Manager (Sales)',
    dept: UserDept.sales, level: 2, type: UserType.sales,
    initials: 'MS', color: Color(0xFF0A6E6F), online: false,
  ),
  const AppUser(
    id: 'u-andreea', name: 'Andreea Cinpoi', role: 'Sales Manager',
    dept: UserDept.sales, level: 3, type: UserType.sales,
    initials: 'AN', color: Color(0xFF7C3AED), online: false,
  ),
  const AppUser(
    id: 'u-laura', name: 'Laura Tomova', role: 'Sales Team Leader',
    dept: UserDept.sales, level: 4, type: UserType.sales,
    initials: 'LA', color: Color(0xFF3A7BD5), online: false,
  ),
  const AppUser(
    id: 'u-tousif', name: 'Tousif Sadman', role: 'Consultant',
    dept: UserDept.sales, level: 5, type: UserType.sales,
    initials: 'TS', color: Color(0xFF0E7C66), online: true,
  ),
  const AppUser(
    id: 'u-riad', name: 'Riad Hossain', role: 'Consultant',
    dept: UserDept.sales, level: 5, type: UserType.sales,
    initials: 'RH', color: Color(0xFFD97706), online: true,
  ),
  const AppUser(
    id: 'u-jennifer', name: 'Jennifer Aboje', role: 'Branch Manager (Admission)',
    dept: UserDept.admission, level: 2, type: UserType.admission,
    initials: 'JA', color: Color(0xFFFC7300), online: false,
  ),
  const AppUser(
    id: 'u-raj', name: 'Raj Ahmed', role: 'Global Admission Manager',
    dept: UserDept.admission, level: 3, type: UserType.admission,
    initials: 'RA', color: Color(0xFF0EA5E9), online: false,
  ),
  const AppUser(
    id: 'u-nur', name: 'Nur Mohammad', role: 'Admission Manager',
    dept: UserDept.admission, level: 4, type: UserType.admission,
    initials: 'NM', color: Color(0xFF8B5CF6), online: false,
  ),
  const AppUser(
    id: 'u-siam', name: 'Md Siam', role: 'Admission Officer',
    dept: UserDept.admission, level: 5, type: UserType.admission,
    initials: 'MS', color: Color(0xFF10B981), online: false,
  ),
  const AppUser(
    id: 'u-rakib', name: 'Md Rakib', role: 'Admission Officer',
    dept: UserDept.admission, level: 5, type: UserType.admission,
    initials: 'MR', color: Color(0xFF06B6D4), online: true,
  ),
  const AppUser(
    id: 'u-nadia', name: 'Nadia Ahmed', role: 'Admission Officer',
    dept: UserDept.admission, level: 5, type: UserType.admission,
    initials: 'NA', color: Color(0xFFF59E0B), online: false,
  ),
  const AppUser(
    id: 'u-mihadul', name: 'Mihadul Islam', role: 'Consultant',
    dept: UserDept.sales, level: 5, type: UserType.sales,
    initials: 'MI', color: Color(0xFF65A30D), online: true,
  ),
  const AppUser(
    id: 'u-asad', name: 'Asad Fahad', role: 'Consultant',
    dept: UserDept.sales, level: 5, type: UserType.sales,
    initials: 'AF', color: Color(0xFFDB2777), online: true,
  ),
];

AppUser? findUser(String id) {
  try {
    return kUsers.firstWhere((u) => u.id == id);
  } catch (_) {
    return null;
  }
}

// ── Current logged-in user ────────────────────────────────────
final AppUser kCurrentUser = kUsers.first; // Shamim Rahman

// ── Mock chat threads ─────────────────────────────────────────
final List<ChatThread> kInitialThreads = [
  ChatThread(
    id: 'thread-shamim-tousif',
    participantIds: ['u-shamim', 'u-tousif'],
    unreadCount: 2,
    isPinned: true,
    messages: [
      ChatMessage(
        id: 'm1', senderId: 'u-tousif',
        text: 'Hi, just checking in on the APP117452 application status.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'm2', senderId: 'u-shamim',
        text: 'It\'s under review. Should have an update by EOD.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      ChatMessage(
        id: 'm3', senderId: 'u-tousif',
        text: 'Perfect, the student is waiting. Shall we schedule a quick call?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-andreea',
    participantIds: ['u-shamim', 'u-andreea'],
    unreadCount: 0,
    isFavourite: true,
    messages: [
      ChatMessage(
        id: 'm4', senderId: 'u-andreea',
        text: 'Quarter target update: we\'re at £312k vs £420k goal.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'm5', senderId: 'u-shamim',
        text: 'Let\'s push hard this week. Can you share the breakdown?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'm6', senderId: 'u-andreea',
        text: 'Sending it now 👍',
        timestamp: DateTime.now().subtract(const Duration(minutes: 58)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-jennifer',
    participantIds: ['u-shamim', 'u-jennifer'],
    unreadCount: 1,
    messages: [
      ChatMessage(
        id: 'm7', senderId: 'u-jennifer',
        text: 'The Sept 2026 intake squad needs your sign-off on the welcome pack.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-raj',
    participantIds: ['u-shamim', 'u-raj'],
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm8', senderId: 'u-raj',
        text: 'New university partnership confirmed — Middlesex University.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ChatMessage(
        id: 'm9', senderId: 'u-shamim',
        text: 'Excellent! Let\'s announce it on the news feed.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-nur',
    participantIds: ['u-shamim', 'u-nur'],
    unreadCount: 3,
    messages: [
      ChatMessage(
        id: 'm10', senderId: 'u-nur',
        text: 'Can we jump on a quick call? It\'s about the admission pipeline.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        id: 'm11', senderId: 'u-nur',
        text: 'We have 37 pending docs to review before Friday.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      ChatMessage(
        id: 'm12', senderId: 'u-nur',
        text: 'Tagging you on the dashboard.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ],
  ),
  ChatThread(
    id: 'group-leadership',
    participantIds: ['u-shamim', 'u-md-shamim', 'u-jennifer', 'u-andreea', 'u-raj'],
    isGroup: true,
    groupName: 'Leadership',
    groupColor: const Color(0xFFE9445A),
    unreadCount: 5,
    isPinned: true,
    messages: [
      ChatMessage(
        id: 'gm1', senderId: 'u-md-shamim',
        text: 'Board deck for Q3 is ready for review.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  ),
  ChatThread(
    id: 'group-sales-team',
    participantIds: ['u-shamim', 'u-md-shamim', 'u-andreea', 'u-laura', 'u-tousif', 'u-riad', 'u-mihadul', 'u-asad'],
    isGroup: true,
    groupName: 'Sales Team',
    groupColor: const Color(0xFF0A6E6F),
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'gm2', senderId: 'u-riad',
        text: 'Morning standup in 10 mins 🚀',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
  ),
  ChatThread(
    id: 'group-admission',
    participantIds: ['u-shamim', 'u-nur', 'u-siam', 'u-rakib', 'u-nadia'],
    isGroup: true,
    groupName: 'Admission Officers',
    groupColor: const Color(0xFFFC7300),
    unreadCount: 2,
    messages: [
      ChatMessage(
        id: 'gm3', senderId: 'u-rakib',
        text: 'APP117453 — docs verified and submitted ✅',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-riad',
    participantIds: ['u-shamim', 'u-riad'],
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm13', senderId: 'u-riad',
        text: 'Lead converted! Sumaya Ahmed is now an active student.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  ),
  ChatThread(
    id: 'thread-shamim-laura',
    participantIds: ['u-shamim', 'u-laura'],
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'm14', senderId: 'u-laura',
        text: 'Weekly target met — 4 students onboarded this week.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  ),
];

// ── Mock meetings ─────────────────────────────────────────────
List<Meeting> kMeetings = [
  Meeting(
    id: 'meet-1',
    withUserId: 'u-tousif',
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    type: MeetingType.video,
    status: MeetingStatus.upcoming,
  ),
  Meeting(
    id: 'meet-2',
    withUserId: 'u-nur',
    scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 10)),
    type: MeetingType.consultation,
    status: MeetingStatus.upcoming,
  ),
  Meeting(
    id: 'meet-3',
    withUserId: 'u-andreea',
    scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
    type: MeetingType.video,
    status: MeetingStatus.passed,
  ),
  Meeting(
    id: 'meet-4',
    withUserId: 'u-jennifer',
    scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
    type: MeetingType.consultation,
    status: MeetingStatus.canceled,
  ),
];

// ── Feed posts ────────────────────────────────────────────────
List<FeedPost> kFeedPosts = [
  FeedPost(
    id: 'p1', authorId: 'u-shamim',
    body: '🎉 Exciting news! UAPP has officially partnered with Middlesex University. This opens up 12 new programs for our students — from BSc Computing to MBA. Big win for the team!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    categoryId: 'partnership', audience: PostAudience.all,
    priority: PostPriority.high, isPinned: true,
    reactions: [
      const PostReaction(userId: 'u-andreea', type: 'celebrate'),
      const PostReaction(userId: 'u-raj', type: 'celebrate'),
      const PostReaction(userId: 'u-jennifer', type: 'like'),
      const PostReaction(userId: 'u-nur', type: 'insightful'),
    ],
    comments: [
      PostComment(id: 'c1', authorId: 'u-andreea', text: 'Brilliant news! 🙌 This will open so many doors for our students.', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
      PostComment(id: 'c2', authorId: 'u-raj', text: 'Huge win! Middlesex is a top choice for international students.', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
    ],
  ),
  FeedPost(
    id: 'p2', authorId: 'u-andreea',
    body: 'Q3 Sales Update: We\'re at £312k against a £420k target. The last two weeks of the quarter are crucial — let\'s push hard on the pipeline! Tagging everyone with open leads.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    categoryId: 'sales', audience: PostAudience.sales, priority: PostPriority.high,
    reactions: [
      const PostReaction(userId: 'u-tousif', type: 'like'),
      const PostReaction(userId: 'u-riad', type: 'like'),
      const PostReaction(userId: 'u-md-shamim', type: 'insightful'),
    ],
    comments: [
      PostComment(id: 'c3', authorId: 'u-md-shamim', text: 'Let\'s do this. All consultants please update your pipeline by 5 PM.', createdAt: DateTime.now().subtract(const Duration(hours: 4))),
    ],
  ),
  FeedPost(
    id: 'p3', authorId: 'u-jennifer',
    body: 'Admission team: September 2026 intake is now open. We have 118 applications processed out of a 155 target. Great pace — keep going! Please update your student dashboards by EOD Friday.',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    categoryId: 'admission', audience: PostAudience.admission, priority: PostPriority.medium,
    reactions: [
      const PostReaction(userId: 'u-nur', type: 'like'),
      const PostReaction(userId: 'u-rakib', type: 'celebrate'),
    ],
    comments: [
      PostComment(id: 'c4', authorId: 'u-nur', text: '37 more to go. We can make it this week!', createdAt: DateTime.now().subtract(const Duration(hours: 7))),
      PostComment(id: 'c5', authorId: 'u-siam', text: 'Just submitted 4 more. Dashboard updated.', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
    ],
  ),
  FeedPost(
    id: 'p4', authorId: 'u-md-shamim',
    body: 'Reminder: Weekly standup is at 9:30 AM tomorrow. Please have your pipeline updates ready. Also, new commission structure goes live Monday — check your inbox for the breakdown.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    categoryId: 'announcement', audience: PostAudience.sales, priority: PostPriority.medium,
    reactions: [
      const PostReaction(userId: 'u-laura', type: 'like'),
      const PostReaction(userId: 'u-tousif', type: 'like'),
    ],
    comments: [],
  ),
  FeedPost(
    id: 'p5', authorId: 'u-raj',
    body: '🎓 Congrats to Rakib and Siam — APP117452 and APP117453 both got conditional offers from University of Hertfordshire! Amazing work getting those docs in so fast.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    categoryId: 'offer', audience: PostAudience.all, priority: PostPriority.medium,
    reactions: [
      const PostReaction(userId: 'u-shamim', type: 'celebrate'),
      const PostReaction(userId: 'u-jennifer', type: 'celebrate'),
      const PostReaction(userId: 'u-nur', type: 'celebrate'),
      const PostReaction(userId: 'u-siam', type: 'like'),
    ],
    comments: [
      PostComment(id: 'c6', authorId: 'u-rakib', text: 'Thank you! The students are thrilled 🎉', createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
    ],
  ),
  FeedPost(
    id: 'p6', authorId: 'u-shamim',
    body: '📢 System Update: The new commission dashboard is now live. All sales team members can view their earned commission in real-time. Report any discrepancies to finance by Wednesday.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    categoryId: 'system_updates', audience: PostAudience.all, priority: PostPriority.low,
    reactions: [
      const PostReaction(userId: 'u-riad', type: 'insightful'),
    ],
    comments: [],
  ),
  FeedPost(
    id: 'p7', authorId: 'u-laura',
    body: '🏆 Sales Team wins the Q2 performance award! We exceeded our target by 15%. Celebrating on Friday evening — everyone\'s invited. Details in the group chat.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    categoryId: 'performance', audience: PostAudience.all, priority: PostPriority.medium,
    reactions: [
      const PostReaction(userId: 'u-shamim', type: 'celebrate'),
      const PostReaction(userId: 'u-andreea', type: 'celebrate'),
      const PostReaction(userId: 'u-md-shamim', type: 'celebrate'),
    ],
    comments: [
      PostComment(id: 'c7', authorId: 'u-asad', text: 'Let\'s go! 🔥🔥🔥', createdAt: DateTime.now().subtract(const Duration(days: 3))),
    ],
  ),
  FeedPost(
    id: 'p8', authorId: 'u-jennifer',
    body: '📚 New training material is available: "UCAS Application Process — 2026 Guide". All admission officers must complete the training quiz by next Monday. Link sent via email.',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    categoryId: 'training', audience: PostAudience.admission, priority: PostPriority.medium,
    reactions: [],
    comments: [],
  ),
];

// ── Availability blocks (for schedule/availability screen) ────
class AvailabilityBlock {
  final String id;
  final String dayKey; // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final String from;   // "09:00"
  final String to;     // "17:00"
  final bool active;

  const AvailabilityBlock({
    required this.id,
    required this.dayKey,
    required this.from,
    required this.to,
    this.active = true,
  });
}

List<AvailabilityBlock> kWorkHours = [
  const AvailabilityBlock(id: 'wh-mon', dayKey: 'Mon', from: '09:00', to: '17:30', active: true),
  const AvailabilityBlock(id: 'wh-tue', dayKey: 'Tue', from: '09:00', to: '17:30', active: true),
  const AvailabilityBlock(id: 'wh-wed', dayKey: 'Wed', from: '09:00', to: '17:30', active: true),
  const AvailabilityBlock(id: 'wh-thu', dayKey: 'Thu', from: '09:00', to: '17:30', active: true),
  const AvailabilityBlock(id: 'wh-fri', dayKey: 'Fri', from: '09:00', to: '16:00', active: true),
  const AvailabilityBlock(id: 'wh-sat', dayKey: 'Sat', from: '10:00', to: '13:00', active: false),
  const AvailabilityBlock(id: 'wh-sun', dayKey: 'Sun', from: '10:00', to: '13:00', active: false),
];

// ── Permission model ──────────────────────────────────────────
class PermissionSet {
  final String id;
  final String label;
  final Color color;
  final Map<String, bool> grants;

  const PermissionSet({required this.id, required this.label, required this.color, required this.grants});
}

const kPermissionModules = [
  'chats_view', 'chats_create', 'chats_react', 'chats_pin', 'chats_archive', 'chats_delete', 'chats_manageMembers',
  'feed_view', 'feed_create', 'feed_bookmark', 'feed_react', 'feed_share', 'feed_deleteOwn', 'feed_deleteAny',
  'schedule_view', 'schedule_create', 'schedule_edit', 'schedule_delete', 'schedule_recurring',
  'webhooks_view', 'webhooks_create', 'webhooks_edit', 'webhooks_delete', 'webhooks_test',
  'crm_view', 'crm_edit', 'crm_create', 'crm_delete',
  'promo_view', 'promo_create', 'promo_edit', 'promo_delete',
];

final List<PermissionSet> kPermissionSets = [
  PermissionSet(
    id: 'full_access', label: 'Full Access', color: const Color(0xFFE9445A),
    grants: {for (final p in kPermissionModules) p: true},
  ),
  PermissionSet(
    id: 'editor', label: 'Editor', color: const Color(0xFF7C3AED),
    grants: {
      for (final p in kPermissionModules)
        p: !p.contains('deleteAny') && !p.contains('webhooks_delete') && !p.contains('crm_delete')
    },
  ),
  PermissionSet(
    id: 'contributor', label: 'Contributor', color: const Color(0xFF0EA5E9),
    grants: {
      for (final p in kPermissionModules)
        p: p.endsWith('_view') || p.endsWith('_create') || p.endsWith('_react') ||
            p.endsWith('_bookmark') || p.endsWith('_share') || p.endsWith('_deleteOwn')
    },
  ),
  PermissionSet(
    id: 'viewer', label: 'Viewer', color: const Color(0xFF64748B),
    grants: {for (final p in kPermissionModules) p: p.endsWith('_view')},
  ),
];

// ── Webhook model ─────────────────────────────────────────────
class WebhookApp {
  final String id;
  final String name;
  final String description;
  final String eventKey;
  final String url;
  final String method;
  bool installed;
  final int successCount;
  final int failureCount;

  WebhookApp({
    required this.id,
    required this.name,
    required this.description,
    required this.eventKey,
    required this.url,
    this.method = 'POST',
    this.installed = false,
    this.successCount = 0,
    this.failureCount = 0,
  });
}

final List<WebhookApp> kWebhooks = [
  WebhookApp(
    id: 'wh-1', name: 'Application Status Changed',
    description: 'Fires when a student application changes status.',
    eventKey: 'application.status.changed',
    url: 'https://api.uapp.uk/webhooks/status',
    installed: true, successCount: 142, failureCount: 2,
  ),
  WebhookApp(
    id: 'wh-2', name: 'Student Enrolled',
    description: 'Fires when a student\'s enrolment is confirmed.',
    eventKey: 'student.enrolled',
    url: 'https://api.uapp.uk/webhooks/enrolled',
    installed: true, successCount: 38, failureCount: 0,
  ),
  WebhookApp(
    id: 'wh-3', name: 'Payment Received',
    description: 'Fires when a commission payment is processed.',
    eventKey: 'payment.received',
    url: 'https://api.uapp.uk/webhooks/payment',
    installed: false, successCount: 0, failureCount: 0,
  ),
  WebhookApp(
    id: 'wh-4', name: 'Document Verified',
    description: 'Fires when admission documents are verified.',
    eventKey: 'document.verified',
    url: 'https://api.uapp.uk/webhooks/docs',
    installed: false, successCount: 0, failureCount: 0,
  ),
];

// ── Notification model ────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? fromUserId;
  final DateTime createdAt;
  bool isRead;
  final String type; // meeting_invite | mention | reaction | system

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.fromUserId,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });
}

List<AppNotification> kNotifications = [
  // ── Today ─────────────────────────────────────────────────────
  AppNotification(
    id: 'n1', title: 'Meeting Invite',
    body: 'Tousif Sadman invited you to a Video Call on Sun, 14 Jun at 4:45 PM',
    fromUserId: 'u-tousif',
    createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    type: 'meeting_invite',
  ),
  AppNotification(
    id: 'n2', title: 'New Reaction',
    body: 'Andreea Cinpoi reacted 🎉 to your post about the Middlesex University partnership',
    fromUserId: 'u-andreea',
    createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    type: 'reaction',
  ),
  AppNotification(
    id: 'n3', title: 'You were mentioned',
    body: 'Nur Mohammad mentioned you in the Admission Officers group: "Please review the latest docs @Shamim"',
    fromUserId: 'u-nur',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    type: 'mention',
  ),
  AppNotification(
    id: 'n6', title: 'New Comment',
    body: 'Raj Ahmed commented on your post: "Huge win! Middlesex is a top choice for international students."',
    fromUserId: 'u-raj',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    type: 'comment', isRead: true,
  ),
  AppNotification(
    id: 'n7', title: 'New Reaction',
    body: 'Jennifer Aboje reacted 👍 to your post about the Q3 Sales Update',
    fromUserId: 'u-jennifer',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    type: 'reaction', isRead: true,
  ),
  AppNotification(
    id: 'n4', title: 'Commission Update',
    body: 'New commission structure document is now available. Review it in Settings.',
    fromUserId: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    type: 'system', isRead: true,
  ),
  AppNotification(
    id: 'n5', title: 'Meeting Reminder',
    body: 'Your Consultation with Nur Mohammad starts in 30 minutes',
    fromUserId: 'u-nur',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    type: 'meeting_invite', isRead: true,
  ),
  // ── Yesterday ─────────────────────────────────────────────────
  AppNotification(
    id: 'n8', title: 'New Reaction',
    body: 'Md Shamim and 3 others reacted 🎉 to your post about the Sales Team award',
    fromUserId: 'u-md-shamim',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    type: 'reaction', isRead: true,
  ),
  AppNotification(
    id: 'n9', title: 'Meeting Accepted',
    body: 'Andreea Cinpoi accepted your Video Call invitation for Mon, 15 Jun at 10:00 AM',
    fromUserId: 'u-andreea',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    type: 'meeting_invite', isRead: true,
  ),
  AppNotification(
    id: 'n10', title: 'You were mentioned',
    body: 'Laura Tomova mentioned you in the Sales Team group: "@Shamim the weekly target is met 🎯"',
    fromUserId: 'u-laura',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    type: 'mention', isRead: true,
  ),
  // ── Earlier this week ─────────────────────────────────────────
  AppNotification(
    id: 'n11', title: 'New Comment',
    body: 'Rakib commented on Jennifer\'s post: "Just submitted 4 more. Dashboard updated."',
    fromUserId: 'u-rakib',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    type: 'comment', isRead: true,
  ),
  AppNotification(
    id: 'n12', title: 'System Update',
    body: 'The new commission dashboard is now live. All sales team members can view earnings in real-time.',
    fromUserId: null,
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    type: 'system', isRead: true,
  ),
  AppNotification(
    id: 'n13', title: 'Meeting Invite',
    body: 'Riad Hossain invited you to a Consultation on Fri, 12 Jun at 2:00 PM',
    fromUserId: 'u-riad',
    createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
    type: 'meeting_invite', isRead: true,
  ),
  // ── This month ────────────────────────────────────────────────
  AppNotification(
    id: 'n14', title: 'New Reaction',
    body: 'Tousif Sadman reacted 💡 to your post about the September 2026 intake',
    fromUserId: 'u-tousif',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
    type: 'reaction', isRead: true,
  ),
  AppNotification(
    id: 'n15', title: 'System Update',
    body: 'UAPP platform updated to v2.4. New features: bulk application export, webhook retry queue.',
    fromUserId: null,
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
    type: 'system', isRead: true,
  ),
];

int get kUnreadNotificationCount => kNotifications.where((n) => !n.isRead).length;

// ── Time slots ────────────────────────────────────────────────
const List<TimeSlot> kTimeSlots = [
  TimeSlot(label: '8:00 AM'),
  TimeSlot(label: '8:30 AM'),
  TimeSlot(label: '9:00 AM'),
  TimeSlot(label: '9:30 AM'),
  TimeSlot(label: '10:00 AM'),
  TimeSlot(label: '10:30 AM'),
  TimeSlot(label: '11:00 AM'),
  TimeSlot(label: '11:30 AM'),
  TimeSlot(label: '12:00 PM', available: false),
  TimeSlot(label: '12:30 PM', available: false),
  TimeSlot(label: '1:00 PM'),
  TimeSlot(label: '1:30 PM'),
  TimeSlot(label: '2:00 PM'),
  TimeSlot(label: '2:30 PM'),
  TimeSlot(label: '3:00 PM'),
  TimeSlot(label: '3:30 PM'),
  TimeSlot(label: '4:00 PM', available: false),
  TimeSlot(label: '4:30 PM'),
  TimeSlot(label: '5:00 PM'),
  TimeSlot(label: '5:30 PM'),
];
