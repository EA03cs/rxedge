import 'package:flutter/material.dart';

/// RxEdge Design System Spacing Tokens
///
/// Built on a strict 4/8 dp grid system.
abstract final class RxSpacing {
  /// 2.0 dp - Micro adjustments
  static const double s2 = 2.0;

  /// 4.0 dp - Extra small gap
  static const double s4 = 4.0;

  /// 6.0 dp - Small text label spacing
  static const double s6 = 6.0;

  /// 8.0 dp - Small gap / dense padding
  static const double s8 = 8.0;

  /// 10.0 dp - Intermediate padding
  static const double s10 = 10.0;

  /// 12.0 dp - Medium-small gap
  static const double s12 = 12.0;

  /// 14.0 dp - Input vertical padding
  static const double s14 = 14.0;

  /// 16.0 dp - Base spacing / standard container padding
  static const double s16 = 16.0;

  /// 20.0 dp - Medium spacing
  static const double s20 = 20.0;

  /// 24.0 dp - Large spacing between sections
  static const double s24 = 24.0;

  /// 32.0 dp - Extra large spacing
  static const double s32 = 32.0;

  /// 40.0 dp - Major screen segment spacing
  static const double s40 = 40.0;

  /// 48.0 dp - Section spacing & minimum touch target dimension
  static const double s48 = 48.0;

  /// 64.0 dp - Jumbo spacing for empty/error state layouts
  static const double s64 = 64.0;

  // Common Directional Edge Insets (RTL safe)
  static const EdgeInsetsDirectional paddingZero = EdgeInsetsDirectional.zero;

  static const EdgeInsetsDirectional paddingAll4 = EdgeInsetsDirectional.all(s4);
  static const EdgeInsetsDirectional paddingAll8 = EdgeInsetsDirectional.all(s8);
  static const EdgeInsetsDirectional paddingAll12 = EdgeInsetsDirectional.all(s12);
  static const EdgeInsetsDirectional paddingAll16 = EdgeInsetsDirectional.all(s16);
  static const EdgeInsetsDirectional paddingAll20 = EdgeInsetsDirectional.all(s20);
  static const EdgeInsetsDirectional paddingAll24 = EdgeInsetsDirectional.all(s24);

  static const EdgeInsetsDirectional paddingH16 = EdgeInsetsDirectional.symmetric(horizontal: s16);
  static const EdgeInsetsDirectional paddingH20 = EdgeInsetsDirectional.symmetric(horizontal: s20);
  static const EdgeInsetsDirectional paddingH24 = EdgeInsetsDirectional.symmetric(horizontal: s24);

  static const EdgeInsetsDirectional paddingV8 = EdgeInsetsDirectional.symmetric(vertical: s8);
  static const EdgeInsetsDirectional paddingV12 = EdgeInsetsDirectional.symmetric(vertical: s12);
  static const EdgeInsetsDirectional paddingV16 = EdgeInsetsDirectional.symmetric(vertical: s16);

  static const EdgeInsetsDirectional cardPadding = EdgeInsetsDirectional.all(s16);
  static const EdgeInsetsDirectional screenPadding = EdgeInsetsDirectional.fromSTEB(s16, s16, s16, s24);
  static const EdgeInsetsDirectional buttonPadding = EdgeInsetsDirectional.symmetric(horizontal: s16, vertical: s12);

  // Minimum touch target size (Accessibility law: min 48dp)
  static const double minTouchTarget = 48.0;
}
