import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/material_item_entity.dart';
import '../controllers/library_controller.dart';
import '../widgets/library_empty_state.dart';
import '../widgets/library_filter_chips.dart';
import '../widgets/library_search_bar.dart';
import '../widgets/library_skeleton_loader.dart';
import '../widgets/library_view_header.dart';
import '../widgets/material_actions_sheet.dart';
import '../widgets/material_card_grid.dart';
import '../widgets/material_card_list.dart';
import 'edetail_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'pdf_viewer_screen.dart';

/// Resource Library Screen
///
/// Features:
/// 1. Large search bar with instant debounce & clear
/// 2. Horizontally scrollable filter chips (All, Brochures, Visual Aids, E-Detail, Marketing)
/// 3. Product filter dropdown + Sort options (Newest, Most used, A to Z)
/// 4. Shortcuts: Favorites and Downloaded
/// 5. Grid/List view toggle
/// 6. Item cards with thumbnail, type icon, size, date, New/Updated badge, offline indicator, and favorite toggle
/// 7. Skeletons, empty search results, offline mode where non-downloaded items are visibly disabled
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _openViewer(BuildContext context, MaterialItemEntity item) {
    Widget destination;
    switch (item.fileType) {
      case MaterialFileType.pdf:
        destination = PdfViewerScreen(material: item);
        break;
      case MaterialFileType.image:
        destination = ImageViewerScreen(material: item);
        break;
      case MaterialFileType.edetailSlides:
        destination = EdetailViewerScreen(material: item);
        break;
    }

    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final stateAsync = ref.watch(libraryControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.libraryTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          // Offline mode toggle for testing and demoing
          stateAsync.whenOrNull(
                data: (st) => IconButton(
                  icon: Icon(
                    st.isOffline ? LucideIcons.cloudOff : LucideIcons.cloud,
                    size: 18.0,
                    color: st.isOffline ? colors.warning : colors.textSecondary,
                  ),
                  tooltip: st.isOffline ? 'Online Mode' : 'Simulate Offline Mode',
                  onPressed: () {
                    ref.read(libraryControllerProvider.notifier).setOfflineMode(!st.isOffline);
                  },
                ),
              ) ??
              const SizedBox.shrink(),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: stateAsync.when(
          loading: () => const Padding(
            padding: EdgeInsetsDirectional.only(top: RxSpacing.s16),
            child: LibrarySkeletonLoader(),
          ),
          error: (error, _) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
              child: ErrorState(
                title: l10n.errorStateTitle,
                description: l10n.errorStateDescription,
                retryText: l10n.retry,
                onRetry: () => ref.read(libraryControllerProvider.notifier).refresh(),
              ),
            ),
          ),
          data: (state) {
            final items = state.filteredMaterials;
            final controller = ref.read(libraryControllerProvider.notifier);

            return RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.surface,
              onRefresh: () => controller.refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Offline Banner if offline
                  if (state.isOffline)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
                        child: OfflineBanner(
                          message: l10n.offlineNotice,
                        ),
                      ),
                    ),

                  // 2. Large Search Bar
                  SliverToBoxAdapter(
                    child: LibrarySearchBar(
                      query: state.searchQuery,
                      onChanged: (q) => controller.setSearchQuery(q),
                      onClear: () => controller.setSearchQuery(''),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: RxSpacing.s12)),

                  // 3. Horizontally Scrollable Filter Chips & Shortcuts
                  SliverToBoxAdapter(
                    child: LibraryFilterChips(
                      selectedCategory: state.selectedCategory,
                      selectedProduct: state.selectedProduct,
                      availableProducts: state.availableProducts,
                      sortOption: state.sortOption,
                      activeShortcut: state.activeShortcut,
                      onCategoryChanged: (cat) => controller.setCategory(cat),
                      onProductChanged: (prod) => controller.setProduct(prod),
                      onSortChanged: (s) => controller.setSortOption(s),
                      onShortcutToggled: (sc) => controller.toggleShortcut(sc),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: RxSpacing.s8)),

                  // 4. View Header (Count & Grid/List Toggle)
                  SliverToBoxAdapter(
                    child: LibraryViewHeader(
                      count: items.length,
                      isGridView: state.isGridView,
                      onToggleView: () => controller.toggleGridView(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: RxSpacing.s8)),

                  // 5. Materials Content: Empty State vs Grid vs List
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: LibraryEmptyState(
                        searchQuery: state.searchQuery,
                        shortcut: state.activeShortcut,
                        onReset: () {
                          controller.setSearchQuery('');
                          controller.setCategory(MaterialCategory.all);
                          controller.setProduct(null);
                          controller.toggleShortcut(state.activeShortcut);
                        },
                      ),
                    )
                  else if (state.isGridView)
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.only(
                        start: RxSpacing.s16,
                        end: RxSpacing.s16,
                        bottom: RxSpacing.s32,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: RxSpacing.s12,
                          mainAxisSpacing: RxSpacing.s12,
                          childAspectRatio: 0.68,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return MaterialCardGrid(
                              item: item,
                              isOffline: state.isOffline,
                              onTap: () => _openViewer(context, item),
                              onToggleFavorite: () => controller.toggleFavorite(item.id),
                              onDownload: () => controller.startDownload(item.id),
                              onCancelDownload: () => controller.cancelDownload(item.id),
                              onMoreActions: () {
                                MaterialActionsSheet.show(
                                  context,
                                  item: item,
                                  isOffline: state.isOffline,
                                  onOpen: () => _openViewer(context, item),
                                  onToggleFavorite: () => controller.toggleFavorite(item.id),
                                  onDownload: () => controller.startDownload(item.id),
                                  onRemoveDownload: () => controller.removeDownload(item.id),
                                );
                              },
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.only(
                        start: RxSpacing.s16,
                        end: RxSpacing.s16,
                        bottom: RxSpacing.s32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s10),
                              child: MaterialCardList(
                                item: item,
                                isOffline: state.isOffline,
                                onTap: () => _openViewer(context, item),
                                onToggleFavorite: () => controller.toggleFavorite(item.id),
                                onDownload: () => controller.startDownload(item.id),
                                onCancelDownload: () => controller.cancelDownload(item.id),
                                onMoreActions: () {
                                  MaterialActionsSheet.show(
                                    context,
                                    item: item,
                                    isOffline: state.isOffline,
                                    onOpen: () => _openViewer(context, item),
                                    onToggleFavorite: () => controller.toggleFavorite(item.id),
                                    onDownload: () => controller.startDownload(item.id),
                                    onRemoveDownload: () => controller.removeDownload(item.id),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
