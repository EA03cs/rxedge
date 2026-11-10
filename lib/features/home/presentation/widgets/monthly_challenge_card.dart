import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "This Month's Challenge" Card
///
/// Features:
/// - 12dp radius surface card with 1px hairline border
/// - Days left pill
/// - Progress bar
/// - District rank indicator
/// - Entire card is tappable and opens the Challenges tab
class MonthlyChallengeCard extends StatelessWidget {
  final MonthlyChallengeEntity challenge;

  const MonthlyChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final percentage = (challenge.progress * 100).toInt();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: AppCard(
        onTap: () => context.go(AppRoutes.challenges),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: Section title & Days Left pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.target,
                      size: 16.0,
                      color: colors.primary,
                    ),
                    const SizedBox(width: RxSpacing.s6),
                    Text(
                      l10n.monthlyChallengeTitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                StatusBadge(
                  label: l10n.daysLeft(challenge.daysLeft),
                  variant: StatusBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: RxSpacing.s10),

            // Challenge Title
            Text(
              challenge.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: RxSpacing.s10),

            // Progress Bar
            ProgressBar(
              value: challenge.progress,
              height: 6.0,
              trailingText: '$percentage%',
            ),
            const SizedBox(height: RxSpacing.s12),

            // District Rank & chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rankInDistrict(challenge.currentRank, challenge.totalParticipants),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                Icon(
                  context.chevronForward,
                  size: 16.0,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
