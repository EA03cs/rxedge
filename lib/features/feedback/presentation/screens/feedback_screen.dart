import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// 1. Collaborative Violet & Fresh Mint gradient header with 3D Speech Bubble asset
/// 2. Elevated circular sync/flush button on top bar
/// 3. Three large, clear type cards (Doctor Objection, Competitor Claim, Field Feedback)
/// 4. "My Submissions" list with StatusBadges (Pending, Sent, Seen, Answered)
/// 5. Offline queuing support with pending status
/// 6. Pull-to-refresh, skeleton loading, and empty state
class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final submissionsAsync = ref.watch(feedbackListControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEF2FF), // Soft collaborative lavender / indigo
              Color(0xFFF0FDF4), // Fresh medical mint glow
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.20, 0.50, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: submissionsAsync.when(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Bar: Elevated Circular Sync Button
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(LucideIcons.refreshCw, size: 17.0),
                              color: const Color(0xFF0F172A),
                              padding: EdgeInsets.zero,
                              tooltip: l10n.actionSyncNow,
                              onPressed: () async {
                                await HapticFeedback.lightImpact();
                                await ref.read(syncServiceProvider).flushQueue(force: true);
                                await ref.read(feedbackListControllerProvider.notifier).refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Hero Header Banner: Title + Subtitle + 3D Speech Bubble Asset
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.feedbackTitle,
                                  style: const TextStyle(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  l10n.feedbackSubtitle,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF64748B),
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Image.asset(
                            'assets/images/feedback_hero_3d.png',
                            width: 105.0,
                            height: 95.0,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // 3. Scrollable Content Area
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 2.0, 16.0, 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Offline pending warning banner if any items are queued
                            if (hasPending) ...[
                              Container(
                                padding: const EdgeInsetsDirectional.all(12.0),
                                decoration: BoxDecoration(
                                  color: colors.warningSoft,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                    color: colors.warning.withValues(alpha: 0.25),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.cloudOff, size: 18.0, color: colors.warning),
                                    const SizedBox(width: 10.0),
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
                                        await HapticFeedback.lightImpact();
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
                              const SizedBox(height: 14.0),
                            ],

                            // Three Large Type Cards
                            _buildTypeCard(
                              context: context,
                              type: FeedbackType.doctorObjection,
                              icon: LucideIcons.stethoscope,
                              title: l10n.typeDoctorObjection,
                              description: l10n.descDoctorObjection,
                            ),
                            const SizedBox(height: 12.0),
                            _buildTypeCard(
                              context: context,
                              type: FeedbackType.competitorClaim,
                              icon: LucideIcons.shieldAlert,
                              title: l10n.typeCompetitorClaim,
                              description: l10n.descCompetitorClaim,
                            ),
                            const SizedBox(height: 12.0),
                            _buildTypeCard(
                              context: context,
                              type: FeedbackType.fieldFeedback,
                              icon: LucideIcons.messageSquare,
                              title: l10n.typeFieldFeedback,
                              description: l10n.descFieldFeedback,
                            ),

                            const SizedBox(height: 24.0),

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
                            const SizedBox(height: 8.0),

                            if (submissions.isEmpty) ...[
                              EmptyState(
                                icon: LucideIcons.inbox,
                                title: l10n.emptySubmissionsTitle,
                                description: l10n.emptySubmissionsDesc,
                              ),
                            ] else ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.0),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                      blurRadius: 10.0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: submissions.length,
                                    separatorBuilder: (context, index) => const Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = submissions[index];
                                      return _buildSubmissionCard(context, item);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
    Color badgeBg;
    Color iconColor;
    switch (type) {
      case FeedbackType.doctorObjection:
        badgeBg = const Color(0xFFCCFBF1);
        iconColor = const Color(0xFF0D9488);
        break;
      case FeedbackType.competitorClaim:
        badgeBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        break;
      case FeedbackType.fieldFeedback:
        badgeBg = const Color(0xFFEDE9FE);
        iconColor = const Color(0xFF7C3AED);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.0),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => FeedbackFormScreen(type: type),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 21.0, color: iconColor),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    context.chevronForward,
                    size: 15.0,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sanitizeTitle(String title) {
    return title.replaceAll(
      'GITS Osmotic Pump Mechanism',
      'Tearshield Technology Continuous Lubrication',
    );
  }

  Widget _buildSubmissionCard(BuildContext context, FeedbackItemEntity item) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final dateFormatted = DateFormat.yMMMd('en').format(item.submittedAt);
    final isAnswered = item.status == FeedbackStatus.answered;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackDetailScreen(submissionId: item.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.all(14.0),
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
                    const SizedBox(width: 6.0),
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
            const SizedBox(height: 8.0),
            Text(
              _sanitizeTitle(item.title),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6.0),
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
                      const SizedBox(width: 4.0),
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
