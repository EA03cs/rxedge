import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';

/// Product Positioning View
///
/// Fully aligned with Excel Module 1 (Product Navigator):
/// 1. Prominent Pack Shot Card (local asset with clean fallback)
/// 2. Product Overview (introductory summary, null-safe)
/// 3. Key Positioning (single paragraph positioning)
/// 4. Key Messaging (bulleted messaging points)
/// 5. Target Patient
/// 6. Key Benefits
/// Additional Detailing Blocks: Target Doctors, Dosage Highlights, Proof Points
class ProductPositioningView extends StatelessWidget {
  final ProductPositioningEntity positioning;
  final String? productOverview;
  final String? packShotAsset;
  final String? productName;

  const ProductPositioningView({
    super.key,
    required this.positioning,
    this.productOverview,
    this.packShotAsset,
    this.productName,
  });

  Widget _buildPackShotFallback(RxColors colors, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.packageCheck,
          size: 48.0,
          color: colors.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: RxSpacing.s8),
        Text(
          productName ?? 'Rohto Eye Drops',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: RxSpacing.s4),
        Text(
          'Official Pack Shot',
          style: textTheme.labelSmall?.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }

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
          // 1. Prominent Pack Shot Hero Card (Local Asset with Clean Fallback)
          Container(
            width: double.infinity,
            height: 190.0,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: packShotAsset != null
                      ? Image.asset(
                          packShotAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPackShotFallback(colors, textTheme),
                        )
                      : _buildPackShotFallback(colors, textTheme),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: StatusBadge(
                    label: l10n.packShotTitle,
                    icon: LucideIcons.packageCheck,
                    variant: StatusBadgeVariant.neutral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 2. Product Overview Block (Excel Specification 1, shown first, handles missing/null value)
          if (productOverview != null && productOverview!.trim().isNotEmpty) ...[
            _BlockHeader(
              icon: LucideIcons.sparkles,
              title: l10n.productOverviewTitle,
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
                productOverview!.trim(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: RxSpacing.s20),
          ],

          // 3. Key Positioning Block (Excel Column D)
          _BlockHeader(
            icon: LucideIcons.compass,
            title: l10n.keyPositioningTitle,
            iconColor: colors.primary,
          ),
          const SizedBox(height: RxSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Text(
              positioning.effectiveKeyPositioning,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // 4. Key Messaging Block (Excel Column E)
          if (positioning.keyMessaging.isNotEmpty) ...[
            _BlockHeader(
              icon: LucideIcons.messageSquare,
              title: l10n.keyMessagingTitle,
              iconColor: colors.primary,
            ),
            const SizedBox(height: RxSpacing.s8),
            AppCard(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
              child: Column(
                children: positioning.keyMessaging.asMap().entries.map((entry) {
                  final isLast = entry.key == positioning.keyMessaging.length - 1;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsetsDirectional.all(RxSpacing.s6),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Icon(
                              LucideIcons.checkCheck,
                              size: 14.0,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: RxSpacing.s10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textPrimary,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
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
          ],

          // 5. Target Patient Block (Excel Column F)
          if (positioning.targetPatient != null &&
              positioning.targetPatient!.trim().isNotEmpty) ...[
            _BlockHeader(
              icon: LucideIcons.heartHandshake,
              title: l10n.targetPatient,
              iconColor: colors.primary,
            ),
            const SizedBox(height: RxSpacing.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: RxRadii.borderCard,
                border: Border.all(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s6),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Icon(
                      LucideIcons.users,
                      size: 16.0,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Text(
                      positioning.targetPatient!.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s20),
          ],

          // 6. Target Doctors Block
          if (positioning.targetDoctors.isNotEmpty) ...[
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
          ],

          // 7. Key Benefits Block (Excel Column G)
          if (positioning.keyBenefits.isNotEmpty) ...[
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
          ],

          // 8. Dosage Highlights Block
          if (positioning.dosageHighlights.isNotEmpty) ...[
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
          ],

          // 9. Proof Points Block
          if (positioning.proofPoints.isNotEmpty) ...[
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
        Expanded(
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
