import 'package:flutter/material.dart';

/// RxEdge Design System Unified Tokens
///
/// Consolidates all design system rules in ONE place:
/// 1. Unified Radii:
///    - cardRadius (8.0 dp): All cards and primary content containers
///    - controlRadius (6.0 dp): All buttons, badges, chips, text input fields
///    - sheetRadius (12.0 dp): Bottom sheets and dialogs
///
/// 2. Brand Color Rules:
///    - brandRed (#E62134) & brandRedSoft (#FDE9EB): Mentholatum Logo red, Primary CTA buttons, and single red badge per section
///    - brandBlue (#005CA8) & brandBlueSoft (#E6F0F8): Corporate structure, active navigation, and clinical tags
///    - ZERO yellow/amber anywhere in the UI
///
/// 3. 4-Level Typography Scale:
///    - title: 20-22sp, w700 (H1 / Screen Titles / Hero headers)
///    - subtitle: 15-16sp, w600 (Card Titles / Section headers)
///    - body: 13.5-14sp, w400 (Clinical descriptions & content)
///    - caption: 11-12sp, w500-w600 (Badges, stats, microcopy, hints)
abstract final class AppTokens {
  // Brand Colors (Official Mentholatum Palette)
  static const Color brandRed = Color(0xFFE62134);
  static const Color brandRedSoft = Color(0xFFFDE9EB);
  static const Color brandBlue = Color(0xFF005CA8);
  static const Color brandBlueSoft = Color(0xFFE6F0F8);

  // Backgrounds & Neutrals
  static const Color background = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEAF1F7);
  static const Color border = Color(0xFFD4E2EE);

  // Typography Colors
  static const Color textPrimary = Color(0xFF142433);
  static const Color textSecondary = Color(0xFF455C72);
  static const Color textTertiary = Color(0xFF859CB0);

  // Unified Radii
  static const double cardRadius = 8.0;
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(cardRadius));

  static const double controlRadius = 6.0;
  static const BorderRadius borderControl = BorderRadius.all(Radius.circular(controlRadius));

  static const double sheetRadius = 12.0;
  static const BorderRadius borderSheet = BorderRadius.only(
    topLeft: Radius.circular(sheetRadius),
    topRight: Radius.circular(sheetRadius),
  );

  // 4 Typography Font Sizes
  static const double fontTitle = 20.0;
  static const double fontSubtitle = 15.0;
  static const double fontBody = 13.5;
  static const double fontCaption = 11.5;
}
