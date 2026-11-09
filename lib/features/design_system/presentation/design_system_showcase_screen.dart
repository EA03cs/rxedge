import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/components/components.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/theme/theme.dart';

class DesignSystemShowcaseScreen extends ConsumerStatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  ConsumerState<DesignSystemShowcaseScreen> createState() => _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState extends ConsumerState<DesignSystemShowcaseScreen> {
  int _navIndex = 0;
  bool _isLoadingButton = false;
  final Set<String> _selectedSpecialties = {'Cardiology', 'Oncology'};
  final TextEditingController _searchController = TextEditingController(text: 'Atorvastatin 20mg');
  final TextEditingController _doctorController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeProvider);
    final isOffline = ref.watch(isOfflineProvider);
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = [
      NavItemData(icon: LucideIcons.fileText, label: l10n.navHome),
      NavItemData(icon: LucideIcons.pill, label: l10n.navProducts),
      NavItemData(icon: LucideIcons.graduationCap, label: l10n.navLearning, badge: '2'),
      NavItemData(icon: LucideIcons.calendar, label: l10n.navSchedule),
      NavItemData(icon: LucideIcons.user, label: l10n.navProfile),
    ];

    return AppScaffold(
      isOffline: isOffline,
      offlineMessage: l10n.offlineNotice,
      onOfflineRetry: () {
        ref.read(isOfflineProvider.notifier).state = false;
      },
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(RxSpacing.s6),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                LucideIcons.activity,
                size: 20.0,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: RxSpacing.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  l10n.showcaseTitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Toggle
          IconButton(
            tooltip: l10n.toggleTheme,
            icon: Icon(
              isDark ? LucideIcons.sun : LucideIcons.moon,
              size: 20.0,
              color: colors.textPrimary,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // Language / RTL Toggle
          TextButton(
            onPressed: () {
              final newLocale = currentLocale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              ref.read(localeProvider.notifier).state = newLocale;
            },
            child: Text(
              currentLocale.languageCode == 'en' ? 'العربية' : 'EN',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.0,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        items: navItems,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Control Strip
            _buildControlStrip(context, isDark, currentLocale.languageCode, isOffline),
            const SizedBox(height: RxSpacing.s24),

            // 1. Color System Palette
            SectionHeader(
              title: l10n.colorsSection,
              subtitle: 'Strictly flat 90% white/neutral palette with deep teal and restrained amber',
            ),
            _buildColorPalette(context),
            const SizedBox(height: RxSpacing.s32),

            // 2. Typography Scale
            SectionHeader(
              title: l10n.typographySection,
              subtitle: currentLocale.languageCode == 'ar'
                  ? 'خط IBM Plex Sans Arabic للأوزان والواجهات العربية'
                  : 'Inter for crisp Latin type, 1.45 body line-height, tight headings',
            ),
            _buildTypographySection(context),
            const SizedBox(height: RxSpacing.s32),

            // 3. Buttons Showcase
            SectionHeader(
              title: l10n.buttonsSection,
              subtitle: '48dp min touch targets, 10dp radius, no gradients',
              action: AppChip(
                label: _isLoadingButton ? 'Stop Loading' : 'Test Loading',
                isSelected: _isLoadingButton,
                isCompact: true,
                onSelected: (val) => setState(() => _isLoadingButton = val),
              ),
            ),
            _buildButtonsSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 4. Text Fields
            SectionHeader(
              title: l10n.textFieldsSection,
              subtitle: '12dp radius, 1px border, high contrast, RTL aware',
            ),
            _buildTextFieldsSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 5. Cards & Surface Elevation
            SectionHeader(
              title: l10n.cardsSection,
              subtitle: '12dp radius, depth from 1px hairline border, subtle surface tints',
            ),
            _buildCardsSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 6. Chips & Filter Pills
            SectionHeader(
              title: l10n.chipsSection,
              subtitle: '999dp pill radius for quick specialty filtering during field visits',
            ),
            _buildChipsSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 7. Status Badges
            SectionHeader(
              title: l10n.badgesSection,
              subtitle: '6dp radius, soft tints; Amber accent reserved for streaks & points',
            ),
            _buildBadgesSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 8. Progress Indicators
            SectionHeader(
              title: l10n.progressSection,
              subtitle: 'Visual quota & curriculum indicators for fast one-handed status scans',
            ),
            _buildProgressSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 9. Skeletons
            SectionHeader(
              title: 'Loading Skeletons',
              subtitle: 'Subtle calm opacity pulse for zero layout shifts during offline cache fetch',
            ),
            _buildSkeletonsSection(context),
            const SizedBox(height: RxSpacing.s32),

            // 10. States: Empty & Error
            SectionHeader(
              title: l10n.feedbackSection,
              subtitle: 'Designed empty & error states with plain human language and clear CTAs',
            ),
            _buildStatesSection(context),
            const SizedBox(height: RxSpacing.s48),
          ],
        ),
      ),
    );
  }

  Widget _buildControlStrip(BuildContext context, bool isDark, String lang, bool isOffline) {
    final colors = context.rxColors;

    return AppCard(
      variant: AppCardVariant.muted,
      padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: RxSpacing.s8,
              runSpacing: RxSpacing.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge(
                  label: isDark ? 'Dark Theme' : 'Light Theme',
                  variant: StatusBadgeVariant.neutral,
                  icon: isDark ? LucideIcons.moon : LucideIcons.sun,
                ),
                StatusBadge(
                  label: lang == 'ar' ? 'Arabic (RTL)' : 'English (LTR)',
                  variant: StatusBadgeVariant.info,
                  icon: LucideIcons.globe,
                ),
                StatusBadge(
                  label: isOffline ? 'Offline Active' : 'Online Sync OK',
                  variant: isOffline ? StatusBadgeVariant.warning : StatusBadgeVariant.success,
                  showDot: true,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(isOfflineProvider.notifier).state = !isOffline;
            },
            borderRadius: RxRadii.borderButton,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s8, vertical: RxSpacing.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOffline ? LucideIcons.wifi : LucideIcons.wifiOff,
                    size: 16.0,
                    color: colors.primary,
                  ),
                  const SizedBox(width: RxSpacing.s4),
                  Text(
                    isOffline ? 'Go Online' : 'Simulate Offline',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context) {
    final colors = context.rxColors;

    final swatches = [
      _ColorItem('Primary Teal', '#0E6B6B', colors.primary, Colors.white),
      _ColorItem('Primary Soft', '#E7F2F2', colors.primarySoft, colors.primary),
      _ColorItem('Accent Amber', '#D9930D', colors.accent, Colors.white),
      _ColorItem('Accent Soft', '#FBF1DC', colors.accentSoft, colors.accent),
      _ColorItem('Surface Muted', '#F6F7F9', colors.surfaceMuted, colors.textPrimary),
      _ColorItem('Border', '#E7E9EE', colors.border, colors.textSecondary),
      _ColorItem('Success', '#168A4A', colors.success, Colors.white),
      _ColorItem('Warning', '#C26A0A', colors.warning, Colors.white),
      _ColorItem('Error', '#C93A3A', colors.error, Colors.white),
      _ColorItem('Info', '#2F5FD0', colors.info, Colors.white),
    ];

    return Wrap(
      spacing: RxSpacing.s8,
      runSpacing: RxSpacing.s8,
      children: swatches.map((item) {
        return Container(
          width: 105.0,
          padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.6),
              width: RxShadows.hairlineBorderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: item.textColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: RxSpacing.s2),
              Text(
                item.hex,
                style: TextStyle(
                  color: item.textColor.withValues(alpha: 0.85),
                  fontSize: 10.0,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display Large (28sp w600)',
            style: textTheme.displayLarge,
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            'Headline Large: Efficacy Study Phase III (22sp)',
            style: textTheme.headlineLarge,
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            'Title Medium: Cardiovascular Product Monograph (16sp)',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            'Body Medium: Standard clinical notes with comfortable 1.45 line-height for rapid scanning between doctor clinics and hospital rounds. (14sp)',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            'Label Medium: DOSAGE REGIMEN & CONTRAINDICATIONS (12sp)',
            style: textTheme.labelMedium?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        AppButton(
          text: l10n.btnPrimary,
          leadingIcon: LucideIcons.send,
          isLoading: _isLoadingButton,
          variant: AppButtonVariant.primary,
          onPressed: () {},
        ),
        const SizedBox(height: RxSpacing.s12),
        AppButton(
          text: l10n.btnSecondary,
          leadingIcon: LucideIcons.downloadCloud,
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
        const SizedBox(height: RxSpacing.s12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: l10n.btnGhost,
                leadingIcon: LucideIcons.eye,
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: RxSpacing.s12),
            Expanded(
              child: AppButton(
                text: l10n.btnDestructive,
                leadingIcon: LucideIcons.trash2,
                variant: AppButtonVariant.destructive,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s12),
        Row(
          children: [
            AppButton(
              text: 'Compact 36dp',
              size: AppButtonSize.small,
              isFullWidth: false,
              variant: AppButtonVariant.primary,
              onPressed: () {},
            ),
            const SizedBox(width: RxSpacing.s8),
            AppButton(
              text: 'Disabled',
              size: AppButtonSize.small,
              isFullWidth: false,
              variant: AppButtonVariant.secondary,
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldsSection(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;

    return Column(
      children: [
        AppTextField(
          label: l10n.inputLabel,
          hint: l10n.inputPlaceholder,
          helperText: l10n.inputHelper,
          controller: _doctorController,
          prefixIcon: Icon(LucideIcons.userCheck, size: 18.0, color: colors.textSecondary),
        ),
        const SizedBox(height: RxSpacing.s16),
        AppTextField(
          label: 'Product Monograph Search',
          hint: l10n.searchHint,
          controller: _searchController,
          clearable: true,
          prefixIcon: Icon(LucideIcons.search, size: 18.0, color: colors.textSecondary),
        ),
        const SizedBox(height: RxSpacing.s16),
        AppTextField(
          label: 'Sample Batch Code',
          initialValue: 'LOT-9921-X',
          errorText: 'Verification failed: Batch requires re-authentication',
          prefixIcon: Icon(LucideIcons.shieldAlert, size: 18.0, color: colors.error),
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Interactive MR Doctor Visit Card
        AppCard(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: 'Scheduled 11:30 AM',
                    variant: StatusBadgeVariant.info,
                    icon: LucideIcons.clock,
                  ),
                  const StatusBadge(
                    label: 'Cardiology',
                    variant: StatusBadgeVariant.neutral,
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s12),
              Text(
                'Dr. Robert Vance, MD',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s4),
              Text(
                'Metro General Hospital • Wing B, Suite 402',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: RxSpacing.s16),
              Divider(color: colors.border, height: 1.0),
              const SizedBox(height: RxSpacing.s12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detailing: Lipid Management Study v3',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16.0,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: RxSpacing.s12),
        // Muted Surface Card
        AppCard(
          variant: AppCardVariant.muted,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  size: 20.0,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: RxSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Materials Cached',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s2),
                    Text(
                      '14 product dossiers available for offline presentation',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSection(BuildContext context) {
    final specialties = ['Cardiology', 'Oncology', 'Pediatrics', 'Neurology', 'Endocrinology'];

    return Wrap(
      spacing: RxSpacing.s8,
      runSpacing: RxSpacing.s8,
      children: specialties.map((item) {
        final isSelected = _selectedSpecialties.contains(item);
        return AppChip(
          label: item,
          isSelected: isSelected,
          icon: isSelected ? LucideIcons.check : null,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSpecialties.add(item);
              } else {
                _selectedSpecialties.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return const Wrap(
      spacing: RxSpacing.s8,
      runSpacing: RxSpacing.s8,
      children: [
        StatusBadge(
          label: 'Approved (Phase III)',
          variant: StatusBadgeVariant.success,
          showDot: true,
        ),
        StatusBadge(
          label: 'Pending Ethics Review',
          variant: StatusBadgeVariant.warning,
          showDot: true,
        ),
        StatusBadge(
          label: 'Contraindicated',
          variant: StatusBadgeVariant.error,
          showDot: true,
        ),
        StatusBadge(
          label: 'New Protocol v2.4',
          variant: StatusBadgeVariant.info,
          icon: LucideIcons.info,
        ),
        StatusBadge(
          label: 'Draft Dossier',
          variant: StatusBadgeVariant.neutral,
        ),
        StatusBadge(
          label: 'Streak: 7 Days 🔥 (350 Pts)',
          variant: StatusBadgeVariant.accent,
          icon: LucideIcons.award,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final colors = context.rxColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ProgressRing(
                value: 0.78,
                size: 56.0,
                strokeWidth: 5.0,
              ),
              const SizedBox(width: RxSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Territory Quota',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s2),
                    Text(
                      '7 of 9 scheduled doctor visits completed',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s20),
          const ProgressBar(
            value: 0.65,
            height: 6.0,
            label: 'Oncology Detailing Certification',
            trailingText: '13/20 Modules',
          ),
          const SizedBox(height: RxSpacing.s16),
          ProgressBar(
            value: 1.0,
            height: 6.0,
            color: colors.success,
            label: 'Compliance & Pharmacovigilance 2026',
            trailingText: 'Completed (100%)',
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonsSection(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox.circle(size: 40.0),
              SizedBox(width: RxSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox.text(width: 140.0, height: 14.0),
                    SizedBox(height: RxSpacing.s6),
                    SkeletonBox.text(width: 200.0, height: 11.0),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: RxSpacing.s16),
          SkeletonBox(
            width: double.infinity,
            height: 36.0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatesSection(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Designed Empty State inside AppCard
        AppCard(
          child: EmptyState(
            title: l10n.emptyStateTitle,
            description: l10n.emptyStateDescription,
            actionText: l10n.emptyStateAction,
            onAction: () {},
          ),
        ),
        const SizedBox(height: RxSpacing.s16),
        // Designed Error State inside AppCard
        AppCard(
          child: ErrorState(
            title: l10n.errorStateTitle,
            description: l10n.errorStateDescription,
            retryText: l10n.errorStateRetry,
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}

class _ColorItem {
  final String name;
  final String hex;
  final Color color;
  final Color textColor;

  const _ColorItem(this.name, this.hex, this.color, this.textColor);
}
