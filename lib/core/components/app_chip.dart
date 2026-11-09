import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// RxEdge Standard Chip / Filter Pill
///
/// Features:
/// - 999dp pill radius (RxRadii.borderChip)
/// - Selected / unselected states
/// - Flat design with hairline border
/// - Optional leading icon or badge
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final Widget? trailing;
  final bool isCompact;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.trailing,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? colors.primarySoft
        : colors.surface;

    final borderColor = isSelected
        ? colors.primary
        : colors.border;

    final textColor = isSelected
        ? colors.primary
        : colors.textSecondary;

    final height = isCompact ? 32.0 : 38.0;
    final horizontalPadding = isCompact ? RxSpacing.s12 : RxSpacing.s16;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: RxRadii.borderChip,
        border: Border.all(
          color: borderColor,
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: RxRadii.borderChip,
        child: InkWell(
          borderRadius: RxRadii.borderChip,
          onTap: onSelected != null ? () => onSelected!(!isSelected) : null,
          splashColor: colors.primarySoft.withValues(alpha: 0.5),
          highlightColor: colors.primarySoft.withValues(alpha: 0.2),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: isCompact ? 14.0 : 16.0,
                    color: textColor,
                  ),
                  const SizedBox(width: RxSpacing.s6),
                ],
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: RxSpacing.s6),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
