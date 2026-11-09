import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';
import '../controllers/learn_controller.dart';
import 'lesson_screen.dart';

/// Bookmarked Lessons Screen
///
/// Features:
/// - Quick scannable list of saved lessons across all therapeutic areas
/// - Direct one-tap navigation to lesson reader
/// - Instant unbookmark action with state reflection
/// - Clean empty state when no bookmarks are saved
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final bookmarkedLessons = ref.watch(bookmarkedLessonsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.bookmarksTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: bookmarkedLessons.isEmpty
          ? EmptyState(
              icon: LucideIcons.bookmark,
              title: l10n.emptyBookmarksTitle,
              description: l10n.emptyBookmarksDesc,
              actionText: l10n.btnBrowseLessons,
              onAction: () => Navigator.of(context).pop(),
            )
          : ListView.separated(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
              itemCount: bookmarkedLessons.length,
              separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s12),
              itemBuilder: (context, index) {
                final lesson = bookmarkedLessons[index];
                return _BookmarkedLessonCard(lesson: lesson);
              },
            ),
    );
  }
}

class _BookmarkedLessonCard extends ConsumerWidget {
  final LessonEntity lesson;

  const _BookmarkedLessonCard({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => LessonScreen(lesson: lesson),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product badge tag
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s8,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  lesson.productName,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.bookmark,
                  size: 20.0,
                  color: colors.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  ref
                      .read(learnControllerProvider.notifier)
                      .toggleLessonBookmark(lesson.id);
                },
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            lesson.title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: RxSpacing.s12),
          Row(
            children: [
              Icon(
                LucideIcons.clock4,
                size: 14.0,
                color: colors.textSecondary,
              ),
              const SizedBox(width: RxSpacing.s4),
              Text(
                '${lesson.durationMinutes} min read',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: RxSpacing.s12),
              if (lesson.isCompleted)
                const StatusBadge(
                  label: 'Completed',
                  variant: StatusBadgeVariant.success,
                  showDot: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
