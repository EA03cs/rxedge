import '../../domain/entities/learning_entities.dart';

/// Splits backend single-string positioning fields (newlines, bullets, Latin/Arabic semicolons)
/// into clean scannable bullet lists. Supports `List` or `String` inputs.
List<String> parseClinicalBulletList(dynamic raw) {
  if (raw == null) return const [];
  if (raw is List) {
    return raw
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  final text = raw.toString().trim();
  if (text.isEmpty) return const [];

  final parts = text
      .split(RegExp(r'(?:\r?\n|•|؛|;)'))
      .map((s) => s.replaceFirst(RegExp(r'^[-*]\s+'), '').trim())
      .where((s) => s.isNotEmpty)
      .toList();

  return parts.isNotEmpty ? parts : [text];
}

/// Converts backend `summary` + markdown/plain `content` into structured [LessonSectionDto]s
/// when explicit `sections[]` are not already provided.
List<LessonSectionDto> parseLessonSectionsFromContent({
  dynamic rawSections,
  String? summary,
  String? content,
  required String fallbackTitle,
}) {
  if (rawSections is List && rawSections.isNotEmpty) {
    return rawSections
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => LessonSectionDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  final sections = <LessonSectionDto>[];
  final trimmedSummary = summary?.trim();
  final trimmedContent = content?.trim() ?? '';

  if (trimmedContent.isEmpty) {
    if (trimmedSummary != null && trimmedSummary.isNotEmpty) {
      sections.add(
        LessonSectionDto(
          title: fallbackTitle,
          content: trimmedSummary,
          keyTakeaway: trimmedSummary,
        ),
      );
    }
    return sections;
  }

  // Split by markdown headings or blank-line paragraphs.
  final blocks = trimmedContent.split(RegExp(r'\r?\n\s*\r?\n'));
  String? pendingHeading;

  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i].trim();
    if (block.isEmpty) continue;

    final headingMatch = RegExp(r'^#{1,3}\s+(.+)$').firstMatch(block);
    if (headingMatch != null && !block.contains('\n')) {
      pendingHeading = headingMatch.group(1)!.trim();
      continue;
    }

    var sectionTitle = pendingHeading ?? fallbackTitle;
    var body = block;

    final lines = block.split(RegExp(r'\r?\n'));
    if (lines.length > 1 && lines.first.trim().startsWith('#')) {
      sectionTitle = lines.first.replaceFirst(RegExp(r'^#{1,3}\s+'), '').trim();
      body = lines.skip(1).join('\n').trim();
    }

    pendingHeading = null;
    sections.add(
      LessonSectionDto(
        title: sectionTitle,
        content: body,
        keyTakeaway: (i == 0 && trimmedSummary != null && trimmedSummary.isNotEmpty)
            ? trimmedSummary
            : null,
      ),
    );
  }

  if (sections.isEmpty && trimmedSummary != null && trimmedSummary.isNotEmpty) {
    sections.add(
      LessonSectionDto(
        title: fallbackTitle,
        content: trimmedSummary,
        keyTakeaway: trimmedSummary,
      ),
    );
  }

  return sections;
}

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
      keyTakeaway: json['key_takeaway'] as String? ?? json['keyTakeaway'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        if (keyTakeaway != null) 'key_takeaway': keyTakeaway,
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
    final title = json['title']?.toString() ?? '';
    final parsedSections = parseLessonSectionsFromContent(
      rawSections: json['sections'],
      summary: json['summary']?.toString(),
      content: json['content']?.toString(),
      fallbackTitle: title,
    );

    return LessonDto(
      id: json['id']?.toString() ?? '',
      productId:
          json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      productName: json['product_name']?.toString() ??
          json['productName']?.toString() ??
          '',
      title: title,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ??
          (json['estimatedMinutes'] as num?)?.toInt() ??
          5,
      isCompleted:
          json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
      isBookmarked:
          json['is_bookmarked'] as bool? ?? json['isBookmarked'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ??
          (json['orderIndex'] as num?)?.toInt() ??
          1,
      sections: parsedSections,
      quizQuestionCount: (json['quiz_question_count'] as num?)?.toInt() ??
          (json['quizQuestionCount'] as num?)?.toInt() ??
          3,
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
      keyMessage: json['key_message']?.toString() ??
          json['keyMessage']?.toString() ??
          '',
      targetDoctors: parseClinicalBulletList(
        json['target_doctors'] ?? json['targetDoctorSpecialties'],
      ),
      keyBenefits: parseClinicalBulletList(
        json['key_benefits'] ?? json['keyBenefits'],
      ),
      dosageHighlights: parseClinicalBulletList(
        json['dosage_highlights'] ?? json['dosageHighlights'],
      ),
      proofPoints: parseClinicalBulletList(
        json['proof_points'] ?? json['clinicalProofPoints'],
      ),
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
      id: json['id']?.toString() ?? '',
      competitorName: json['competitor_name']?.toString() ??
          json['competitorName']?.toString() ??
          json['name']?.toString() ??
          '',
      theirClaim: json['their_claim']?.toString() ??
          json['theirClaim']?.toString() ??
          json['claims']?.toString() ??
          '',
      howToRespond: json['how_to_respond']?.toString() ??
          json['howToRespond']?.toString() ??
          json['recommendedResponse']?.toString() ??
          '',
      proofReference: json['proof_reference']?.toString() ??
          json['proofReference']?.toString() ??
          json['clinicalReference']?.toString() ??
          '',
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
  final String? boxImageUrl;
  final ProductPositioningDto positioning;
  final List<CompetitorComparisonDto> competitors;
  final List<LessonDto> lessons;

  const ProductLearningDto({
    required this.id,
    required this.name,
    required this.therapeuticArea,
    required this.isRecommended,
    this.boxImageUrl,
    required this.positioning,
    required this.competitors,
    required this.lessons,
  });

  factory ProductLearningDto.fromJson(Map<String, dynamic> json) {
    final positioningSource = json['positioning'] is Map
        ? Map<String, dynamic>.from(json['positioning'] as Map)
        : json;

    return ProductLearningDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      therapeuticArea: json['therapeuticAreaName']?.toString() ??
          json['therapeutic_area']?.toString() ??
          json['therapeuticArea']?.toString() ??
          '',
      isRecommended:
          json['is_recommended'] as bool? ?? json['isRecommended'] as bool? ?? false,
      boxImageUrl:
          json['box_image_url']?.toString() ?? json['boxImageUrl']?.toString(),
      positioning: ProductPositioningDto.fromJson(positioningSource),
      competitors: (json['competitors'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => CompetitorComparisonDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => LessonDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'therapeutic_area': therapeuticArea,
        'is_recommended': isRecommended,
        if (boxImageUrl != null) 'box_image_url': boxImageUrl,
        'positioning': positioning.toJson(),
        'competitors': competitors.map((e) => e.toJson()).toList(),
        'lessons': lessons.map((e) => e.toJson()).toList(),
      };

  ProductLearningEntity toDomain() => ProductLearningEntity(
        id: id,
        name: name,
        therapeuticArea: therapeuticArea,
        isRecommended: isRecommended,
        boxImageUrl: boxImageUrl,
        positioning: positioning.toDomain(),
        competitors: competitors.map((e) => e.toDomain()).toList(),
        lessons: lessons.map((e) => e.toDomain()).toList(),
      );
}
