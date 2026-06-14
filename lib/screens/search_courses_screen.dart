import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/course_data.dart';

class SearchCoursesScreen extends StatefulWidget {
  const SearchCoursesScreen({super.key});

  @override
  State<SearchCoursesScreen> createState() => _SearchCoursesScreenState();
}

class _SearchCoursesScreenState extends State<SearchCoursesScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  final _favourites = <String>{};
  final _compare = <String>{};
  String _fieldFilter = 'all';

  static const _bg = Color(0xFF030D0F);
  static const _surface = Color(0xFF051A1C);
  static const _border = Color(0xFF0D3235);
  static const _green = Color(0xFF0FBD8C);

  List<Course> get _filtered {
    return kCourses.where((c) {
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.university.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q);
      final matchField = _fieldFilter == 'all' || c.fieldId == _fieldFilter;
      return matchQ && matchField;
    }).toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterRow(results.length),
            Expanded(
              child: results.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _CourseRow(
                        course: results[i],
                        isFav: _favourites.contains(results[i].id),
                        isCompare: _compare.contains(results[i].id),
                        onFav: () => setState(() {
                          if (_favourites.contains(results[i].id)) _favourites.remove(results[i].id);
                          else _favourites.add(results[i].id);
                        }),
                        onCompare: () => setState(() {
                          if (_compare.contains(results[i].id)) _compare.remove(results[i].id);
                          else _compare.add(results[i].id);
                        }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _ctrl,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                decoration: const InputDecoration(
                  hintText: 'Search courses, universities…',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(int count) {
    return Column(
      children: [
        // Field chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kStudyFields.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = kStudyFields[i];
              final sel = f.id == _fieldFilter;
              return GestureDetector(
                onTap: () => setState(() => _fieldFilter = f.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? _green : _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? _green : _border),
                  ),
                  child: Text(f.label, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 12.5, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Result count + compare/fav chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: Text('$count Course${count == 1 ? '' : 's'}', style: const TextStyle(color: _green, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              _FilterPill(label: 'Favourites (${_favourites.length})', active: _favourites.isNotEmpty, onTap: () {}),
              const SizedBox(width: 8),
              _FilterPill(label: 'Compare (${_compare.length})', active: _compare.isNotEmpty, onTap: () {}, color: AppColors.orange),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 52),
        const SizedBox(height: 12),
        Text(_query.isEmpty ? 'Start typing to search' : 'No results for "$_query"', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
      ],
    ),
  );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;
  const _FilterPill({required this.label, required this.active, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color.withValues(alpha: 0.4) : const Color(0xFF0D3235)),
      ),
      child: Text(label, style: TextStyle(color: active ? color : AppColors.textMuted, fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
    ),
  );
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final bool isFav;
  final bool isCompare;
  final VoidCallback onFav;
  final VoidCallback onCompare;

  const _CourseRow({required this.course, required this.isFav, required this.isCompare, required this.onFav, required this.onCompare});

  static const _green = Color(0xFF0FBD8C);
  static const _surface = Color(0xFF051A1C);
  static const _border = Color(0xFF0D3235);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // University badge
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: course.universityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: course.universityColor.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(course.code, style: TextStyle(color: course.universityColor, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${course.university}, ${course.location}  ·  ${course.code}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                const SizedBox(height: 8),
                // Intake badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: course.intakes.map((intake) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _green.withValues(alpha: 0.25)),
                    ),
                    child: Text(intake, style: const TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (course.scholarshipAvailable)
                      const Text('Scholarship Available  ', style: TextStyle(color: _green, fontSize: 11.5, fontWeight: FontWeight.w500)),
                    if (course.loanAvailable)
                      Text('Loan available', style: TextStyle(color: AppColors.orange.withValues(alpha: 0.9), fontSize: 11.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onFav,
                child: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFav ? _green : AppColors.textMuted, size: 22),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onCompare,
                child: Icon(Icons.compare_arrows_rounded, color: isCompare ? AppColors.orange : AppColors.textMuted, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
