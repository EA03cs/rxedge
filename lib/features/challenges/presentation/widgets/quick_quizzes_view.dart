import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';
import '../screens/quick_quiz_screen.dart';

/// Quick Quizzes View
///
/// Features:
/// - List of clinical knowledge reinforcement quizzes
/// - Clear metadata: question count, time estimate, reward points
/// - Completion status and previous score preview
/// - Direct one-tap launch of Quick Quiz flow
class QuickQuizzesView extends StatelessWidget {
  final List<QuickQuizEntity> quizzes;

  const QuickQuizzesView({
    super.key,
    required this.quizzes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    if (quizzes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsetsDirectional.all(RxSpacing.s24),
          child: EmptyState(
            icon: LucideIcons.helpCircle,
            title: 'No Quizzes Available',
            description: 'New clinical quizzes will appear here with each detailing cycle.',
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      itemCount: quizzes.length,
      separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s12),
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final isDone = quiz.isCompleted;

        return AppCard(
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => QuickQuizScreen(quiz: quiz),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top meta: Category + Points
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
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
                  StatusBadge(
                    label: '+${quiz.rewardPoints} Pts',
                    variant: StatusBadgeVariant.accent,
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
                  Icon(LucideIcons.helpCircle, size: 14.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s4),
                  Text(
                    '${quiz.questions.length} questions',
                    style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Icon(LucideIcons.clock4, size: 14.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s4),
                  Text(
                    '${quiz.durationMinutes} min',
                    style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                  const Spacer(),
                  if (isDone) ...[
                    StatusBadge(
                      label: quiz.lastScore != null
                          ? 'Score: ${quiz.lastScore}/${quiz.lastMaxScore}'
                          : l10n.completedBadge,
                      variant: StatusBadgeVariant.success,
                      showDot: true,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: RxSpacing.s14),

              // Action button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => QuickQuizScreen(quiz: quiz),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDone ? colors.surface : colors.primary,
                      foregroundColor: isDone ? colors.primary : Colors.white,
                      side: BorderSide(
                        color: isDone ? colors.border : colors.primary,
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
                      isDone ? LucideIcons.rotateCw : LucideIcons.play,
                      size: 14.0,
                    ),
                    label: Text(
                      isDone ? 'Retake Quiz' : l10n.btnStartQuiz,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDone ? colors.primary : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
