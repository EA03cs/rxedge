import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';
import 'app_button.dart';

/// RxEdge Empty State Widget
///
/// Follows UX Law:
/// "Every screen has designed empty (explain + CTA). Never dead ends."
/// Specific microcopy, calm illustration/icon, clear single call to action.
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData icon;
  final EdgeInsetsDirectional padding;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.icon = LucideIcons.folderOpen,
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
                color: colors.surfaceMuted,
                borderRadius: RxRadii.borderCard,
                border: Border.all(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24.0,
                  color: colors.textSecondary,
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
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: RxSpacing.s24),
              SizedBox(
                width: 200.0,
                child: AppButton(
                  text: actionText!,
                  onPressed: onAction,
                  variant: AppButtonVariant.primary,
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
