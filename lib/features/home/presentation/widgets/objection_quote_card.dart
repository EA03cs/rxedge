import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "Objection of the Month" Card
///
/// Features:
/// - Editorial quote-style card with hairline border
/// - Doctor's quote and physician credentials
/// - Secondary outline button: "See how to respond" (maintaining the single primary button rule)
/// - Modal detailing card with evidence-based response talking points
class ObjectionQuoteCard extends StatelessWidget {
  final DoctorObjectionEntity objection;

  const ObjectionQuoteCard({
    super.key,
    required this.objection,
  });

  void _showResponseSheet(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: RxRadii.borderSheet,
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: RxSpacing.s20,
            end: RxSpacing.s20,
            top: RxSpacing.s20,
            bottom: MediaQuery.of(ctx).padding.bottom + RxSpacing.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: RxSpacing.s16),

              Text(
                l10n.clinicalDetailingGuidance,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),

              Text(
                objection.productConcerned,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s12),

              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Text(
                  objection.doctorQuote,
                  style: textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: RxSpacing.s16),

              Text(
                l10n.recommendedClinicalCounter,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),

              Text(
                objection.responseSummary,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: RxSpacing.s24),

              AppButton(
                text: l10n.btnGotIt,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Section Tag
            Row(
              children: [
                Icon(
                  LucideIcons.messageCircle,
                  size: 16.0,
                  color: colors.primary,
                ),
                const SizedBox(width: RxSpacing.s6),
                Text(
                  l10n.objectionOfTheMonth,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: RxSpacing.s12),

            // Doctor Quote with subtle quotation line
            Container(
              padding: const EdgeInsetsDirectional.only(
                start: RxSpacing.s12,
                top: RxSpacing.s4,
                bottom: RxSpacing.s4,
              ),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(
                    color: colors.primary,
                    width: 3.0,
                  ),
                ),
              ),
              child: Text(
                objection.doctorQuote,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: RxSpacing.s10),

            // Doctor Name and specialty
            Text(
              '${objection.doctorName} • ${objection.specialty}',
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: RxSpacing.s14),

            // Secondary Action (Keeps strict rule: ONLY ONE filled primary button on screen)
            AppButton(
              text: l10n.seeHowToRespond,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              leadingIcon: LucideIcons.bookOpen,
              onPressed: () => _showResponseSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}
