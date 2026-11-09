import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/entities/feedback_entities.dart';
import '../controllers/feedback_controller.dart';
import 'feedback_success_screen.dart';

/// Guided Feedback Form with progressive disclosure and autosaved draft
class FeedbackFormScreen extends ConsumerStatefulWidget {
  final FeedbackType type;

  const FeedbackFormScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  // Doctor Objection controllers
  final _productController = TextEditingController();
  final _objectionController = TextEditingController();
  final _doctorSpecialtyController = TextEditingController();
  final _howRespondedController = TextEditingController();

  // Competitor Claim controllers
  final _competitorNameController = TextEditingController();
  final _claimController = TextEditingController();
  final _whereHeardController = TextEditingController();
  bool _hasPhotoAttached = false;

  // Field Feedback controllers
  final _topicController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _hasVoiceNoteAttached = false;

  // Validation error states
  String? _field1Error;
  String? _field2Error;

  // UI state
  bool _isSubmitting = false;
  bool _draftRestored = false;
  bool _showOptionalFields = false;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final repo = ref.read(feedbackRepositoryProvider);
    final result = await repo.getDraft(widget.type);
    result.when(
      success: (draft) {
        if (draft != null && !draft.isEmpty && mounted) {
          setState(() {
            _draftRestored = true;
            _showOptionalFields = true;

            switch (widget.type) {
              case FeedbackType.doctorObjection:
                _productController.text = draft.product ?? '';
                _objectionController.text = draft.objection ?? '';
                _doctorSpecialtyController.text = draft.doctorSpecialty ?? '';
                _howRespondedController.text = draft.howResponded ?? '';
                break;
              case FeedbackType.competitorClaim:
                _competitorNameController.text = draft.competitorName ?? '';
                _claimController.text = draft.claim ?? '';
                _whereHeardController.text = draft.whereHeard ?? '';
                _hasPhotoAttached = draft.hasAttachment;
                break;
              case FeedbackType.fieldFeedback:
                _topicController.text = draft.topic ?? '';
                _detailsController.text = draft.details ?? '';
                _hasVoiceNoteAttached = draft.hasAttachment;
                break;
            }
          });
        }
      },
      failure: (_) {},
    );
  }

  void _onFieldChanged() {
    if (!_showOptionalFields) {
      setState(() => _showOptionalFields = true);
    }
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _saveDraft();
    });
  }

  Future<void> _saveDraft() async {
    final draft = FeedbackDraftEntity(
      type: widget.type,
      product: _productController.text.trim(),
      objection: _objectionController.text.trim(),
      doctorSpecialty: _doctorSpecialtyController.text.trim(),
      howResponded: _howRespondedController.text.trim(),
      competitorName: _competitorNameController.text.trim(),
      claim: _claimController.text.trim(),
      whereHeard: _whereHeardController.text.trim(),
      topic: _topicController.text.trim(),
      details: _detailsController.text.trim(),
      hasAttachment: _hasPhotoAttached || _hasVoiceNoteAttached,
    );

    await ref.read(feedbackRepositoryProvider).saveDraft(draft);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _productController.dispose();
    _objectionController.dispose();
    _doctorSpecialtyController.dispose();
    _howRespondedController.dispose();
    _competitorNameController.dispose();
    _claimController.dispose();
    _whereHeardController.dispose();
    _topicController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  bool _validate() {
    final l10n = context.l10n;
    setState(() {
      _field1Error = null;
      _field2Error = null;
    });

    bool isValid = true;
    switch (widget.type) {
      case FeedbackType.doctorObjection:
        if (_productController.text.trim().isEmpty) {
          _field1Error = l10n.fieldRequired;
          isValid = false;
        }
        if (_objectionController.text.trim().isEmpty) {
          _field2Error = l10n.fieldRequired;
          isValid = false;
        }
        break;
      case FeedbackType.competitorClaim:
        if (_competitorNameController.text.trim().isEmpty) {
          _field1Error = l10n.fieldRequired;
          isValid = false;
        }
        if (_claimController.text.trim().isEmpty) {
          _field2Error = l10n.fieldRequired;
          isValid = false;
        }
        break;
      case FeedbackType.fieldFeedback:
        if (_topicController.text.trim().isEmpty) {
          _field1Error = l10n.fieldRequired;
          isValid = false;
        }
        if (_detailsController.text.trim().isEmpty) {
          _field2Error = l10n.fieldRequired;
          isValid = false;
        }
        break;
    }

    if (!isValid) {
      setState(() {});
    }
    return isValid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    String title;
    FeedbackItemEntity item;

    switch (widget.type) {
      case FeedbackType.doctorObjection:
        final prod = _productController.text.trim();
        final obj = _objectionController.text.trim();
        title = '$prod: ${obj.length > 40 ? "${obj.substring(0, 40)}..." : obj}';
        item = FeedbackItemEntity(
          id: '',
          type: FeedbackType.doctorObjection,
          title: title,
          submittedAt: DateTime.now(),
          product: prod,
          objection: obj,
          doctorSpecialty: _doctorSpecialtyController.text.trim().isEmpty
              ? null
              : _doctorSpecialtyController.text.trim(),
          howResponded: _howRespondedController.text.trim().isEmpty
              ? null
              : _howRespondedController.text.trim(),
        );
        break;

      case FeedbackType.competitorClaim:
        final comp = _competitorNameController.text.trim();
        final cl = _claimController.text.trim();
        title = '$comp: ${cl.length > 40 ? "${cl.substring(0, 40)}..." : cl}';
        item = FeedbackItemEntity(
          id: '',
          type: FeedbackType.competitorClaim,
          title: title,
          submittedAt: DateTime.now(),
          competitorName: comp,
          claim: cl,
          whereHeard: _whereHeardController.text.trim().isEmpty
              ? null
              : _whereHeardController.text.trim(),
          photoUrl: _hasPhotoAttached ? 'assets/mock/attached_photo.jpg' : null,
        );
        break;

      case FeedbackType.fieldFeedback:
        final top = _topicController.text.trim();
        final det = _detailsController.text.trim();
        title = top;
        item = FeedbackItemEntity(
          id: '',
          type: FeedbackType.fieldFeedback,
          title: title,
          submittedAt: DateTime.now(),
          topic: top,
          details: det,
          voiceNoteUrl: _hasVoiceNoteAttached ? 'assets/mock/voice_note.m4a' : null,
        );
        break;
    }

    final repo = ref.read(feedbackRepositoryProvider);
    final result = await repo.submitFeedback(item);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (submittedItem) {
        // Optimistically insert into controller list
        ref.read(feedbackListControllerProvider.notifier).addSubmission(submittedItem);

        // Replace route with success screen
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackSuccessScreen(
              submittedItem: submittedItem,
              type: widget.type,
            ),
          ),
        );
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.debugMessage ?? 'Submission failed'),
            backgroundColor: context.rxColors.error,
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

    String screenTitle;
    String screenSubtitle;
    IconData typeIcon;

    switch (widget.type) {
      case FeedbackType.doctorObjection:
        screenTitle = l10n.typeDoctorObjection;
        screenSubtitle = l10n.descDoctorObjection;
        typeIcon = LucideIcons.stethoscope;
        break;
      case FeedbackType.competitorClaim:
        screenTitle = l10n.typeCompetitorClaim;
        screenSubtitle = l10n.descCompetitorClaim;
        typeIcon = LucideIcons.shieldAlert;
        break;
      case FeedbackType.fieldFeedback:
        screenTitle = l10n.typeFieldFeedback;
        screenSubtitle = l10n.descFieldFeedback;
        typeIcon = LucideIcons.messageSquare;
        break;
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (_draftRestored)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: RxSpacing.s16),
              child: Center(
                child: StatusBadge(
                  label: l10n.draftRestored,
                  variant: StatusBadgeVariant.neutral,
                  icon: LucideIcons.fileCheck,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s14),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
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
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: RxRadii.borderButton,
                    ),
                    child: Icon(typeIcon, size: 18.0, color: colors.primary),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          screenTitle,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: RxSpacing.s2),
                        Text(
                          screenSubtitle,
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
            const SizedBox(height: RxSpacing.s20),

            // Form inputs depending on feedback type
            if (widget.type == FeedbackType.doctorObjection) ...[
              AppTextField(
                controller: _productController,
                label: 'Product',
                hint: 'e.g. Cardura XL, AtorvaCare',
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _objectionController,
                label: 'The Objection',
                hint: 'What exact concern or skepticism did the doctor express?',
                errorText: _field2Error,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _doctorSpecialtyController,
                  label: 'Doctor Specialty (optional)',
                  hint: 'e.g. Interventional Cardiologist, Nephrologist',
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _howRespondedController,
                  label: 'How I Responded (optional)',
                  hint: 'What clinical talking point or trial data did you share?',
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ],
            ] else if (widget.type == FeedbackType.competitorClaim) ...[
              AppTextField(
                controller: _competitorNameController,
                label: 'Competitor Name & Product',
                hint: 'e.g. PharmaStar Generic Atorvastatin',
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _claimController,
                label: 'The Claim Heard',
                hint: 'What promotional statement or comparison was made?',
                errorText: _field2Error,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _whereHeardController,
                  label: 'Where Heard (optional)',
                  hint: 'e.g. Cardiology CME Conference, Hospital Dept Meeting',
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: RxSpacing.s16),
                // Photo Attachment toggle
                InkWell(
                  onTap: () {
                    setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                    _onFieldChanged();
                  },
                  borderRadius: RxRadii.borderInput,
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                    decoration: BoxDecoration(
                      color: _hasPhotoAttached
                          ? colors.primary.withValues(alpha: 0.05)
                          : colors.surface,
                      borderRadius: RxRadii.borderInput,
                      border: Border.all(
                        color: _hasPhotoAttached ? colors.primary : colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasPhotoAttached ? LucideIcons.checkCircle2 : LucideIcons.camera,
                          size: 18.0,
                          color: _hasPhotoAttached ? colors.primary : colors.textSecondary,
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            _hasPhotoAttached
                                ? 'Photo flyer attached (sample_flyer.jpg)'
                                : 'Attach flyer or promotional photo (optional)',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: _hasPhotoAttached ? FontWeight.w600 : FontWeight.w400,
                              color: _hasPhotoAttached ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                        if (_hasPhotoAttached)
                          Icon(LucideIcons.x, size: 16.0, color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ] else if (widget.type == FeedbackType.fieldFeedback) ...[
              AppTextField(
                controller: _topicController,
                label: 'Topic / Campaign',
                hint: 'e.g. Sample Availability, Laminated Visual Aid Request',
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _detailsController,
                label: 'Details',
                hint: 'Explain the situation or request clearly for the marketing team...',
                errorText: _field2Error,
                minLines: 4,
                maxLines: 6,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                // Voice note simulated attachment
                InkWell(
                  onTap: () {
                    setState(() => _hasVoiceNoteAttached = !_hasVoiceNoteAttached);
                    _onFieldChanged();
                  },
                  borderRadius: RxRadii.borderInput,
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                    decoration: BoxDecoration(
                      color: _hasVoiceNoteAttached
                          ? colors.primary.withValues(alpha: 0.05)
                          : colors.surface,
                      borderRadius: RxRadii.borderInput,
                      border: Border.all(
                        color: _hasVoiceNoteAttached ? colors.primary : colors.border,
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasVoiceNoteAttached ? LucideIcons.checkCircle2 : LucideIcons.mic,
                          size: 18.0,
                          color: _hasVoiceNoteAttached ? colors.primary : colors.textSecondary,
                        ),
                        const SizedBox(width: RxSpacing.s10),
                        Expanded(
                          child: Text(
                            _hasVoiceNoteAttached
                                ? 'Voice note recorded (0:32)'
                                : 'Attach quick voice note (optional)',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight:
                                  _hasVoiceNoteAttached ? FontWeight.w600 : FontWeight.w400,
                              color: _hasVoiceNoteAttached ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                        if (_hasVoiceNoteAttached)
                          Icon(LucideIcons.x, size: 16.0, color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: RxSpacing.s24),

            // Single primary send button
            AppButton(
              text: l10n.btnSendFeedback,
              leadingIcon: LucideIcons.send,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
