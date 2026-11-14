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
/// - Swiss-minimalist layout, high visual hierarchy
/// - Clean, crisp Medical Interface Preview Cards (no abstract doodles or arbitrary icons)
/// - Dots indicator, Language switcher, Skip, and a primary Next / Get started button
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
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
    final activeLocale = ref.watch(localeProvider);
    final isArabic = activeLocale.languageCode == 'ar';

    final slides = [
      _OnboardingSlideData(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        preview: _buildClinicalLearningPreview(context, colors, textTheme, isArabic),
      ),
      _OnboardingSlideData(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        preview: _buildLibraryPreview(context, colors, textTheme, isArabic),
      ),
      _OnboardingSlideData(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        preview: _buildFieldFeedbackPreview(context, colors, textTheme, isArabic),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: RxRadii.borderBadge,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.activity,
                  size: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Text(
              'RxEdge',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Instant Language Toggle
          TextButton.icon(
            icon: Icon(LucideIcons.globe, size: 15.0, color: colors.textSecondary),
            label: Text(
              isArabic ? 'English' : 'العربية',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            onPressed: () {
              final newLocale = isArabic ? const Locale('en') : const Locale('ar');
              ref.read(localeProvider.notifier).state = newLocale;
            },
          ),
          // Skip Action
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
                        // Clinical UI Preview Card
                        slide.preview,
                        const SizedBox(height: RxSpacing.s32),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: RxSpacing.s12),

                        // Description
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340.0),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Action Area: Indicator + Next/Get Started Button
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
                  // Minimalist Pill Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        margin: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s4),
                        width: isActive ? 24.0 : 8.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: isActive ? colors.primary : colors.border,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: RxSpacing.s20),

                  // Primary Next / Get Started Action
                  AppButton(
                    text: _currentPage == 2 ? l10n.getStarted : l10n.next,
                    variant: AppButtonVariant.primary,
                    trailingIcon: _currentPage == 2 ? LucideIcons.check : context.arrowForward,
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

  /// Slide 1 Hero: Clinical Product Learning Card
  Widget _buildClinicalLearningPreview(
    BuildContext context,
    RxColors colors,
    TextTheme textTheme,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340.0),
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
        boxShadow: RxShadows.floatingLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Tag & Monograph Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RxSpacing.s6,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: RxRadii.borderBadge,
                  ),
                  child: Text(
                    isArabic ? 'القلب والشرايين' : 'CARDIOLOGY',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 9.5,
                      color: colors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RxSpacing.s6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s4),
                    Flexible(
                      child: Text(
                        isArabic ? 'دراسة معتمدة' : 'Approved',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),

          // Product Name & Active Molecule
          Text(
            'LipidCare® 20mg',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: RxSpacing.s2),
          Text(
            isArabic ? 'أتورفاستاتين كالسيوم • ملخص الجرعات السريرية' : 'Atorvastatin Calcium • Clinical Dosing Guide',
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: RxSpacing.s14),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s8, vertical: RxSpacing.s6),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: RxRadii.borderBadge,
                    border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.bookOpen, size: 14.0, color: colors.primary),
                      const SizedBox(width: RxSpacing.s6),
                      Expanded(
                        child: Text(
                          isArabic ? '3 وحدات تدريبية' : '3 Core Modules',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: RxSpacing.s8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s8, vertical: RxSpacing.s6),
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: RxRadii.borderBadge,
                    border: Border.all(
                      color: colors.accent.withValues(alpha: 0.3),
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.award, size: 14.0, color: colors.accent),
                      const SizedBox(width: RxSpacing.s6),
                      Expanded(
                        child: Text(
                          isArabic ? 'إتقان 98% في الكويز' : '98% Quiz Mastery',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.accent,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),

          // Learning progress track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'مستوى الإنجاز المعرفي' : 'Learning Completion',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
              Text(
                '100%',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 5.0,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Slide 2 Hero: Medical Library & Digital Detailing Preview
  Widget _buildLibraryPreview(
    BuildContext context,
    RxColors colors,
    TextTheme textTheme,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340.0),
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
        boxShadow: RxShadows.floatingLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simulated Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s10, vertical: RxSpacing.s8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: RxRadii.borderInput,
              border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, size: 14.0, color: colors.textTertiary),
                const SizedBox(width: RxSpacing.s8),
                Expanded(
                  child: Text(
                    isArabic ? 'بحث في الدراسات والكتيبات المعتمدة...' : 'Search clinical trials, detailing decks...',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textTertiary,
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s6, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: RxRadii.borderBadge,
                  ),
                  child: Text(
                    'PDF',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s12),

          // Approved Document 1
          _buildDocumentRow(
            colors: colors,
            textTheme: textTheme,
            icon: LucideIcons.fileText,
            title: isArabic ? 'دراسة الفعالية السريرية Phase III' : 'Phase III Clinical Efficacy Study',
            meta: isArabic ? 'كتيب العرض العلمي المعتمد • 2.4 MB' : 'Approved Visual Aid • PDF • 2.4 MB',
            badgeText: isArabic ? 'معتمد' : 'Verified',
            badgeColor: colors.success,
            badgeBg: colors.successSoft,
          ),
          const SizedBox(height: RxSpacing.s8),

          // Approved Document 2
          _buildDocumentRow(
            colors: colors,
            textTheme: textTheme,
            icon: LucideIcons.barChart2,
            title: isArabic ? 'ملف الأمان وسلامة المرضى' : 'Cardiovascular Safety Profile',
            meta: isArabic ? '14 شريحة تفصيلية • الفريق الطبي' : '14 Detailing Slides • Medical Affairs',
            badgeText: isArabic ? 'محدث' : 'Updated',
            badgeColor: colors.info,
            badgeBg: colors.infoSoft,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow({
    required RxColors colors,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String meta,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: RxRadii.borderInput,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
      ),
      child: Row(
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: RxRadii.borderBadge,
              border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
            ),
            child: Center(
              child: Icon(icon, size: 16.0, color: colors.primary),
            ),
          ),
          const SizedBox(width: RxSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1.0),
                Text(
                  meta,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 10.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s6, vertical: 2.0),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: RxRadii.borderBadge,
            ),
            child: Text(
              badgeText,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Slide 3 Hero: Field Intelligence & Doctor Insights Preview
  Widget _buildFieldFeedbackPreview(
    BuildContext context,
    RxColors colors,
    TextTheme textTheme,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340.0),
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RxRadii.borderCard,
        border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
        boxShadow: RxShadows.floatingLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Field Tag & Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: RxRadii.borderBadge,
                      ),
                      child: Center(
                        child: Icon(LucideIcons.stethoscope, size: 12.0, color: colors.primary),
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s6),
                    Expanded(
                      child: Text(
                        isArabic ? 'عيادات القاهرة - وسط البلد' : 'Cairo Clinics • Region North',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RxSpacing.s6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: RxSpacing.s6, vertical: 2.0),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: RxRadii.borderBadge,
                ),
                child: Text(
                  isArabic ? 'اليوم' : 'Today',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 9.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),

          // Doctor Quote / Insight Bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: RxRadii.borderInput,
              border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.messageSquare, size: 14.0, color: colors.primary),
                    const SizedBox(width: RxSpacing.s6),
                    Text(
                      isArabic ? 'ملاحظة الطبيب على العينة' : 'Doctor Objection / Feedback',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s6),
                Text(
                  isArabic
                      ? '«استجابة ممتازة من المرضى لفاعلية الجرعة، ونحتاج عينات إضافية لمرضى السكري.»'
                      : '"Favorable patient response to daily efficacy; requested additional clinical samples."',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textPrimary,
                    fontStyle: FontStyle.italic,
                    fontSize: 11.0,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s12),

          // Marketing sync status
          Row(
            children: [
              Icon(LucideIcons.checkCheck, size: 14.0, color: colors.success),
              const SizedBox(width: RxSpacing.s6),
              Expanded(
                child: Text(
                  isArabic ? 'وصلت الملاحظة فوراً لمدير المنتج وفريق التسويق' : 'Delivered directly to Brand Marketing team',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.success,
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String description;
  final Widget preview;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.preview,
  });
}

