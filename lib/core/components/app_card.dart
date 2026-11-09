import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppCardVariant {
  surface,
  muted,
}

/// RxEdge Standard Card
///
/// Features:
/// - 12dp radius (RxRadii.borderCard)
/// - Strictly flat, depth from 1px hairline border
/// - Optional surface muted variant
/// - Optional tap feedback for list items or interactive tiles
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AppCardVariant variant;
  final EdgeInsetsDirectional padding;
  final double? width;
  final double? height;
  final Border? customBorder;
  final bool isFloating;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.variant = AppCardVariant.surface,
    this.padding = RxSpacing.cardPadding,
    this.width,
    this.height,
    this.customBorder,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = variant == AppCardVariant.surface
        ? colors.surface
        : colors.surfaceMuted;

    final border = customBorder ?? Border.all(
      color: colors.border,
      width: RxShadows.hairlineBorderWidth,
    );

    final shadows = isFloating
        ? (isDark ? RxShadows.floatingDark : RxShadows.floatingLight)
        : RxShadows.flat;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: RxRadii.borderCard,
        border: border,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: RxRadii.borderCard,
        child: onTap != null
            ? InkWell(
                borderRadius: RxRadii.borderCard,
                onTap: onTap,
                onLongPress: onLongPress,
                splashColor: colors.primarySoft.withValues(alpha: 0.35),
                highlightColor: colors.primarySoft.withValues(alpha: 0.15),
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              )
            : Padding(
                padding: padding,
                child: child,
              ),
      ),
    );
  }
}
