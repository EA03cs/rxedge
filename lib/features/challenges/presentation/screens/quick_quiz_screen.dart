import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/error/failure_message_mapper.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../learn/presentation/controllers/learn_controller.dart';
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
  final QuizSubmissionResultEntity? initialReviewResult;

  const QuickQuizScreen({
    super.key,
    required this.quiz,
    this.initialReviewResult,
  });

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

enum QuizBreakdownFilter { all, incorrectOnly }

class _QuestionEvaluationData {
  final int index;
  final QuizQuestionEntity question;
  final int chosenIndex;
  final String? selectedAnswerText;
  final int correctIndex;
  final String? correctAnswerText;
  final bool isCorrect;
  final String explanation;

  const _QuestionEvaluationData({
    required this.index,
    required this.question,
    required this.chosenIndex,
    required this.selectedAnswerText,
    required this.correctIndex,
    required this.correctAnswerText,
    required this.isCorrect,
    required this.explanation,
  });
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
  QuizBreakdownFilter _breakdownFilter = QuizBreakdownFilter.all;

  @override
  void initState() {
    super.initState();
    _quiz = widget.quiz;
    _stopwatch = Stopwatch();
    final review = widget.initialReviewResult;
    if (review != null) {
      _serverResult = review;
      _isFinished = true;
      for (int i = 0; i < _quiz.questions.length; i++) {
        final q = _quiz.questions[i];
        final match = review.answers.where((a) => a.questionId == q.id);
        if (match.isNotEmpty) {
          final selId = match.first.selectedOptionId;
          final selText = match.first.selectedOptionText;
          var idx = selId != null ? q.optionIds.indexOf(selId) : -1;
          if (idx < 0 && selText != null) {
            idx = q.options.indexOf(selText);
          }
          if (idx >= 0) {
            _userAnswers[i] = idx;
          }
        }
      }
      return;
    }
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

    HapticFeedback.selectionClick();

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

          if (evalResult.isPassed) {
            unawaited(HapticFeedback.mediumImpact());
            final lid = _quiz.lessonId;
            if (lid != null && lid.isNotEmpty) {
              unawaited(
                ref
                    .read(learnControllerProvider.notifier)
                    .markLessonCompleted(lid),
              );
            }
          }

          setState(() {
            _quiz = _quiz.copyWith(questions: updatedQuestions);
            _serverResult = evalResult;
            _isSubmitting = false;
            _isFinished = true;
          });
        },
        failure: (failure) {
          setState(() => _isSubmitting = false);
          final errorText = FailureMessageMapper.map(context, failure);
          final failStr = failure.toString();
          final isConflict = failStr.contains('409') ||
              failStr.contains('ATTEMPT_ALREADY_EXISTS');
          final isWindowClosed = failStr.contains('QUIZ_WINDOW_CLOSED');
          final isNotStarted = failStr.contains('QUIZ_NOT_STARTED');

          String message = errorText;
          if (isConflict) {
            message =
                'You have already attempted this quiz. Retakes are not permitted per challenge policy.';
          } else if (isWindowClosed) {
            message = 'This quiz is closed as the completion window has ended.';
          } else if (isNotStarted) {
            message = 'This quiz has not started yet. Please check back on the start date.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
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
    final isPassed = total > 0 && (score / total) >= 0.7;

    if (isPassed) {
      unawaited(HapticFeedback.mediumImpact());
      final lid = _quiz.lessonId;
      if (lid != null && lid.isNotEmpty) {
        unawaited(
          ref
              .read(learnControllerProvider.notifier)
              .markLessonCompleted(lid),
        );
      }
    }

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
      _breakdownFilter = QuizBreakdownFilter.all;
      _stopwatch
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished && (_serverResult != null || _quiz.questions.isNotEmpty)) {
      return _buildResultScreen(context);
    }

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
    final total = _quiz.questions.isNotEmpty
        ? _quiz.questions.length
        : (_serverResult?.answers.length ?? 0);
    final percent = total > 0
        ? score / total
        : ((_serverResult?.scorePercentage ?? 0) / 100.0);
    final isHighScore = _serverResult?.isPassed ?? (percent >= 0.8);
    final pointsEarned = _serverResult?.pointsAwarded ??
        ((score * 10) + (score == total ? 10 : 0));

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.initialReviewResult != null
              ? _quiz.title
              : l10n.quizScoreTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        automaticallyImplyLeading: widget.initialReviewResult != null,
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
                          Flexible(
                            child: Text(
                              l10n.highScoreBadge,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.accent,
                              ),
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
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.pointsEarnedLabel,
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                            ),
                            const SizedBox(height: 4.0),
                            StatusBadge(
                              label: pointsEarned > 0
                                  ? l10n.pointsPlusValue(pointsEarned)
                                  : 'Claimed',
                              variant: pointsEarned > 0
                                  ? StatusBadgeVariant.accent
                                  : StatusBadgeVariant.neutral,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.0,
                        height: 36.0,
                        color: colors.border,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.timeElapsedLabel,
                              textAlign: TextAlign.center,
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
                      ),
                    ],
                  ),
                  if (pointsEarned == 0 || _quiz.isCompleted) ...[
                    const SizedBox(height: RxSpacing.s16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.border,
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.info, size: 15.0, color: colors.textSecondary),
                          const SizedBox(width: RxSpacing.s8),
                          Expanded(
                            child: Text(
                              'Marks Note: Quiz challenge marks${_quiz.rewardPoints > 0 ? ' (+${_quiz.rewardPoints} Marks)' : ''} are awarded once upon first pass. Additional attempts serve as clinical refresher and practice.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (percent >= 0.7 && _quiz.lessonId != null && _quiz.lessonId!.isNotEmpty) ...[
                    const SizedBox(height: RxSpacing.s12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
                      decoration: BoxDecoration(
                        color: colors.successSoft,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.success.withValues(alpha: 0.35),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.checkCheck, size: 16.0, color: colors.success),
                          const SizedBox(width: RxSpacing.s8),
                          Expanded(
                            child: Text(
                              'Quiz passed! The associated lesson has been automatically marked as complete.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s24),

            // Per-question Breakdown Section (All questions by default, filterable to Incorrect only)
            _buildQuestionsBreakdownSection(context),
            const SizedBox(height: RxSpacing.s20),

            // 3 Actions: Review Mistakes / Show All Questions, Retry, Back to learning
            AppButton(
              text: _breakdownFilter == QuizBreakdownFilter.incorrectOnly
                  ? l10n.btnShowAllQuestions
                  : l10n.btnReviewMistakes,
              leadingIcon: _breakdownFilter == QuizBreakdownFilter.incorrectOnly
                  ? LucideIcons.layers
                  : LucideIcons.fileSearch,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                setState(() {
                  _breakdownFilter = _breakdownFilter == QuizBreakdownFilter.incorrectOnly
                      ? QuizBreakdownFilter.all
                      : QuizBreakdownFilter.incorrectOnly;
                });
              },
            ),
            const SizedBox(height: RxSpacing.s10),
            if (!_quiz.isCompleted && _serverResult == null) ...[
              AppButton(
                text: l10n.btnRetryQuiz,
                leadingIcon: LucideIcons.rotateCw,
                variant: AppButtonVariant.secondary,
                onPressed: _restartQuiz,
              ),
              const SizedBox(height: RxSpacing.s10),
            ],
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

  _QuestionEvaluationData _evaluateQuestion(int i) {
    final q = _quiz.questions[i];
    final chosenIndex = _userAnswers[i] ?? -1;

    QuizAnswerEvaluationEntity? evalMatch;
    if (_serverResult != null) {
      final matches = _serverResult!.answers.where((a) => a.questionId == q.id);
      if (matches.isNotEmpty) {
        evalMatch = matches.first;
      }
    }

    final selectedAnswerText =
        (chosenIndex >= 0 && chosenIndex < q.options.length)
            ? q.options[chosenIndex]
            : evalMatch?.selectedOptionText;

    final bool isCorrect;
    if (evalMatch != null) {
      isCorrect = evalMatch.isCorrect;
    } else if (q.correctOptionIndex >= 0) {
      isCorrect = chosenIndex == q.correctOptionIndex;
    } else {
      isCorrect = false;
    }

    var correctIndex = q.correctOptionIndex;
    if (correctIndex < 0 && evalMatch != null) {
      if (evalMatch.correctOptionId != null && q.optionIds.isNotEmpty) {
        correctIndex = q.optionIds.indexOf(evalMatch.correctOptionId!);
      }
      if (correctIndex < 0 && evalMatch.correctOptionText != null) {
        correctIndex = q.options.indexOf(evalMatch.correctOptionText!);
      }
    }

    String? correctAnswerText;
    if (correctIndex >= 0 && correctIndex < q.options.length) {
      correctAnswerText = q.options[correctIndex];
    } else if (evalMatch?.correctOptionText != null &&
        evalMatch!.correctOptionText!.isNotEmpty) {
      correctAnswerText = evalMatch.correctOptionText;
    }

    final explanation = (evalMatch?.explanation?.trim().isNotEmpty == true)
        ? evalMatch!.explanation!.trim()
        : q.explanation.trim();

    return _QuestionEvaluationData(
      index: i,
      question: q,
      chosenIndex: chosenIndex,
      selectedAnswerText: selectedAnswerText,
      correctIndex: correctIndex,
      correctAnswerText: correctAnswerText,
      isCorrect: isCorrect,
      explanation: explanation,
    );
  }

  Widget _buildQuestionsBreakdownSection(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final evaluations = _quiz.questions.isNotEmpty
        ? List.generate(
            _quiz.questions.length,
            (i) => _evaluateQuestion(i),
          )
        : [
            for (int i = 0; i < (_serverResult?.answers.length ?? 0); i++)
              _QuestionEvaluationData(
                index: i,
                question: QuizQuestionEntity(
                  id: _serverResult!.answers[i].questionId,
                  question: _serverResult!.answers[i].questionText?.trim().isNotEmpty == true
                      ? _serverResult!.answers[i].questionText!
                      : l10n.questionNumber(i + 1),
                  options: const [],
                  correctOptionIndex: -1,
                  explanation: _serverResult!.answers[i].explanation ?? '',
                ),
                chosenIndex: -1,
                selectedAnswerText: _serverResult!.answers[i].selectedOptionText,
                correctIndex: -1,
                correctAnswerText: _serverResult!.answers[i].correctOptionText,
                isCorrect: _serverResult!.answers[i].isCorrect,
                explanation: _serverResult!.answers[i].explanation ?? '',
              ),
          ];

    final totalCount = evaluations.length;
    final incorrectCount = evaluations.where((e) => !e.isCorrect).length;

    final displayedEvaluations =
        _breakdownFilter == QuizBreakdownFilter.incorrectOnly
            ? evaluations.where((e) => !e.isCorrect).toList()
            : evaluations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.questionsBreakdownTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s10),

        // Filter Controls Row (All vs Incorrect only)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBreakdownFilterChip(
                context: context,
                label: l10n.filterAllCount(totalCount),
                icon: LucideIcons.layers,
                isSelected: _breakdownFilter == QuizBreakdownFilter.all,
                onTap: () {
                  if (_breakdownFilter != QuizBreakdownFilter.all) {
                    setState(() {
                      _breakdownFilter = QuizBreakdownFilter.all;
                    });
                  }
                },
              ),
              const SizedBox(width: RxSpacing.s8),
              _buildBreakdownFilterChip(
                context: context,
                label: l10n.filterIncorrectCount(incorrectCount),
                icon: LucideIcons.alertCircle,
                isSelected: _breakdownFilter == QuizBreakdownFilter.incorrectOnly,
                onTap: () {
                  if (_breakdownFilter != QuizBreakdownFilter.incorrectOnly) {
                    setState(() {
                      _breakdownFilter = QuizBreakdownFilter.incorrectOnly;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: RxSpacing.s14),

        // Empty state when filtering incorrect only and zero mistakes exist
        if (_breakdownFilter == QuizBreakdownFilter.incorrectOnly &&
            incorrectCount == 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: RxRadii.borderCard,
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  color: Color(0xFF16A34A),
                  size: 18.0,
                ),
                const SizedBox(width: RxSpacing.s10),
                Expanded(
                  child: Text(
                    l10n.flawlessAnswersMsg,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Render each question breakdown card
          ...displayedEvaluations.map((item) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
              child: _buildBreakdownQuestionCard(
                context: context,
                data: item,
                l10n: l10n,
                colors: colors,
                textTheme: textTheme,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildBreakdownFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RxSpacing.s12,
            vertical: RxSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.0,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
              const SizedBox(width: RxSpacing.s6),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownQuestionCard({
    required BuildContext context,
    required _QuestionEvaluationData data,
    required AppLocalizations l10n,
    required RxColors colors,
    required TextTheme textTheme,
  }) {
    final isCorrect = data.isCorrect;
    final selectedText = data.selectedAnswerText ?? l10n.notAnsweredLabel;
    final correctAnswer = data.correctAnswerText;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question number badge & Status Badge (Icon + Label, accessible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: RxSpacing.s8,
                    vertical: RxSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Text(
                    l10n.questionNumber(data.index + 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RxSpacing.s8),
              // Dual indicator: Icon AND Text Label (ensures accessible readability beyond color)
              Flexible(
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: RxSpacing.s8,
                    vertical: RxSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFECFDF5) // Emerald 50
                        : const Color(0xFFFEF2F2), // Red 50
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFFA7F3D0) // Emerald 200
                          : const Color(0xFFFECACA), // Red 200
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                        size: 13.0,
                        color: isCorrect
                            ? const Color(0xFF059669) // Emerald 600
                            : const Color(0xFFDC2626), // Red 600
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          isCorrect ? l10n.statusCorrect : l10n.statusIncorrect,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? const Color(0xFF047857)
                                : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s10),

          // Question Text
          Text(
            data.question.question,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: RxSpacing.s10),

          // Rep's Selected Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFFECDD3),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2.0),
                  child: Icon(
                    isCorrect ? LucideIcons.check : LucideIcons.x,
                    size: 15.0,
                    color: isCorrect
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: Text(
                    l10n.yourAnswerPrefix(selectedText),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCorrect
                          ? const Color(0xFF15803D)
                          : const Color(0xFFBE123C),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // If incorrect, show the Correct Answer explicitly
          if (!isCorrect && correctAnswer != null && correctAnswer.isNotEmpty) ...[
            const SizedBox(height: RxSpacing.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color(0xFFBBF7D0),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.only(top: 2.0),
                    child: Icon(
                      LucideIcons.checkCheck,
                      size: 15.0,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s8),
                  Expanded(
                    child: Text(
                      l10n.correctAnswerPrefix(correctAnswer),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Explanation Box
          if (data.explanation.isNotEmpty) ...[
            const SizedBox(height: RxSpacing.s10),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(8.0),
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
                      Icon(
                        LucideIcons.sparkles,
                        size: 13.0,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: RxSpacing.s6),
                      Expanded(
                        child: Text(
                          l10n.explanationHeader,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s4),
                  Text(
                    data.explanation,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 12.0,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}
