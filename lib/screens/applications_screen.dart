import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/course_data.dart';
import '../data/mock_data.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _bg = Color(0xFF030D0F);
  static const _surface = Color(0xFF051A1C);
  static const _border = Color(0xFF0D3235);
  static const _green = Color(0xFF0FBD8C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AppList(apps: kStudentApplications),
                  _AppList(apps: kStudentApplications.where((a) => a.status.contains('Review') || a.status.contains('Required')).toList()),
                  _AppList(apps: kStudentApplications.where((a) => a.status.contains('Offer')).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('New Application', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        onPressed: () {},
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        const Text('My Applications', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withValues(alpha: 0.35)),
          ),
          child: Text('${kStudentApplications.length} Total', style: const TextStyle(color: _green, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  Widget _buildTabs() => TabBar(
    controller: _tabController,
    labelColor: _green,
    unselectedLabelColor: AppColors.textMuted,
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(fontSize: 13),
    indicatorColor: _green,
    indicatorWeight: 2,
    dividerColor: _border,
    tabs: const [Tab(text: 'All'), Tab(text: 'In Progress'), Tab(text: 'Offers')],
  );
}

class _AppList extends StatelessWidget {
  final List<StudentApplication> apps;
  static const _bg = Color(0xFF030D0F);
  static const _green = Color(0xFF0FBD8C);

  const _AppList({required this.apps});

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.description_outlined, color: AppColors.textMuted, size: 52),
          const SizedBox(height: 12),
          const Text('No applications here', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Start an Application'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
          ),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: apps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AppCard(app: apps[i]),
    );
  }
}

class _AppCard extends StatelessWidget {
  final StudentApplication app;
  static const _surface = Color(0xFF051A1C);
  static const _border = Color(0xFF0D3235);
  static const _green = Color(0xFF0FBD8C);

  const _AppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    Course? course;
    try {
      course = kCourses.firstWhere((c) => c.id == app.courseId);
    } catch (_) {}
    final consultant = findUser(app.consultantId ?? '');

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App number badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _green.withValues(alpha: 0.3)),
                ),
                child: Text(app.appNumber, style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: app.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: app.statusColor.withValues(alpha: 0.35)),
                ),
                child: Text(app.status, style: TextStyle(color: app.statusColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (course != null) ...[
            const SizedBox(height: 12),
            Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3), maxLines: 2),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.account_balance_rounded, color: course.universityColor, size: 14),
                const SizedBox(width: 5),
                Text('${course.university} · ${course.location}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            // Intakes
            Wrap(
              spacing: 6,
              children: course.intakes.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _green.withValues(alpha: 0.2)),
                ),
                child: Text(i, style: const TextStyle(color: _green, fontSize: 10.5, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF0D3235)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 13),
              const SizedBox(width: 5),
              Text('Applied ${DateFormat('dd MMM yyyy').format(app.appliedAt)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const Spacer(),
              if (consultant != null) ...[
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: consultant.color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(consultant.initials, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Text(consultant.name.split(' ').first, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF0D3235)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Message Consultant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
