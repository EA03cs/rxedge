import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
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
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Container(
        height: RxSpacing.s48,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: RxRadii.borderInput,
          border: Border.all(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s12),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              size: 18.0,
              color: colors.textSecondary,
            ),
            const SizedBox(width: RxSpacing.s10),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 14.0,
                ),
                decoration: InputDecoration(
                  hintText: l10n.librarySearchHint,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colors.textTertiary,
                    fontSize: 14.0,
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
