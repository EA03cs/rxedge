import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/challenges_controller.dart';
import '../widgets/challenges_skeleton_loader.dart';
import '../widgets/monthly_challenge_view.dart';
import '../widgets/objection_of_month_view.dart';
import '../widgets/quick_quizzes_view.dart';
import 'history_screen.dart';

/// Field Challenges Tab
///
/// Features:
/// - 3 clear sections via segmented control:
///   1. Monthly Challenge (deadline, rules, my progress, leaderboard with pinned rank, rewards)
///   2. Quick Quizzes (pharmacology recall quizzes, immediate launch)
///   3. Objection of the Month ("Think First" pause, revealed response, feedback, share response)
/// - Top action: History of past challenges & quiz scores
/// - Restrained professional gamification (amber accent strictly for points & milestone badges)
/// - Skeletons, error retry, pull-to-refresh
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final challengesAsync = ref.watch(challengesControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.challengesTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.history, size: 20.0),
            tooltip: l10n.btnHistory,
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: challengesAsync.when(
        loading: () => const ChallengesSkeletonLoader(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
            child: ErrorState(
              title: l10n.errorStateTitle,
              description: err.toString().replaceAll('Exception: ', ''),
              retryText: l10n.errorStateRetry,
              onRetry: () => ref.read(challengesControllerProvider.notifier).refresh(),
            ),
          ),
        ),
        data: (state) {
          final selectedTab = state.selectedTabIndex;

          return RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surface,
            onRefresh: () => ref.read(challengesControllerProvider.notifier).refresh(),
            child: Column(
              children: [
                // Top 3-Section Segmented Control
                Container(
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: RxRadii.borderButton,
                      border: Border.all(
                        color: colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        _SegmentTab(
                          label: l10n.tabMonthlyChallenge,
                          isSelected: selectedTab == 0,
                          onTap: () => ref
                              .read(challengesControllerProvider.notifier)
                              .setTabIndex(0),
                        ),
                        _SegmentTab(
                          label: l10n.tabQuickQuizzes,
                          isSelected: selectedTab == 1,
                          onTap: () => ref
                              .read(challengesControllerProvider.notifier)
                              .setTabIndex(1),
                        ),
                        _SegmentTab(
                          label: l10n.tabObjection,
                          isSelected: selectedTab == 2,
                          onTap: () => ref
                              .read(challengesControllerProvider.notifier)
                              .setTabIndex(2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Tab Content
                Expanded(
                  child: IndexedStack(
                    index: selectedTab,
                    children: [
                      MonthlyChallengeView(challenge: state.monthlyChallenge),
                      QuickQuizzesView(quizzes: state.quizzes),
                      ObjectionOfMonthView(objection: state.objection),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsetsDirectional.symmetric(vertical: RxSpacing.s10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: isSelected
                ? Border.all(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.textPrimary : colors.textSecondary,
              fontSize: 12.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
