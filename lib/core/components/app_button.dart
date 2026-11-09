import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
}

enum AppButtonSize {
  regular(height: RxSpacing.s48, fontSize: 14.0, iconSize: 18.0),
  small(height: 36.0, fontSize: 13.0, iconSize: 16.0);

  final double height;
  final double fontSize;
  final double iconSize;

  const AppButtonSize({
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });
}

/// RxEdge Standard Button
///
/// Complies with:
/// - 48dp min touch target for regular size
/// - 10dp radius (RxRadii.borderButton)
/// - Strictly flat (no gradients, no drop shadows)
/// - Built-in loading state with matching 2px stroke indicator
/// - RTL-aware icon layout
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isEnabled ? colors.primary : colors.surfaceMuted;
        foregroundColor = isEnabled ? Colors.white : colors.textTertiary;
        break;

      case AppButtonVariant.secondary:
        backgroundColor = isEnabled ? colors.surface : colors.surfaceMuted;
        foregroundColor = isEnabled ? colors.textPrimary : colors.textTertiary;
        borderSide = BorderSide(
          color: isEnabled ? colors.border : colors.border.withValues(alpha: 0.5),
          width: RxShadows.hairlineBorderWidth,
        );
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.textPrimary : colors.textTertiary;
        break;

      case AppButtonVariant.destructive:
        backgroundColor = isEnabled ? colors.errorSoft : colors.surfaceMuted;
        foregroundColor = isEnabled ? colors.error : colors.textTertiary;
        borderSide = BorderSide(
          color: isEnabled ? colors.error.withValues(alpha: 0.2) : colors.border.withValues(alpha: 0.5),
          width: RxShadows.hairlineBorderWidth,
        );
        break;
    }

    final buttonTextStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontSize: size.fontSize,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
      letterSpacing: 0,
    );

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: size.iconSize,
        height: size.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else {
      final children = <Widget>[];

      if (leadingIcon != null) {
        children.add(
          Icon(
            leadingIcon,
            size: size.iconSize,
            color: foregroundColor,
          ),
        );
        children.add(const SizedBox(width: RxSpacing.s8));
      }

      children.add(
        Flexible(
          child: Text(
            text,
            style: buttonTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      if (trailingIcon != null) {
        children.add(const SizedBox(width: RxSpacing.s8));
        children.add(
          Icon(
            trailingIcon,
            size: size.iconSize,
            color: foregroundColor,
          ),
        );
      }

      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: size.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: RxRadii.borderButton,
        border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: RxRadii.borderButton,
        child: InkWell(
          borderRadius: RxRadii.borderButton,
          onTap: isEnabled ? onPressed : null,
          splashColor: variant == AppButtonVariant.primary
              ? colors.primaryPressed.withValues(alpha: 0.2)
              : colors.primarySoft.withValues(alpha: 0.4),
          highlightColor: variant == AppButtonVariant.primary
              ? colors.primaryPressed.withValues(alpha: 0.1)
              : colors.primarySoft.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: Center(
              widthFactor: isFullWidth ? null : 1.0,
              child: content,
            ),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
