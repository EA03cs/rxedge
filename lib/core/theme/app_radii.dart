import 'package:flutter/material.dart';

/// RxEdge Design System Corner Radii (Unified)
///
/// Precise, sharp & modern clinical radius values:
/// - 8.0 for cards and primary containers (RxRadii.card)
/// - 6.0 for controls: buttons, badges, chips, text input fields (RxRadii.button / badge / input / chip)
/// - 12.0 for modal sheets / dialogs (RxRadii.sheet)
abstract final class RxRadii {
  /// 8.0 dp - Cards and primary containers (Unified Card Radius)
  static const double card = 8.0;
  static const Radius rCard = Radius.circular(card);
  static const BorderRadius borderCard = BorderRadius.all(rCard);

  /// 6.0 dp - Unified Control Radius for buttons, badges, inputs, and chips
  static const double button = 6.0;
  static const Radius rButton = Radius.circular(button);
  static const BorderRadius borderButton = BorderRadius.all(rButton);

  static const double badge = 6.0;
  static const Radius rBadge = Radius.circular(badge);
  static const BorderRadius borderBadge = BorderRadius.all(rBadge);

  static const double input = 6.0;
  static const Radius rInput = Radius.circular(input);
  static const BorderRadius borderInput = BorderRadius.all(rInput);

  static const double chip = 6.0;
  static const Radius rChip = Radius.circular(chip);
  static const BorderRadius borderChip = BorderRadius.all(rChip);

  /// 12.0 dp - Modal sheets / dialogs
  static const double sheet = 12.0;
  static const BorderRadius borderSheet = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );
}
