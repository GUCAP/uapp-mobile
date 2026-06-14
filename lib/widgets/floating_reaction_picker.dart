import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Shows a WhatsApp/Facebook-style floating emoji pill above a widget.
/// Call [showFloatingReactions] with the render box of the trigger widget.
void showFloatingReactions({
  required BuildContext context,
  required RenderBox triggerBox,
  required List<_ReactionOption> reactions,
  Alignment align = Alignment.bottomLeft,
}) {
  late OverlayEntry entry;

  final triggerOffset = triggerBox.localToGlobal(Offset.zero);
  final screenW       = MediaQuery.of(context).size.width;

  // Position the pill so it sits just above the trigger and doesn't overflow
  double left = triggerOffset.dx - 8;
  if (left + 220 > screenW) left = screenW - 228;
  if (left < 8) left = 8;
  final top = triggerOffset.dy - 60;

  entry = OverlayEntry(
    builder: (_) => GestureDetector(
      onTap: () => entry.remove(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: _ReactionPill(
                reactions: reactions,
                onSelect: (r) { entry.remove(); r.onTap(); },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Overlay.of(context).insert(entry);
}

class _ReactionPill extends StatefulWidget {
  final List<_ReactionOption> reactions;
  final void Function(_ReactionOption) onSelect;
  const _ReactionPill({required this.reactions, required this.onSelect});

  @override
  State<_ReactionPill> createState() => _ReactionPillState();
}

class _ReactionPillState extends State<_ReactionPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = C(context);
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.reactions.asMap().entries.map((e) {
              final i = e.key;
              final r = e.value;
              return GestureDetector(
                onTap: () => widget.onSelect(r),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = i),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _hoveredIndex == i ? AppColors.primaryFaint : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 120),
                      style: TextStyle(fontSize: _hoveredIndex == i ? 34 : 28),
                      child: Text(r.emoji),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ReactionOption {
  final String emoji;
  final String type;
  final VoidCallback onTap;
  const _ReactionOption({required this.emoji, required this.type, required this.onTap});
}

/// Convenience factory — build the 3 standard reaction options
List<_ReactionOption> buildReactions({required void Function(String type) onReact}) => [
  _ReactionOption(emoji: '👍', type: 'like',        onTap: () => onReact('like')),
  _ReactionOption(emoji: '💡', type: 'insightful',  onTap: () => onReact('insightful')),
  _ReactionOption(emoji: '🎉', type: 'celebrate',   onTap: () => onReact('celebrate')),
];
