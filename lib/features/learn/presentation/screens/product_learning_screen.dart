import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';
import '../controllers/learn_controller.dart';
import '../widgets/competitive_handling_view.dart';
import '../widgets/product_positioning_view.dart';
import 'lesson_screen.dart';

/// Product Learning Screen
///
/// Features:
/// - Product overview with ProgressRing & completion metrics
/// - "Lessons & Modules" drawer / bottom sheet for fast lesson access
/// - Two clear detailing tabs:
///   1. "Product Positioning" (scannable blocks: key message, doctors, benefits, dosing, proof)
///   2. "Competitive Handling" (claims, how to respond, clinical proof, copy talking point)
class ProductLearningScreen extends ConsumerWidget {
  final ProductLearningEntity product;

  const ProductLearningScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    // Reactively watch for lesson completion and updates
    final liveProduct = ref.watch(productLearningDetailProvider(product.id)) ?? product;

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(
            liveProduct.name,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.listOrdered, size: 22.0),
              tooltip: l10n.lessonModulesLabel,
              onPressed: () => _openLessonsSheet(context, liveProduct),
            ),
            const SizedBox(width: RxSpacing.s8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
              ),
              child: TabBar(
                indicatorColor: colors.primary,
                indicatorWeight: 2.5,
                labelColor: colors.primary,
                unselectedLabelColor: colors.textSecondary,
                labelStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: l10n.tabPositioning),
                  Tab(text: l10n.tabCompetitive),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Top Product Summary Strip
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: RxSpacing.s16,
                vertical: RxSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  ProgressRing(
                    value: liveProduct.progress,
                    size: 44.0,
                    strokeWidth: 3.5,
                    center: Text(
                      '${(liveProduct.progress * 100).toInt()}%',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 10.0,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liveProduct.therapeuticArea,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          l10n.lessonsCompleted(
                            liveProduct.completedLessonsCount,
                            liveProduct.totalLessonsCount,
                          ),
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openLessonsSheet(context, liveProduct),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.primary,
                      side: BorderSide(
                        color: colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: RxRadii.borderButton,
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: RxSpacing.s12,
                        vertical: RxSpacing.s6,
                      ),
                      minimumSize: const Size(0, 32.0),
                    ),
                    icon: const Icon(LucideIcons.bookOpen, size: 14.0),
                    label: Text(
                      l10n.lessonsTabLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Product Positioning
                  ProductPositioningView(positioning: liveProduct.positioning),

                  // Tab 2: Competitive Handling
                  CompetitiveHandlingView(competitors: liveProduct.competitors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLessonsSheet(BuildContext context, ProductLearningEntity product) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      backgroundColor: colors.surface,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final liveProduct = ref.watch(productLearningDetailProvider(product.id)) ?? product;

            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Padding(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.lessonModulesLabel,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              l10n.lessonsCompleted(
                                liveProduct.completedLessonsCount,
                                liveProduct.totalLessonsCount,
                              ),
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20.0),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: RxSpacing.s16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: liveProduct.lessons.length,
                        separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s8),
                        itemBuilder: (context, index) {
                          final lesson = liveProduct.lessons[index];
                          final isDone = lesson.isCompleted;

                          return AppCard(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: RxSpacing.s12,
                              vertical: RxSpacing.s8,
                            ),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context, rootNavigator: true).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => LessonScreen(lesson: lesson),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                // Interactive leading order / check badge
                                InkWell(
                                  onTap: () {
                                    if (!isDone) {
                                      ref.read(learnControllerProvider.notifier).markLessonCompleted(lesson.id);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 36.0,
                                    height: 36.0,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDone ? colors.successSoft : colors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: isDone
                                            ? colors.success.withValues(alpha: 0.3)
                                            : colors.border,
                                        width: RxShadows.hairlineBorderWidth,
                                      ),
                                    ),
                                    child: isDone
                                        ? Icon(
                                            LucideIcons.check,
                                            size: 18.0,
                                            color: colors.success,
                                          )
                                        : Text(
                                            '${lesson.order}',
                                            style: textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: RxSpacing.s12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson.title,
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        '${lesson.durationMinutes} min read',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.textTertiary,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: RxSpacing.s8),
                                // Quick completion pill or chevron
                                if (!isDone)
                                  InkWell(
                                    onTap: () {
                                      ref.read(learnControllerProvider.notifier).markLessonCompleted(lesson.id);
                                    },
                                    borderRadius: RxRadii.borderBadge,
                                    child: Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: RxSpacing.s8,
                                        vertical: RxSpacing.s4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.primarySoft,
                                        borderRadius: RxRadii.borderBadge,
                                        border: Border.all(
                                          color: colors.primary.withValues(alpha: 0.25),
                                          width: RxShadows.hairlineBorderWidth,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.check,
                                            size: 12.0,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: RxSpacing.s4),
                                          Text(
                                            l10n.markAsComplete,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  StatusBadge(
                                    label: l10n.completedBadge,
                                    variant: StatusBadgeVariant.success,
                                    showDot: true,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
