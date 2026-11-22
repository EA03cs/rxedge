import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/mentholatum_logo.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../controllers/home_controller.dart';

/// Top Header of the Home Screen
///
/// Features:
/// 1. Greeting + Rep First Name ("Good morning, Alex")
/// 2. User Avatar circle with initials (opens Profile / System info)
/// 3. Notification bell icon button with unread dot
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _getGreeting(BuildContext context, String firstName) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.greetingMorning(firstName);
    } else if (hour < 17) {
      return l10n.greetingAfternoon(firstName);
    } else {
      return l10n.greetingEvening(firstName);
    }
  }

  String _getInitials(String displayName) {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'MR';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    final displayName = user?.displayName ?? l10n.defaultRepName;
    final firstName = displayName.split(' ').first;
    final territory = user?.territory ?? l10n.dailyDetailingItinerary;
    final greeting = _getGreeting(context, firstName);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s16,
        vertical: RxSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Corporate Brand Bar (Mentholatum Logo + Actions)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MentholatumLogo(height: 24.0),
              const Spacer(),

              // Quick Language Switcher
              Consumer(
                builder: (context, ref, _) {
                  final activeLocale = ref.watch(localeProvider);
                  final isArabic = activeLocale.languageCode == 'ar';
                  return InkWell(
                    onTap: () {
                      final newLocale = isArabic ? const Locale('en') : const Locale('ar');
                      ref.read(localeProvider.notifier).state = newLocale;
                      ref.read(homeControllerProvider.notifier).refresh();
                    },
                    borderRadius: RxRadii.borderBadge,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: RxSpacing.s8,
                        vertical: RxSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: RxRadii.borderBadge,
                        border: Border.all(
                          color: colors.border,
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Text(
                        isArabic ? 'EN' : 'عربي',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: RxSpacing.s4),

              // Notification Bell with vibrant Mentholatum Red unread dot
              Consumer(
                builder: (context, ref, _) {
                  final unreadCount = ref.watch(unreadNotificationsCountProvider);
                  return Semantics(
                    button: true,
                    label: l10n.notificationsTooltip,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.bell,
                            size: 20.0,
                            color: colors.textPrimary,
                          ),
                          tooltip: l10n.notificationsTooltip,
                          onPressed: () => context.push(AppRoutes.notifications),
                        ),
                        if (unreadCount > 0)
                          PositionedDirectional(
                            top: 10.0,
                            end: 10.0,
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: colors.brandRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Profile Avatar circle (opens Profile)
              Semantics(
                button: true,
                label: l10n.profileTooltip,
                child: InkWell(
                  onTap: () => context.push(AppRoutes.profile),
                  borderRadius: BorderRadius.circular(RxSpacing.s20),
                  child: Container(
                    width: 36.0,
                    height: 36.0,
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
                      _getInitials(displayName),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s12),

          // 2. Greeting & Rep Territory / Status Subtitle
          Text(
            greeting,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: RxSpacing.s2),
          Text(
            territory,
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 12.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
