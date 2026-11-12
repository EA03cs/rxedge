import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/feedback_entities.dart';
import '../controllers/feedback_controller.dart';
import '../widgets/feedback_skeleton_loader.dart';
import 'feedback_detail_screen.dart';
import 'feedback_form_screen.dart';

/// Live Marketing Feedback Screen (Tab 4)
///
/// Features:
/// 1. Three large, clear type cards (Doctor Objection, Competitor Claim, Field Feedback)
/// 2. "My Submissions" list with StatusBadges (Pending, Sent, Seen by marketing, Answered)
/// 3. Offline queuing support with pending status
/// 4. Pull-to-refresh, skeleton loading, and empty state
class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final submissionsAsync = ref.watch(feedbackListControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.feedbackTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: submissionsAsync.when(
        loading: () => const FeedbackSkeletonLoader(),
        error: (err, _) => ErrorState(
          title: l10n.unableLoadFeedback,
          description: err.toString().replaceAll('Exception: ', ''),
          retryText: l10n.retry,
          onRetry: () => ref.read(feedbackListControllerProvider.notifier).refresh(),
        ),
        data: (submissions) {
          final hasPending = submissions.any((s) => s.status == FeedbackStatus.pending);

          return RefreshIndicator(
            onRefresh: () => ref.read(feedbackListControllerProvider.notifier).refresh(),
            color: colors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offline pending warning banner if any items are queued
                  if (hasPending) ...[
                    Container(
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                      decoration: BoxDecoration(
                        color: colors.warningSoft,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.warning.withValues(alpha: 0.25),
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.cloudOff, size: 18.0, color: colors.warning),
                          const SizedBox(width: RxSpacing.s10),
                          Expanded(
                            child: Text(
                              l10n.pendingOfflineWarning,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref.read(syncServiceProvider).flushQueue(force: true);
                              await ref.read(feedbackListControllerProvider.notifier).refresh();
                            },
                            child: Text(
                              l10n.actionSyncNow,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),
                  ],

                  // Header Subtitle
                  Text(
                    l10n.feedbackSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // Three Large Type Cards
                  _buildTypeCard(
                    context: context,
                    type: FeedbackType.doctorObjection,
                    icon: LucideIcons.stethoscope,
                    title: l10n.typeDoctorObjection,
                    description: l10n.descDoctorObjection,
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  _buildTypeCard(
                    context: context,
                    type: FeedbackType.competitorClaim,
                    icon: LucideIcons.shieldAlert,
                    title: l10n.typeCompetitorClaim,
                    description: l10n.descCompetitorClaim,
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  _buildTypeCard(
                    context: context,
                    type: FeedbackType.fieldFeedback,
                    icon: LucideIcons.messageSquare,
                    title: l10n.typeFieldFeedback,
                    description: l10n.descFieldFeedback,
                  ),

                  const SizedBox(height: RxSpacing.s24),

                  // My Submissions Section
                  SectionHeader(
                    title: l10n.mySubmissions,
                    action: submissions.isNotEmpty
                        ? StatusBadge(
                            label: '${submissions.length}',
                            variant: StatusBadgeVariant.neutral,
                          )
                        : null,
                  ),
                  const SizedBox(height: RxSpacing.s8),

                  if (submissions.isEmpty) ...[
                    EmptyState(
                      icon: LucideIcons.inbox,
                      title: l10n.emptySubmissionsTitle,
                      description: l10n.emptySubmissionsDesc,
                    ),
                  ] else ...[
                    AppCard(
                      padding: EdgeInsetsDirectional.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: submissions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1.0,
                          thickness: RxShadows.hairlineBorderWidth,
                          color: colors.border,
                        ),
                        itemBuilder: (context, index) {
                          final item = submissions[index];
                          return _buildSubmissionCard(context, item);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeCard({
    required BuildContext context,
    required FeedbackType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackFormScreen(type: type),
          ),
        );
      },
      borderRadius: RxRadii.borderCard,
      child: Container(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
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
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: RxRadii.borderButton,
              ),
              child: Icon(icon, size: 22.0, color: colors.primary),
            ),
            const SizedBox(width: RxSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Icon(
              context.chevronForward,
              size: 18.0,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, FeedbackItemEntity item) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final locale = Localizations.localeOf(context).languageCode;
    final dateFormatted = DateFormat.yMMMd(locale).format(item.submittedAt);
    final isAnswered = item.status == FeedbackStatus.answered;

    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackDetailScreen(submissionId: item.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(item.type),
                      size: 15.0,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: RxSpacing.s6),
                    Text(
                      _getTypeName(context, item.type),
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(context, item.status),
              ],
            ),
            const SizedBox(height: RxSpacing.s8),
            Text(
              item.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: RxSpacing.s6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormatted,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textTertiary,
                    fontSize: 11.5,
                  ),
                ),
                if (isAnswered)
                  Row(
                    children: [
                      Icon(LucideIcons.messagesSquare, size: 13.0, color: colors.success),
                      const SizedBox(width: RxSpacing.s4),
                      Text(
                        l10n.statusAnswered,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
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

  IconData _getTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.doctorObjection:
        return LucideIcons.stethoscope;
      case FeedbackType.competitorClaim:
        return LucideIcons.shieldAlert;
      case FeedbackType.fieldFeedback:
        return LucideIcons.messageSquare;
    }
  }

  String _getTypeName(BuildContext context, FeedbackType type) {
    final l10n = context.l10n;
    switch (type) {
      case FeedbackType.doctorObjection:
        return l10n.typeDoctorObjection;
      case FeedbackType.competitorClaim:
        return l10n.typeCompetitorClaim;
      case FeedbackType.fieldFeedback:
        return l10n.typeFieldFeedback;
    }
  }
}
