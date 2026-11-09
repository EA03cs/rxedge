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

  /// Soft shadow for floating elements in Light Theme
  static const List<BoxShadow> floatingLight = [
    BoxShadow(
      color: Color(0x0A0F172A), // 4% opacity of #0F172A
      blurRadius: 12.0,
      spreadRadius: 0.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Soft shadow for floating elements in Dark Theme
  static const List<BoxShadow> floatingDark = [
    BoxShadow(
      color: Color(0x33000000), // ~20% black in dark mode
      blurRadius: 12.0,
      spreadRadius: 0.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Strictly flat: empty list
  static const List<BoxShadow> flat = [];
}
