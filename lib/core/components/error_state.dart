import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';
import 'app_button.dart';

/// RxEdge Error State Widget
///
/// Follows UX Law:
/// "Every screen has designed error (plain message + Retry). Never show raw errors or status codes."
class ErrorState extends StatelessWidget {
  final String title;
  final String description;
  final String retryText;
  final VoidCallback? onRetry;
  final IconData icon;
  final EdgeInsetsDirectional padding;

  const ErrorState({
    super.key,
    required this.title,
    required this.description,
    this.retryText = 'Retry',
    this.onRetry,
    this.icon = LucideIcons.alertCircle,
    this.padding = const EdgeInsetsDirectional.all(RxSpacing.s24),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: colors.errorSoft,
                borderRadius: RxRadii.borderCard,
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.2),
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24.0,
                  color: colors.error,
                ),
              ),
            ),
            const SizedBox(height: RxSpacing.s20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: RxSpacing.s8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: RxSpacing.s24),
              SizedBox(
                width: 180.0,
                child: AppButton(
                  text: retryText,
                  onPressed: onRetry,
                  variant: AppButtonVariant.secondary,
                  leadingIcon: LucideIcons.rotateCw,
                  isFullWidth: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
