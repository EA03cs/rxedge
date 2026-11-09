import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';
import '../controllers/learn_controller.dart';

/// Lesson Reading Screen
///
/// Features:
/// - Clean distraction-free reading layout (1.45 line-height, Inter)
/// - Top progress indicator
/// - Bookmark toggle in AppBar with instant reactive persistence
/// - Structured sections with clinical "Key Takeaway" callout boxes
/// - "Mark as complete" action at the end
/// - "Take quick quiz" next step card once completed
class LessonScreen extends ConsumerStatefulWidget {
  final LessonEntity lesson;

  const LessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0.15;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.15, 1.0);
      if (progress != _readingProgress) {
        setState(() {
          _readingProgress = progress;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    // Reactively watch for lesson updates (bookmark/completed status)
    final product = ref.watch(productLearningDetailProvider(widget.lesson.productId));
    final liveLesson = product?.lessons.firstWhere(
          (l) => l.id == widget.lesson.id,
          orElse: () => widget.lesson,
        ) ??
        widget.lesson;

    final isCompleted = liveLesson.isCompleted;
    final isBookmarked = liveLesson.isBookmarked;

    return AppScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              liveLesson.productName,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              liveLesson.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? LucideIcons.bookmark : LucideIcons.bookmark,
              color: isBookmarked ? colors.primary : colors.textSecondary,
              size: 22.0,
            ),
            tooltip: l10n.btnBookmarks,
            onPressed: () {
              ref.read(learnControllerProvider.notifier).toggleLessonBookmark(liveLesson.id);
            },
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: Column(
        children: [
          // Reading Progress Bar at top
          ProgressBar(
            value: isCompleted ? 1.0 : _readingProgress,
            height: 3.0,
            color: colors.primary,
          ),

          // Scrollable Reading Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info row
                  Row(
                    children: [
                      StatusBadge(
                        label: '${liveLesson.durationMinutes} min read',
                        variant: StatusBadgeVariant.neutral,
                        icon: LucideIcons.clock4,
                      ),
                      const SizedBox(width: RxSpacing.s8),
                      if (isCompleted)
                        StatusBadge(
                          label: l10n.completedBadge,
                          variant: StatusBadgeVariant.success,
                          showDot: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s12),

                  // Lesson Title
                  Text(
                    liveLesson.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s20),
                  Divider(
                    height: 1.0,
                    thickness: RxShadows.hairlineBorderWidth,
                    color: colors.border,
                  ),
                  const SizedBox(height: RxSpacing.s20),

                  // Lesson Sections
                  ...liveLesson.sections.asMap().entries.map((entry) {
                    final sectionIndex = entry.key + 1;
                    final section = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24.0,
                              height: 24.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.surfaceMuted,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                '$sectionIndex',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: RxSpacing.s8),
                            Expanded(
                              child: Text(
                                section.title,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: RxSpacing.s10),

                        // Section Content Body
                        Text(
                          section.content,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: RxSpacing.s12),

                        // Key Takeaway callout box
                        if (section.keyTakeaway != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: RxRadii.borderCard,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.25),
                                width: RxShadows.hairlineBorderWidth,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  LucideIcons.checkCircle,
                                  size: 16.0,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: RxSpacing.s10),
                                Expanded(
                                  child: Text(
                                    section.keyTakeaway!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s20),
                        ],
                        const SizedBox(height: RxSpacing.s12),
                      ],
                    );
                  }),

                  const SizedBox(height: RxSpacing.s20),
                  Divider(
                    height: 1.0,
                    thickness: RxShadows.hairlineBorderWidth,
                    color: colors.border,
                  ),
                  const SizedBox(height: RxSpacing.s24),

                  // Bottom Action Area
                  if (!isCompleted) ...[
                    AppButton(
                      text: l10n.markAsComplete,
                      leadingIcon: LucideIcons.checkCircle2,
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        ref
                            .read(learnControllerProvider.notifier)
                            .markLessonCompleted(liveLesson.id);
                      },
                    ),
                  ] else ...[
                    // Completed status & Next Step
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.checkCircle2,
                                size: 18.0,
                                color: colors.success,
                              ),
                              const SizedBox(width: RxSpacing.s8),
                              Text(
                                l10n.completedBadge,
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: RxSpacing.s8),
                          Text(
                            l10n.nextStep,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s4),
                          Text(
                            'Reinforce your detailing confidence with ${liveLesson.quizQuestionCount} quick clinical recall questions.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s16),
                          AppButton(
                            text: l10n.takeQuickQuiz,
                            leadingIcon: LucideIcons.helpCircle,
                            variant: AppButtonVariant.primary,
                            onPressed: () => _openQuickQuiz(context, liveLesson),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: RxSpacing.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQuickQuiz(BuildContext context, LessonEntity lesson) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      backgroundColor: colors.surface,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(LucideIcons.award, size: 20.0, color: colors.primary),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Recall Quiz',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          lesson.productName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s16),
              Text(
                'This quiz includes ${lesson.quizQuestionCount} questions testing key study endpoints and competitor differentiation points.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: RxSpacing.s24),
              AppButton(
                text: 'Start Quiz Now (+50 Pts)',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Quiz session initialized'),
                      backgroundColor: colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: RxSpacing.s8),
              AppButton(
                text: 'Review Later',
                variant: AppButtonVariant.ghost,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
