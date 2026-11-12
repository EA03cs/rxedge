import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/rx_network_image.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "Continue Learning" Card
///
/// Features:
/// 1. Active state: Product name, lesson title, progress bar with module counts, and single primary "Continue" button.
/// 2. Empty state (New MR): "Start with [recommended product]", clinical rationale, and single primary "Start Lesson" button.
///
/// STRICT DESIGN RULE:
/// This card contains the ONLY filled primary button visible on the Home Screen.
class ContinueLearningCard extends StatelessWidget {
  final ContinueLearningEntity? lesson;
  final RecommendedProductEntity? recommendedProduct;

  const ContinueLearningCard({
    super.key,
    this.lesson,
    this.recommendedProduct,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: AppCard(
        child: lesson != null
            ? _buildActiveLearningState(context, colors, textTheme, l10n, lesson!)
            : _buildNewUserEmptyState(context, colors, textTheme, l10n, recommendedProduct),
      ),
    );
  }

  Widget _buildActiveLearningState(
    BuildContext context,
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
    ContinueLearningEntity item,
  ) {
    final percentage = (item.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section tag & Product Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.continueLearningTitle.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 11.0,
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: RxSpacing.s8,
                vertical: RxSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: RxRadii.borderBadge,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Text(
                item.productName,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s12),

        // Lesson Title
        Text(
          item.lessonTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -0.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: RxSpacing.s12),

        // Progress bar with module stats
        ProgressBar(
          value: item.progress,
          height: 6.0,
          label: l10n.moduleProgressCount(
            item.completedModules,
            item.totalModules,
          ),
          trailingText: '$percentage%',
        ),
        const SizedBox(height: RxSpacing.s16),

        // Single Primary Action on screen
        AppButton(
          text: l10n.btnContinue,
          variant: AppButtonVariant.primary,
          trailingIcon: context.arrowForward,
          onPressed: () => context.go(AppRoutes.learn),
        ),
      ],
    );
  }

  Widget _buildNewUserEmptyState(
    BuildContext context,
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
    RecommendedProductEntity? product,
  ) {
    final prodName = product?.productName ?? 'Cardura XL';
    final rationale =
        product?.description ?? l10n.recommendedDetailingSubtitle;
    final boxImageUrl = product?.boxImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommended badge
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: RxSpacing.s8,
                      vertical: RxSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: RxRadii.borderBadge,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2),
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Text(
                      l10n.recommendedLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s10),

                  // "Start with [Product Name]" headline
                  Text(
                    l10n.noLessonStarted(prodName),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s6),

                  // Clinical Rationale
                  Text(
                    rationale,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            if (boxImageUrl != null && boxImageUrl.trim().isNotEmpty) ...[
              const SizedBox(width: RxSpacing.s12),
              RxNetworkImage(
                imageUrl: boxImageUrl,
                width: 56,
                height: 56,
                borderRadius: RxRadii.borderBadge,
                fallbackIcon: LucideIcons.pill,
              ),
            ],
          ],
        ),
        const SizedBox(height: RxSpacing.s16),

        // Single Primary Action on screen
        AppButton(
          text: l10n.btnStartLesson,
          variant: AppButtonVariant.primary,
          trailingIcon: context.arrowForward,
          onPressed: () => context.go(AppRoutes.learn),
        ),
      ],
    );
  }
}
