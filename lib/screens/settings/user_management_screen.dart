import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/user.dart';
import '../../widgets/user_avatar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  final _groups = [
    (label: 'Administrators', type: UserType.admin,      color: const Color(0xFFE9445A)),
    (label: 'Sales Team',     type: UserType.sales,      color: const Color(0xFF0A6E6F)),
    (label: 'Admission Team', type: UserType.admission,  color: const Color(0xFFFC7300)),
    (label: 'Students',       type: UserType.student,    color: const Color(0xFF64748B)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _groups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppUser> _usersFor(UserType type) {
    return kUsers.where((u) {
      if (u.type != type) return false;
      if (_search.isEmpty) return true;
      return u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.role.toLowerCase().contains(_search.toLowerCase());
    }).toList();
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
        title: const Text('User Management', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.divider,
          tabs: _groups.map((g) => Tab(text: g.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search users…',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _groups.map((g) => _UserList(
                users: _usersFor(g.type),
                groupColor: g.color,
                onUserTap: (u) => _showUserDetail(u),
              )).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Invite User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onPressed: () => _showInviteDialog(),
      ),
    );
  }

  void _showUserDetail(AppUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            UserAvatar(userId: user.id, size: 64, showOnline: true),
            const SizedBox(height: 12),
            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(user.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              _DetailChip(label: user.dept.name.toUpperCase(), color: AppColors.primary),
              const SizedBox(width: 8),
              _DetailChip(label: 'Level ${user.level}', color: AppColors.orange),
              const SizedBox(width: 8),
              _DetailChip(
                label: user.online ? 'Online' : 'Offline',
                color: user.online ? AppColors.online : AppColors.textMuted,
              ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.block_rounded, size: 16),
                  label: const Text('Suspend'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Invite User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Email address'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<AppUser> users;
  final Color groupColor;
  final void Function(AppUser) onUserTap;

  const _UserList({required this.users, required this.groupColor, required this.onUserTap});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, i) => _UserTile(user: users[i], groupColor: groupColor, onTap: () => onUserTap(users[i])),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final Color groupColor;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.groupColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            UserAvatar(userId: user.id, size: 44, showOnline: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                  Text(user.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: groupColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.dept.name,
                style: TextStyle(color: groupColor, fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final Color color;
  const _DetailChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
