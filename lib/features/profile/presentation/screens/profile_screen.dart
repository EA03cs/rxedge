import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entities.dart';
import '../controllers/profile_controller.dart';

/// Comprehensive Profile & Settings Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final profileAsync = ref.watch(profileControllerProvider);
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          title: l10n.unableLoadProfile,
          description: err.toString().replaceAll('Exception: ', ''),
          retryText: l10n.retry,
          onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        ),
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Rep Profile Card
                _buildRepCard(context, profile),
                const SizedBox(height: RxSpacing.s16),

                // 2. Points, Streak & Badges (Amber Accent Strictly Here)
                _buildPointsAndBadgesCard(context, profile),
                const SizedBox(height: RxSpacing.s24),

                // 3. General Settings: Language & Theme
                SectionHeader(title: l10n.settingsGeneral),
                _buildGeneralSettingsCard(context, ref, activeLocale, activeThemeMode),
                const SizedBox(height: RxSpacing.s24),

                // 4. Notification Preferences
                SectionHeader(title: l10n.notificationPreferences),
                _buildNotificationPrefsCard(context, ref, profile.notificationPreferences),
                const SizedBox(height: RxSpacing.s24),

                // 5. Storage & Downloads
                SectionHeader(title: l10n.storageAndDownloads),
                _buildStorageCard(context, ref, profile),
                const SizedBox(height: RxSpacing.s24),

                // 6. Security & Company Support
                SectionHeader(title: l10n.supportAndSecurity),
                _buildSecurityCard(context),
                const SizedBox(height: RxSpacing.s24),

                // 7. Logout Button
                AppButton(
                  text: l10n.logoutTitle,
                  leadingIcon: LucideIcons.logOut,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _confirmLogout(context, ref),
                ),
                const SizedBox(height: RxSpacing.s16),

                // 8. App Version Footer
                Center(
                  child: Text(
                    l10n.appVersionLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(height: RxSpacing.s16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRepCard(BuildContext context, UserProfileEntity profile) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(profile.displayName),
              style: textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: RxSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: RxSpacing.s2),
                Text(
                  profile.role,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: RxSpacing.s6),
                Row(
                  children: [
                    StatusBadge(
                      label: '${l10n.employeeIdLabel}: ${profile.employeeId}',
                      variant: StatusBadgeVariant.neutral,
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    Expanded(
                      child: Text(
                        profile.territory,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textTertiary,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsAndBadgesCard(BuildContext context, UserProfileEntity profile) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.pointsAndBadges,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              StatusBadge(
                label: l10n.streakDaysLabel(profile.streakDays),
                variant: StatusBadgeVariant.accent,
                icon: LucideIcons.flame,
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),
          Row(
            children: [
              Icon(LucideIcons.award, size: 28.0, color: colors.accent),
              const SizedBox(width: RxSpacing.s10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.statPoints(profile.points),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.topTenTerritoryBadge,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),
          const Divider(height: 1.0),
          const SizedBox(height: RxSpacing.s12),
          Wrap(
            spacing: RxSpacing.s8,
            runSpacing: RxSpacing.s8,
            children: profile.badges.map((badge) {
              return StatusBadge(
                label: badge.name,
                variant: StatusBadgeVariant.accent,
                icon: LucideIcons.checkCircle2,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsCard(
    BuildContext context,
    WidgetRef ref,
    Locale activeLocale,
    ThemeMode activeThemeMode,
  ) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          // Language Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.globe, size: 18.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s10),
                  Text(
                    l10n.languagePreference,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'ar', label: Text('العربية')),
                ],
                selected: {activeLocale.languageCode},
                onSelectionChanged: (newVal) {
                  final nextLang = newVal.first;
                  ref.read(localeProvider.notifier).state = Locale(nextLang);
                  Future<void>.microtask(() async {
                    try {
                      await ref
                          .read(profileRepositoryProvider)
                          .updateLanguagePreference(nextLang);
                    } catch (_) {}
                  });
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s16),
          const Divider(height: 1.0),
          const SizedBox(height: RxSpacing.s16),

          // Theme Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.sunMedium, size: 18.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s10),
                  Text(
                    l10n.themePreference,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                  ),
                ],
                selected: {activeThemeMode},
                onSelectionChanged: (newVal) {
                  ref.read(themeModeProvider.notifier).state = newVal.first;
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPrefsCard(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferencesEntity prefs,
  ) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          _buildSwitchRow(
            title: l10n.prefNewMaterials,
            value: prefs.newMaterials,
            onChanged: (val) {
              ref.read(profileControllerProvider.notifier).updatePreferences(
                    prefs.copyWith(newMaterials: val),
                  );
            },
            context: context,
          ),
          const Divider(height: 1.0),
          _buildSwitchRow(
            title: l10n.prefChallenges,
            value: prefs.monthlyChallenges,
            onChanged: (val) {
              ref.read(profileControllerProvider.notifier).updatePreferences(
                    prefs.copyWith(monthlyChallenges: val),
                  );
            },
            context: context,
          ),
          const Divider(height: 1.0),
          _buildSwitchRow(
            title: l10n.prefFeedbackReplies,
            value: prefs.feedbackReplies,
            onChanged: (val) {
              ref.read(profileControllerProvider.notifier).updatePreferences(
                    prefs.copyWith(feedbackReplies: val),
                  );
            },
            context: context,
          ),
          const Divider(height: 1.0),
          _buildSwitchRow(
            title: l10n.prefQuizReminders,
            value: prefs.quizReminders,
            onChanged: (val) {
              ref.read(profileControllerProvider.notifier).updatePreferences(
                    prefs.copyWith(quizReminders: val),
                  );
            },
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: RxSpacing.s4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colors.primary.withValues(alpha: 0.5),
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.hardDrive, size: 18.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s10),
                  Text(
                    l10n.offlineStorageUsed(profile.formattedStorageSize),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: profile.storageUsageBytes > 0
                    ? l10n.storageStatusDownloaded
                    : l10n.storageStatusEmpty,
                variant: profile.storageUsageBytes > 0
                    ? StatusBadgeVariant.info
                    : StatusBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),
          Text(
            l10n.offlineStorageDesc,
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: RxSpacing.s16),
          AppButton(
            text: l10n.btnClearDownloads,
            variant: AppButtonVariant.secondary,
            leadingIcon: LucideIcons.trash2,
            isFullWidth: false,
            onPressed: profile.storageUsageBytes <= 0
                ? null
                : () => _confirmClearDownloads(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          // Change password
          InkWell(
            onTap: () => _showChangePasswordModal(context),
            borderRadius: RxRadii.borderButton,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: RxSpacing.s8),
              child: Row(
                children: [
                  Icon(LucideIcons.keyRound, size: 18.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Text(
                      l10n.changePasswordTitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(context.chevronForward, size: 18.0, color: colors.textTertiary),
                ],
              ),
            ),
          ),
          const Divider(height: 1.0),
          // Contact Marketing
          InkWell(
            onTap: () => _showContactMarketingModal(context),
            borderRadius: RxRadii.borderButton,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: RxSpacing.s8),
              child: Row(
                children: [
                  Icon(LucideIcons.helpCircle, size: 18.0, color: colors.textSecondary),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Text(
                      l10n.contactMarketingTitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(context.chevronForward, size: 18.0, color: colors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearDownloads(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.btnClearDownloads),
        content: Text(l10n.clearDownloadsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(profileControllerProvider.notifier).clearDownloads();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.downloadsClearedToast)),
                );
              }
            },
            child: Text(l10n.btnClear),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(l10n.logoutTitle),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.rxColors;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changePasswordTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),
              Text(
                l10n.changePasswordDesc,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppButton(
                text: l10n.btnClose,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactMarketingModal(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.rxColors;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.contactMarketingTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s12),
              Row(
                children: [
                  Icon(LucideIcons.mail, size: 18.0, color: colors.primary),
                  const SizedBox(width: RxSpacing.s10),
                  Text(
                    l10n.contactMarketingEmail,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s8),
              Row(
                children: [
                  Icon(LucideIcons.phone, size: 18.0, color: colors.primary),
                  const SizedBox(width: RxSpacing.s10),
                  Text(
                    l10n.contactMarketingPhone,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s16),
              AppButton(
                text: l10n.btnClose,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'MR';
  }
}
