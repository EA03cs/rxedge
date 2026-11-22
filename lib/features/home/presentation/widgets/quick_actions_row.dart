import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../challenges/presentation/screens/challenges_screen.dart';
import '../../../feedback/presentation/screens/feedback_screen.dart';
import '../../../learn/presentation/screens/learn_screen.dart';
import '../../../library/presentation/screens/library_screen.dart';

/// 4 Core Portfolio Modules Grid (2x2)
///
/// Features:
/// 1. Product Navigator -> Learn Tab (Clinical & Product Science)
/// 2. Marketing Hub -> Library Tab (Visual Aids & Brochures)
/// 3. Eye-Know Challenges -> Challenges Tab (Quizzes & Leaderboards)
/// 4. Rep Voice -> Feedback Tab (Field Intelligence & Objections)
///
/// Strictly flat, hairline border, balanced brand accents (Blue, Mentholatum Red, Amber).
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final actions = [
      _QuickActionItem(
        icon: LucideIcons.bookOpen,
        title: l10n.moduleProductNavigator,
        subtitle: l10n.moduleProductNavigatorSub,
        iconColor: colors.primary,
        iconBgColor: colors.primarySoft,
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const LearnScreen(),
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.presentation,
        title: l10n.moduleMarketingHub,
        subtitle: l10n.moduleMarketingHubSub,
        iconColor: colors.brandRed,
        iconBgColor: colors.brandRedSoft,
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const LibraryScreen(),
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.target,
        title: l10n.moduleEyeKnowChallenges,
        subtitle: l10n.moduleEyeKnowChallengesSub,
        iconColor: colors.accent,
        iconBgColor: colors.accentSoft,
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const ChallengesScreen(initialTabIndex: 0),
            ),
          );
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.messageSquare,
        title: l10n.moduleRepVoice,
        subtitle: l10n.moduleRepVoiceSub,
        iconColor: colors.info,
        iconBgColor: colors.infoSoft,
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const FeedbackScreen(),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _buildCard(context, actions[0], colors, textTheme)),
              const SizedBox(width: RxSpacing.s10),
              Expanded(child: _buildCard(context, actions[1], colors, textTheme)),
            ],
          ),
          const SizedBox(height: RxSpacing.s10),
          Row(
            children: [
              Expanded(child: _buildCard(context, actions[2], colors, textTheme)),
              const SizedBox(width: RxSpacing.s10),
              Expanded(child: _buildCard(context, actions[3], colors, textTheme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    _QuickActionItem item,
    RxColors colors,
    TextTheme textTheme,
  ) {
    return Semantics(
      button: true,
      label: '${item.title}, ${item.subtitle}',
      child: Material(
        color: colors.surface,
        borderRadius: RxRadii.borderCard,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: RxRadii.borderCard,
          splashColor: item.iconBgColor.withValues(alpha: 0.5),
          highlightColor: item.iconBgColor.withValues(alpha: 0.2),
          child: Container(
            constraints: const BoxConstraints(minHeight: 82.0),
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            decoration: BoxDecoration(
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(RxSpacing.s8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        size: 17.0,
                        color: item.iconColor,
                      ),
                    ),
                    Icon(
                      context.chevronForward,
                      size: 14.0,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s8),
                Text(
                  item.title,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RxSpacing.s2),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });
}
