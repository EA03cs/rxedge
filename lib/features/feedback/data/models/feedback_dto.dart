import '../../domain/entities/feedback_entities.dart';

/// DTO for Feedback Item
class FeedbackItemDto {
  final String id;
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
    return FeedbackItemDto(
      id: json['id'] as String,
      typeString: json['typeString'] as String,
      title: json['title'] as String,
      submittedAtIso: json['submittedAtIso'] as String,
      statusString: json['statusString'] as String? ?? 'sent',
      product: json['product'] as String?,
      objection: json['objection'] as String?,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      howResponded: json['howResponded'] as String?,
      competitorName: json['competitorName'] as String?,
      claim: json['claim'] as String?,
      whereHeard: json['whereHeard'] as String?,
      photoUrl: json['photoUrl'] as String?,
      topic: json['topic'] as String?,
      details: json['details'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      marketingReply: json['marketingReply'] as String?,
      repliedBy: json['repliedBy'] as String?,
      repliedAtIso: json['repliedAtIso'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
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
