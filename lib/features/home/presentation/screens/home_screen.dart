import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/home_controller.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/monthly_challenge_card.dart';
import '../widgets/objection_quote_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/slim_stats_strip.dart';
import '../widgets/whats_new_section.dart';

/// Home Tab Screen
///
/// Goal: In 3 seconds the MR knows what to do today.
///
/// Layout (Top to bottom, white background, generous spacing):
/// 1. Header: greeting + first name, avatar (opens Profile), notification bell with unread dot.
/// 2. Search bar (opens global search).
/// 3. "Continue learning" card: last lesson, product name, progress bar, single primary button. If nothing started: "Start with [recommended product]".
/// 4. "This month's challenge": title, days left, my progress, rank. Tap opens Challenges.
/// 5. "Objection of the Month": quote-style card with doctor objection and "See how to respond" action.
/// 6. Quick actions row (3 items): Quick quiz, Send feedback, Search library.
/// 7. "What's new": list of recently added/updated materials with New/Updated badges.
/// 8. Slim stats strip: points, streak, quizzes completed (ACCENT AMBER ONLY HERE).
///
/// Strict Rules:
/// - No more than ONE filled primary button visible at a time (on Continue learning card).
/// - Skeleton loading for each section independently.
/// - Empty states for new users.
/// - Pull to refresh.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final dashboardAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const HomeSkeletonLoader(),
          error: (error, _) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
              child: ErrorState(
                title: l10n.errorStateTitle,
                description: l10n.errorStateDescription,
                retryText: l10n.retry,
                onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
              ),
            ),
          ),
          data: (dashboard) {
            return RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.surface,
              onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    const HomeHeader(),
                    const SizedBox(height: RxSpacing.s4),

                    // 2. Search bar
                    const HomeSearchBar(),
                    const SizedBox(height: RxSpacing.s16),

                    // 3. Continue learning card (Single filled primary button on screen)
                    ContinueLearningCard(
                      lesson: dashboard.continueLesson,
                      recommendedProduct: dashboard.recommendedProduct,
                    ),
                    const SizedBox(height: RxSpacing.s16),

                    // 4. This month's challenge
                    MonthlyChallengeCard(challenge: dashboard.challenge),
                    const SizedBox(height: RxSpacing.s16),

                    // 5. Objection of the month (Secondary outline button)
                    ObjectionQuoteCard(objection: dashboard.objection),
                    const SizedBox(height: RxSpacing.s20),

                    // 6. Quick actions row (3 items)
                    const QuickActionsRow(),
                    const SizedBox(height: RxSpacing.s20),

                    // 7. What's new list
                    WhatsNewSection(materials: dashboard.recentMaterials),
                    const SizedBox(height: RxSpacing.s20),

                    // 8. Slim stats strip (Accent amber ONLY here)
                    SlimStatsStrip(stats: dashboard.stats),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
