import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/entities/material_item_entity.dart';

/// Horizontally Scrollable Filter Chips for Resource Library
class LibraryFilterChips extends StatelessWidget {
  final MaterialCategory selectedCategory;
  final String? selectedProduct;
  final List<String> availableProducts;
  final LibrarySortOption sortOption;
  final LibraryShortcut activeShortcut;
  final ValueChanged<MaterialCategory> onCategoryChanged;
  final ValueChanged<String?> onProductChanged;
  final ValueChanged<LibrarySortOption> onSortChanged;
  final ValueChanged<LibraryShortcut> onShortcutToggled;

  const LibraryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.selectedProduct,
    required this.availableProducts,
    required this.sortOption,
    required this.activeShortcut,
    required this.onCategoryChanged,
    required this.onProductChanged,
    required this.onSortChanged,
    required this.onShortcutToggled,
  });

  String _getCategoryLabel(BuildContext context, MaterialCategory cat) {
    final l10n = context.l10n;
    switch (cat) {
      case MaterialCategory.all:
        return l10n.filterAll;
      case MaterialCategory.brochure:
        return l10n.filterBrochures;
      case MaterialCategory.visualAid:
        return l10n.filterVisualAids;
      case MaterialCategory.edetail:
        return l10n.filterEDetail;
      case MaterialCategory.marketing:
        return l10n.filterMarketing;
    }
  }

  String _getSortLabel(BuildContext context, LibrarySortOption sort) {
    final l10n = context.l10n;
    switch (sort) {
      case LibrarySortOption.newest:
        return l10n.sortNewest;
      case LibrarySortOption.mostUsed:
        return l10n.sortMostUsed;
      case LibrarySortOption.alphabetical:
        return l10n.sortAlphabetical;
    }
  }

  void _showProductPicker(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: RxSpacing.s16),
                Text(
                  'Filter by Pharmaceutical Product',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: RxSpacing.s12),
                ListTile(
                  title: Text(l10n.filterAllProducts),
                  trailing: selectedProduct == null
                      ? Icon(LucideIcons.check, color: colors.primary, size: 18.0)
                      : null,
                  onTap: () {
                    onProductChanged(null);
                    Navigator.of(ctx).pop();
                  },
                ),
                ...availableProducts.map((prod) {
                  final isSelected = selectedProduct == prod;
                  return ListTile(
                    title: Text(prod),
                    trailing: isSelected
                        ? Icon(LucideIcons.check, color: colors.primary, size: 18.0)
                        : null,
                    onTap: () {
                      onProductChanged(prod);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortPicker(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: RxSpacing.s16),
                Text(
                  'Sort Materials By',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: RxSpacing.s12),
                ...LibrarySortOption.values.map((sort) {
                  final isSelected = sortOption == sort;
                  return ListTile(
                    title: Text(_getSortLabel(context, sort)),
                    trailing: isSelected
                        ? Icon(LucideIcons.check, color: colors.primary, size: 18.0)
                        : null,
                    onTap: () {
                      onSortChanged(sort);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Row(
        children: [
          // 1. Shortcuts: Favorites & Downloaded
          _buildShortcutChip(
            label: l10n.shortcutFavorites,
            icon: LucideIcons.bookmark,
            isActive: activeShortcut == LibraryShortcut.favorites,
            colors: colors,
            textTheme: textTheme,
            onTap: () => onShortcutToggled(LibraryShortcut.favorites),
          ),
          const SizedBox(width: RxSpacing.s8),
          _buildShortcutChip(
            label: l10n.shortcutDownloaded,
            icon: LucideIcons.downloadCloud,
            isActive: activeShortcut == LibraryShortcut.downloaded,
            colors: colors,
            textTheme: textTheme,
            onTap: () => onShortcutToggled(LibraryShortcut.downloaded),
          ),

          // Divider
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s8),
            width: 1.0,
            height: 24.0,
            color: colors.border,
          ),

          // 2. Category Chips
          ...MaterialCategory.values.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: RxSpacing.s8),
              child: _buildStandardChip(
                label: _getCategoryLabel(context, cat),
                isSelected: isSelected,
                colors: colors,
                textTheme: textTheme,
                onTap: () => onCategoryChanged(cat),
              ),
            );
          }),

          // Divider
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s4),
            width: 1.0,
            height: 24.0,
            color: colors.border,
          ),

          // 3. Product Filter Chip
          Padding(
            padding: const EdgeInsetsDirectional.only(start: RxSpacing.s8, end: RxSpacing.s8),
            child: _buildDropdownChip(
              label: selectedProduct ?? l10n.filterAllProducts,
              isActive: selectedProduct != null,
              icon: LucideIcons.pill,
              colors: colors,
              textTheme: textTheme,
              onTap: () => _showProductPicker(context),
            ),
          ),

          // 4. Sort Selector Chip
          _buildDropdownChip(
            label: _getSortLabel(context, sortOption),
            isActive: sortOption != LibrarySortOption.newest,
            icon: LucideIcons.arrowUpDown,
            colors: colors,
            textTheme: textTheme,
            onTap: () => _showSortPicker(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardChip({
    required String label,
    required bool isSelected,
    required RxColors colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? colors.primary : colors.surface,
      borderRadius: RxRadii.borderChip,
      child: InkWell(
        onTap: onTap,
        borderRadius: RxRadii.borderChip,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14.0, vertical: 7.0),
          decoration: BoxDecoration(
            borderRadius: RxRadii.borderChip,
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected ? colors.surface : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required RxColors colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? colors.primarySoft : colors.surface,
      borderRadius: RxRadii.borderChip,
      child: InkWell(
        onTap: onTap,
        borderRadius: RxRadii.borderChip,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0, vertical: 7.0),
          decoration: BoxDecoration(
            borderRadius: RxRadii.borderChip,
            border: Border.all(
              color: isActive ? colors.primary.withValues(alpha: 0.3) : colors.border,
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.0,
                color: isActive ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: RxSpacing.s6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: isActive ? colors.primary : colors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required bool isActive,
    required IconData icon,
    required RxColors colors,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? colors.primarySoft : colors.surface,
      borderRadius: RxRadii.borderChip,
      child: InkWell(
        onTap: onTap,
        borderRadius: RxRadii.borderChip,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0, vertical: 7.0),
          decoration: BoxDecoration(
            borderRadius: RxRadii.borderChip,
            border: Border.all(
              color: isActive ? colors.primary.withValues(alpha: 0.3) : colors.border,
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.0,
                color: isActive ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: RxSpacing.s6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: isActive ? colors.primary : colors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(width: RxSpacing.s4),
              Icon(
                LucideIcons.chevronDown,
                size: 13.0,
                color: isActive ? colors.primary : colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
