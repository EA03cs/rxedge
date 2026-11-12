import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/notification_entities.dart';
import '../controllers/notifications_controller.dart';

/// Notifications Center Screen
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final notifsAsync = ref.watch(notificationsControllerProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.notificationsTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: unreadCount > 0
                ? () => ref.read(notificationsControllerProvider.notifier).markAllAsRead()
                : null,
            child: Text(
              l10n.btnMarkAllRead,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: unreadCount > 0 ? colors.primary : colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: RxSpacing.s8),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          title: l10n.unableLoadNotifications,
          description: err.toString().replaceAll('Exception: ', ''),
          retryText: l10n.retry,
          onRetry: () => ref.read(notificationsControllerProvider.notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: LucideIcons.bellOff,
              title: l10n.emptyNotificationsTitle,
              description: l10n.emptyNotificationsDesc,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsControllerProvider.notifier).refresh(),
            color: colors.primary,
            child: ListView.separated(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildNotificationCard(context, ref, item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationItemEntity item,
  ) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationsControllerProvider.notifier).markAsRead(item.id);
        }
        if (item.targetRoute != null && context.mounted) {
          final route = item.targetRoute!;
          if (route == AppRoutes.feedbackDetail) {
            final targetId = item.targetId?.trim();
            if (targetId != null && targetId.isNotEmpty) {
              context.push(
                '${AppRoutes.feedbackDetail}?id=${Uri.encodeQueryComponent(targetId)}',
              );
            } else {
              context.go(AppRoutes.feedback);
            }
          } else if (route == '/home' ||
              route == '/learn' ||
              route == '/library' ||
              route == '/challenges' ||
              route == '/feedback' ||
              route == '/profile') {
            context.go(route);
          } else {
            context.push(route);
          }
        }
      },
      borderRadius: RxRadii.borderCard,
      child: Container(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
        decoration: BoxDecoration(
          color: item.isRead ? colors.surface : colors.surfaceMuted,
          borderRadius: RxRadii.borderCard,
          border: Border.all(
            color: item.isRead ? colors.border : colors.primary.withValues(alpha: 0.3),
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: _getIconBgColor(context, item.type),
                borderRadius: RxRadii.borderButton,
              ),
              child: Icon(
                _getIcon(item.type),
                size: 20.0,
                color: _getIconFgColor(context, item.type),
              ),
            ),
            const SizedBox(width: RxSpacing.s12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s8),
                      Text(
                        _formatTime(context, item.timestamp),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s4),
                  Text(
                    item.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot indicator
            if (!item.isRead) ...[
              const SizedBox(width: RxSpacing.s8),
              Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsetsDirectional.only(top: RxSpacing.s6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newMaterial:
        return LucideIcons.fileText;
      case NotificationType.newChallenge:
        return LucideIcons.award;
      case NotificationType.feedbackReply:
        return LucideIcons.messagesSquare;
      case NotificationType.quizReminder:
        return LucideIcons.clock;
    }
  }

  Color _getIconBgColor(BuildContext context, NotificationType type) {
    final colors = context.rxColors;
    switch (type) {
      case NotificationType.newMaterial:
        return colors.infoSoft;
      case NotificationType.newChallenge:
        return colors.accentSoft;
      case NotificationType.feedbackReply:
        return colors.successSoft;
      case NotificationType.quizReminder:
        return colors.warningSoft;
    }
  }

  Color _getIconFgColor(BuildContext context, NotificationType type) {
    final colors = context.rxColors;
    switch (type) {
      case NotificationType.newMaterial:
        return colors.info;
      case NotificationType.newChallenge:
        return colors.accent;
      case NotificationType.feedbackReply:
        return colors.success;
      case NotificationType.quizReminder:
        return colors.warning;
    }
  }

  String _formatTime(BuildContext context, DateTime time) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return l10n.minAgoCount(diff.inMinutes.clamp(1, 59));
    } else if (diff.inHours < 24) {
      return l10n.hoursAgoCount(diff.inHours);
    } else {
      return l10n.daysAgoCount(diff.inDays);
    }
  }
}
