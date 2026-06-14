import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/post.dart';
import '../models/user.dart';

// Feeling model
class _Feeling {
  final String emoji;
  final String label;
  const _Feeling(this.emoji, this.label);
}

const _feelings = [
  _Feeling('🤩', 'excited'),
  _Feeling('😊', 'happy'),
  _Feeling('🥳', 'proud'),
  _Feeling('🙏', 'grateful'),
  _Feeling('🎉', 'celebrating'),
  _Feeling('💪', 'motivated'),
  _Feeling('🤔', 'thoughtful'),
  _Feeling('🎯', 'focused'),
  _Feeling('😎', 'confident'),
  _Feeling('❤️', 'thankful'),
  _Feeling('🚀', 'inspired'),
  _Feeling('😤', 'determined'),
];

class PostComposerScreen extends StatefulWidget {
  final void Function(FeedPost) onPost;

  const PostComposerScreen({super.key, required this.onPost});

  @override
  State<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends State<PostComposerScreen> {
  final _bodyCtrl = TextEditingController();
  final _focusNode = FocusNode();

  PostAudience _audience = PostAudience.all;
  PostPriority _priority = PostPriority.medium;
  String _categoryId = 'announcement';
  _Feeling? _feeling;
  final List<String> _tagged = [];
  bool _showPhotoPicker = false;
  final List<int> _selectedPhotos = [];

  bool get _canPost => _bodyCtrl.text.trim().isNotEmpty;

  final _audienceLabels = {
    PostAudience.all:        ('Everyone',       Icons.public_rounded),
    PostAudience.sales:      ('Sales Team',     Icons.trending_up_rounded),
    PostAudience.admission:  ('Admission Team', Icons.school_rounded),
    PostAudience.leadership: ('Leadership',     Icons.star_rounded),
  };

  @override
  void initState() {
    super.initState();
    _bodyCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _publish() {
    final text = _bodyCtrl.text.trim();
    if (text.isEmpty) return;

    String body = text;
    if (_feeling != null) body = '${_feeling!.emoji} $body — feeling ${_feeling!.label}';

    widget.onPost(FeedPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: kCurrentUser.id,
      body: body,
      createdAt: DateTime.now(),
      categoryId: _categoryId,
      audience: _audience,
      priority: _priority,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cat = findCategory(_categoryId)!;
    final aud = _audienceLabels[_audience]!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Header
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ),
        centerTitle: true,
        title: const Text('Create Post', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _canPost ? _publish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPost ? AppColors.primary : AppColors.surfaceElevated,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Post', style: TextStyle(fontWeight: FontWeight.w700, color: _canPost ? Colors.white : AppColors.textMuted)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: kCurrentUser.color, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(kCurrentUser.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kCurrentUser.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            // Audience selector
                            GestureDetector(
                              onTap: _pickAudience,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(aud.$2, color: AppColors.primaryLight, size: 13),
                                    const SizedBox(width: 5),
                                    Text(aud.$1, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Feeling chip (if set)
                  if (_feeling != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _feeling = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC7300).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFC7300).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_feeling!.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text('Feeling ${_feeling!.label}', style: const TextStyle(color: AppColors.orange, fontSize: 12.5, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              const Icon(Icons.close_rounded, color: AppColors.orange, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Tagged people chips
                  if (_tagged.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Wrap(
                        spacing: 6,
                        children: _tagged.map((uid) {
                          final u = findUser(uid);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFaint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.person_rounded, color: AppColors.primaryLight, size: 13),
                              const SizedBox(width: 4),
                              Text(u?.name ?? uid, style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() => _tagged.remove(uid)),
                                child: const Icon(Icons.close_rounded, color: AppColors.primaryLight, size: 12),
                              ),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),

                  // Text field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: TextField(
                      controller: _bodyCtrl,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.55),
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 17),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),

                  // Category + priority meta row
                  if (_categoryId != 'announcement' || _priority != PostPriority.medium)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _MetaBadge(
                            icon: findCategory(_categoryId)!.icon,
                            label: findCategory(_categoryId)!.label,
                            color: findCategory(_categoryId)!.color,
                            onTap: _pickCategory,
                          ),
                          if (_priority != PostPriority.medium)
                            _MetaBadge(
                              icon: Icons.flag_rounded,
                              label: '${_priority.name[0].toUpperCase()}${_priority.name.substring(1)}',
                              color: _priority == PostPriority.high ? AppColors.danger : AppColors.textMuted,
                              onTap: _pickPriority,
                            ),
                        ],
                      ),
                    ),

                  // Photo grid (if shown)
                  if (_showPhotoPicker) _buildPhotoGrid(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom action bar (Facebook-style)
          _buildBottomBar(cat),
        ],
      ),
    );
  }

  Widget _buildBottomBar(PostCategory cat) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        left: 8, right: 8,
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom + 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add to your post label
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('Add to your post', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Icon(cat.icon, color: cat.color, size: 18),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _pickCategory,
                  child: Text(cat.label, style: TextStyle(color: cat.color, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomAction(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF16A34A),
                label: 'Photo',
                onTap: () => setState(() { _showPhotoPicker = !_showPhotoPicker; }),
                active: _selectedPhotos.isNotEmpty,
              ),
              _BottomAction(
                icon: Icons.person_add_rounded,
                color: AppColors.primary,
                label: 'Tag',
                onTap: _pickTag,
                active: _tagged.isNotEmpty,
              ),
              _BottomAction(
                icon: Icons.emoji_emotions_rounded,
                color: const Color(0xFFF59E0B),
                label: 'Feeling',
                onTap: _pickFeeling,
                active: _feeling != null,
              ),
              _BottomAction(
                icon: Icons.category_rounded,
                color: AppColors.orange,
                label: 'Category',
                onTap: _pickCategory,
              ),
              _BottomAction(
                icon: Icons.flag_rounded,
                color: _priority == PostPriority.high ? AppColors.danger : AppColors.textMuted,
                label: 'Priority',
                onTap: _pickPriority,
                active: _priority != PostPriority.medium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select photos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (_, i) {
              final sel = _selectedPhotos.contains(i);
              return GestureDetector(
                onTap: () => setState(() { sel ? _selectedPhotos.remove(i) : _selectedPhotos.add(i); }),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Icon(Icons.image_rounded, color: sel ? AppColors.primaryLight : AppColors.textMuted, size: 32)),
                      if (sel)
                        Positioned(top: 6, right: 6, child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${_selectedPhotos.indexOf(i) + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        )),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Pickers ───────────────────────────────────────────────────

  void _pickAudience() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PickerSheet(
        title: 'Post audience',
        items: PostAudience.values.map((a) {
          final info = _audienceLabels[a]!;
          return _PickerItem(icon: info.$2, label: info.$1, color: AppColors.primary, selected: _audience == a,
            onTap: () { setState(() => _audience = a); Navigator.pop(context); });
        }).toList(),
      ),
    );
  }

  void _pickFeeling() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55,
        builder: (_, ctrl) => Column(children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('How are you feeling?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
          const Divider(color: AppColors.divider),
          Expanded(
            child: GridView.builder(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.85, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _feelings.length,
              itemBuilder: (_, i) {
                final f = _feelings[i];
                final sel = _feeling?.label == f.label;
                return GestureDetector(
                  onTap: () { setState(() => _feeling = sel ? null : f); Navigator.pop(context); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.orange.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? AppColors.orange : AppColors.border),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(f.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(f.label, style: TextStyle(color: sel ? AppColors.orange : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _pickTag() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.65,
        builder: (_, ctrl) {
          final others = kUsers.where((u) => u.id != kCurrentUser.id && u.type != UserType.student).toList();
          return Column(children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Tag people', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            const Divider(color: AppColors.divider),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: others.length,
                itemBuilder: (_, i) {
                  final u = others[i];
                  final sel = _tagged.contains(u.id);
                  return ListTile(
                    leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: u.color, shape: BoxShape.circle), alignment: Alignment.center, child: Text(u.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                    title: Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
                    subtitle: Text(u.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    trailing: sel ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : const Icon(Icons.circle_outlined, color: AppColors.textMuted),
                    onTap: () { setState(() { sel ? _tagged.remove(u.id) : _tagged.add(u.id); }); },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Done (${_tagged.length} tagged)', style: const TextStyle(fontWeight: FontWeight.w700)),
              )),
            ),
          ]);
        },
      ),
    );
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75,
        builder: (_, ctrl) => Column(children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Post category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
          const Divider(color: AppColors.divider),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kPostCategories.length,
              itemBuilder: (_, i) {
                final cat = kPostCategories[i];
                final sel = _categoryId == cat.id;
                return ListTile(
                  leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Icon(cat.icon, color: cat.color, size: 20)),
                  title: Text(cat.label, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
                  trailing: sel ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
                  onTap: () { setState(() => _categoryId = cat.id); Navigator.pop(context); },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _pickPriority() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PickerSheet(
        title: 'Post priority',
        items: [
          _PickerItem(icon: Icons.flag_rounded, label: 'High — urgent, show prominently', color: AppColors.danger, selected: _priority == PostPriority.high, onTap: () { setState(() => _priority = PostPriority.high); Navigator.pop(context); }),
          _PickerItem(icon: Icons.flag_rounded, label: 'Medium — standard post', color: AppColors.warn, selected: _priority == PostPriority.medium, onTap: () { setState(() => _priority = PostPriority.medium); Navigator.pop(context); }),
          _PickerItem(icon: Icons.flag_outlined, label: 'Low — informational only', color: AppColors.textMuted, selected: _priority == PostPriority.low, onTap: () { setState(() => _priority = PostPriority.low); Navigator.pop(context); }),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _BottomAction({required this.icon, required this.color, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: active ? color.withValues(alpha: 0.15) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: color.withValues(alpha: 0.4)) : null,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: active ? color : AppColors.textSecondary, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? color : AppColors.textMuted, fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    ),
  );
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MetaBadge({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Icon(Icons.close_rounded, color: color, size: 12),
      ]),
    ),
  );
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _PickerSheet({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
      const Divider(color: AppColors.divider),
      ...items,
      const SizedBox(height: 16),
    ],
  );
}

class _PickerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PickerItem({required this.icon, required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Icon(icon, color: color, size: 20)),
    title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14.5)),
    trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight) : null,
    onTap: onTap,
  );
}
