import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/rx_network_image.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';
import '../controllers/learn_controller.dart';
import '../widgets/learn_skeleton_loader.dart';
import 'bookmarks_screen.dart';
import 'product_learning_screen.dart';

/// Smart Learning Hub (Learn Tab)
///
/// Features:
/// - Product cards with ProgressRing, therapeutic area, completed counts
/// - Priority sorting: Recommended and In-Progress products sorted first
/// - Direct access to Bookmarks screen
/// - Full async state handling: skeleton loader, empty state, error retry, pull-to-refresh
/// - Strictly flat, 1px hairline borders, calm whitespace
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final learnAsync = ref.watch(learnControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.learnTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bookmark, size: 22.0),
            tooltip: l10n.btnBookmarks,
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const BookmarksScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: learnAsync.when(
        loading: () => const LearnSkeletonLoader(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
            child: ErrorState(
              title: l10n.errorStateTitle,
              description: err.toString().replaceAll('Exception: ', ''),
              retryText: l10n.errorStateRetry,
              onRetry: () => ref.read(learnControllerProvider.notifier).refresh(),
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: EmptyState(
                icon: LucideIcons.graduationCap,
                title: l10n.noLearningModulesTitle,
                description: l10n.noLearningModulesDesc,
                actionText: l10n.retry,
                onAction: () => ref.read(learnControllerProvider.notifier).refresh(),
              ),
            );
          }

          return RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surface,
            onRefresh: () => ref.read(learnControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
              children: [
                // Top Subtitle & Quick Metric
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.learnSubtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    _BookmarksPillButton(
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => const BookmarksScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s16),

                // Product Cards List
                ...products.map((product) => _ProductCard(product: product)),
                const SizedBox(height: RxSpacing.s24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookmarksPillButton extends ConsumerWidget {
  final VoidCallback onTap;

  const _BookmarksPillButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final bookmarks = ref.watch(bookmarkedLessonsProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.0),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: RxSpacing.s12,
          vertical: RxSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.bookmark, size: 13.0, color: colors.textSecondary),
            const SizedBox(width: RxSpacing.s6),
            Text(
              l10n.bookmarksLabel,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            if (bookmarks.isNotEmpty) ...[
              const SizedBox(width: RxSpacing.s6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(999.0),
                ),
                child: Text(
                  '${bookmarks.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductLearningEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
      child: AppCard(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ProductLearningScreen(product: product),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (product.boxImageUrl != null &&
                product.boxImageUrl!.trim().isNotEmpty) ...[
              RxNetworkImage(
                imageUrl: product.boxImageUrl,
                width: 52,
                height: 52,
                borderRadius: RxRadii.borderBadge,
                fallbackIcon: LucideIcons.pill,
              ),
              const SizedBox(width: RxSpacing.s12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      if (product.isRecommended) ...[
                        StatusBadge(
                          label: l10n.recommendedTag,
                          variant: StatusBadgeVariant.info,
                        ),
                        const SizedBox(width: RxSpacing.s6),
                      ],
                      if (product.isInProgress) ...[
                        StatusBadge(
                          label: l10n.inProgressTag,
                          variant: StatusBadgeVariant.neutral,
                        ),
                      ] else if (product.isCompleted) ...[
                        StatusBadge(
                          label: l10n.completedBadge,
                          variant: StatusBadgeVariant.success,
                          showDot: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s8),

                  // Product Name
                  Text(
                    product.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Therapeutic Area
                  Text(
                    product.therapeuticArea,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s8),

                  // Lessons Completed
                  Text(
                    l10n.lessonsCompleted(
                      product.completedLessonsCount,
                      product.totalLessonsCount,
                    ),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s16),

            // ProgressRing
            ProgressRing(
              value: product.progress,
              size: 52.0,
              strokeWidth: 4.0,
              center: Text(
                '${(product.progress * 100).toInt()}%',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.0,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
