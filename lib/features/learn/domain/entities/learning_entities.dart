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
  final List<String> targetDoctors;
  final List<String> keyBenefits;
  final List<String> dosageHighlights;
  final List<String> proofPoints;

  const ProductPositioningEntity({
    required this.keyMessage,
    required this.targetDoctors,
    required this.keyBenefits,
    required this.dosageHighlights,
    required this.proofPoints,
  });

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

class ProductLearningEntity {
  final String id;
  final String name;
  final String therapeuticArea;
  final bool isRecommended;
  final ProductPositioningEntity positioning;
  final List<CompetitorComparisonEntity> competitors;
  final List<LessonEntity> lessons;

  const ProductLearningEntity({
    required this.id,
    required this.name,
    required this.therapeuticArea,
    this.isRecommended = false,
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

  ProductLearningEntity copyWith({
    String? id,
    String? name,
    String? therapeuticArea,
    bool? isRecommended,
    ProductPositioningEntity? positioning,
    List<CompetitorComparisonEntity>? competitors,
    List<LessonEntity>? lessons,
  }) {
    return ProductLearningEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      therapeuticArea: therapeuticArea ?? this.therapeuticArea,
      isRecommended: isRecommended ?? this.isRecommended,
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
