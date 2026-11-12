import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/learning_entities.dart';

/// Competitive Handling View
///
/// Features:
/// - Competitor selection for fast one-handed switching
/// - Three clear structured parts:
///   1. "Their claim"
///   2. "How to respond"
///   3. "Proof / reference"
/// - "Copy talking point" action with system clipboard integration and SnackBar feedback
class CompetitiveHandlingView extends StatefulWidget {
  final List<CompetitorComparisonEntity> competitors;

  const CompetitiveHandlingView({
    super.key,
    required this.competitors,
  });

  @override
  State<CompetitiveHandlingView> createState() => _CompetitiveHandlingViewState();
}

class _CompetitiveHandlingViewState extends State<CompetitiveHandlingView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    if (widget.competitors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
          child: Text(
            l10n.noCompetitorsAvailable,
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final safeIndex = _selectedIndex.clamp(0, widget.competitors.length - 1);
    final activeCompetitor = widget.competitors[safeIndex];

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Competitor selector chips (if more than 1)
          if (widget.competitors.length > 1) ...[
            Text(
              l10n.labelCompetitor,
              style: textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: RxSpacing.s8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.competitors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final comp = entry.value;
                  final isSelected = index == safeIndex;

                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: RxSpacing.s8),
                    child: AppChip(
                      label: comp.competitorName,
                      isSelected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: RxSpacing.s16),
          ],

          // Active competitor details
          // 1. Their claim
          _ComparisonSectionCard(
            label: l10n.theirClaim,
            icon: LucideIcons.alertCircle,
            headerColor: colors.warning,
            backgroundColor: colors.surfaceMuted,
            borderColor: colors.border,
            content: activeCompetitor.theirClaim,
          ),
          const SizedBox(height: RxSpacing.s12),

          // 2. How to respond (with copy action)
          _ComparisonSectionCard(
            label: l10n.howToRespond,
            icon: LucideIcons.messageSquare,
            headerColor: colors.primary,
            backgroundColor: colors.primarySoft,
            borderColor: colors.primary.withValues(alpha: 0.25),
            content: activeCompetitor.howToRespond,
            action: OutlinedButton.icon(
              onPressed: () => _copyTalkingPoint(context, activeCompetitor.howToRespond),
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: colors.primary,
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: RxShadows.hairlineBorderWidth,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: RxRadii.borderButton,
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s12,
                  vertical: RxSpacing.s8,
                ),
                minimumSize: const Size(0, 36.0),
              ),
              icon: const Icon(LucideIcons.copy, size: 14.0),
              label: Text(
                l10n.copyTalkingPoint,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: RxSpacing.s12),

          // 3. Proof / reference
          _ComparisonSectionCard(
            label: l10n.proofReference,
            icon: LucideIcons.fileCheck2,
            headerColor: colors.info,
            backgroundColor: colors.surface,
            borderColor: colors.border,
            content: activeCompetitor.proofReference,
          ),
          const SizedBox(height: RxSpacing.s24),
        ],
      ),
    );
  }

  void _copyTalkingPoint(BuildContext context, String text) {
    final l10n = context.l10n;
    final colors = context.rxColors;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, size: 16.0, color: Colors.white),
            const SizedBox(width: RxSpacing.s8),
            Expanded(child: Text(l10n.talkingPointCopied)),
          ],
        ),
        backgroundColor: colors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ComparisonSectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color headerColor;
  final Color backgroundColor;
  final Color borderColor;
  final String content;
  final Widget? action;

  const _ComparisonSectionCard({
    required this.label,
    required this.icon,
    required this.headerColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.content,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: RxRadii.borderCard,
        border: Border.all(
          color: borderColor,
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16.0, color: headerColor),
                  const SizedBox(width: RxSpacing.s8),
                  Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: RxSpacing.s10),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
