import '../../../../core/utils/uuid_v4.dart';
import '../../domain/entities/feedback_entities.dart';

/// DTO for Feedback Item
class FeedbackItemDto {
  final String id;
  final String? clientSubmissionId;
  final String? productId;
  final String typeString;
  final String title;
  final String submittedAtIso;
  final String statusString;

  // Doctor Objection
  final String? product;
  final String? objection;
  final String? doctorSpecialty;
  final String? howResponded;

  // Competitor Claim
  final String? competitorName;
  final String? claim;
  final String? whereHeard;
  final String? photoUrl;

  // Field Feedback
  final String? topic;
  final String? details;
  final String? voiceNoteUrl;

  // Marketing Reply
  final String? marketingReply;
  final String? repliedBy;
  final String? repliedAtIso;

  const FeedbackItemDto({
    required this.id,
    this.clientSubmissionId,
    this.productId,
    required this.typeString,
    required this.title,
    required this.submittedAtIso,
    this.statusString = 'sent',
    this.product,
    this.objection,
    this.doctorSpecialty,
    this.howResponded,
    this.competitorName,
    this.claim,
    this.whereHeard,
    this.photoUrl,
    this.topic,
    this.details,
    this.voiceNoteUrl,
    this.marketingReply,
    this.repliedBy,
    this.repliedAtIso,
  });

  factory FeedbackItemDto.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String?;
    final resolvedTypeString =
        json['typeString'] as String? ?? _typeFromCategory(category);
    final rawStatus = (json['statusString'] ?? json['status']) as String? ?? 'sent';
    final replies = json['replies'] as List<dynamic>?;
    Map<String, dynamic>? latestReply;
    if (replies != null && replies.isNotEmpty && replies.last is Map) {
      latestReply = Map<String, dynamic>.from(replies.last as Map);
    }
    final repliedByUser = latestReply?['repliedBy'] as Map<String, dynamic>?;

    final details = json['details'] as String?;
    final attachmentUrl = json['attachmentUrl'] as String?;

    return FeedbackItemDto(
      id: json['id'] as String? ?? '',
      clientSubmissionId: json['clientSubmissionId'] as String?,
      productId: json['productId'] as String?,
      typeString: resolvedTypeString,
      title: json['title'] as String? ?? '',
      submittedAtIso: json['submittedAtIso'] as String? ??
          json['createdAt'] as String? ??
          DateTime.now().toIso8601String(),
      statusString: rawStatus.toLowerCase(),
      product: json['product'] as String? ?? json['productName'] as String?,
      objection: json['objection'] as String? ??
          (resolvedTypeString == 'doctorObjection' ? details : null),
      doctorSpecialty: json['doctorSpecialty'] as String?,
      howResponded: json['howResponded'] as String? ??
          json['representativeResponse'] as String?,
      competitorName: json['competitorName'] as String?,
      claim: json['claim'] as String? ?? json['competitorClaim'] as String?,
      whereHeard: json['whereHeard'] as String?,
      photoUrl: json['photoUrl'] as String? ?? attachmentUrl,
      topic: json['topic'] as String? ??
          (resolvedTypeString == 'fieldFeedback' ? json['title'] as String? : null),
      details: details,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      marketingReply: json['marketingReply'] as String? ??
          latestReply?['message'] as String?,
      repliedBy: json['repliedBy'] as String? ??
          repliedByUser?['name'] as String?,
      repliedAtIso: json['repliedAtIso'] as String? ??
          latestReply?['createdAt'] as String?,
    );
  }

  static String _typeFromCategory(String? category) {
    switch (category) {
      case 'doctor_objection':
        return 'doctorObjection';
      case 'competitor_claim':
        return 'competitorClaim';
      case 'general_field_feedback':
      default:
        return 'fieldFeedback';
    }
  }

  String get backendCategory {
    switch (typeString) {
      case 'doctorObjection':
        return 'doctor_objection';
      case 'competitorClaim':
        return 'competitor_claim';
      case 'fieldFeedback':
      default:
        return 'general_field_feedback';
    }
  }

  /// Payload aligned with `D:\Backend\rxedge\src\modules\feedback\feedback.validation.js`
  Map<String, dynamic> toBackendPayload({String? overrideClientSubmissionId}) {
    final resolvedClientId = overrideClientSubmissionId ??
        clientSubmissionId ??
        UuidV4.generate();
    final resolvedDetails = (details != null && details!.trim().isNotEmpty)
        ? details!.trim()
        : (objection?.trim().isNotEmpty == true
            ? objection!.trim()
            : (claim?.trim().isNotEmpty == true
                ? claim!.trim()
                : title.trim()));

    final rawAttachment = photoUrl ?? voiceNoteUrl;
    final validAttachment = rawAttachment != null &&
            (rawAttachment.startsWith('http://') ||
                rawAttachment.startsWith('https://'))
        ? rawAttachment
        : null;

    return <String, dynamic>{
      'clientSubmissionId': resolvedClientId,
      'category': backendCategory,
      if (productId != null && _isUuid(productId!)) 'productId': productId,
      'title': title.trim().isNotEmpty ? title.trim() : resolvedDetails,
      if (doctorSpecialty != null && doctorSpecialty!.trim().isNotEmpty)
        'doctorSpecialty': doctorSpecialty!.trim(),
      'details': resolvedDetails,
      if (howResponded != null && howResponded!.trim().isNotEmpty)
        'representativeResponse': howResponded!.trim(),
      if (competitorName != null && competitorName!.trim().isNotEmpty)
        'competitorName': competitorName!.trim(),
      if (claim != null && claim!.trim().isNotEmpty) 'competitorClaim': claim!.trim(),
      'attachmentUrl': ?validAttachment,
    };
  }

  static bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (clientSubmissionId != null)
          'clientSubmissionId': clientSubmissionId,
        if (productId != null) 'productId': productId,
        'typeString': typeString,
        'title': title,
        'submittedAtIso': submittedAtIso,
        'statusString': statusString,
        'product': product,
        'objection': objection,
        'doctorSpecialty': doctorSpecialty,
        'howResponded': howResponded,
        'competitorName': competitorName,
        'claim': claim,
        'whereHeard': whereHeard,
        'photoUrl': photoUrl,
        'topic': topic,
        'details': details,
        'voiceNoteUrl': voiceNoteUrl,
        'marketingReply': marketingReply,
        'repliedBy': repliedBy,
        'repliedAtIso': repliedAtIso,
      };

  FeedbackItemEntity toDomain() {
    FeedbackType type;
    switch (typeString) {
      case 'doctorObjection':
        type = FeedbackType.doctorObjection;
        break;
      case 'competitorClaim':
        type = FeedbackType.competitorClaim;
        break;
      case 'fieldFeedback':
      default:
        type = FeedbackType.fieldFeedback;
        break;
    }

    FeedbackStatus status;
    switch (statusString) {
      case 'pending':
        status = FeedbackStatus.pending;
        break;
      case 'seen':
        status = FeedbackStatus.seen;
        break;
      case 'answered':
        status = FeedbackStatus.answered;
        break;
      case 'sent':
      default:
        status = FeedbackStatus.sent;
        break;
    }

    return FeedbackItemEntity(
      id: id,
      clientSubmissionId: clientSubmissionId,
      productId: productId,
      type: type,
      title: title,
      submittedAt: DateTime.tryParse(submittedAtIso) ?? DateTime.now(),
      status: status,
      product: product,
      objection: objection,
      doctorSpecialty: doctorSpecialty,
      howResponded: howResponded,
      competitorName: competitorName,
      claim: claim,
      whereHeard: whereHeard,
      photoUrl: photoUrl,
      topic: topic,
      details: details,
      voiceNoteUrl: voiceNoteUrl,
      marketingReply: marketingReply,
      repliedBy: repliedBy,
      repliedAt: repliedAtIso != null ? DateTime.tryParse(repliedAtIso!) : null,
    );
  }

  factory FeedbackItemDto.fromDomain(FeedbackItemEntity entity) {
    return FeedbackItemDto(
      id: entity.id,
      clientSubmissionId: entity.clientSubmissionId,
      productId: entity.productId,
      typeString: entity.type.name,
      title: entity.title,
      submittedAtIso: entity.submittedAt.toIso8601String(),
      statusString: entity.status.name,
      product: entity.product,
      objection: entity.objection,
      doctorSpecialty: entity.doctorSpecialty,
      howResponded: entity.howResponded,
      competitorName: entity.competitorName,
      claim: entity.claim,
      whereHeard: entity.whereHeard,
      photoUrl: entity.photoUrl,
      topic: entity.topic,
      details: entity.details,
      voiceNoteUrl: entity.voiceNoteUrl,
      marketingReply: entity.marketingReply,
      repliedBy: entity.repliedBy,
      repliedAtIso: entity.repliedAt?.toIso8601String(),
    );
  }
}

/// DTO for Feedback Draft
class FeedbackDraftDto {
  final String typeString;
  final String? product;
  final String? objection;
  final String? doctorSpecialty;
  final String? howResponded;
  final String? competitorName;
  final String? claim;
  final String? whereHeard;
  final String? topic;
  final String? details;
  final bool hasAttachment;

  const FeedbackDraftDto({
    required this.typeString,
    this.product,
    this.objection,
    this.doctorSpecialty,
    this.howResponded,
    this.competitorName,
    this.claim,
    this.whereHeard,
    this.topic,
    this.details,
    this.hasAttachment = false,
  });

  factory FeedbackDraftDto.fromJson(Map<String, dynamic> json) {
    return FeedbackDraftDto(
      typeString: json['typeString'] as String,
      product: json['product'] as String?,
      objection: json['objection'] as String?,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      howResponded: json['howResponded'] as String?,
      competitorName: json['competitorName'] as String?,
      claim: json['claim'] as String?,
      whereHeard: json['whereHeard'] as String?,
      topic: json['topic'] as String?,
      details: json['details'] as String?,
      hasAttachment: json['hasAttachment'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'typeString': typeString,
        'product': product,
        'objection': objection,
        'doctorSpecialty': doctorSpecialty,
        'howResponded': howResponded,
        'competitorName': competitorName,
        'claim': claim,
        'whereHeard': whereHeard,
        'topic': topic,
        'details': details,
        'hasAttachment': hasAttachment,
      };

  FeedbackDraftEntity toDomain() {
    FeedbackType type;
    switch (typeString) {
      case 'doctorObjection':
        type = FeedbackType.doctorObjection;
        break;
      case 'competitorClaim':
        type = FeedbackType.competitorClaim;
        break;
      case 'fieldFeedback':
      default:
        type = FeedbackType.fieldFeedback;
        break;
    }

    return FeedbackDraftEntity(
      type: type,
      product: product,
      objection: objection,
      doctorSpecialty: doctorSpecialty,
      howResponded: howResponded,
      competitorName: competitorName,
      claim: claim,
      whereHeard: whereHeard,
      topic: topic,
      details: details,
      hasAttachment: hasAttachment,
    );
  }

  factory FeedbackDraftDto.fromDomain(FeedbackDraftEntity entity) {
    return FeedbackDraftDto(
      typeString: entity.type.name,
      product: entity.product,
      objection: entity.objection,
      doctorSpecialty: entity.doctorSpecialty,
      howResponded: entity.howResponded,
      competitorName: entity.competitorName,
      claim: entity.claim,
      whereHeard: entity.whereHeard,
      topic: entity.topic,
      details: entity.details,
      hasAttachment: entity.hasAttachment,
    );
  }
}
