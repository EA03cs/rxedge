import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/feedback_entities.dart';
import 'feedback_form_screen.dart';

/// Screen displayed after submitting a feedback report
class FeedbackSuccessScreen extends StatelessWidget {
  final FeedbackItemEntity submittedItem;
  final FeedbackType type;

  const FeedbackSuccessScreen({
    super.key,
    required this.submittedItem,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isOfflinePending = submittedItem.status == FeedbackStatus.pending;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(LucideIcons.x, color: colors.textSecondary),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // Icon indicator
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    color: isOfflinePending
                        ? colors.warningSoft
                        : colors.successSoft,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isOfflinePending
                          ? colors.warning.withValues(alpha: 0.25)
                          : colors.success.withValues(alpha: 0.25),
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Icon(
                    isOfflinePending ? LucideIcons.cloudOff : LucideIcons.checkCheck,
                    size: 32.0,
                    color: isOfflinePending ? colors.warning : colors.success,
                  ),
                ),
                const SizedBox(height: RxSpacing.s20),

                // Main Title
                Text(
                  isOfflinePending ? l10n.feedbackQueuedTitle : l10n.feedbackSentTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: RxSpacing.s8),

                // Subtitle
                Text(
                  isOfflinePending
                      ? 'Stored securely on your device. We will automatically submit it to medical affairs as soon as connection is restored.'
                      : 'Commercial marketing and medical affairs review field intelligence reports daily to update talking points.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: RxSpacing.s24),

                // Summary Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _typeName(type),
                            style: textTheme.labelMedium?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          StatusBadge(
                            label: isOfflinePending ? l10n.statusPending : l10n.statusSent,
                            variant: isOfflinePending
                                ? StatusBadgeVariant.warning
                                : StatusBadgeVariant.info,
                            icon: isOfflinePending ? LucideIcons.clock : LucideIcons.check,
                          ),
                        ],
                      ),
                      const SizedBox(height: RxSpacing.s8),
                      Text(
                        submittedItem.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Action Buttons
                AppButton(
                  text: l10n.btnSendAnother,
                  variant: AppButtonVariant.secondary,
                  leadingIcon: LucideIcons.plus,
                  onPressed: () {
                    Navigator.of(context).pushReplacement<void, void>(
                      MaterialPageRoute<void>(
                        builder: (_) => FeedbackFormScreen(type: type),
                      ),
                    );
                  },
                ),
                const SizedBox(height: RxSpacing.s12),
                AppButton(
                  text: l10n.btnBackHome,
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                const SizedBox(height: RxSpacing.s8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _typeName(FeedbackType type) {
    switch (type) {
      case FeedbackType.doctorObjection:
        return 'Doctor Objection';
      case FeedbackType.competitorClaim:
        return 'Competitor Claim';
      case FeedbackType.fieldFeedback:
        return 'Field Feedback';
    }
  }
}
