import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../challenges/presentation/screens/challenges_screen.dart';
import '../../../learn/data/repositories/learn_repository_impl.dart';
import '../../../learn/domain/entities/learning_entities.dart';
import '../../../learn/presentation/controllers/learn_controller.dart';
import '../../../learn/presentation/screens/lesson_screen.dart';
import '../../../learn/presentation/screens/product_learning_screen.dart';
import '../../../library/data/repositories/library_repository_impl.dart';
import '../../../library/domain/entities/material_item_entity.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../../../library/presentation/screens/image_viewer_screen.dart';
import '../../../library/presentation/screens/pdf_viewer_screen.dart';
import '../../domain/entities/search_entities.dart';
import '../controllers/search_controller.dart';

/// Global Search Screen across Lessons, Library Materials, and Doctor Objections
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final text = _searchController.text.trim();
      if (text != _activeQuery) {
        setState(() => _activeQuery = text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final recentSearchesAsync = ref.watch(recentSearchesProvider);
    final searchResultsAsync = _activeQuery.isNotEmpty
        ? ref.watch(searchResultsProvider(_activeQuery))
        : null;

    return AppScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: RxSpacing.s16),
          child: Container(
            height: 44.0,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: RxRadii.borderInput,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
              ),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                hintText: l10n.globalSearchPlaceholder,
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: colors.textTertiary,
                  fontSize: 13.0,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18.0,
                  color: colors.textSecondary,
                ),
                suffixIcon: _activeQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(LucideIcons.x, size: 16.0, color: colors.textSecondary),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s12,
                  vertical: RxSpacing.s10,
                ),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  ref.read(recentSearchesProvider.notifier).addSearch(query.trim());
                }
              },
            ),
          ),
        ),
      ),
      body: _activeQuery.isEmpty
          ? _buildRecentAndSuggestions(context, recentSearchesAsync)
          : _buildSearchResults(context, searchResultsAsync),
    );
  }

  Widget _buildRecentAndSuggestions(
    BuildContext context,
    AsyncValue<List<String>> recentSearchesAsync,
  ) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final quickPills = [
      'Rohto Dry Aid',
      'Rohto Cool',
      'Rohto Aqua',
      l10n.suggestedTopicDosing,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          recentSearchesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            data: (recents) {
              if (recents.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentSearchesTitle,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(recentSearchesProvider.notifier).clearAll(),
                        child: Text(
                          l10n.btnClearAll,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Wrap(
                    spacing: RxSpacing.s8,
                    runSpacing: RxSpacing.s8,
                    children: recents.map((item) {
                      return InkWell(
                        onTap: () => _onSelectQuery(item),
                        borderRadius: RxRadii.borderBadge,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(
                            start: RxSpacing.s10,
                            end: RxSpacing.s6,
                            top: RxSpacing.s6,
                            bottom: RxSpacing.s6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: RxRadii.borderBadge,
                            border: Border.all(
                              color: colors.border,
                              width: RxShadows.hairlineBorderWidth,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.history, size: 13.0, color: colors.textSecondary),
                              const SizedBox(width: RxSpacing.s6),
                              Text(
                                item,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s4),
                              InkWell(
                                onTap: () => ref
                                    .read(recentSearchesProvider.notifier)
                                    .removeSearch(item),
                                borderRadius: BorderRadius.circular(10.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.all(RxSpacing.s2),
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 13.0,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: RxSpacing.s24),
                ],
              );
            },
          ),

          // Suggested quick searches
          Text(
            l10n.suggestedTopicsLabel,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: RxSpacing.s10),
          Wrap(
            spacing: RxSpacing.s8,
            runSpacing: RxSpacing.s8,
            children: quickPills.map((pill) {
              return ActionChip(
                label: Text(pill),
                avatar: Icon(LucideIcons.search, size: 13.0, color: colors.primary),
                backgroundColor: colors.surface,
                side: BorderSide(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
                shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderBadge),
                labelStyle: textTheme.bodySmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                onPressed: () => _onSelectQuery(pill),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AsyncValue<Map<SearchResultCategory, List<SearchResultItemEntity>>?>? resultsAsync,
  ) {
    final colors = context.rxColors;
    final l10n = context.l10n;

    if (resultsAsync == null) return const SizedBox.shrink();

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ErrorState(
        title: l10n.searchFailedTitle,
        description: err.toString().replaceAll('Exception: ', ''),
        retryText: l10n.retry,
        onRetry: () => ref.refresh(searchResultsProvider(_activeQuery)),
      ),
      data: (map) {
        if (map == null || map.isEmpty || map.values.every((list) => list.isEmpty)) {
          return Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Icon(LucideIcons.searchX, size: 26.0, color: colors.textSecondary),
                  ),
                  const SizedBox(height: RxSpacing.s16),
                  Text(
                    l10n.searchNoResultsTitle(_activeQuery),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Text(
                    l10n.searchNoResultsDesc,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        final lessons = map[SearchResultCategory.lesson] ?? [];
        final libraryFiles = map[SearchResultCategory.libraryFile] ?? [];
        final objections = map[SearchResultCategory.objection] ?? [];

        return ListView(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
          children: [
            if (lessons.isNotEmpty) ...[
              SectionHeader(title: l10n.groupLessons),
              ...lessons.map((item) => _buildResultCard(context, item)),
              const SizedBox(height: RxSpacing.s16),
            ],
            if (libraryFiles.isNotEmpty) ...[
              SectionHeader(title: l10n.groupLibrary),
              ...libraryFiles.map((item) => _buildResultCard(context, item)),
              const SizedBox(height: RxSpacing.s16),
            ],
            if (objections.isNotEmpty) ...[
              SectionHeader(title: l10n.groupObjections),
              ...objections.map((item) => _buildResultCard(context, item)),
              const SizedBox(height: RxSpacing.s16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, SearchResultItemEntity item) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
      child: InkWell(
        onTap: () => _handleResultClick(context, item),
        borderRadius: RxRadii.borderCard,
        child: Container(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: RxRadii.borderCard,
            border: Border.all(
              color: colors.border,
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: RxRadii.borderButton,
                ),
                child: Icon(_getCategoryIcon(item), size: 18.0, color: colors.primary),
              ),
              const SizedBox(width: RxSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: RxSpacing.s8),
                        StatusBadge(
                          label: item.badgeText,
                          variant: StatusBadgeVariant.neutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: RxSpacing.s4),
                    Text(
                      item.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12.0,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RxSpacing.s6),
              Icon(context.chevronForward, size: 16.0, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleResultClick(BuildContext context, SearchResultItemEntity item) async {
    await ref.read(recentSearchesProvider.notifier).addSearch(_activeQuery);

    // 1. Fetch available products (from Riverpod state or repository)
    List<ProductLearningEntity> products =
        ref.read(learnControllerProvider).valueOrNull ?? [];
    if (products.isEmpty) {
      final repo = ref.read(learnRepositoryProvider);
      final res = await repo.getProducts();
      res.when(
        success: (List<ProductLearningEntity> list) => products = list,
        failure: (_) {},
      );
    }

    if (!context.mounted) return;

    // Normalization helper (lowercase alphanumeric only)
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final targetId = item.targetId ?? '';
    final itemId = item.id;
    final itemTitleNorm = norm(item.title);
    final itemBadgeNorm = norm(item.badgeText);
    final targetIdNorm = norm(targetId);
    final itemIdNorm = norm(itemId);

    final isExplicitProduct = item.targetRoute == '/learn/product' ||
        itemId.startsWith('prod_') ||
        itemId.startsWith('sr_prod_');

    final isExplicitLesson = item.targetRoute == '/learn/lesson' ||
        itemId.startsWith('lesson_') ||
        itemId.startsWith('sr_les_');

    // 2. Try finding matched product
    ProductLearningEntity? matchedProduct;
    for (final p in products) {
      final pIdNorm = norm(p.id);
      final pNameNorm = norm(p.name);

      if (pIdNorm == targetIdNorm ||
          pIdNorm == itemIdNorm ||
          targetIdNorm.contains(pIdNorm) ||
          itemIdNorm.contains(pIdNorm) ||
          pNameNorm == itemTitleNorm ||
          itemTitleNorm.contains(pNameNorm) ||
          pNameNorm == itemBadgeNorm) {
        matchedProduct = p;
        break;
      }
    }

    // 3. Try finding matched lesson
    LessonEntity? matchedLesson;
    for (final p in products) {
      for (final l in p.lessons) {
        final lIdNorm = norm(l.id);
        final lTitleNorm = norm(l.title);

        if (lIdNorm == targetIdNorm ||
            lIdNorm == itemIdNorm ||
            targetIdNorm.contains(lIdNorm) ||
            itemIdNorm.contains(lIdNorm) ||
            lTitleNorm == itemTitleNorm ||
            itemTitleNorm.contains(lTitleNorm)) {
          matchedLesson = l;
          matchedProduct ??= p;
          break;
        }
      }
      if (matchedLesson != null) break;
    }

    // Priority 1: If it's a lesson and user clicked a specific lesson
    if (isExplicitLesson && matchedLesson != null) {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          builder: (_) => LessonScreen(lesson: matchedLesson!),
        ),
      );
      return;
    }

    // Priority 2: If it's a product (or product was matched)
    if (isExplicitProduct || matchedProduct != null) {
      if (matchedProduct != null) {
        await Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(
            builder: (_) => ProductLearningScreen(product: matchedProduct!),
          ),
        );
        return;
      }
    }

    // If lesson was matched and no product found
    if (matchedLesson != null) {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          builder: (_) => LessonScreen(lesson: matchedLesson!),
        ),
      );
      return;
    }

    // Priority 3: Library File
    if (item.category == SearchResultCategory.libraryFile || item.targetRoute == '/library') {
      final libState = ref.read(libraryControllerProvider).valueOrNull;
      List<MaterialItemEntity> materials = libState?.allMaterials ?? [];
      if (materials.isEmpty) {
        final libRepo = ref.read(libraryRepositoryProvider);
        final res = await libRepo.getMaterials();
        res.when(success: (List<MaterialItemEntity> m) => materials = m, failure: (_) {});
      }

      MaterialItemEntity? matchedMat;
      for (final m in materials) {
        final mIdNorm = norm(m.id);
        final mTitleNorm = norm(m.title);

        if (mIdNorm == targetIdNorm ||
            mIdNorm == itemIdNorm ||
            mTitleNorm == itemTitleNorm ||
            itemTitleNorm.contains(mTitleNorm)) {
          matchedMat = m;
          break;
        }
      }

      if (matchedMat != null && context.mounted) {
        final destination = matchedMat.fileType == MaterialFileType.pdf
            ? PdfViewerScreen(material: matchedMat)
            : ImageViewerScreen(material: matchedMat);
        await Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(builder: (_) => destination),
        );
        return;
      }

      if (context.mounted) {
        context.go('/library');
      }
      return;
    }

    // Priority 4: Doctor Objection / Challenges
    if (item.category == SearchResultCategory.objection || item.targetRoute == '/challenges') {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          builder: (_) => const ChallengesScreen(initialTabIndex: 2),
        ),
      );
      return;
    }

    // Priority 5: Fallback GoRouter navigation
    final route = item.targetRoute?.trim();
    if (route != null && route.isNotEmpty && context.mounted) {
      if (route == '/learn' ||
          route == '/library' ||
          route == '/challenges' ||
          route == '/feedback') {
        context.go(route);
      } else {
        await context.push(route);
      }
    }
  }

  IconData _getCategoryIcon(SearchResultItemEntity item) {
    if (item.targetRoute == '/learn/product' ||
        item.id.startsWith('prod_') ||
        item.id.startsWith('sr_prod_')) {
      return LucideIcons.package;
    }
    switch (item.category) {
      case SearchResultCategory.lesson:
        return LucideIcons.graduationCap;
      case SearchResultCategory.libraryFile:
        return LucideIcons.fileText;
      case SearchResultCategory.objection:
        return LucideIcons.messageSquare;
    }
  }
}
