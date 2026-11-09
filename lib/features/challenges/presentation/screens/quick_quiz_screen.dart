import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';
import '../controllers/challenges_controller.dart';

/// Quick Quiz Interactive Flow
///
/// Features:
/// - One question per screen
/// - Thin progress bar at top
/// - Large full-width touch options (12dp radius, hairline border)
/// - Immediate right/wrong feedback with one-line clinical explanation
/// - Result screen: score, points earned, time, and 3 actions (Review mistakes, Retry, Back to learning)
/// - Single subtle celebration on high scores only (NO confetti spam, restrained professional aesthetic)
class QuickQuizScreen extends ConsumerStatefulWidget {
  final QuickQuizEntity quiz;

  const QuickQuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends ConsumerState<QuickQuizScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex

  late final Stopwatch _stopwatch;
  Timer? _ticker;
  bool _isFinished = false;
  bool _showReviewMistakes = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _onOptionSelected(int optionIndex) {
    if (_isAnswerSubmitted) return;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswerSubmitted = true;
      _userAnswers[_currentIndex] = optionIndex;
    });
  }

  void _onNext() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswerSubmitted = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _stopwatch.stop();
    _ticker?.cancel();

    final score = _calculateScore();
    final total = widget.quiz.questions.length;
    final elapsedSec = _stopwatch.elapsed.inSeconds;

    ref.read(challengesControllerProvider.notifier).onQuizCompleted(
          quizId: widget.quiz.id,
          score: score,
          totalQuestions: total,
          timeTakenSeconds: elapsedSec,
        );

    setState(() {
      _isFinished = true;
    });
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final chosen = _userAnswers[i];
      final correct = widget.quiz.questions[i].correctOptionIndex;
      if (chosen == correct) {
        score++;
      }
    }
    return score;
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswerSubmitted = false;
      _userAnswers.clear();
      _isFinished = false;
      _showReviewMistakes = false;
      _stopwatch
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultScreen(context);
    }
    return _buildQuestionScreen(context);
  }

  Widget _buildQuestionScreen(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final currentQuestion = widget.quiz.questions[_currentIndex];
    final totalQuestions = widget.quiz.questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.quiz.title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: Column(
        children: [
          // Thin Progress Bar at top
          ProgressBar(
            value: progress,
            height: 3.0,
            color: colors.primary,
          ),

          // Question Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter & Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.quizQuestionProgress(_currentIndex + 1, totalQuestions),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(LucideIcons.clock4, size: 14.0, color: colors.textSecondary),
                          const SizedBox(width: RxSpacing.s4),
                          Text(
                            _formatDuration(_stopwatch.elapsed),
                            style: textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // Question Text
                  Text(
                    currentQuestion.question,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  // Answer Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final optionText = entry.value;

                    return _buildOptionTile(
                      context: context,
                      index: index,
                      optionText: optionText,
                      correctIndex: currentQuestion.correctOptionIndex,
                    );
                  }),
                  const SizedBox(height: RxSpacing.s16),

                  // Immediate Right/Wrong Feedback with One-Line Explanation
                  if (_isAnswerSubmitted) ...[
                    _buildFeedbackBox(context, currentQuestion),
                    const SizedBox(height: RxSpacing.s20),

                    // Next / Finish Button
                    AppButton(
                      text: _currentIndex < totalQuestions - 1
                          ? l10n.btnNextQuestion
                          : l10n.btnFinishQuiz,
                      variant: AppButtonVariant.primary,
                      trailingIcon: _currentIndex < totalQuestions - 1
                          ? LucideIcons.arrowRight
                          : LucideIcons.checkCircle,
                      onPressed: _onNext,
                    ),
                  ],
                  const SizedBox(height: RxSpacing.s24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required int index,
    required String optionText,
    required int correctIndex,
  }) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == correctIndex;

    Color bg = colors.surface;
    Color border = colors.border;
    Color text = colors.textPrimary;
    Widget? trailingIcon;

    if (_isAnswerSubmitted) {
      if (isCorrect) {
        bg = colors.successSoft;
        border = colors.success;
        text = colors.textPrimary;
        trailingIcon = Icon(LucideIcons.checkCircle2, size: 18.0, color: colors.success);
      } else if (isSelected && !isCorrect) {
        bg = colors.errorSoft;
        border = colors.error;
        text = colors.textPrimary;
        trailingIcon = Icon(LucideIcons.xCircle, size: 18.0, color: colors.error);
      } else {
        bg = colors.surfaceMuted;
        text = colors.textTertiary;
      }
    }

    final optionLetters = ['A', 'B', 'C', 'D', 'E'];
    final letter = index < optionLetters.length ? optionLetters[index] : '${index + 1}';

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
      child: InkWell(
        onTap: _isAnswerSubmitted ? null : () => _onOptionSelected(index),
        borderRadius: RxRadii.borderCard,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: RxRadii.borderCard,
            border: Border.all(
              color: border,
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28.0,
                height: 28.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected && !_isAnswerSubmitted ? colors.primary : colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected && !_isAnswerSubmitted ? Colors.white : colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: RxSpacing.s12),
              Expanded(
                child: Text(
                  optionText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: text,
                    height: 1.4,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: RxSpacing.s8),
                trailingIcon,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBox(BuildContext context, QuizQuestionEntity question) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final isCorrect = _selectedOptionIndex == question.correctOptionIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
      decoration: BoxDecoration(
        color: isCorrect ? colors.successSoft : colors.primarySoft,
        borderRadius: RxRadii.borderCard,
        border: Border.all(
          color: isCorrect ? colors.success.withValues(alpha: 0.3) : colors.primary.withValues(alpha: 0.3),
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? LucideIcons.check : LucideIcons.info,
            size: 16.0,
            color: isCorrect ? colors.success : colors.primary,
          ),
          const SizedBox(width: RxSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct Recall' : 'Clinical Rationale',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isCorrect ? colors.success : colors.primary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  question.explanation,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final score = _calculateScore();
    final total = widget.quiz.questions.length;
    final percent = total == 0 ? 0.0 : score / total;
    final isHighScore = percent >= 0.8;
    final pointsEarned = (score * 10) + (score == total ? 10 : 0);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizScoreTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
        child: Column(
          children: [
            const SizedBox(height: RxSpacing.s12),

            // Score & Metric Card
            AppCard(
              child: Column(
                children: [
                  // Single Subtle Celebration Badge on High Scores only (NO confetti spam)
                  if (isHighScore) ...[
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: RxSpacing.s12,
                        vertical: RxSpacing.s6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: BorderRadius.circular(999.0),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.35),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.award, size: 14.0, color: colors.accent),
                          const SizedBox(width: RxSpacing.s6),
                          Text(
                            l10n.highScoreBadge,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),
                  ],

                  // Circular Progress Ring showing Score
                  ProgressRing(
                    value: percent,
                    size: 80.0,
                    strokeWidth: 6.0,
                    color: isHighScore ? colors.primary : colors.warning,
                    center: Text(
                      '${(percent * 100).toInt()}%',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  Text(
                    '$score of $total Questions Correct',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),
                  Divider(
                    height: 1.0,
                    thickness: RxShadows.hairlineBorderWidth,
                    color: colors.border,
                  ),
                  const SizedBox(height: RxSpacing.s12),

                  // Stats Row: Points + Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Points Earned',
                            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4.0),
                          StatusBadge(
                            label: '+$pointsEarned Pts',
                            variant: StatusBadgeVariant.accent,
                          ),
                        ],
                      ),
                      Container(
                        width: 1.0,
                        height: 36.0,
                        color: colors.border,
                      ),
                      Column(
                        children: [
                          Text(
                            'Time Elapsed',
                            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _formatDuration(_stopwatch.elapsed),
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s24),

            // Mistakes Review Block (Expandable)
            if (_showReviewMistakes) ...[
              _buildMistakesReview(context),
              const SizedBox(height: RxSpacing.s20),
            ],

            // 3 Actions: Review Mistakes, Retry, Back to learning
            AppButton(
              text: _showReviewMistakes ? 'Hide Mistakes' : l10n.btnReviewMistakes,
              leadingIcon: LucideIcons.fileSearch,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                setState(() {
                  _showReviewMistakes = !_showReviewMistakes;
                });
              },
            ),
            const SizedBox(height: RxSpacing.s10),
            AppButton(
              text: l10n.btnRetryQuiz,
              leadingIcon: LucideIcons.rotateCw,
              variant: AppButtonVariant.secondary,
              onPressed: _restartQuiz,
            ),
            const SizedBox(height: RxSpacing.s10),
            AppButton(
              text: l10n.btnBackToLearning,
              leadingIcon: LucideIcons.arrowLeft,
              variant: AppButtonVariant.primary,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: RxSpacing.s24),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakesReview(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final wrongQuestions = <(int index, QuizQuestionEntity q, int chosen)>[];
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final chosen = _userAnswers[i] ?? -1;
      final q = widget.quiz.questions[i];
      if (chosen != q.correctOptionIndex) {
        wrongQuestions.add((i, q, chosen));
      }
    }

    if (wrongQuestions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: RxRadii.borderCard,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: colors.success, size: 18.0),
            const SizedBox(width: RxSpacing.s8),
            Text(
              'Flawless! Zero incorrect answers to review.',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Incorrect Answers Breakdown',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: RxSpacing.s10),
        ...wrongQuestions.map((item) {
          final q = item.$2;
          final chosen = item.$3;
          final correct = q.correctOptionIndex;

          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  if (chosen >= 0 && chosen < q.options.length) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.x, size: 15.0, color: colors.error),
                        const SizedBox(width: RxSpacing.s6),
                        Expanded(
                          child: Text(
                            'Your answer: ${q.options[chosen]}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.error,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.check, size: 15.0, color: colors.success),
                      const SizedBox(width: RxSpacing.s6),
                      Expanded(
                        child: Text(
                          'Correct answer: ${q.options[correct]}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Text(
                    q.explanation,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}
