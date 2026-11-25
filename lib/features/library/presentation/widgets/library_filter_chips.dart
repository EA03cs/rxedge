import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/entities/material_item_entity.dart';

/// Horizontally Scrollable Filter Chips for Resource Library / Marketing Hub
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

    final isFavoritesActive = activeShortcut == LibraryShortcut.favorites;
    final isDownloadedActive = activeShortcut == LibraryShortcut.downloaded;
    final isAllActive = activeShortcut == LibraryShortcut.none &&
        selectedCategory == MaterialCategory.all &&
        selectedProduct == null;
    final isBrochuresActive =
        activeShortcut == LibraryShortcut.none && selectedCategory == MaterialCategory.brochure;
    final isVisualAidsActive =
        activeShortcut == LibraryShortcut.none && selectedCategory == MaterialCategory.visualAid;
    final isEDetailActive =
        activeShortcut == LibraryShortcut.none && selectedCategory == MaterialCategory.edetail;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // 1. Favorites Chip
          _buildPillChip(
            label: 'Favorites',
            icon: Icons.bookmark_outline,
            isActive: isFavoritesActive,
            onTap: () => onShortcutToggled(
              isFavoritesActive ? LibraryShortcut.none : LibraryShortcut.favorites,
            ),
          ),
          const SizedBox(width: 8.0),

          // 2. Downloaded Chip
          _buildPillChip(
            label: 'Downloaded',
            icon: LucideIcons.cloud,
            isActive: isDownloadedActive,
            onTap: () => onShortcutToggled(
              isDownloadedActive ? LibraryShortcut.none : LibraryShortcut.downloaded,
            ),
          ),
          const SizedBox(width: 8.0),

          // 3. All Chip
          _buildPillChip(
            label: 'All',
            icon: LucideIcons.layoutGrid,
            isActive: isAllActive,
            onTap: () {
              if (activeShortcut != LibraryShortcut.none) {
                onShortcutToggled(LibraryShortcut.none);
              }
              onCategoryChanged(MaterialCategory.all);
              onProductChanged(null);
            },
          ),
          const SizedBox(width: 8.0),

          // 4. Brochures Chip
          _buildPillChip(
            label: 'Brochures',
            icon: LucideIcons.fileText,
            isActive: isBrochuresActive,
            onTap: () {
              if (activeShortcut != LibraryShortcut.none) {
                onShortcutToggled(LibraryShortcut.none);
              }
              onCategoryChanged(MaterialCategory.brochure);
            },
          ),
          const SizedBox(width: 8.0),

          // 5. Visual Aids Chip
          _buildPillChip(
            label: 'Visual Aids',
            icon: LucideIcons.image,
            isActive: isVisualAidsActive,
            onTap: () {
              if (activeShortcut != LibraryShortcut.none) {
                onShortcutToggled(LibraryShortcut.none);
              }
              onCategoryChanged(MaterialCategory.visualAid);
            },
          ),
          const SizedBox(width: 8.0),

          // 6. E-Detail Chip
          _buildPillChip(
            label: 'E-Detail',
            icon: LucideIcons.presentation,
            isActive: isEDetailActive,
            onTap: () {
              if (activeShortcut != LibraryShortcut.none) {
                onShortcutToggled(LibraryShortcut.none);
              }
              onCategoryChanged(MaterialCategory.edetail);
            },
          ),
          const SizedBox(width: 8.0),

          // Divider
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
            width: 1.0,
            height: 22.0,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 8.0),

          // Product Filter Chip
          _buildDropdownChip(
            label: selectedProduct ?? 'All Products',
            isActive: selectedProduct != null,
            icon: LucideIcons.pill,
            colors: colors,
            textTheme: textTheme,
            onTap: () => _showProductPicker(context),
          ),
          const SizedBox(width: 8.0),

          // Sort Chip
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

  Widget _buildPillChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0284C7) : Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            border: isActive
                ? null
                : Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.0,
                color: isActive ? Colors.white : const Color(0xFF334155),
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF334155),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13.0,
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.0),
        child: Container(
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE0F2FE) : Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(
              color: isActive ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.0,
                color: isActive ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF0284C7) : const Color(0xFF334155),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 4.0),
              Icon(
                LucideIcons.chevronDown,
                size: 13.0,
                color: isActive ? const Color(0xFF0284C7) : const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
