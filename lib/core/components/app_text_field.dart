import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/theme.dart';

/// RxEdge Standard Text Field
///
/// Features:
/// - 12dp radius (RxRadii.borderInput)
/// - Flat surface background, 1px hairline border
/// - 48dp minimum touch target height
/// - Clear, restrained typography with helper/error microcopy
/// - RTL-safe prefix and suffix positioning
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool clearable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.clearable = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.clearable && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    Widget? effectiveSuffix;
    if (widget.obscureText) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
          size: 18.0,
          color: colors.textSecondary,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        splashRadius: 20,
      );
    } else if (widget.clearable && _controller.text.isNotEmpty && widget.enabled && !widget.readOnly) {
      effectiveSuffix = IconButton(
        icon: Icon(
          LucideIcons.x,
          size: 16.0,
          color: colors.textTertiary,
        ),
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        splashRadius: 20,
      );
    } else {
      effectiveSuffix = widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: textTheme.labelMedium?.copyWith(
              color: widget.enabled ? colors.textPrimary : colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: RxSpacing.s6),
        ],
        TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscureText,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          style: textTheme.bodyMedium?.copyWith(
            color: widget.enabled ? colors.textPrimary : colors.textTertiary,
          ),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colors.textTertiary,
            ),
            helperText: widget.helperText,
            helperMaxLines: 2,
            helperStyle: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 12.0,
            ),
            errorText: widget.errorText,
            errorMaxLines: 2,
            errorStyle: textTheme.bodySmall?.copyWith(
              color: colors.error,
              fontSize: 12.0,
            ),
            fillColor: widget.enabled ? colors.surface : colors.surfaceMuted,
            filled: true,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: RxSpacing.s12, end: RxSpacing.s8),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40.0,
              minHeight: 40.0,
            ),
            suffixIcon: effectiveSuffix != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: RxSpacing.s8),
                    child: effectiveSuffix,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40.0,
              minHeight: 40.0,
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: RxSpacing.s16,
              vertical: RxSpacing.s14,
            ),
            border: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.error,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.error,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: RxRadii.borderInput,
              borderSide: BorderSide(
                color: colors.border.withValues(alpha: 0.5),
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
