import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';

/// Large Search Bar for Resource Library
///
/// Features:
/// - 48dp touch target
/// - Hairline border, 12dp radius
/// - Clear button (X) when search query is entered
/// - Instant search feedback
class LibrarySearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const LibrarySearchBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<LibrarySearchBar> createState() => _LibrarySearchBarState();
}

class _LibrarySearchBarState extends State<LibrarySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant LibrarySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(
              LucideIcons.search,
              size: 19.0,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search materials, monographs, trials...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  LucideIcons.x,
                  size: 16.0,
                  color: colors.textTertiary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              ),
          ],
        ),
      ),
    );
  }
}
