import 'package:flutter/material.dart';

/// RxEdge Design System Corner Radii
///
/// Precise, disciplined clinical radius values:
/// - 4 for status badges & micro tags
/// - 8 for buttons and text input fields
/// - 10 for cards and content containers
/// - 14 for modal sheets / dialogs
/// - 999 for pill chips
abstract final class RxRadii {
  /// 4.0 dp - Status badges & micro tags
  static const double badge = 4.0;
  static const Radius rBadge = Radius.circular(badge);
  static const BorderRadius borderBadge = BorderRadius.all(rBadge);

  /// 8.0 dp - Standard buttons
  static const double button = 8.0;
  static const Radius rButton = Radius.circular(button);
  static const BorderRadius borderButton = BorderRadius.all(rButton);

  /// 10.0 dp - Cards and primary containers
  static const double card = 10.0;
  static const Radius rCard = Radius.circular(card);
  static const BorderRadius borderCard = BorderRadius.all(rCard);

  /// 8.0 dp - Text input fields
  static const double input = 8.0;
  static const Radius rInput = Radius.circular(input);
  static const BorderRadius borderInput = BorderRadius.all(rInput);

  /// 14.0 dp - Modal sheets / dialogs
  static const double sheet = 14.0;
  static const BorderRadius borderSheet = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );

  /// 999.0 dp - Chips and circular indicators
  static const double chip = 999.0;
  static const Radius rChip = Radius.circular(chip);
  static const BorderRadius borderChip = BorderRadius.all(rChip);
}
