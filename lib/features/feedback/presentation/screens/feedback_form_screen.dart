import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:record/record.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/storage/local_file_helper.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../learn/domain/entities/learning_entities.dart';
import '../../../learn/presentation/controllers/learn_controller.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/entities/feedback_entities.dart';
import '../controllers/feedback_controller.dart';
import '../widgets/voice_note_player_card.dart';
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
  String? _selectedProductId;

  // UI state
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;
  bool _isRecordingVoice = false;
  bool _isUploadingVoice = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  AudioRecorder? _recorder;
  bool _draftRestored = false;
  bool _showOptionalFields = false;
  Uint8List? _attachedPhotoBytes;
  String? _uploadedPhotoUrl;
  String? _localPhotoPath;
  String? _uploadedVoiceNoteUrl;
  String? _localVoicePath;
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
    _recordingTimer?.cancel();
    try {
      _recorder?.dispose();
    } catch (_) {}
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
    final submissionId = UuidV4.generate();
    final products =
        ref.read(learnControllerProvider).valueOrNull ??
            const <ProductLearningEntity>[];

    switch (widget.type) {
      case FeedbackType.doctorObjection:
        final prod = _productController.text.trim();
        final obj = _objectionController.text.trim();
        final matchedProductId = _selectedProductId ??
            products
                .where(
                  (p) => p.name.trim().toLowerCase() == prod.toLowerCase(),
                )
                .map((p) => p.id)
                .firstOrNull;
        title = '$prod: ${obj.length > 40 ? "${obj.substring(0, 40)}..." : obj}';
        item = FeedbackItemEntity(
          id: '',
          clientSubmissionId: submissionId,
          productId: matchedProductId,
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
          photoUrl: _uploadedPhotoUrl ?? _localPhotoPath,
        );
        break;

      case FeedbackType.competitorClaim:
        final comp = _competitorNameController.text.trim();
        final cl = _claimController.text.trim();
        title = '$comp: ${cl.length > 40 ? "${cl.substring(0, 40)}..." : cl}';
        item = FeedbackItemEntity(
          id: '',
          clientSubmissionId: submissionId,
          productId: _selectedProductId,
          type: FeedbackType.competitorClaim,
          title: title,
          submittedAt: DateTime.now(),
          competitorName: comp,
          claim: cl,
          whereHeard: _whereHeardController.text.trim().isEmpty
              ? null
              : _whereHeardController.text.trim(),
          photoUrl: _uploadedPhotoUrl ?? _localPhotoPath,
        );
        break;

      case FeedbackType.fieldFeedback:
        final top = _topicController.text.trim();
        final det = _detailsController.text.trim();
        title = top;
        item = FeedbackItemEntity(
          id: '',
          clientSubmissionId: submissionId,
          productId: _selectedProductId,
          type: FeedbackType.fieldFeedback,
          title: title,
          submittedAt: DateTime.now(),
          topic: top,
          details: det,
          photoUrl: _uploadedPhotoUrl ?? _localPhotoPath,
          voiceNoteUrl: _uploadedVoiceNoteUrl ?? _localVoicePath,
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
        Navigator.of(context, rootNavigator: true).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => FeedbackSuccessScreen(
              submittedItem: submittedItem,
              type: widget.type,
            ),
          ),
        );
      },
      failure: (failure) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.debugMessage ?? l10n.submissionFailedFallback),
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

            if ((ref.watch(learnControllerProvider).valueOrNull ??
                    const <ProductLearningEntity>[])
                .isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final products =
                      ref.watch(learnControllerProvider).valueOrNull ??
                          const <ProductLearningEntity>[];
                  final validSelected = products.any(
                    (p) => p.id == _selectedProductId,
                  )
                      ? _selectedProductId
                      : null;
                  return DropdownButtonFormField<String?>(
                    initialValue: validSelected,
                    decoration: InputDecoration(
                      labelText: l10n.selectProductOptional,
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: RxRadii.borderInput,
                        borderSide: BorderSide(
                          color: colors.border,
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.noProductSelected),
                      ),
                      ...products.map(
                        (p) => DropdownMenuItem<String?>(
                          value: p.id,
                          child: Text(p.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedProductId = val;
                        if (val != null &&
                            widget.type == FeedbackType.doctorObjection) {
                          final picked = products
                              .where((p) => p.id == val)
                              .firstOrNull;
                          if (picked != null) {
                            _productController.text = picked.name;
                          }
                        }
                      });
                      _onFieldChanged();
                    },
                  );
                },
              ),
              const SizedBox(height: RxSpacing.s16),
            ],

            // Form inputs depending on feedback type
            if (widget.type == FeedbackType.doctorObjection) ...[
              AppTextField(
                controller: _productController,
                label: l10n.labelProduct,
                hint: l10n.productHintExamples,
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _objectionController,
                label: l10n.labelDoctorObjection,
                hint: l10n.hintDoctorObjection,
                errorText: _field2Error,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _doctorSpecialtyController,
                  label: l10n.optionalFieldSuffix(l10n.labelDoctorSpecialty),
                  hint: l10n.specialtyHintExamples,
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _howRespondedController,
                  label: l10n.optionalFieldSuffix(l10n.labelHowResponded),
                  hint: l10n.hintHowResponded,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: RxSpacing.s16),
                _buildPhotoAttachmentCard(context),
              ],
            ] else if (widget.type == FeedbackType.competitorClaim) ...[
              AppTextField(
                controller: _competitorNameController,
                label: l10n.labelCompetitorProduct,
                hint: l10n.competitorHintExamples,
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _claimController,
                label: l10n.labelClaimHeard,
                hint: l10n.hintCompetitorClaim,
                errorText: _field2Error,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                AppTextField(
                  controller: _whereHeardController,
                  label: l10n.optionalFieldSuffix(l10n.labelWhereHeard),
                  hint: l10n.whereHeardHintExamples,
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: RxSpacing.s16),
                _buildPhotoAttachmentCard(context),
              ],
            ] else if (widget.type == FeedbackType.fieldFeedback) ...[
              AppTextField(
                controller: _topicController,
                label: l10n.labelTopicCampaign,
                hint: l10n.topicHintExamples,
                errorText: _field1Error,
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: RxSpacing.s16),
              AppTextField(
                controller: _detailsController,
                label: l10n.labelDetails,
                hint: l10n.hintDetails,
                errorText: _field2Error,
                minLines: 4,
                maxLines: 6,
                onChanged: (_) => _onFieldChanged(),
              ),
              if (_showOptionalFields) ...[
                const SizedBox(height: RxSpacing.s16),
                _buildPhotoAttachmentCard(context),
                const SizedBox(height: RxSpacing.s12),
                _buildVoiceAttachmentCard(context),
              ],
            ],

            const SizedBox(height: RxSpacing.s24),

            // Single primary send button
            AppButton(
              text: l10n.btnSendFeedback,
              leadingIcon: LucideIcons.send,
              isLoading: _isSubmitting || _isUploadingPhoto || _isUploadingVoice,
              onPressed: (_isSubmitting ||
                      _isUploadingPhoto ||
                      _isUploadingVoice ||
                      _isRecordingVoice)
                  ? null
                  : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_isUploadingPhoto) return;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(isArabic ? 'التقاط صورة بالكاميرا' : 'Take Photo with Camera'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(isArabic ? 'اختيار صورة من المعرض' : 'Choose from Gallery'),
              onTap: () => Navigator.of(sheetCtx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _attachedPhotoBytes = bytes;
        _hasPhotoAttached = true;
        _isUploadingPhoto = true;
      });

      final uploadRes = await ref.read(feedbackRepositoryProvider).uploadAttachment(
            bytes: bytes,
            filename: picked.name.isEmpty ? 'feedback_photo.jpg' : picked.name,
          );
      if (!mounted) return;

      await uploadRes.when<Future<void>>(
        success: (url) async {
          setState(() {
            _uploadedPhotoUrl = url;
            _localPhotoPath = null;
            _hasPhotoAttached = true;
            _isUploadingPhoto = false;
          });
          _onFieldChanged();
        },
        failure: (f) async {
          final savedLocalPath = await savePendingUploadBytes(
            bytes,
            picked.name.isEmpty ? 'feedback_photo.jpg' : picked.name,
          );
          if (!mounted) return;
          if (savedLocalPath != null) {
            setState(() {
              _uploadedPhotoUrl = null;
              _localPhotoPath = savedLocalPath;
              _hasPhotoAttached = true;
              _isUploadingPhoto = false;
            });
            _onFieldChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? 'تم حفظ الصورة محلياً وسيتم رفعها تلقائياً عند عودة الإنترنت'
                      : 'Photo saved locally and will upload when back online.',
                ),
              ),
            );
            return;
          }
          setState(() {
            _isUploadingPhoto = false;
            _hasPhotoAttached = _uploadedPhotoUrl != null;
            if (_uploadedPhotoUrl == null) {
              _attachedPhotoBytes = null;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                f.debugMessage ??
                    (isArabic
                        ? 'تعذر رفع الصورة، تحقق من الاتصال وحاول مجدداً'
                        : 'Failed to upload image. Please check connection.'),
              ),
              backgroundColor: context.rxColors.error,
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
    }
  }

  Widget _buildPhotoAttachmentCard(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final hasImage = _hasPhotoAttached || _uploadedPhotoUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            if (hasImage && !_isUploadingPhoto) {
              final oldLocal = _localPhotoPath;
              setState(() {
                _hasPhotoAttached = false;
                _attachedPhotoBytes = null;
                _uploadedPhotoUrl = null;
                _localPhotoPath = null;
              });
              deleteLocalFile(oldLocal);
              _onFieldChanged();
            } else {
              _pickAndUploadPhoto();
            }
          },
          borderRadius: RxRadii.borderInput,
          child: Container(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
            decoration: BoxDecoration(
              color: hasImage
                  ? colors.primary.withValues(alpha: 0.05)
                  : colors.surface,
              borderRadius: RxRadii.borderInput,
              border: Border.all(
                color: hasImage ? colors.primary : colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Row(
              children: [
                if (_isUploadingPhoto)
                  SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: colors.primary,
                    ),
                  )
                else
                  Icon(
                    hasImage ? LucideIcons.checkCircle2 : LucideIcons.camera,
                    size: 18.0,
                    color: hasImage ? colors.primary : colors.textSecondary,
                  ),
                const SizedBox(width: RxSpacing.s10),
                Expanded(
                  child: Text(
                    hasImage ? l10n.photoAttachedLabel : l10n.attachPhotoOptional,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: hasImage ? FontWeight.w600 : FontWeight.w400,
                      color: hasImage ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ),
                if (hasImage && !_isUploadingPhoto)
                  Icon(LucideIcons.x, size: 16.0, color: colors.textSecondary),
              ],
            ),
          ),
        ),
        if (_attachedPhotoBytes != null) ...[
          const SizedBox(height: RxSpacing.s8),
          ClipRRect(
            borderRadius: RxRadii.borderInput,
            child: Image.memory(
              _attachedPhotoBytes!,
              height: 120.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  String _formatRecordingDuration(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _toggleVoiceRecording() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    try {
      final recorder = _recorder ??= AudioRecorder();

      if (_isRecordingVoice) {
        _recordingTimer?.cancel();
        final path = await recorder.stop();
        if (!mounted) return;

        setState(() {
          _isRecordingVoice = false;
        });

        if (path == null || path.isEmpty) return;

        final bytes = await readLocalFileBytes(path);
        if (!mounted) return;
        if (bytes == null || bytes.isEmpty) {
          setState(() {
            _localVoicePath = path;
            _hasVoiceNoteAttached = true;
          });
          _onFieldChanged();
          return;
        }

        setState(() => _isUploadingVoice = true);
        final uploadRes = await ref.read(feedbackRepositoryProvider).uploadAttachment(
              bytes: bytes,
              filename: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
            );
        if (!mounted) return;

        await uploadRes.when<Future<void>>(
          success: (url) async {
            setState(() {
              _uploadedVoiceNoteUrl = url;
              _localVoicePath = path;
              _hasVoiceNoteAttached = true;
              _isUploadingVoice = false;
            });
            _onFieldChanged();
          },
          failure: (_) async {
            setState(() {
              _uploadedVoiceNoteUrl = null;
              _localVoicePath = path;
              _hasVoiceNoteAttached = true;
              _isUploadingVoice = false;
            });
            _onFieldChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? 'تم حفظ التسجيل الصوتي محلياً وسيتم رفعه تلقائياً عند عودة الإنترنت'
                      : 'Voice note saved locally and will upload when back online.',
                ),
              ),
            );
          },
        );
        return;
      }

      final hasPerm = await recorder.hasPermission();
      if (!mounted) return;
      if (!hasPerm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'يرجى منح صلاحية الميكروفون لتسجيل ملاحظة صوتية'
                  : 'Microphone permission is required to record a voice note.',
            ),
            backgroundColor: context.rxColors.error,
          ),
        );
        return;
      }

      final targetPath = await createRecordingFilePath();
      if (!mounted) return;
      if (targetPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'التسجيل الصوتي متاح على تطبيق الهاتف حالياً'
                  : 'Voice recording is available on mobile devices.',
            ),
          ),
        );
        return;
      }

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 16000,
        ),
        path: targetPath,
      );
      if (!mounted) return;

      _recordingTimer?.cancel();
      setState(() {
        _isRecordingVoice = true;
        _recordingSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordingSeconds++);
      });
    } catch (_) {
      if (!mounted) return;
      _recordingTimer?.cancel();
      setState(() {
        _isRecordingVoice = false;
        _isUploadingVoice = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذر بدء التسجيل الصوتي على هذا الجهاز'
                : 'Unable to record audio on this device.',
          ),
          backgroundColor: context.rxColors.error,
        ),
      );
    }
  }

  Widget _buildVoiceAttachmentCard(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final voiceSource = _localVoicePath ?? _uploadedVoiceNoteUrl;

    if (voiceSource != null && voiceSource.isNotEmpty && !_isRecordingVoice) {
      return VoiceNotePlayerCard(
        voiceSource: voiceSource,
        durationLabel: _recordingSeconds > 0
            ? _formatRecordingDuration(_recordingSeconds)
            : null,
        onRemove: () {
          final oldPath = _localVoicePath;
          setState(() {
            _hasVoiceNoteAttached = false;
            _uploadedVoiceNoteUrl = null;
            _localVoicePath = null;
            _recordingSeconds = 0;
          });
          deleteLocalFile(oldPath);
          _onFieldChanged();
        },
      );
    }

    return InkWell(
      onTap: _isUploadingVoice ? null : _toggleVoiceRecording,
      borderRadius: RxRadii.borderInput,
      child: Container(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
        decoration: BoxDecoration(
          color: _isRecordingVoice
              ? colors.error.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: RxRadii.borderInput,
          border: Border.all(
            color: _isRecordingVoice ? colors.error : colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
        child: Row(
          children: [
            if (_isUploadingVoice)
              SizedBox(
                width: 18.0,
                height: 18.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: colors.primary,
                ),
              )
            else
              Icon(
                _isRecordingVoice ? LucideIcons.square : LucideIcons.mic,
                size: 18.0,
                color: _isRecordingVoice ? colors.error : colors.textSecondary,
              ),
            const SizedBox(width: RxSpacing.s10),
            Expanded(
              child: Text(
                _isUploadingVoice
                    ? (isArabic ? 'جاري رفع التسجيل الصوتي...' : 'Uploading voice note...')
                    : (_isRecordingVoice
                        ? (isArabic
                            ? 'جاري التسجيل... اضغط للإيقاف (${_formatRecordingDuration(_recordingSeconds)})'
                            : 'Recording... Tap to stop (${_formatRecordingDuration(_recordingSeconds)})')
                        : l10n.attachVoiceOptional),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: _isRecordingVoice ? FontWeight.w600 : FontWeight.w400,
                  color: _isRecordingVoice ? colors.error : colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
