import 'package:flutter/material.dart';

/// RxEdge Design System Elevation & Shadows
///
/// Follows strict flat design guidelines:
/// - No gradients anywhere
/// - No glassmorphism or glow
/// - Depth is established primarily via 1px hairline borders
/// - Floating elements (e.g. bottom navigation, floating action card) use
///   at most one very soft, restrained shadow (blur 12, ~4% opacity).
abstract final class RxShadows {
  /// Hairline border width (1.0 dp)
  static const double hairlineBorderWidth = 1.0;

  /// Restrained shadow for floating elements (3% subtle navy tint)
  static const List<BoxShadow> floatingLight = [
    BoxShadow(
      color: Color(0x08183B56),
      blurRadius: 6.0,
      spreadRadius: 0.0,
      offset: Offset(0, 2),
    ),
  ];

  /// Fallback
  static const List<BoxShadow> floatingDark = floatingLight;

  /// Strictly flat: empty list
  static const List<BoxShadow> flat = [];
}
