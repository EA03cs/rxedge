import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/material_item_entity.dart';

/// Clean, informative empty state for Resource Library
class LibraryEmptyState extends StatelessWidget {
  final String searchQuery;
  final LibraryShortcut shortcut;
  final VoidCallback onReset;

  const LibraryEmptyState({
    super.key,
    required this.searchQuery,
    required this.shortcut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (searchQuery.trim().isNotEmpty) {
      return EmptyState(
        icon: LucideIcons.searchX,
        title: l10n.emptySearchResultsTitle(searchQuery.trim()),
        description: l10n.emptySearchResultsDesc,
        actionText: l10n.clearFilters,
        onAction: onReset,
      );
    }

    if (shortcut == LibraryShortcut.favorites) {
      return EmptyState(
        icon: LucideIcons.bookmark,
        title: l10n.emptyFavoritesTitle,
        description: l10n.emptyFavoritesDesc,
        actionText: l10n.clearFilters,
        onAction: onReset,
      );
    }

    if (shortcut == LibraryShortcut.downloaded) {
      return EmptyState(
        icon: LucideIcons.downloadCloud,
        title: l10n.emptyDownloadsTitle,
        description: l10n.emptyDownloadsDesc,
        actionText: l10n.clearFilters,
        onAction: onReset,
      );
    }

    return EmptyState(
      icon: LucideIcons.folderX,
      title: l10n.emptyStateTitle,
      description: l10n.emptyStateDescription,
      actionText: l10n.clearFilters,
      onAction: onReset,
    );
  }
}
