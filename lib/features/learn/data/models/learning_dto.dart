import '../../domain/entities/learning_entities.dart';

class LessonSectionDto {
  final String title;
  final String content;
  final String? keyTakeaway;

  const LessonSectionDto({
    required this.title,
    required this.content,
    this.keyTakeaway,
  });

  factory LessonSectionDto.fromJson(Map<String, dynamic> json) {
    return LessonSectionDto(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      keyTakeaway: json['key_takeaway'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'key_takeaway': keyTakeaway,
      };

  LessonSection toDomain() => LessonSection(
        title: title,
        content: content,
        keyTakeaway: keyTakeaway,
      );
}

class LessonDto {
  final String id;
  final String productId;
  final String productName;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final bool isBookmarked;
  final int order;
  final List<LessonSectionDto> sections;
  final int quizQuestionCount;

  const LessonDto({
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

  factory LessonDto.fromJson(Map<String, dynamic> json) {
    return LessonDto(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      isCompleted: json['is_completed'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      order: json['order'] as int? ?? 1,
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => LessonSectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      quizQuestionCount: json['quiz_question_count'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'title': title,
        'duration_minutes': durationMinutes,
        'is_completed': isCompleted,
        'is_bookmarked': isBookmarked,
        'order': order,
        'sections': sections.map((e) => e.toJson()).toList(),
        'quiz_question_count': quizQuestionCount,
      };

  LessonEntity toDomain() => LessonEntity(
        id: id,
        productId: productId,
        productName: productName,
        title: title,
        durationMinutes: durationMinutes,
        isCompleted: isCompleted,
        isBookmarked: isBookmarked,
        order: order,
        sections: sections.map((e) => e.toDomain()).toList(),
        quizQuestionCount: quizQuestionCount,
      );
}

class ProductPositioningDto {
  final String keyMessage;
  final List<String> targetDoctors;
  final List<String> keyBenefits;
  final List<String> dosageHighlights;
  final List<String> proofPoints;

  const ProductPositioningDto({
    required this.keyMessage,
    required this.targetDoctors,
    required this.keyBenefits,
    required this.dosageHighlights,
    required this.proofPoints,
  });

  factory ProductPositioningDto.fromJson(Map<String, dynamic> json) {
    return ProductPositioningDto(
      keyMessage: json['key_message'] as String? ?? '',
      targetDoctors: (json['target_doctors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      keyBenefits: (json['key_benefits'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      dosageHighlights: (json['dosage_highlights'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      proofPoints: (json['proof_points'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key_message': keyMessage,
        'target_doctors': targetDoctors,
        'key_benefits': keyBenefits,
        'dosage_highlights': dosageHighlights,
        'proof_points': proofPoints,
      };

  ProductPositioningEntity toDomain() => ProductPositioningEntity(
        keyMessage: keyMessage,
        targetDoctors: targetDoctors,
        keyBenefits: keyBenefits,
        dosageHighlights: dosageHighlights,
        proofPoints: proofPoints,
      );
}

class CompetitorComparisonDto {
  final String id;
  final String competitorName;
  final String theirClaim;
  final String howToRespond;
  final String proofReference;

  const CompetitorComparisonDto({
    required this.id,
    required this.competitorName,
    required this.theirClaim,
    required this.howToRespond,
    required this.proofReference,
  });

  factory CompetitorComparisonDto.fromJson(Map<String, dynamic> json) {
    return CompetitorComparisonDto(
      id: json['id'] as String? ?? '',
      competitorName: json['competitor_name'] as String? ?? '',
      theirClaim: json['their_claim'] as String? ?? '',
      howToRespond: json['how_to_respond'] as String? ?? '',
      proofReference: json['proof_reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'competitor_name': competitorName,
        'their_claim': theirClaim,
        'how_to_respond': howToRespond,
        'proof_reference': proofReference,
      };

  CompetitorComparisonEntity toDomain() => CompetitorComparisonEntity(
        id: id,
        competitorName: competitorName,
        theirClaim: theirClaim,
        howToRespond: howToRespond,
        proofReference: proofReference,
      );
}

class ProductLearningDto {
  final String id;
  final String name;
  final String therapeuticArea;
  final bool isRecommended;
  final ProductPositioningDto positioning;
  final List<CompetitorComparisonDto> competitors;
  final List<LessonDto> lessons;

  const ProductLearningDto({
    required this.id,
    required this.name,
    required this.therapeuticArea,
    this.isRecommended = false,
    required this.positioning,
    required this.competitors,
    required this.lessons,
  });

  factory ProductLearningDto.fromJson(Map<String, dynamic> json) {
    return ProductLearningDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      therapeuticArea: json['therapeutic_area'] as String? ?? '',
      isRecommended: json['is_recommended'] as bool? ?? false,
      positioning: ProductPositioningDto.fromJson(
        json['positioning'] as Map<String, dynamic>? ?? {},
      ),
      competitors: (json['competitors'] as List<dynamic>? ?? [])
          .map((e) => CompetitorComparisonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((e) => LessonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'therapeutic_area': therapeuticArea,
        'is_recommended': isRecommended,
        'positioning': positioning.toJson(),
        'competitors': competitors.map((e) => e.toJson()).toList(),
        'lessons': lessons.map((e) => e.toJson()).toList(),
      };

  ProductLearningEntity toDomain() => ProductLearningEntity(
        id: id,
        name: name,
        therapeuticArea: therapeuticArea,
        isRecommended: isRecommended,
        positioning: positioning.toDomain(),
        competitors: competitors.map((e) => e.toDomain()).toList(),
        lessons: lessons.map((e) => e.toDomain()).toList(),
      );
}
