library;

/// Pure Dart Domain Entities for Smart Learning Hub
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."

class LessonSection {
  final String title;
  final String content;
  final String? keyTakeaway;

  const LessonSection({
    required this.title,
    required this.content,
    this.keyTakeaway,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonSection &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => title.hashCode ^ content.hashCode;
}

class LessonEntity {
  final String id;
  final String productId;
  final String productName;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final bool isBookmarked;
  final int order;
  final List<LessonSection> sections;
  final int quizQuestionCount;

  const LessonEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.title,
    required this.durationMinutes,
    this.isCompleted = false,
    this.isBookmarked = false,
    required this.order,
    this.sections = const [],
    this.quizQuestionCount = 3,
  });

  LessonEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? title,
    int? durationMinutes,
    bool? isCompleted,
    bool? isBookmarked,
    int? order,
    List<LessonSection>? sections,
    int? quizQuestionCount,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      order: order ?? this.order,
      sections: sections ?? this.sections,
      quizQuestionCount: quizQuestionCount ?? this.quizQuestionCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isCompleted == other.isCompleted &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode => id.hashCode ^ isCompleted.hashCode ^ isBookmarked.hashCode;
}

class ProductPositioningEntity {
  final String keyMessage;
  final String? keyPositioning;
  final List<String> keyMessaging;
  final List<String> targetDoctors;
  final String? targetPatient;
  final List<String> keyBenefits;
  final List<String> dosageHighlights;
  final List<String> proofPoints;

  const ProductPositioningEntity({
    required this.keyMessage,
    this.keyPositioning,
    this.keyMessaging = const [],
    required this.targetDoctors,
    this.targetPatient,
    required this.keyBenefits,
    required this.dosageHighlights,
    required this.proofPoints,
  });

  String get effectiveKeyPositioning =>
      (keyPositioning != null && keyPositioning!.trim().isNotEmpty)
          ? keyPositioning!
          : keyMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPositioningEntity &&
          runtimeType == other.runtimeType &&
          keyMessage == other.keyMessage;

  @override
  int get hashCode => keyMessage.hashCode;
}

class CompetitorComparisonEntity {
  final String id;
  final String competitorName;
  final String theirClaim;
  final String howToRespond;
  final String proofReference;

  const CompetitorComparisonEntity({
    required this.id,
    required this.competitorName,
    required this.theirClaim,
    required this.howToRespond,
    required this.proofReference,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitorComparisonEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          competitorName == other.competitorName;

  @override
  int get hashCode => id.hashCode ^ competitorName.hashCode;
}

class ProductPackShotEntity {
  final String id;
  final String imageUrl;
  final String? title;
  final int orderIndex;

  const ProductPackShotEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.orderIndex = 0,
  });
}

class SupportingStudyEntity {
  final String id;
  final String title;
  final String fileUrl;
  final String studyType;
  final int orderIndex;

  const SupportingStudyEntity({
    required this.id,
    required this.title,
    required this.fileUrl,
    this.studyType = 'e_detailed_slides',
    this.orderIndex = 0,
  });
}

class ProductFaqEntity {
  final String id;
  final String question;
  final String answer;
  final int orderIndex;

  const ProductFaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.orderIndex = 0,
  });
}

class ProductLearningEntity {
  final String id;
  final String name;
  final String therapeuticArea;
  final String? productOverview;
  final bool isRecommended;
  final String? boxImageUrl;
  final List<ProductPackShotEntity> packShots;
  final List<SupportingStudyEntity> supportingStudies;
  final List<ProductFaqEntity> faqs;
  final ProductPositioningEntity positioning;
  final List<CompetitorComparisonEntity> competitors;
  final List<LessonEntity> lessons;

  const ProductLearningEntity({
    required this.id,
    required this.name,
    required this.therapeuticArea,
    this.productOverview,
    this.isRecommended = false,
    this.boxImageUrl,
    this.packShots = const [],
    this.supportingStudies = const [],
    this.faqs = const [],
    required this.positioning,
    required this.competitors,
    required this.lessons,
  });

  int get completedLessonsCount => lessons.where((l) => l.isCompleted).length;
  int get totalLessonsCount => lessons.length;

  double get progress =>
      totalLessonsCount == 0 ? 0.0 : completedLessonsCount / totalLessonsCount;

  bool get isInProgress =>
      completedLessonsCount > 0 && completedLessonsCount < totalLessonsCount;

  bool get isCompleted =>
      totalLessonsCount > 0 && completedLessonsCount == totalLessonsCount;

  String? get defaultAssetBanner {
    final lower = name.toLowerCase();
    if (lower.contains('dry aid') || lower.contains('dry-aid')) {
      return 'assets/images/rohto_dry_aid.png';
    }
    if (lower.contains('cool')) return 'assets/images/rohto_cool.png';
    if (lower.contains('aqua')) return 'assets/images/rohto_aqua.png';
    return null;
  }

  ProductLearningEntity copyWith({
    String? id,
    String? name,
    String? therapeuticArea,
    String? productOverview,
    bool? isRecommended,
    String? boxImageUrl,
    List<ProductPackShotEntity>? packShots,
    List<SupportingStudyEntity>? supportingStudies,
    List<ProductFaqEntity>? faqs,
    ProductPositioningEntity? positioning,
    List<CompetitorComparisonEntity>? competitors,
    List<LessonEntity>? lessons,
  }) {
    return ProductLearningEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      therapeuticArea: therapeuticArea ?? this.therapeuticArea,
      productOverview: productOverview ?? this.productOverview,
      isRecommended: isRecommended ?? this.isRecommended,
      boxImageUrl: boxImageUrl ?? this.boxImageUrl,
      packShots: packShots ?? this.packShots,
      supportingStudies: supportingStudies ?? this.supportingStudies,
      faqs: faqs ?? this.faqs,
      positioning: positioning ?? this.positioning,
      competitors: competitors ?? this.competitors,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductLearningEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          completedLessonsCount == other.completedLessonsCount;

  @override
  int get hashCode => id.hashCode ^ completedLessonsCount.hashCode;
}
