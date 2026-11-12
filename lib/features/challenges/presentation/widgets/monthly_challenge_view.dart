import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';

/// Monthly Challenge View
///
/// Features:
/// - Title and countdown deadline badge
/// - Challenge rules in max 3 lines
/// - Personal milestone progress indicator
/// - Territory leaderboard (Top 10 + pinned "my rank" card)
/// - Rewards section with restrained accent amber
/// - Professional aesthetic: strictly flat, no confetti, calm whitespace
class MonthlyChallengeView extends StatelessWidget {
  final MonthlyChallengeEntity challenge;

  const MonthlyChallengeView({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview & Rules Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: l10n.activeSprintBadge,
                      variant: StatusBadgeVariant.info,
                      showDot: true,
                    ),
                    StatusBadge(
                      label: l10n.timeLeftCountdown(
                        challenge.daysLeft,
                        challenge.hoursLeft,
                      ),
                      variant: StatusBadgeVariant.neutral,
                      icon: LucideIcons.clock4,
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s12),
                Text(
                  challenge.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: RxSpacing.s12),

                // Rules Block (Max 3 lines)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: RxRadii.borderCard,
                    border: Border.all(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.fileText, size: 14.0, color: colors.textSecondary),
                          const SizedBox(width: RxSpacing.s6),
                          Text(
                            l10n.rulesTitle,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RxSpacing.s8),
                      ...challenge.rules.take(3).map((rule) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.textPrimary,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: RxSpacing.s16),

                // My Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.myProgressTitle,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${challenge.completedMilestones}/${challenge.totalMilestones}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s8),
                ProgressBar(
                  value: challenge.currentProgress,
                  height: 6.0,
                  color: colors.primary,
                ),
                const SizedBox(height: RxSpacing.s16),

                // Rewards Section
                Divider(
                  height: 1.0,
                  thickness: RxShadows.hairlineBorderWidth,
                  color: colors.border,
                ),
                const SizedBox(height: RxSpacing.s12),
                Row(
                  children: [
                    Icon(LucideIcons.award, size: 15.0, color: colors.accent),
                    const SizedBox(width: RxSpacing.s6),
                    Text(
                      l10n.rewardsTitle,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s8),
                Wrap(
                  spacing: RxSpacing.s8,
                  runSpacing: RxSpacing.s6,
                  children: challenge.rewards.map((reward) {
                    final isPoints = reward.contains('Points') || reward.contains('Pts');
                    return StatusBadge(
                      label: reward,
                      variant: isPoints ? StatusBadgeVariant.accent : StatusBadgeVariant.neutral,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 2. Territory Leaderboard Header & Pinned My Rank Card
          Text(
            l10n.leaderboardTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: RxSpacing.s4),
          Text(
            l10n.leaderboardUpdateCaption,
            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: RxSpacing.s12),

          // Pinned "My Rank" Highlight Strip
          Builder(
            builder: (context) {
              final currentEntry = challenge.leaderboard
                  .where((e) => e.isCurrentUser)
                  .firstOrNull;
              final userPoints =
                  currentEntry?.points ?? challenge.completedMilestones;
              return Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.0,
                      height: 32.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        challenge.userRank > 0 ? '#${challenge.userRank}' : '-',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.pinnedMyRank,
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s6),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 6.0,
                                  vertical: 1.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  l10n.youLabel,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            challenge.totalParticipants > 0
                                ? l10n.rankOfTotalDistrict(
                                    challenge.userRank,
                                    challenge.totalParticipants,
                                  )
                                : l10n.statPoints(userPoints),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: l10n.statPoints(userPoints),
                      variant: StatusBadgeVariant.accent,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: RxSpacing.s12),

          // Leaderboard List (Top 10)
          AppCard(
            padding: EdgeInsetsDirectional.zero,
            child: Column(
              children: challenge.leaderboard.asMap().entries.map((entry) {
                final index = entry.key;
                final rep = entry.value;
                final isLast = index == challenge.leaderboard.length - 1;

                return Column(
                  children: [
                    Container(
                      color: rep.isCurrentUser ? colors.primarySoft.withValues(alpha: 0.35) : Colors.transparent,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: RxSpacing.s16,
                        vertical: RxSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          // Rank badge
                          _buildRankIndicator(context, rep.rank),
                          const SizedBox(width: RxSpacing.s12),

                          // Rep details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        rep.repName,
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: rep.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (rep.isCurrentUser) ...[
                                      const SizedBox(width: RxSpacing.s6),
                                      StatusBadge(
                                        label: l10n.youLabel,
                                        variant: StatusBadgeVariant.info,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  rep.territory,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 12.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: RxSpacing.s8),

                          // Points (Restrained amber accent)
                          StatusBadge(
                            label: l10n.statPoints(rep.points),
                            variant: rep.rank <= 3 ? StatusBadgeVariant.accent : StatusBadgeVariant.neutral,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1.0,
                        thickness: RxShadows.hairlineBorderWidth,
                        color: colors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RxSpacing.s24),
        ],
      ),
    );
  }

  Widget _buildRankIndicator(BuildContext context, int rank) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    Color bg;
    Color fg;
    Border? border;

    switch (rank) {
      case 1:
        bg = colors.accentSoft;
        fg = colors.accent;
        border = Border.all(color: colors.accent.withValues(alpha: 0.4), width: 1.0);
        break;
      case 2:
        bg = colors.surfaceMuted;
        fg = colors.textPrimary;
        border = Border.all(color: colors.border, width: 1.0);
        break;
      case 3:
        bg = colors.surfaceMuted;
        fg = colors.textSecondary;
        border = Border.all(color: colors.border, width: 1.0);
        break;
      default:
        bg = Colors.transparent;
        fg = colors.textTertiary;
        border = null;
    }

    return Container(
      width: 28.0,
      height: 28.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
        border: border,
      ),
      child: Text(
        '$rank',
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
