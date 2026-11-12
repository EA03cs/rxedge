import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/error/failure_message_mapper.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/repositories/challenges_repository_impl.dart';
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
  late QuickQuizEntity _quiz;
  bool _isLoadingQuiz = false;
  String? _loadError;

  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;
  bool _isSubmitting = false;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex
  QuizSubmissionResultEntity? _serverResult;

  late final Stopwatch _stopwatch;
  Timer? _ticker;
  bool _isFinished = false;
  bool _showReviewMistakes = false;

  @override
  void initState() {
    super.initState();
    _quiz = widget.quiz;
    _stopwatch = Stopwatch();
    if (_quiz.questions.isEmpty) {
      _loadQuizQuestions();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isFinished) setState(() {});
    });
  }

  Future<void> _loadQuizQuestions() async {
    setState(() {
      _isLoadingQuiz = true;
      _loadError = null;
    });

    final result = await ref.read(challengesRepositoryProvider).getQuizById(_quiz.id);
    if (!mounted) return;

    result.when(
      success: (loadedQuiz) {
        setState(() {
          _quiz = loadedQuiz;
          _isLoadingQuiz = false;
        });
        if (loadedQuiz.questions.isNotEmpty) {
          _startTimer();
        }
      },
      failure: (failure) {
        setState(() {
          _isLoadingQuiz = false;
          _loadError = FailureMessageMapper.map(context, failure);
        });
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  bool get _isServerEvaluated =>
      _quiz.questions.isNotEmpty && _quiz.questions.first.isServerEvaluated;

  void _onOptionSelected(int optionIndex) {
    final currentQuestion = _quiz.questions[_currentIndex];
    if (!currentQuestion.isServerEvaluated && _isAnswerSubmitted) return;
    if (_isSubmitting) return;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _userAnswers[_currentIndex] = optionIndex;
      if (!currentQuestion.isServerEvaluated) {
        _isAnswerSubmitted = true;
      }
    });
  }

  void _onNext() {
    if (_currentIndex < _quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = _userAnswers[_currentIndex];
        _isAnswerSubmitted = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    if (_isServerEvaluated) {
      final payload = <Map<String, String>>[];
      for (int i = 0; i < _quiz.questions.length; i++) {
        final q = _quiz.questions[i];
        final selectedIdx = _userAnswers[i];
        if (selectedIdx != null && selectedIdx < q.optionIds.length) {
          payload.add({
            'questionId': q.id,
            'selectedOptionId': q.optionIds[selectedIdx],
          });
        }
      }

      if (payload.length < _quiz.questions.length) {
        return;
      }

      setState(() => _isSubmitting = true);
      final res = await ref
          .read(challengesControllerProvider.notifier)
          .submitServerQuiz(quizId: _quiz.id, answers: payload);

      if (!mounted) return;
      res.when(
        success: (evalResult) {
          _stopwatch.stop();
          _ticker?.cancel();

          final updatedQuestions = _quiz.questions.map((q) {
            final match = evalResult.answers.where((a) => a.questionId == q.id);
            if (match.isEmpty) return q;
            final a = match.first;
            var resolvedCorrectIdx = a.correctOptionId != null
                ? q.optionIds.indexOf(a.correctOptionId!)
                : -1;
            if (resolvedCorrectIdx < 0 && a.correctOptionText != null) {
              resolvedCorrectIdx = q.options.indexOf(a.correctOptionText!);
            }
            return q.copyWith(
              correctOptionIndex: resolvedCorrectIdx,
              explanation: a.explanation ?? q.explanation,
            );
          }).toList();

          setState(() {
            _quiz = _quiz.copyWith(questions: updatedQuestions);
            _serverResult = evalResult;
            _isSubmitting = false;
            _isFinished = true;
          });
        },
        failure: (failure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FailureMessageMapper.map(context, failure)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
      return;
    }

    _stopwatch.stop();
    _ticker?.cancel();

    final score = _calculateScore();
    final total = _quiz.questions.length;
    final elapsedSec = _stopwatch.elapsed.inSeconds;

    unawaited(
      ref.read(challengesControllerProvider.notifier).onQuizCompleted(
            quizId: _quiz.id,
            score: score,
            totalQuestions: total,
            timeTakenSeconds: elapsedSec,
          ),
    );

    setState(() {
      _isFinished = true;
    });
  }

  int _calculateScore() {
    if (_serverResult != null) {
      return _serverResult!.answers.where((a) => a.isCorrect).length;
    }
    int score = 0;
    for (int i = 0; i < _quiz.questions.length; i++) {
      final chosen = _userAnswers[i];
      final correct = _quiz.questions[i].correctOptionIndex;
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
      _isSubmitting = false;
      _serverResult = null;
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
    if (_isLoadingQuiz || _loadError != null || _quiz.questions.isEmpty) {
      final colors = context.rxColors;
      final textTheme = Theme.of(context).textTheme;
      return AppScaffold(
        appBar: AppBar(
          title: Text(
            _quiz.title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: _isLoadingQuiz
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                  child: EmptyState(
                    icon: LucideIcons.helpCircle,
                    title: _quiz.title,
                    description: _loadError ?? '',
                    actionText: context.l10n.retry,
                    onAction: _loadQuizQuestions,
                  ),
                ),
        ),
      );
    }

    if (_isFinished) {
      return _buildResultScreen(context);
    }
    return _buildQuestionScreen(context);
  }

  Widget _buildQuestionScreen(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final currentQuestion = _quiz.questions[_currentIndex];
    final totalQuestions = _quiz.questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          _quiz.title,
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

                  // Immediate Right/Wrong Feedback with One-Line Explanation (local quizzes)
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
                          ? context.arrowForward
                          : LucideIcons.checkCircle,
                      onPressed: _onNext,
                    ),
                  ] else if (currentQuestion.isServerEvaluated &&
                      _selectedOptionIndex != null) ...[
                    const SizedBox(height: RxSpacing.s8),
                    AppButton(
                      text: _currentIndex < totalQuestions - 1
                          ? l10n.btnNextQuestion
                          : l10n.btnFinishQuiz,
                      variant: AppButtonVariant.primary,
                      isLoading: _isSubmitting,
                      trailingIcon: _currentIndex < totalQuestions - 1
                          ? context.arrowForward
                          : LucideIcons.checkCircle,
                      onPressed: _isSubmitting ? null : _onNext,
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
    final l10n = context.l10n;
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
                  isCorrect ? l10n.correctRecallLabel : l10n.clinicalRationaleLabel,
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
    final total = _quiz.questions.length;
    final percent = total == 0 ? 0.0 : score / total;
    final isHighScore = _serverResult?.isPassed ?? (percent >= 0.8);
    final pointsEarned = _serverResult?.pointsAwarded ??
        ((score * 10) + (score == total ? 10 : 0));

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
                    l10n.scoreCorrectOfTotal(score, total),
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
                            l10n.pointsEarnedLabel,
                            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 4.0),
                          StatusBadge(
                            label: l10n.pointsPlusValue(pointsEarned),
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
                            l10n.timeElapsedLabel,
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
              text: _showReviewMistakes ? l10n.btnHideMistakes : l10n.btnReviewMistakes,
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
              leadingIcon: context.arrowBack,
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
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final wrongQuestions = <(int index, QuizQuestionEntity q, int chosen)>[];
    for (int i = 0; i < _quiz.questions.length; i++) {
      final chosen = _userAnswers[i] ?? -1;
      final q = _quiz.questions[i];
      if (q.correctOptionIndex >= 0 && chosen != q.correctOptionIndex) {
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
            Expanded(
              child: Text(
                l10n.flawlessAnswersMsg,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
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
          l10n.incorrectBreakdownTitle,
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
                            l10n.yourAnswerPrefix(q.options[chosen]),
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
                          l10n.correctAnswerPrefix(q.options[correct]),
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
