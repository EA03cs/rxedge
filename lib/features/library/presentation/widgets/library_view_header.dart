import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';

/// Sub-header displaying items count and filter/view toggle
class LibraryViewHeader extends StatelessWidget {
  final int count;
  final bool isGridView;
  final VoidCallback onToggleView;
  final VoidCallback? onFilterTap;

  const LibraryViewHeader({
    super.key,
    required this.count,
    required this.isGridView,
    required this.onToggleView,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count approved materials',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 16.0,
              letterSpacing: -0.2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
                  size: 18.0,
                  color: const Color(0xFF0F172A),
                ),
                tooltip: isGridView ? l10n.viewList : l10n.viewGrid,
                onPressed: onToggleView,
                constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
              ),
              if (onFilterTap != null)
                IconButton(
                  icon: const Icon(
                    LucideIcons.slidersHorizontal,
                    size: 17.0,
                    color: Color(0xFF0F172A),
                  ),
                  tooltip: 'Filter options',
                  onPressed: onFilterTap,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
