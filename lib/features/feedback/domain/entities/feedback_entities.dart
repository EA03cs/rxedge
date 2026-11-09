library;

/// Pure Dart Domain Entities for Live Marketing Feedback
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."

enum FeedbackType {
  doctorObjection,
  competitorClaim,
  fieldFeedback,
}

enum FeedbackStatus {
  pending,
  sent,
  seen,
  answered,
}

class FeedbackItemEntity {
  final String id;
  final FeedbackType type;
  final String title;
  final DateTime submittedAt;
  final FeedbackStatus status;

  // Doctor Objection fields
  final String? product;
  final String? objection;
  final String? doctorSpecialty;
  final String? howResponded;

  // Competitor Claim fields
  final String? competitorName;
  final String? claim;
  final String? whereHeard;
  final String? photoUrl;

  // Field Feedback fields
  final String? topic;
  final String? details;
  final String? voiceNoteUrl;

  // Marketing Reply
  final String? marketingReply;
  final String? repliedBy;
  final DateTime? repliedAt;

  const FeedbackItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.submittedAt,
    this.status = FeedbackStatus.sent,
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
    this.repliedAt,
  });

  FeedbackItemEntity copyWith({
    String? id,
    FeedbackType? type,
    String? title,
    DateTime? submittedAt,
    FeedbackStatus? status,
    String? product,
    String? objection,
    String? doctorSpecialty,
    String? howResponded,
    String? competitorName,
    String? claim,
    String? whereHeard,
    String? photoUrl,
    String? topic,
    String? details,
    String? voiceNoteUrl,
    String? marketingReply,
    String? repliedBy,
    DateTime? repliedAt,
  }) {
    return FeedbackItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      product: product ?? this.product,
      objection: objection ?? this.objection,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      howResponded: howResponded ?? this.howResponded,
      competitorName: competitorName ?? this.competitorName,
      claim: claim ?? this.claim,
      whereHeard: whereHeard ?? this.whereHeard,
      photoUrl: photoUrl ?? this.photoUrl,
      topic: topic ?? this.topic,
      details: details ?? this.details,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      marketingReply: marketingReply ?? this.marketingReply,
      repliedBy: repliedBy ?? this.repliedBy,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;
}

class FeedbackDraftEntity {
  final FeedbackType type;
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

  const FeedbackDraftEntity({
    required this.type,
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

  bool get isEmpty =>
      (product == null || product!.isEmpty) &&
      (objection == null || objection!.isEmpty) &&
      (competitorName == null || competitorName!.isEmpty) &&
      (claim == null || claim!.isEmpty) &&
      (details == null || details!.isEmpty);
}
