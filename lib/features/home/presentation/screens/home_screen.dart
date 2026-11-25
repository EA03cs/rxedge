import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/home_controller.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/monthly_challenge_card.dart';
import '../widgets/objection_quote_card.dart';
import '../widgets/personal_dashboard_card.dart';
import '../widgets/slim_stats_strip.dart';
import '../widgets/whats_new_section.dart';

/// Home Tab Screen
///
/// Goal: In 3 seconds the MR knows what to do today.
///
/// Executive Visual Hierarchy:
/// 1. Top Brand Header: Mentholatum logo, language pill, notification bell, user avatar.
/// 2. Personalized Greeting Row: Salutation, Rep First Name, Subtitle, 3D graduation cap illustration.
/// 3. Modern Pill Search Bar with circular teal filter action.
/// 4. Sapphire "Continue Learning" card with mint progress and glowing 3D heart hologram.
/// 5. Slim Stats Strip: 3 modern cards with pastel badges and bottom wave charts.
/// 6. Unified Quick Actions card: 4 pastel shortcuts (Visual Aid, Quick Quiz, Challenge, Log Voice).
/// 7. 3D Monthly Challenge card: Left dark teal block with 3D trophy, days left pill, progress, rank.
/// 8. Doctor Objection of the Month & What's New.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dashboardAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBF4FD), // Soft airy sky blue matching header
              Color(0xFFF1F7FD),
              Color(0xFFF8FAFC),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.22, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
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
                color: const Color(0xFF00807D),
                backgroundColor: Colors.white,
                onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Corporate Brand Header & Rep Greeting
                      const HomeHeader(),
                      const SizedBox(height: RxSpacing.s8),

                      // Global Search Bar
                      const HomeSearchBar(),
                      const SizedBox(height: RxSpacing.s16),

                      // 2. Continue Learning
                      ContinueLearningCard(
                        lesson: dashboard.continueLesson,
                        recommendedProduct: dashboard.recommendedProduct,
                      ),
                      const SizedBox(height: RxSpacing.s12),

                      // 3. Stats Strip
                      SlimStatsStrip(stats: dashboard.stats),
                      const SizedBox(height: RxSpacing.s12),

                      // 4. Quick Field Tools
                      const HomeQuickActions(),
                      const SizedBox(height: RxSpacing.s14),

                      // 5. Monthly Challenge
                      MonthlyChallengeCard(challenge: dashboard.challenge),
                      const SizedBox(height: RxSpacing.s14),

                      // 6. Personal Dashboard & Quarterly Badges
                      PersonalDashboardCard(stats: dashboard.stats),
                      const SizedBox(height: RxSpacing.s14),

                      // 6. Objection of the Month
                      ObjectionQuoteCard(objection: dashboard.objection),
                      const SizedBox(height: RxSpacing.s16),

                      // 7. What's New (compact 2-3 items)
                      WhatsNewSection(materials: dashboard.recentMaterials),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
