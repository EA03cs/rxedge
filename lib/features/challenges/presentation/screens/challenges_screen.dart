import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/challenges_controller.dart';
import '../widgets/challenges_skeleton_loader.dart';
import '../widgets/monthly_challenge_view.dart';
import '../widgets/objection_of_month_view.dart';
import '../widgets/quick_quizzes_view.dart';
import 'history_screen.dart';

/// Field Challenges Tab (Tab 3)
///
/// Features:
/// - Distinctive champion gradient header with 3D Gold Trophy illustration
/// - 3-Section Segmented Pill Switcher (Monthly Challenge, Quick Quizzes, Objection of Month)
/// - Top action: History of past challenges & quiz scores in circular elevated button
/// - Restrained professional gamification with amber & sapphire accents
/// - Full offline support, skeletons, error retry, and pull-to-refresh
class ChallengesScreen extends ConsumerStatefulWidget {
  final int? initialTabIndex;

  const ChallengesScreen({
    super.key,
    this.initialTabIndex,
  });

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(challengesControllerProvider.notifier)
              .setTabIndex(widget.initialTabIndex!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final challengesAsync = ref.watch(challengesControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF), // Soft ice blue
              Color(0xFFFEF3C7), // Champagne gold ambient trophy glow
              Color(0xFFF1F7FD),
              Color(0xFFF8FAFC),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.16, 0.32, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: challengesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsetsDirectional.only(top: 16.0),
              child: ChallengesSkeletonLoader(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                child: ErrorState(
                  title: l10n.errorStateTitle,
                  description: err.toString().replaceAll('Exception: ', ''),
                  retryText: l10n.errorStateRetry,
                  onRetry: () => ref.read(challengesControllerProvider.notifier).refresh(),
                ),
              ),
            ),
            data: (state) {
              final selectedTab = state.selectedTabIndex;

              return RefreshIndicator(
                color: colors.primary,
                backgroundColor: colors.surface,
                onRefresh: () => ref.read(challengesControllerProvider.notifier).refresh(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Bar: History Button (Elevated circular button)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(LucideIcons.history, size: 18.0),
                              color: const Color(0xFF0F172A),
                              padding: EdgeInsets.zero,
                              tooltip: l10n.btnHistory,
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push<void>(
                                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Hero Header Banner: Title + Subtitle + 3D Trophy Asset
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.challengesTitle,
                                  style: const TextStyle(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                const Text(
                                  'Compete in monthly sprints, test clinical recall, and climb district ranks',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF64748B),
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Image.asset(
                            'assets/images/home_trophy_3d.png',
                            width: 105.0,
                            height: 92.0,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // 3. Segmented Pill Switcher
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _ChallengePillTab(
                            label: l10n.tabMonthlyChallenge,
                            icon: LucideIcons.trophy,
                            isSelected: selectedTab == 0,
                            onTap: () => ref
                                .read(challengesControllerProvider.notifier)
                                .setTabIndex(0),
                          ),
                          const SizedBox(width: 8.0),
                          _ChallengePillTab(
                            label: l10n.tabQuickQuizzes,
                            icon: LucideIcons.zap,
                            isSelected: selectedTab == 1,
                            onTap: () => ref
                                .read(challengesControllerProvider.notifier)
                                .setTabIndex(1),
                          ),
                          const SizedBox(width: 8.0),
                          _ChallengePillTab(
                            label: l10n.tabObjection,
                            icon: LucideIcons.target,
                            isSelected: selectedTab == 2,
                            onTap: () => ref
                                .read(challengesControllerProvider.notifier)
                                .setTabIndex(2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // 4. Active Tab Content
                    Expanded(
                      child: IndexedStack(
                        index: selectedTab,
                        children: [
                          MonthlyChallengeView(challenge: state.monthlyChallenge),
                          QuickQuizzesView(quizzes: state.quizzes),
                          ObjectionOfMonthView(objection: state.objection),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChallengePillTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChallengePillTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF005CA8) : Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            border: isSelected
                ? null
                : Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF005CA8).withValues(alpha: 0.28),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.0,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
