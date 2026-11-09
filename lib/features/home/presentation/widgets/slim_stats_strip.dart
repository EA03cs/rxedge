import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// Slim Stats Strip
///
/// Features:
/// - 3 key metrics: Points, Streak Days, Quizzes Completed
/// - STRICT COLOR SYSTEM COMPLIANCE: Accent amber (#D9930D) is used ONLY here for points, streaks, and gamification
/// - Hairline border, compact height
class SlimStatsStrip extends StatelessWidget {
  final RepStatsEntity stats;

  const SlimStatsStrip({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: AppCard(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: RxSpacing.s12,
          vertical: RxSpacing.s10,
        ),
        child: Row(
          children: [
            // 1. Points (Accent Amber)
            Expanded(
              child: _buildStatItem(
                context,
                icon: LucideIcons.award,
                label: l10n.statPoints(stats.points),
                sublabel: l10n.statPointsLabel,
                colors: colors,
                textTheme: textTheme,
              ),
            ),
            Container(
              width: 1.0,
              height: 28.0,
              color: colors.border,
            ),

            // 2. Streak (Accent Amber)
            Expanded(
              child: _buildStatItem(
                context,
                icon: LucideIcons.flame,
                label: l10n.statStreak(stats.streakDays),
                sublabel: l10n.statStreakLabel,
                colors: colors,
                textTheme: textTheme,
              ),
            ),
            Container(
              width: 1.0,
              height: 28.0,
              color: colors.border,
            ),

            // 3. Quizzes Completed (Accent Amber)
            Expanded(
              child: _buildStatItem(
                context,
                icon: LucideIcons.checkCircle2,
                label: l10n.statQuizzes(stats.quizzesCompleted),
                sublabel: l10n.statQuizzesLabel,
                colors: colors,
                textTheme: textTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required RxColors colors,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: colors.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.25),
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 15.0,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: RxSpacing.s8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontSize: 12.0,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sublabel,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
