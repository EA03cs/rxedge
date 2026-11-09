import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';

/// RxEdge Offline Banner
///
/// Follows UX Law:
/// "Every screen has designed offline states. Calm, confident, non-blocking."
class OfflineBanner extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isVisible;

  const OfflineBanner({
    super.key,
    this.message,
    this.onRetry,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s16,
        vertical: RxSpacing.s8,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: colors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Icon(
              LucideIcons.wifiOff,
              size: 15.0,
              color: colors.textSecondary,
            ),
            const SizedBox(width: RxSpacing.s8),
            Expanded(
              child: Text(
                message ?? "You're offline. Changes are saved locally.",
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: RxSpacing.s8),
              InkWell(
                onTap: onRetry,
                borderRadius: RxRadii.borderButton,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s6, vertical: RxSpacing.s2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.rotateCw,
                        size: 13.0,
                        color: colors.primary,
                      ),
                      const SizedBox(width: RxSpacing.s4),
                      Text(
                        'Retry',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
