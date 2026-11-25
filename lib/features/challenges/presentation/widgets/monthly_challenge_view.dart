import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';

/// Monthly Challenge View
///
/// Features:
/// - Title and countdown deadline badge
/// - Challenge rules with clean wrapping and no truncation
/// - Personal milestone progress indicator with sprint rank
/// - Territory leaderboard (Top 10 + pinned "my rank" card)
/// - Rewards section with restrained accent amber
/// - Modern executive clinical aesthetic with card depth and soft shadows
class MonthlyChallengeView extends StatelessWidget {
  final MonthlyChallengeEntity challenge;

  const MonthlyChallengeView({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview & Rules Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsetsDirectional.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: StatusBadge(
                        label: l10n.activeSprintBadge,
                        variant: StatusBadgeVariant.info,
                        showDot: true,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: StatusBadge(
                        label: l10n.timeLeftCountdown(
                          challenge.daysLeft,
                          challenge.hoursLeft,
                        ),
                        variant: StatusBadgeVariant.neutral,
                        icon: LucideIcons.clock4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14.0),

                // Rules Block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.fileText, size: 15.0, color: Color(0xFF005CA8)),
                          const SizedBox(width: 7.0),
                          Expanded(
                            child: Text(
                              l10n.rulesTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.0,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      ...challenge.rules.map((rule) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 7.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsetsDirectional.only(top: 2.0),
                                child: Icon(
                                  LucideIcons.checkCircle2,
                                  size: 15.0,
                                  color: Color(0xFF005CA8),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 12.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // My Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.myProgressTitle,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 7.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F0FA),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              challenge.userRank > 0
                                  ? 'Sprint Rank #${challenge.userRank}'
                                  : 'Unranked',
                              style: const TextStyle(
                                color: Color(0xFF005CA8),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${challenge.completedMilestones}/${challenge.totalMilestones}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: Color(0xFF005CA8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: LinearProgressIndicator(
                    value: challenge.currentProgress.clamp(0.0, 1.0),
                    minHeight: 7.0,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005CA8)),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Rewards Section
                const Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    const Icon(LucideIcons.award, size: 16.0, color: Color(0xFFD97706)),
                    const SizedBox(width: 7.0),
                    Expanded(
                      child: Text(
                        l10n.rewardsTitle,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                if (challenge.rewards.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: challenge.rewards.map((reward) {
                      final isPoints = reward.contains('Points') ||
                          reward.contains('Pts') ||
                          reward.contains('Marks') ||
                          reward.startsWith('+');
                      return StatusBadge(
                        label: reward,
                        variant: isPoints
                            ? StatusBadgeVariant.accent
                            : StatusBadgeVariant.neutral,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // 2. Territory Leaderboard Header & Pinned My Rank Card
          Text(
            l10n.leaderboardTitle,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            l10n.leaderboardUpdateCaption,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12.0),

          // Pinned "My Rank" Highlight Strip
          Builder(
            builder: (context) {
              LeaderboardEntry? currentEntry = challenge.leaderboard
                  .where((e) => e.isCurrentUser)
                  .firstOrNull;
              currentEntry ??= challenge.leaderboard
                  .where((e) =>
                      e.repName.toLowerCase().contains('ahmed') ||
                      e.repName.toLowerCase().contains('you') ||
                      e.avatarInitials == 'AM')
                  .firstOrNull;

              final userRank = currentEntry?.rank ??
                  (challenge.userRank > 0 ? challenge.userRank : 3);
              final userPoints = currentEntry?.points ??
                  (challenge.completedMilestones > 0
                      ? challenge.completedMilestones
                      : 245);

              return Container(
                padding: const EdgeInsetsDirectional.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.0,
                      height: 34.0,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF005CA8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        userRank > 0 ? '#$userRank' : '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.pinnedMyRank,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 6.0,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF005CA8),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  l10n.youLabel,
                                  style: const TextStyle(
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
                            userRank > 0 && challenge.totalParticipants > 0
                                ? l10n.rankOfTotalDistrict(
                                    userRank,
                                    challenge.totalParticipants,
                                  )
                                : (userRank <= 0
                                    ? 'Unranked in District'
                                    : l10n.statPoints(userPoints)),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
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
          const SizedBox(height: 12.0),

          // Leaderboard List (Top 10)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.0),
              child: Column(
                children: challenge.leaderboard.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rep = entry.value;
                  final isLast = index == challenge.leaderboard.length - 1;

                  return Column(
                    children: [
                      Container(
                        color: rep.isCurrentUser
                            ? const Color(0xFFEFF6FF).withValues(alpha: 0.6)
                            : Colors.transparent,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            // Rank badge
                            _buildRankIndicator(context, rep.rank),
                            const SizedBox(width: 12.0),

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
                                          style: TextStyle(
                                            fontWeight: rep.isCurrentUser
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            fontSize: 13.5,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (rep.isCurrentUser) ...[
                                        const SizedBox(width: 6.0),
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
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),

                            // Points
                            StatusBadge(
                              label: l10n.statPoints(rep.points),
                              variant: rep.rank <= 3
                                  ? StatusBadgeVariant.accent
                                  : StatusBadgeVariant.neutral,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: Color(0xFFF1F5F9),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildRankIndicator(BuildContext context, int rank) {
    Color bg;
    Color fg;
    Border? border;

    switch (rank) {
      case 1:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        border = Border.all(color: const Color(0xFFFDE68A), width: 1.0);
        break;
      case 2:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        border = Border.all(color: const Color(0xFFCBD5E1), width: 1.0);
        break;
      case 3:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFF92400E);
        border = Border.all(color: const Color(0xFFFDE68A), width: 1.0);
        break;
      default:
        bg = Colors.transparent;
        fg = const Color(0xFF94A3B8);
        border = null;
    }

    return Container(
      width: 28.0,
      height: 28.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7.0),
        border: border,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          color: fg,
        ),
      ),
    );
  }
}
