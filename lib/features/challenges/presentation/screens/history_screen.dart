import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/challenges_controller.dart';

/// History Screen for Past Challenges and Quiz Results
///
/// Features:
/// - Tabbed view: Past Challenges & Quiz Results
/// - Full async state handling: loading skeleton, empty states, error with retry
/// - Professional gamification logs: points earned, ranks, completion timestamps
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(
            l10n.historyTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
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
                tabs: [
                  Tab(text: l10n.pastChallenges),
                  Tab(text: l10n.quizResultsHistory),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _PastChallengesTab(),
            _QuizResultsTab(),
          ],
        ),
      ),
    );
  }
}

class _PastChallengesTab extends ConsumerWidget {
  const _PastChallengesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final pastAsync = ref.watch(pastChallengesHistoryProvider);

    return pastAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: ErrorState(
          title: l10n.errorStateTitle,
          description: err.toString().replaceAll('Exception: ', ''),
          retryText: l10n.errorStateRetry,
          onRetry: () => ref.invalidate(pastChallengesHistoryProvider),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: EmptyState(
              icon: LucideIcons.calendar,
              title: l10n.emptyHistoryTitle,
              description: l10n.emptyHistoryDesc,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s12),
          itemBuilder: (context, index) {
            final item = list[index];

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.completedAt.year}-${_twoDigits(item.completedAt.month)}',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      StatusBadge(
                        label: '+${item.pointsEarned} Pts',
                        variant: StatusBadgeVariant.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Text(
                    item.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Row(
                    children: [
                      StatusBadge(
                        label: 'Rank #${item.finalRank} of ${item.totalParticipants}',
                        variant: item.finalRank <= 3 ? StatusBadgeVariant.info : StatusBadgeVariant.neutral,
                      ),
                      if (item.badgeEarned != null) ...[
                        const SizedBox(width: RxSpacing.s8),
                        Expanded(
                          child: Text(
                            item.badgeEarned!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
}

class _QuizResultsTab extends ConsumerWidget {
  const _QuizResultsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final resultsAsync = ref.watch(quizResultsHistoryProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: ErrorState(
          title: l10n.errorStateTitle,
          description: err.toString().replaceAll('Exception: ', ''),
          retryText: l10n.errorStateRetry,
          onRetry: () => ref.invalidate(quizResultsHistoryProvider),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: EmptyState(
              icon: LucideIcons.helpCircle,
              title: l10n.emptyHistoryTitle,
              description: l10n.emptyHistoryDesc,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s12),
          itemBuilder: (context, index) {
            final res = list[index];

            return AppCard(
              child: Row(
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: res.isHighScore ? colors.successSoft : colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '${(res.percentage * 100).toInt()}%',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: res.isHighScore ? colors.success : colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.quizTitle,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${res.score}/${res.totalQuestions} Correct • ${res.timeTakenSeconds}s',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s8),
                  StatusBadge(
                    label: '+${res.pointsEarned} Pts',
                    variant: StatusBadgeVariant.accent,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
