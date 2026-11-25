import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
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

/// Marketing Hub / Resource Library Screen
/// Matches reference design with 3D Folder header, search, pill shortcuts, and material cards
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _openViewer(BuildContext context, MaterialItemEntity item) {
    if (item.fileUrl == null || item.fileUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه المادة قيد الإعداد والمراجعة الطبية وستتوفر قريباً.'),
        ),
      );
      return;
    }

    if (item.fileUrl != null &&
        (item.fileUrl!.contains('drive.google.com') ||
            item.fileUrl!.contains('docs.google.com'))) {
      final uri = Uri.tryParse(item.fileUrl!);
      if (uri != null) {
        unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
        return;
      }
    }

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

  void _showFilterOptions(BuildContext context, WidgetRef ref, LibraryState state) {
    final controller = ref.read(libraryControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Layout & Sort Options',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14.0),
                ListTile(
                  leading: Icon(
                    state.isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
                    color: const Color(0xFF0284C7),
                  ),
                  title: Text(state.isGridView ? 'Switch to List View' : 'Switch to Grid View'),
                  onTap: () {
                    controller.toggleGridView();
                    Navigator.of(ctx).pop();
                  },
                ),
                const Divider(height: 20.0),
                const Text(
                  'Sort Order',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                ...LibrarySortOption.values.map((sort) {
                  final isSelected = state.sortOption == sort;
                  return ListTile(
                    title: Text(
                      sort == LibrarySortOption.newest
                          ? 'Newest First'
                          : (sort == LibrarySortOption.mostUsed
                              ? 'Most Used'
                              : 'Alphabetical (A-Z)'),
                    ),
                    trailing: isSelected
                        ? const Icon(LucideIcons.check, color: Color(0xFF0284C7), size: 18.0)
                        : null,
                    onTap: () {
                      controller.setSortOption(sort);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final stateAsync = ref.watch(libraryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2FE),
              Color(0xFFEBF6FD),
              Color(0xFFF1F7FD),
              Color(0xFFF8FAFC),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.16, 0.32, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
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
                    // 1. Top Bar with Cloud Download / Offline Mode Button (No Mentholatum logo)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 38.0,
                              height: 38.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  state.isOffline ? LucideIcons.cloudOff : LucideIcons.downloadCloud,
                                  size: 18.0,
                                  color: state.isOffline ? colors.warning : const Color(0xFF0F172A),
                                ),
                                padding: EdgeInsets.zero,
                                tooltip: state.isOffline ? 'Online Mode' : 'Simulate Offline Mode',
                                onPressed: () {
                                  controller.setOfflineMode(!state.isOffline);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Offline Banner if offline
                    if (state.isOffline)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0, 20.0, 12.0),
                          child: OfflineBanner(
                            message: l10n.offlineNotice,
                          ),
                        ),
                      ),

                    // 3. Header Banner: "Marketing Hub" + Subtitle + 3D Folder Illustration
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.libraryTitle,
                                    style: const TextStyle(
                                      fontSize: 27.0,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  const Text(
                                    'Access your approved marketing materials and resources',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      color: Color(0xFF64748B),
                                      height: 1.35,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Image.asset(
                              'assets/images/marketing_folder_3d.png',
                              width: 105.0,
                              height: 90.0,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Large Pill Search Bar
                    SliverToBoxAdapter(
                      child: LibrarySearchBar(
                        query: state.searchQuery,
                        onChanged: (q) => controller.setSearchQuery(q),
                        onClear: () => controller.setSearchQuery(''),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12.0)),

                    // 5. Filter Chips & Shortcuts Row
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
                    const SliverToBoxAdapter(child: SizedBox(height: 10.0)),

                    // 6. Section Header (Count & Sliders Filter Button)
                    SliverToBoxAdapter(
                      child: LibraryViewHeader(
                        count: items.length,
                        isGridView: state.isGridView,
                        onToggleView: () => controller.toggleGridView(),
                        onFilterTap: () => _showFilterOptions(context, ref, state),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8.0)),

                    // 7. Materials Content: Empty State vs Grid vs List
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
                          start: 16.0,
                          end: 16.0,
                          bottom: 32.0,
                        ),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.76,
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
                          start: 16.0,
                          end: 16.0,
                          bottom: 32.0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 10.0),
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
      ),
    );
  }
}
