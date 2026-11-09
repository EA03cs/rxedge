import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// RxEdge Skeleton Box
///
/// Follows UX Law:
/// "Every screen has designed loading (skeleton)."
/// Purely flat, gentle opacity pulse, no shiny gradient shimmer.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// Skeleton for standard text line
  const SkeletonBox.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius,
  }) : isCircle = false;

  /// Skeleton for circle avatar or icon container
  const SkeletonBox.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  /// Skeleton for standard 12dp card
  const SkeletonBox.card({
    super.key,
    this.width = double.infinity,
    this.height = 120.0,
    this.borderRadius = RxRadii.borderCard,
  }) : isCircle = false;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.45,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircle
                  ? null
                  : (widget.borderRadius ?? BorderRadius.circular(widget.height > 20 ? RxRadii.card : 4.0)),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}
