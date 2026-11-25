import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/repositories/challenges_repository_impl.dart';
import '../../domain/entities/challenges_entities.dart';
import '../screens/quick_quiz_screen.dart';

/// Quick Quizzes View
///
/// Features:
/// - Filter chips: All, Available (+Marks), Completed (Review)
/// - List of clinical knowledge reinforcement quizzes
/// - Clear metadata: question count, time estimate, reward marks
/// - Completion status and previous score preview
/// - Direct one-tap launch of Quick Quiz flow + Review Answers for completed quizzes
class QuickQuizzesView extends ConsumerStatefulWidget {
  final List<QuickQuizEntity> quizzes;

  const QuickQuizzesView({
    super.key,
    required this.quizzes,
  });

  @override
  ConsumerState<QuickQuizzesView> createState() => _QuickQuizzesViewState();
}

class _QuickQuizzesViewState extends ConsumerState<QuickQuizzesView> {
  int _filterIndex = 0; // 0 = all, 1 = available, 2 = completed
  String? _loadingReviewQuizId;

  Future<void> _openQuizReview(QuickQuizEntity quiz) async {
    if (_loadingReviewQuizId != null) return;
    setState(() => _loadingReviewQuizId = quiz.id);
    try {
      final repo = ref.read(challengesRepositoryProvider);
      final reviewRes = await repo.getQuizAttemptReview(quiz.id);
      if (!mounted) return;
      reviewRes.when(
        success: (review) {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => QuickQuizScreen(
                quiz: quiz,
                initialReviewResult: review,
              ),
            ),
          );
        },
        failure: (f) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(f.debugMessage ?? 'Unable to load quiz review.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _loadingReviewQuizId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    if (widget.quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
          child: EmptyState(
            icon: LucideIcons.helpCircle,
            title: l10n.noQuizzesTitle,
            description: l10n.noQuizzesDesc,
          ),
        ),
      );
    }

    final totalCount = widget.quizzes.length;
    final availableCount = widget.quizzes.where((q) => !q.isCompleted).length;
    final completedCount = widget.quizzes.where((q) => q.isCompleted).length;

    final filteredQuizzes = widget.quizzes.where((q) {
      if (_filterIndex == 1) return !q.isCompleted;
      if (_filterIndex == 2) return q.isCompleted;
      return true;
    }).toList();

    return Column(
      children: [
        // Horizontal Filter Chips
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(
            RxSpacing.s16,
            RxSpacing.s12,
            RxSpacing.s16,
            RxSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: 'All',
                  isSelected: _filterIndex == 0,
                  trailing: _CountBadge(
                    count: totalCount,
                    isSelected: _filterIndex == 0,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _filterIndex = 0);
                  },
                ),
                const SizedBox(width: RxSpacing.s8),
                AppChip(
                  label: 'Available (+Marks)',
                  isSelected: _filterIndex == 1,
                  trailing: _CountBadge(
                    count: availableCount,
                    isSelected: _filterIndex == 1,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _filterIndex = 1);
                  },
                ),
                const SizedBox(width: RxSpacing.s8),
                AppChip(
                  label: 'Completed',
                  isSelected: _filterIndex == 2,
                  trailing: _CountBadge(
                    count: completedCount,
                    isSelected: _filterIndex == 2,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _filterIndex = 2);
                  },
                ),
              ],
            ),
          ),
        ),

        // Quizzes List or Filter Empty State
        Expanded(
          child: filteredQuizzes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                    child: EmptyState(
                      icon: _filterIndex == 2
                          ? LucideIcons.award
                          : LucideIcons.checkCircle2,
                      title: _filterIndex == 2
                          ? 'No completed quizzes yet'
                          : 'All quizzes completed!',
                      description: _filterIndex == 2
                          ? 'Take quick quizzes to earn Challenge Marks and reinforce clinical detailing.'
                          : 'Great job! Switch to "Completed" to view your completed quizzes.',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                  itemCount: filteredQuizzes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: RxSpacing.s12),
                  itemBuilder: (context, index) {
                    final quiz = filteredQuizzes[index];
                    final isDone = quiz.isCompleted;
                    final isClosed = quiz.isClosed;
                    final isUpcoming = quiz.isUpcoming;
                    final canStart = !isDone && !isClosed && !isUpcoming;

                    return AppCard(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isDone) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This quiz has already been attempted. Retakes are not permitted per challenge policy.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (isClosed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.quizWindowClosedError),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (isUpcoming) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.quizNotStartedError),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          Navigator.of(context, rootNavigator: true).push<void>(
                            MaterialPageRoute(
                              builder: (_) => QuickQuizScreen(quiz: quiz),
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top meta: Category + Availability + Marks
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: RxSpacing.s6,
                                  runSpacing: RxSpacing.s6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                        horizontal: RxSpacing.s8,
                                        vertical: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        quiz.category,
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (isClosed)
                                      StatusBadge(
                                        label: l10n.quizClosed,
                                        variant: StatusBadgeVariant.neutral,
                                      )
                                    else if (isUpcoming &&
                                        quiz.startDate != null)
                                      StatusBadge(
                                        label: l10n.quizOpensOn(
                                            '${quiz.startDate!.day}/${quiz.startDate!.month}'),
                                        variant: StatusBadgeVariant.neutral,
                                      )
                                    else if (quiz.endDate != null ||
                                        (quiz.completionWindowDays != null &&
                                            quiz.completionWindowDays! > 0))
                                      StatusBadge(
                                        label: quiz.daysUntilClose > 0
                                            ? l10n.quizClosesInDays(
                                                quiz.daysUntilClose)
                                            : l10n.quizClosesToday,
                                        variant: StatusBadgeVariant.warning,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s8),
                              StatusBadge(
                                label: isDone
                                    ? 'Marks Claimed'
                                    : l10n.pointsPlusValue(quiz.rewardPoints),
                                variant: isDone
                                    ? StatusBadgeVariant.neutral
                                    : StatusBadgeVariant.accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: RxSpacing.s10),

                          // Title
                          Text(
                            quiz.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s10),

                          // Duration & Question Count
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: RxSpacing.s12,
                                  runSpacing: RxSpacing.s4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.helpCircle,
                                            size: 14.0,
                                            color: colors.textSecondary),
                                        const SizedBox(width: RxSpacing.s4),
                                        Flexible(
                                          child: Text(
                                            l10n.questionsCountLabel(
                                                quiz.displayQuestionCount),
                                            style: textTheme.bodySmall?.copyWith(
                                                color: colors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.clock4,
                                            size: 14.0,
                                            color: colors.textSecondary),
                                        const SizedBox(width: RxSpacing.s4),
                                        Flexible(
                                          child: Text(
                                            l10n.minutesCountLabel(
                                                quiz.durationMinutes),
                                            style: textTheme.bodySmall?.copyWith(
                                                color: colors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isDone) ...[
                                const SizedBox(width: RxSpacing.s8),
                                StatusBadge(
                                  label: quiz.lastScore != null &&
                                          quiz.lastMaxScore != null
                                      ? l10n.scoreOutOfLabel(
                                          quiz.lastScore!, quiz.lastMaxScore!)
                                      : l10n.completedBadge,
                                  variant: StatusBadgeVariant.success,
                                  showDot: true,
                                ),
                              ],
                            ],
                          ),
                          if (isDone) ...[
                            const SizedBox(height: RxSpacing.s8),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.shieldCheck,
                                  size: 13.0,
                                  color: colors.success,
                                ),
                                const SizedBox(width: RxSpacing.s4),
                                Expanded(
                                  child: Text(
                                    'Challenge policy: exactly one attempt permitted per participant, no retakes.',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.textSecondary,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: RxSpacing.s12),

                          // Action button
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Wrap(
                              spacing: RxSpacing.s8,
                              runSpacing: RxSpacing.s8,
                              alignment: WrapAlignment.end,
                              children: [
                                if (isDone)
                                  OutlinedButton.icon(
                                    onPressed: _loadingReviewQuizId == quiz.id
                                        ? null
                                        : () {
                                            HapticFeedback.selectionClick();
                                            _openQuizReview(quiz);
                                          },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: colors.primarySoft,
                                      foregroundColor: colors.primary,
                                      side: BorderSide(
                                        color: colors.primary.withValues(alpha: 0.35),
                                        width: RxShadows.hairlineBorderWidth,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: RxRadii.borderButton,
                                      ),
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: RxSpacing.s12,
                                        vertical: RxSpacing.s8,
                                      ),
                                      minimumSize: const Size(0, 36.0),
                                    ),
                                    icon: _loadingReviewQuizId == quiz.id
                                        ? SizedBox(
                                            width: 14.0,
                                            height: 14.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              color: colors.primary,
                                            ),
                                          )
                                        : const Icon(LucideIcons.fileSearch, size: 14.0),
                                    label: Text(
                                      'Review Answers',
                                      style: textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                OutlinedButton.icon(
                                onPressed: canStart
                                    ? () {
                                        HapticFeedback.selectionClick();
                                        Navigator.of(context, rootNavigator: true)
                                            .push<void>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                QuickQuizScreen(quiz: quiz),
                                          ),
                                        );
                                      }
                                    : isDone
                                        ? () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'This quiz has already been attempted. Retakes are not permitted per challenge policy.',
                                                ),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        : isClosed
                                            ? () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(l10n.quizWindowClosedError),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            : () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(l10n.quizNotStartedError),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      canStart ? colors.primary : colors.surfaceMuted,
                                  foregroundColor:
                                      canStart ? Colors.white : colors.textSecondary,
                                  side: BorderSide(
                                    color: canStart
                                        ? colors.primary
                                        : colors.border,
                                    width: RxShadows.hairlineBorderWidth,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: RxRadii.borderButton,
                                  ),
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: RxSpacing.s16,
                                    vertical: RxSpacing.s8,
                                  ),
                                  minimumSize: const Size(0, 36.0),
                                ),
                                icon: Icon(
                                  isDone
                                      ? LucideIcons.checkCheck
                                      : isClosed
                                          ? LucideIcons.lock
                                          : isUpcoming
                                              ? LucideIcons.clock
                                              : LucideIcons.play,
                                  size: 14.0,
                                ),
                                label: Text(
                                  isDone
                                      ? 'Completed (Single Attempt)'
                                      : isClosed
                                          ? l10n.quizClosed
                                          : isUpcoming
                                              ? (quiz.startDate != null
                                                  ? l10n.quizOpensOn('${quiz.startDate!.day}/${quiz.startDate!.month}')
                                                  : 'Not Started')
                                              : l10n.btnStartQuiz,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        canStart ? Colors.white : colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _CountBadge({
    required this.count,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsetsDirectional.only(start: RxSpacing.s6),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : colors.surfaceMuted,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        '$count',
        style: textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : colors.textSecondary,
        ),
      ),
    );
  }
}
