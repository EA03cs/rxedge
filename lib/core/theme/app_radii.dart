import 'package:flutter/material.dart';

/// RxEdge Design System Corner Radii
///
/// Precise, disciplined radius values:
/// - 12 for cards and inputs
/// - 10 for buttons
/// - 999 for chips
/// - 6 for status badges
abstract final class RxRadii {
  /// 6.0 dp - Status badges & micro tags
  static const double badge = 6.0;
  static const Radius rBadge = Radius.circular(badge);
  static const BorderRadius borderBadge = BorderRadius.all(rBadge);

  /// 10.0 dp - Standard buttons
  static const double button = 10.0;
  static const Radius rButton = Radius.circular(button);
  static const BorderRadius borderButton = BorderRadius.all(rButton);

  /// 12.0 dp - Cards and text input fields
  static const double card = 12.0;
  static const double input = 12.0;
  static const Radius rCard = Radius.circular(card);
  static const BorderRadius borderCard = BorderRadius.all(rCard);
  static const BorderRadius borderInput = BorderRadius.all(Radius.circular(input));

  /// 16.0 dp - Modal sheets / dialogs
  static const double sheet = 16.0;
  static const BorderRadius borderSheet = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );

  /// 999.0 dp - Chips and circular indicators
  static const double chip = 999.0;
  static const Radius rChip = Radius.circular(chip);
  static const BorderRadius borderChip = BorderRadius.all(rChip);
}
