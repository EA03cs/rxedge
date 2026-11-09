import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/feedback_entities.dart';
import '../controllers/feedback_controller.dart';

/// Screen displaying the full details of a submitted feedback item and marketing response
class FeedbackDetailScreen extends ConsumerWidget {
  final String submissionId;

  const FeedbackDetailScreen({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final item = ref.watch(feedbackDetailProvider(submissionId));

    if (item == null) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Feedback Details')),
        body: const Center(child: Text('Submission not found')),
      );
    }

    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(item.submittedAt);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Feedback Details',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Date Banner Card
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeName(item.type),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: RxSpacing.s4),
                      Text(
                        dateFormatted,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(context, item.status),
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s16),

            // Submission Content Details Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Field Submission',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  const Divider(height: 1.0),
                  const SizedBox(height: RxSpacing.s12),

                  if (item.type == FeedbackType.doctorObjection) ...[
                    _buildFieldRow(context, 'Product', item.product ?? '-'),
                    const SizedBox(height: RxSpacing.s12),
                    _buildFieldRow(context, 'Doctor Objection', item.objection ?? '-'),
                    if (item.doctorSpecialty != null && item.doctorSpecialty!.isNotEmpty) ...[
                      const SizedBox(height: RxSpacing.s12),
                      _buildFieldRow(context, 'Doctor Specialty', item.doctorSpecialty!),
                    ],
                    if (item.howResponded != null && item.howResponded!.isNotEmpty) ...[
                      const SizedBox(height: RxSpacing.s12),
                      _buildFieldRow(context, 'How I Responded', item.howResponded!),
                    ],
                  ] else if (item.type == FeedbackType.competitorClaim) ...[
                    _buildFieldRow(context, 'Competitor', item.competitorName ?? '-'),
                    const SizedBox(height: RxSpacing.s12),
                    _buildFieldRow(context, 'Claim Heard', item.claim ?? '-'),
                    if (item.whereHeard != null && item.whereHeard!.isNotEmpty) ...[
                      const SizedBox(height: RxSpacing.s12),
                      _buildFieldRow(context, 'Where Heard', item.whereHeard!),
                    ],
                    if (item.photoUrl != null) ...[
                      const SizedBox(height: RxSpacing.s12),
                      Row(
                        children: [
                          Icon(LucideIcons.image, size: 16.0, color: colors.primary),
                          const SizedBox(width: RxSpacing.s8),
                          Text(
                            'Promotional photo attached',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else if (item.type == FeedbackType.fieldFeedback) ...[
                    _buildFieldRow(context, 'Topic', item.topic ?? '-'),
                    const SizedBox(height: RxSpacing.s12),
                    _buildFieldRow(context, 'Details', item.details ?? '-'),
                    if (item.voiceNoteUrl != null) ...[
                      const SizedBox(height: RxSpacing.s12),
                      Row(
                        children: [
                          Icon(LucideIcons.mic, size: 16.0, color: colors.primary),
                          const SizedBox(width: RxSpacing.s8),
                          Text(
                            'Voice note attached (0:32)',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s16),

            // Marketing Reply Card or Status State
            if (item.status == FeedbackStatus.answered && item.marketingReply != null) ...[
              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.04),
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.messagesSquare, size: 20.0, color: colors.primary),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            l10n.marketingReply,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RxSpacing.s10),
                    Text(
                      item.marketingReply!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s12),
                    const Divider(height: 1.0),
                    const SizedBox(height: RxSpacing.s8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.repliedBy ?? 'Medical Affairs',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        if (item.repliedAt != null)
                          Text(
                            DateFormat('dd MMM, HH:mm').format(item.repliedAt!),
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textTertiary,
                              fontSize: 11.5,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (item.status == FeedbackStatus.pending) ...[
              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                decoration: BoxDecoration(
                  color: colors.warningSoft,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.25),
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.cloudOff, size: 20.0, color: colors.warning),
                    const SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.feedbackQueuedTitle,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.warning,
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s4),
                          Text(
                            'Saved offline. It will be sent automatically as soon as an internet connection is established.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.clock, size: 18.0, color: colors.textSecondary),
                    const SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Text(
                        l10n.noReplyYet,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(BuildContext context, String label, String value) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: RxSpacing.s4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, FeedbackStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case FeedbackStatus.pending:
        return StatusBadge(
          label: l10n.statusPending,
          variant: StatusBadgeVariant.warning,
          icon: LucideIcons.clock,
        );
      case FeedbackStatus.sent:
        return StatusBadge(
          label: l10n.statusSent,
          variant: StatusBadgeVariant.neutral,
          icon: LucideIcons.send,
        );
      case FeedbackStatus.seen:
        return StatusBadge(
          label: l10n.statusSeen,
          variant: StatusBadgeVariant.info,
          icon: LucideIcons.eye,
        );
      case FeedbackStatus.answered:
        return StatusBadge(
          label: l10n.statusAnswered,
          variant: StatusBadgeVariant.success,
          icon: LucideIcons.checkCheck,
        );
    }
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
