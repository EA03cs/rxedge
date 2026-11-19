import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';
import '../screens/quick_quiz_screen.dart';

/// Quick Quizzes View
///
/// Features:
/// - Filter chips: All, Available (+Pts), Completed (Review)
/// - List of clinical knowledge reinforcement quizzes
/// - Clear metadata: question count, time estimate, reward points
/// - Completion status and previous score preview
/// - Direct one-tap launch of Quick Quiz flow
class QuickQuizzesView extends StatefulWidget {
  final List<QuickQuizEntity> quizzes;

  const QuickQuizzesView({
    super.key,
    required this.quizzes,
  });

  @override
  State<QuickQuizzesView> createState() => _QuickQuizzesViewState();
}

class _QuickQuizzesViewState extends State<QuickQuizzesView> {
  int _filterIndex = 0; // 0 = all, 1 = available, 2 = completed

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                  label: isArabic ? 'الكل' : 'All',
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
                  label: isArabic ? 'متاحة (+نقاط)' : 'Available (+Pts)',
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
                  label: isArabic ? 'مكتملة (مراجعة)' : 'Completed',
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
                          ? (isArabic
                              ? 'لا توجد اختبارات مكتملة بعد'
                              : 'No completed quizzes yet')
                          : (isArabic
                              ? 'تم اجتياز جميع الاختبارات!'
                              : 'All quizzes completed!'),
                      description: _filterIndex == 2
                          ? (isArabic
                              ? 'ابدأ باختبار لتعزيز معلوماتك الإكلينيكية وحصد النقاط.'
                              : 'Take quick quizzes to earn points and reinforce clinical detailing.')
                          : (isArabic
                              ? 'أحسنت! يمكنك التبديل إلى تبويب "الكل" أو "مكتملة" لإعادة أي اختبار والمراجعة.'
                              : 'Great job! Switch to "Completed" to review and retake any quiz.'),
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

                    return AppCard(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context, rootNavigator: true).push<void>(
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
                                label: isDone
                                    ? (isArabic
                                        ? 'سُجلت النقاط'
                                        : 'Points Claimed')
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
                              Icon(LucideIcons.helpCircle,
                                  size: 14.0, color: colors.textSecondary),
                              const SizedBox(width: RxSpacing.s4),
                              Text(
                                l10n.questionsCountLabel(
                                    quiz.displayQuestionCount),
                                style: textTheme.bodySmall
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                              const SizedBox(width: RxSpacing.s12),
                              Icon(LucideIcons.clock4,
                                  size: 14.0, color: colors.textSecondary),
                              const SizedBox(width: RxSpacing.s4),
                              Text(
                                l10n.minutesCountLabel(quiz.durationMinutes),
                                style: textTheme.bodySmall
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                              const Spacer(),
                              if (isDone) ...[
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
                                    isArabic
                                        ? 'سياسة التحدي: محاولة واحدة فقط معتمدة لكل مشارك، ولا يُسمح بالإعادة.'
                                        : 'Challenge policy: exactly one attempt permitted per participant, no retakes.',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isDone
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isArabic
                                                  ? 'تم تسجيل محاولتك لهذا الاختبار مسبقاً بنجاح. لا يُسمح بإعادة الاختبار وفقاً لقواعد التحديات.'
                                                  : 'This quiz has already been attempted. Retakes are not permitted per challenge policy.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    : () {
                                        HapticFeedback.selectionClick();
                                        Navigator.of(context, rootNavigator: true)
                                            .push<void>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                QuickQuizScreen(quiz: quiz),
                                          ),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      isDone ? colors.surfaceMuted : colors.primary,
                                  foregroundColor:
                                      isDone ? colors.textSecondary : Colors.white,
                                  side: BorderSide(
                                    color: isDone
                                        ? colors.border
                                        : colors.primary,
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
                                      : LucideIcons.play,
                                  size: 14.0,
                                ),
                                label: Text(
                                  isDone
                                      ? (isArabic
                                          ? 'مكتمل (محاولة واحدة)'
                                          : 'Completed (Single Attempt)')
                                      : l10n.btnStartQuiz,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDone ? colors.textSecondary : Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
