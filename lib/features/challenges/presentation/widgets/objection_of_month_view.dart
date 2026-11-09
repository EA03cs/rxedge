import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
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
                    Container(
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
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.thumbsUp, size: 13.0, color: colors.textSecondary),
                        const SizedBox(width: RxSpacing.s4),
                        Text(
                          '${widget.objection.helpfulCount} helpful votes',
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
                      Text(
                        'Recommended Clinical Response',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
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
                    'Key Detailing Anchors',
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
                      final userFeedback = widget.objection.userFeedback;

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
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: userFeedback == null
                                      ? () => ref
                                          .read(challengesControllerProvider.notifier)
                                          .submitObjectionFeedback('helpful')
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: userFeedback == 'helpful'
                                        ? colors.primarySoft
                                        : colors.surface,
                                    side: BorderSide(
                                      color: userFeedback == 'helpful'
                                          ? colors.primary
                                          : colors.border,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: RxRadii.borderButton,
                                    ),
                                  ),
                                  icon: Icon(
                                    LucideIcons.thumbsUp,
                                    size: 15.0,
                                    color: userFeedback == 'helpful'
                                        ? colors.primary
                                        : colors.textSecondary,
                                  ),
                                  label: Text(
                                    l10n.btnHelpfulYes,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: userFeedback == 'helpful'
                                          ? colors.primary
                                          : colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: userFeedback == null
                                      ? () => ref
                                          .read(challengesControllerProvider.notifier)
                                          .submitObjectionFeedback('needs_improvement')
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: userFeedback == 'needs_improvement'
                                        ? colors.surfaceMuted
                                        : colors.surface,
                                    side: BorderSide(
                                      color: colors.border,
                                    ),
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
                          '${widget.objection.communityResponseCount} peers contributed field phrasing',
                          style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.arrowRight, size: 18.0),
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
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      ref
                          .read(challengesControllerProvider.notifier)
                          .submitDoctorObjectionResponse(text);

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.responseSubmitted),
                          backgroundColor: colors.textPrimary,
                          behavior: SnackBarBehavior.floating,
                        ),
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
