import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';

/// Sub-header displaying items count and Grid/List view toggle
class LibraryViewHeader extends StatelessWidget {
  final int count;
  final bool isGridView;
  final VoidCallback onToggleView;

  const LibraryViewHeader({
    super.key,
    required this.count,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s16,
        vertical: RxSpacing.s4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.materialsCount(count),
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          IconButton(
            icon: Icon(
              isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
              size: 18.0,
              color: colors.textPrimary,
            ),
            tooltip: isGridView ? l10n.viewList : l10n.viewGrid,
            onPressed: onToggleView,
            constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
          ),
        ],
      ),
    );
  }
}
