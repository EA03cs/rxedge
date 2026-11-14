import 'package:flutter/material.dart';

/// RxEdge Design System Corner Radii
///
/// Precise, sharp & modern clinical radius values:
/// - 4 for status badges & micro tags
/// - 6 for buttons and text input fields (crisp, professional touch target)
/// - 8 for cards and content containers (sharp, modern enterprise)
/// - 12 for modal sheets / dialogs
/// - 6 for chips & tags (sharp medical tags, no bubbly round lozenges)
abstract final class RxRadii {
  /// 4.0 dp - Status badges & micro tags
  static const double badge = 4.0;
  static const Radius rBadge = Radius.circular(badge);
  static const BorderRadius borderBadge = BorderRadius.all(rBadge);

  /// 6.0 dp - Standard buttons
  static const double button = 6.0;
  static const Radius rButton = Radius.circular(button);
  static const BorderRadius borderButton = BorderRadius.all(rButton);

  /// 8.0 dp - Cards and primary containers
  static const double card = 8.0;
  static const Radius rCard = Radius.circular(card);
  static const BorderRadius borderCard = BorderRadius.all(rCard);

  /// 6.0 dp - Text input fields
  static const double input = 6.0;
  static const Radius rInput = Radius.circular(input);
  static const BorderRadius borderInput = BorderRadius.all(rInput);

  /// 12.0 dp - Modal sheets / dialogs
  static const double sheet = 12.0;
  static const BorderRadius borderSheet = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );

  /// 6.0 dp - Chips and indicators
  static const double chip = 6.0;
  static const Radius rChip = Radius.circular(chip);
  static const BorderRadius borderChip = BorderRadius.all(rChip);
}
