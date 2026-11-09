import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// RxEdge Linear Progress Bar
///
/// Features:
/// - 4px or 8px height with clean rounded caps
/// - Flat design with crisp track contrast
/// - Fully RTL aware
/// - Optional label and value indicator
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? color;
  final Color? trackColor;
  final String? label;
  final String? trailingText;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6.0,
    this.color,
    this.trackColor,
    this.label,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final progressColor = color ?? colors.primary;
    final backgroundTrack = trackColor ?? colors.surfaceMuted;
    final clampedValue = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || trailingText != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: RxSpacing.s6),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundTrack,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * clampedValue;
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
