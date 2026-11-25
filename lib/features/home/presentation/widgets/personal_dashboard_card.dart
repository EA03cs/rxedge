import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// Compact Personal Dashboard Card on Home
///
/// Surfaces individual progress, accumulated Challenge Marks (credits earned),
/// monthly Rep Voice submissions, and Quarterly Badges without extra primary CTAs.
class PersonalDashboardCard extends StatelessWidget {
  final RepStatsEntity stats;

  const PersonalDashboardCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final hasLessons = stats.totalLessons > 0;
    final lessonProgress = hasLessons
        ? (stats.completedLessons / stats.totalLessons).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: RxRadii.borderBadge,
                  ),
                  child: Icon(
                    LucideIcons.barChart3,
                    size: 16.0,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: RxSpacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Dashboard',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Credits earned, monthly activity & quarterly badges',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: RxRadii.borderBadge,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RxSpacing.s6,
                      vertical: RxSpacing.s4,
                    ),
                    child: Text(
                      'Profile',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RxSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: LucideIcons.award,
                    iconColor: const Color(0xFFD97706),
                    value: '${stats.challengeMarks} Marks',
                    label: 'Credits Earned',
                  ),
                ),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: _MetricTile(
                    icon: LucideIcons.messageSquarePlus,
                    iconColor: colors.primary,
                    value: '${stats.monthlySubmissions} Logs',
                    label: 'Monthly Voice',
                  ),
                ),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: _MetricTile(
                    icon: LucideIcons.medal,
                    iconColor: const Color(0xFF059669),
                    value: '${stats.quarterlyBadges.length} Badges',
                    label: 'Quarterly',
                  ),
                ),
              ],
            ),
            if (hasLessons) ...[
              const SizedBox(height: RxSpacing.s12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Individual Module Progress',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${stats.completedLessons}/${stats.totalLessons} modules',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: lessonProgress,
                  minHeight: 6.0,
                  backgroundColor: colors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ],
            const SizedBox(height: RxSpacing.s12),
            const Divider(height: 1.0),
            const SizedBox(height: RxSpacing.s10),
            if (stats.quarterlyBadges.isNotEmpty)
              Wrap(
                spacing: RxSpacing.s8,
                runSpacing: RxSpacing.s6,
                children: stats.quarterlyBadges.map((badge) {
                  final quarterSuffix = badge.quarter != null && badge.year != null
                      ? ' (Q${badge.quarter} ${badge.year})'
                      : '';
                  return StatusBadge(
                    label: '${badge.title}$quarterSuffix',
                    variant: StatusBadgeVariant.accent,
                    icon: LucideIcons.award,
                  );
                }).toList(),
              )
            else
              Row(
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    size: 14.0,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: RxSpacing.s6),
                  Expanded(
                    child: Text(
                      'Quarterly achievement badges appear here as earned.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RxSpacing.s8,
        vertical: RxSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: RxRadii.borderInput,
        border: Border.all(
          color: colors.border,
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.0, color: iconColor),
          const SizedBox(height: RxSpacing.s6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
