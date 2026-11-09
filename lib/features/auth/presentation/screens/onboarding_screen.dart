import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

/// Onboarding Screen
///
/// Follows Design & UX Specifications:
/// "2. Onboarding (first launch only, skippable): 3 slides with simple flat illustrations
/// (geometric, single-color + tint, no gradients).
/// Titles: 'Learn every product', 'Find any material in seconds', 'Tell marketing what you see in the field'.
/// One-line description each. Dots indicator, Skip, and a primary Next/Get started button."
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    ref.read(authControllerProvider.notifier).completeOnboarding();
    context.go(AppRoutes.login);
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final slides = [
      _OnboardingSlideData(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        illustration: _buildSlideIllustration1(colors),
      ),
      _OnboardingSlideData(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        illustration: _buildSlideIllustration2(colors),
      ),
      _OnboardingSlideData(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        illustration: _buildSlideIllustration3(colors),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: Text(
              l10n.skip,
              style: textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Geometric, single-color + tint illustration
                        slide.illustration,
                        const SizedBox(height: RxSpacing.s40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: RxSpacing.s12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320.0),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Action Area: Dots indicator + Next/Get Started Button
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                RxSpacing.s24,
                RxSpacing.s16,
                RxSpacing.s24,
                RxSpacing.s24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flat Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        margin: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s4),
                        width: isActive ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: isActive ? colors.primary : colors.border,
                          borderRadius: RxRadii.borderChip,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: RxSpacing.s24),
                  AppButton(
                    text: _currentPage == 2 ? l10n.getStarted : l10n.next,
                    variant: AppButtonVariant.primary,
                    trailingIcon: _currentPage == 2 ? LucideIcons.check : LucideIcons.arrowRight,
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Flat Illustration 1: "Learn every product"
  Widget _buildSlideIllustration1(RxColors colors) {
    return Container(
      width: 200.0,
      height: 160.0,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140.0,
            height: 90.0,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
            ),
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
                const SizedBox(height: RxSpacing.s8),
                Container(
                  width: 100.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: RxSpacing.s4),
                Container(
                  width: 80.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 20.0,
            end: 24.0,
            child: Container(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                size: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Flat Illustration 2: "Find any material in seconds"
  Widget _buildSlideIllustration2(RxColors colors) {
    return Container(
      width: 200.0,
      height: 160.0,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDocTile(colors, LucideIcons.fileText),
              const SizedBox(width: RxSpacing.s8),
              _buildDocTile(colors, LucideIcons.barChart2),
              const SizedBox(width: RxSpacing.s8),
              _buildDocTile(colors, LucideIcons.shieldCheck),
            ],
          ),
          PositionedDirectional(
            bottom: 24.0,
            end: 32.0,
            child: Container(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(
                LucideIcons.search,
                size: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(RxColors colors, IconData icon) {
    return Container(
      width: 44.0,
      height: 58.0,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
      ),
      child: Center(
        child: Icon(icon, size: 20.0, color: colors.textSecondary),
      ),
    );
  }

  /// Flat Illustration 3: "Tell marketing what you see in the field"
  Widget _buildSlideIllustration3(RxColors colors) {
    return Container(
      width: 200.0,
      height: 160.0,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140.0,
            height: 70.0,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
            ),
            padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
            child: Row(
              children: [
                Icon(LucideIcons.messageSquare, size: 18.0, color: colors.primary),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 50, height: 4, color: colors.primary),
                      const SizedBox(height: 4),
                      Container(width: 70, height: 4, color: colors.border),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 20.0,
            start: 24.0,
            child: Container(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s6),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: const Icon(LucideIcons.send, size: 14.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String description;
  final Widget illustration;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}
