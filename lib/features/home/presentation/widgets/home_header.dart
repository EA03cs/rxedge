import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';

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
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    final displayName = user?.displayName ?? 'Field Representative';
    final firstName = displayName.split(' ').first;
    final territory = user?.territory ?? 'Daily Detailing Itinerary';
    final greeting = _getGreeting(context, firstName);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s16,
        vertical: RxSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar circle (Tapping opens Profile/Diagnostics)
          Semantics(
            button: true,
            label: 'Profile for $displayName',
            child: InkWell(
              onTap: () => context.push(AppRoutes.profile),
              borderRadius: BorderRadius.circular(RxSpacing.s20),
              child: Container(
                width: 40.0,
                height: 40.0,
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
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: RxSpacing.s12),

          // 2. Greeting & Territory subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RxSpacing.s2),
                Text(
                  territory,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Notification Bell with unread dot
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(unreadNotificationsCountProvider);
              return Semantics(
                button: true,
                label: 'Notifications',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.bell,
                        size: 20.0,
                        color: colors.textPrimary,
                      ),
                      tooltip: 'Notifications',
                      onPressed: () => context.push(AppRoutes.notifications),
                    ),
                    if (unreadCount > 0)
                      PositionedDirectional(
                        top: 10.0,
                        end: 10.0,
                        child: Container(
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            color: colors.primary,
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
        ],
      ),
    );
  }
}
