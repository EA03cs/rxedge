import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/error/failure_message_mapper.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/challenges_entities.dart';
import '../controllers/challenges_controller.dart';

/// Objection of the Month View
///
/// Features:
/// - Step 1: Physician objection quote + "Think First" mental pause
/// - Step 2: "Reveal Recommended Response" reveals talking points & trial evidence
/// - Interaction: "Was this helpful?" feedback buttons
/// - Field Rep Collaboration: "Share your own response" submission modal
class ObjectionOfMonthView extends StatefulWidget {
  final ObjectionOfTheMonthEntity objection;

  const ObjectionOfMonthView({
    super.key,
    required this.objection,
  });

  @override
  State<ObjectionOfMonthView> createState() => _ObjectionOfMonthViewState();
}

class _ObjectionOfMonthViewState extends State<ObjectionOfMonthView> {
  bool _isResponseRevealed = false;
  String? _localFeedback;
  int _helpfulDelta = 0;
  int _communityDelta = 0;

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
          // Doctor & Objection Quote Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: RxSpacing.s8,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          widget.objection.productConcerned,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.thumbsUp, size: 13.0, color: colors.textSecondary),
                        const SizedBox(width: RxSpacing.s4),
                        Text(
                          l10n.helpfulVotesCount(widget.objection.helpfulCount + _helpfulDelta),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s12),

                // Doctor Quote
                Text(
                  widget.objection.doctorQuote,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: RxSpacing.s12),

                // Doctor Info
                Row(
                  children: [
                    Container(
                      width: 28.0,
                      height: 28.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Icon(LucideIcons.user, size: 14.0, color: colors.textSecondary),
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.objection.doctorName.trim().isNotEmpty)
                            Text(
                              widget.objection.doctorName,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          Text(
                            widget.objection.doctorSpecialty,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s16),

          // Step 1: Think First Card
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s6),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Icon(LucideIcons.lightbulb, size: 16.0, color: colors.accent),
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    Text(
                      l10n.thinkFirstTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s8),
                Text(
                  l10n.thinkFirstPrompt,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s16),

          // Reveal Action or Step 2 Response
          if (!_isResponseRevealed) ...[
            AppButton(
              text: l10n.btnRevealResponse,
              leadingIcon: LucideIcons.eye,
              variant: AppButtonVariant.primary,
              onPressed: () {
                setState(() {
                  _isResponseRevealed = true;
                });
              },
            ),
          ] else ...[
            // Step 2: Revealed Recommended Clinical Response
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.checkCircle2, size: 18.0, color: colors.primary),
                      const SizedBox(width: RxSpacing.s8),
                      Expanded(
                        child: Text(
                          l10n.recommendedClinicalResponseLabel,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.copy, size: 16.0, color: colors.textSecondary),
                        tooltip: 'Copy response',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.objection.recommendedResponse));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Response copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  Text(
                    widget.objection.recommendedResponse,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // Structured Talking Points
                  Text(
                    l10n.keyDetailingAnchorsLabel,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  ...widget.objection.talkingPoints.map((point) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.check, size: 15.0, color: colors.primary),
                          const SizedBox(width: RxSpacing.s8),
                          Expanded(
                            child: Text(
                              point,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: RxSpacing.s12),

                  // Clinical Study Reference
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.fileCheck2, size: 14.0, color: colors.info),
                        const SizedBox(width: RxSpacing.s6),
                        Expanded(
                          child: Text(
                            widget.objection.studyReference,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s20),
                  Divider(
                    height: 1.0,
                    thickness: RxShadows.hairlineBorderWidth,
                    color: colors.border,
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // "Was this helpful?" Section
                  Consumer(
                    builder: (context, ref, _) {
                      final userFeedback = _localFeedback ?? widget.objection.userFeedback;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.wasThisHelpful,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: RxSpacing.s8),
                          if (userFeedback != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                              decoration: BoxDecoration(
                                color: userFeedback == 'helpful'
                                    ? colors.successSoft
                                    : colors.surfaceMuted,
                                borderRadius: RxRadii.borderCard,
                                border: Border.all(
                                  color: userFeedback == 'helpful'
                                      ? colors.success.withValues(alpha: 0.35)
                                      : colors.border,
                                  width: RxShadows.hairlineBorderWidth,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    userFeedback == 'helpful'
                                        ? LucideIcons.checkCheck
                                        : LucideIcons.info,
                                    size: 16.0,
                                    color: userFeedback == 'helpful'
                                        ? colors.success
                                        : colors.textSecondary,
                                  ),
                                  const SizedBox(width: RxSpacing.s8),
                                  Expanded(
                                    child: Text(
                                      userFeedback == 'helpful'
                                          ? 'Your feedback (Helpful) has been recorded to support your peers.'
                                          : 'Thank you — note forwarded to Medical Affairs to refine the response.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _localFeedback = 'helpful';
                                        _helpfulDelta = 1;
                                      });
                                      ref
                                          .read(challengesControllerProvider.notifier)
                                          .submitObjectionFeedback('helpful');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                LucideIcons.checkCircle2,
                                                color: colors.success,
                                                size: 18.0,
                                              ),
                                              const SizedBox(width: RxSpacing.s8),
                                              const Expanded(
                                                child: Text(
                                                  'Thank you! Your feedback has been recorded.',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: colors.surface,
                                      side: BorderSide(color: colors.border),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: RxRadii.borderButton,
                                      ),
                                    ),
                                    icon: Icon(
                                      LucideIcons.thumbsUp,
                                      size: 15.0,
                                      color: colors.textSecondary,
                                    ),
                                    label: Text(
                                      l10n.btnHelpfulYes,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: RxSpacing.s12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _localFeedback = 'needs_improvement';
                                      });
                                      ref
                                          .read(challengesControllerProvider.notifier)
                                          .submitObjectionFeedback('needs_improvement');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                LucideIcons.info,
                                                color: colors.info,
                                                size: 18.0,
                                              ),
                                              const SizedBox(width: RxSpacing.s8),
                                              const Expanded(
                                                child: Text(
                                                  'Thank you! We will refine this response with Medical Affairs.',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: colors.surface,
                                      side: BorderSide(color: colors.border),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: RxRadii.borderButton,
                                      ),
                                    ),
                                    icon: Icon(
                                      LucideIcons.thumbsDown,
                                      size: 15.0,
                                      color: colors.textSecondary,
                                    ),
                                    label: Text(
                                      l10n.btnHelpfulNo,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: RxSpacing.s16),

            // "Share your own response" CTA
            AppCard(
              variant: AppCardVariant.muted,
              onTap: () => _openShareResponseSheet(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(LucideIcons.messageSquarePlus, size: 20.0, color: colors.primary),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.btnShareOwnResponse,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.peersContributedCount(
                            widget.objection.communityResponseCount + _communityDelta,
                          ),
                          style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(context.arrowForward, size: 18.0),
                    onPressed: () => _openShareResponseSheet(context),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: RxSpacing.s24),
        ],
      ),
    );
  }

  void _openShareResponseSheet(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      backgroundColor: colors.surface,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: RxSpacing.s20,
            end: RxSpacing.s20,
            top: RxSpacing.s20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + RxSpacing.s20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.shareResponseTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18.0),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.shareResponseHint,
                  hintStyle: textTheme.bodySmall?.copyWith(color: colors.textTertiary),
                  filled: true,
                  fillColor: colors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: RxRadii.borderInput,
                    borderSide: BorderSide(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: RxSpacing.s16),
              Consumer(
                builder: (context, ref, _) {
                  return AppButton(
                    text: l10n.btnSubmitResponse,
                    variant: AppButtonVariant.primary,
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);
                      final res = await ref
                          .read(challengesControllerProvider.notifier)
                          .submitDoctorObjectionResponse(text);
                      if (!mounted) return;

                      navigator.pop();
                      res.when(
                        success: (_) {
                          setState(() {
                            _communityDelta++;
                          });
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    LucideIcons.checkCircle2,
                                    color: colors.success,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: RxSpacing.s8),
                                  Expanded(
                                    child: Text(
                                      l10n.responseSubmitted,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        failure: (failure) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(FailureMessageMapper.map(context, failure)),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
