import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';

/// Product Positioning View
///
/// Features:
/// - Scannable blocks (Key message, Target doctors, Key benefits, Dosage highlights, Proof points)
/// - Never long text walls: structured bite-sized cards with consistent icons and hierarchy
/// - Strictly flat, 1px hairline borders, subtle surface tints
class ProductPositioningView extends StatelessWidget {
  final ProductPositioningEntity positioning;

  const ProductPositioningView({
    super.key,
    required this.positioning,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Message Block
          _BlockHeader(
            icon: LucideIcons.quote,
            title: l10n.keyMessage,
            iconColor: colors.primary,
          ),
          const SizedBox(height: RxSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.2),
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Text(
              positioning.keyMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 2. Target Doctors Block
          _BlockHeader(
            icon: LucideIcons.stethoscope,
            title: l10n.targetDoctors,
            iconColor: colors.info,
          ),
          const SizedBox(height: RxSpacing.s8),
          AppCard(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            child: Column(
              children: positioning.targetDoctors.asMap().entries.map((entry) {
                final isLast = entry.key == positioning.targetDoctors.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.all(RxSpacing.s6),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(
                            LucideIcons.userCheck,
                            size: 14.0,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Divider(
                        height: RxSpacing.s16,
                        thickness: RxShadows.hairlineBorderWidth,
                        color: colors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 3. Key Benefits Block
          _BlockHeader(
            icon: LucideIcons.checkCircle2,
            title: l10n.keyBenefits,
            iconColor: colors.success,
          ),
          const SizedBox(height: RxSpacing.s8),
          AppCard(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            child: Column(
              children: positioning.keyBenefits.asMap().entries.map((entry) {
                final isLast = entry.key == positioning.keyBenefits.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.check,
                          size: 16.0,
                          color: colors.primary,
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Divider(
                        height: RxSpacing.s16,
                        thickness: RxShadows.hairlineBorderWidth,
                        color: colors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 4. Dosage Highlights Block
          _BlockHeader(
            icon: LucideIcons.pill,
            title: l10n.dosageHighlights,
            iconColor: colors.warning,
          ),
          const SizedBox(height: RxSpacing.s8),
          AppCard(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            child: Column(
              children: positioning.dosageHighlights.asMap().entries.map((entry) {
                final isLast = entry.key == positioning.dosageHighlights.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.clock4,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Divider(
                        height: RxSpacing.s16,
                        thickness: RxShadows.hairlineBorderWidth,
                        color: colors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 5. Proof Points Block
          _BlockHeader(
            icon: LucideIcons.fileCheck2,
            title: l10n.proofPoints,
            iconColor: colors.info,
          ),
          const SizedBox(height: RxSpacing.s8),
          AppCard(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            child: Column(
              children: positioning.proofPoints.asMap().entries.map((entry) {
                final isLast = entry.key == positioning.proofPoints.length - 1;
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.award,
                          size: 16.0,
                          color: colors.primary,
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Divider(
                        height: RxSpacing.s16,
                        thickness: RxShadows.hairlineBorderWidth,
                        color: colors.border,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: RxSpacing.s24),
        ],
      ),
    );
  }
}

class _BlockHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _BlockHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16.0, color: iconColor),
        const SizedBox(width: RxSpacing.s8),
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
