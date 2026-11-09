import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum StatusBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  accent, // Strictly for points, streaks, badges
}

/// RxEdge Status Badge
///
/// Features:
/// - 6dp radius (RxRadii.borderBadge)
/// - Strictly flat, soft tinted background with 1px matching border
/// - Optional leading status dot or icon
/// - Respects accent rule: accent amber is ONLY for points, streaks and badges
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final IconData? icon;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.icon,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case StatusBadgeVariant.success:
        bg = colors.successSoft;
        fg = colors.success;
        border = colors.success.withValues(alpha: 0.2);
        break;
      case StatusBadgeVariant.warning:
        bg = colors.warningSoft;
        fg = colors.warning;
        border = colors.warning.withValues(alpha: 0.2);
        break;
      case StatusBadgeVariant.error:
        bg = colors.errorSoft;
        fg = colors.error;
        border = colors.error.withValues(alpha: 0.2);
        break;
      case StatusBadgeVariant.info:
        bg = colors.infoSoft;
        fg = colors.info;
        border = colors.info.withValues(alpha: 0.2);
        break;
      case StatusBadgeVariant.accent:
        bg = colors.accentSoft;
        fg = colors.accent;
        border = colors.accent.withValues(alpha: 0.25);
        break;
      case StatusBadgeVariant.neutral:
        bg = colors.surfaceMuted;
        fg = colors.textSecondary;
        border = colors.border;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RxRadii.borderBadge,
        border: Border.all(
          color: border,
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s8,
        vertical: RxSpacing.s2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: RxSpacing.s6),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 13.0,
              color: fg,
            ),
            const SizedBox(width: RxSpacing.s4),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
