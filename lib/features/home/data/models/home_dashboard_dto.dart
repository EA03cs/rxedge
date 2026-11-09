import '../../domain/entities/home_dashboard_entity.dart';

/// DTO for Home Dashboard Aggregated Data
class HomeDashboardDto {
  final ContinueLearningDto? continueLesson;
  final RecommendedProductDto? recommendedProduct;
  final MonthlyChallengeDto challenge;
  final DoctorObjectionDto objection;
  final List<MaterialUpdateDto> recentMaterials;
  final RepStatsDto stats;

  const HomeDashboardDto({
    this.continueLesson,
    this.recommendedProduct,
    required this.challenge,
    required this.objection,
    required this.recentMaterials,
    required this.stats,
  });

  factory HomeDashboardDto.fromJson(Map<String, dynamic> json) {
    return HomeDashboardDto(
      continueLesson: json['continue_lesson'] != null
          ? ContinueLearningDto.fromJson(json['continue_lesson'] as Map<String, dynamic>)
          : null,
      recommendedProduct: json['recommended_product'] != null
          ? RecommendedProductDto.fromJson(json['recommended_product'] as Map<String, dynamic>)
          : null,
      challenge: MonthlyChallengeDto.fromJson(json['challenge'] as Map<String, dynamic>),
      objection: DoctorObjectionDto.fromJson(json['objection'] as Map<String, dynamic>),
      recentMaterials: (json['recent_materials'] as List<dynamic>? ?? [])
          .map((item) => MaterialUpdateDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: RepStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'continue_lesson': continueLesson?.toJson(),
      'recommended_product': recommendedProduct?.toJson(),
      'challenge': challenge.toJson(),
      'objection': objection.toJson(),
      'recent_materials': recentMaterials.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  HomeDashboardEntity toDomain() {
    return HomeDashboardEntity(
      continueLesson: continueLesson?.toDomain(),
      recommendedProduct: recommendedProduct?.toDomain(),
      challenge: challenge.toDomain(),
      objection: objection.toDomain(),
      recentMaterials: recentMaterials.map((e) => e.toDomain()).toList(),
      stats: stats.toDomain(),
    );
  }
}

class ContinueLearningDto {
  final String id;
  final String productName;
  final String lessonTitle;
  final double progress;
  final int totalModules;
  final int completedModules;

  const ContinueLearningDto({
    required this.id,
    required this.productName,
    required this.lessonTitle,
    required this.progress,
    required this.totalModules,
    required this.completedModules,
  });

  factory ContinueLearningDto.fromJson(Map<String, dynamic> json) {
    return ContinueLearningDto(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      lessonTitle: json['lesson_title'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalModules: json['total_modules'] as int? ?? 5,
      completedModules: json['completed_modules'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'lesson_title': lessonTitle,
        'progress': progress,
        'total_modules': totalModules,
        'completed_modules': completedModules,
      };

  ContinueLearningEntity toDomain() => ContinueLearningEntity(
        id: id,
        productName: productName,
        lessonTitle: lessonTitle,
        progress: progress,
        totalModules: totalModules,
        completedModules: completedModules,
      );
}

class RecommendedProductDto {
  final String id;
  final String productName;
  final String therapeuticArea;
  final String description;

  const RecommendedProductDto({
    required this.id,
    required this.productName,
    required this.therapeuticArea,
    required this.description,
  });

  factory RecommendedProductDto.fromJson(Map<String, dynamic> json) {
    return RecommendedProductDto(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      therapeuticArea: json['therapeutic_area'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'therapeutic_area': therapeuticArea,
        'description': description,
      };

  RecommendedProductEntity toDomain() => RecommendedProductEntity(
        id: id,
        productName: productName,
        therapeuticArea: therapeuticArea,
        description: description,
      );
}

class MonthlyChallengeDto {
  final String id;
  final String title;
  final int daysLeft;
  final double progress;
  final int currentRank;
  final int totalParticipants;

  const MonthlyChallengeDto({
    required this.id,
    required this.title,
    required this.daysLeft,
    required this.progress,
    required this.currentRank,
    required this.totalParticipants,
  });

  factory MonthlyChallengeDto.fromJson(Map<String, dynamic> json) {
    return MonthlyChallengeDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      daysLeft: json['days_left'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      currentRank: json['current_rank'] as int? ?? 1,
      totalParticipants: json['total_participants'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'days_left': daysLeft,
        'progress': progress,
        'current_rank': currentRank,
        'total_participants': totalParticipants,
      };

  MonthlyChallengeEntity toDomain() => MonthlyChallengeEntity(
        id: id,
        title: title,
        daysLeft: daysLeft,
        progress: progress,
        currentRank: currentRank,
        totalParticipants: totalParticipants,
      );
}

class DoctorObjectionDto {
  final String id;
  final String doctorQuote;
  final String doctorName;
  final String specialty;
  final String productConcerned;
  final String responseSummary;

  const DoctorObjectionDto({
    required this.id,
    required this.doctorQuote,
    required this.doctorName,
    required this.specialty,
    required this.productConcerned,
    required this.responseSummary,
  });

  factory DoctorObjectionDto.fromJson(Map<String, dynamic> json) {
    return DoctorObjectionDto(
      id: json['id'] as String? ?? '',
      doctorQuote: json['doctor_quote'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      productConcerned: json['product_concerned'] as String? ?? '',
      responseSummary: json['response_summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor_quote': doctorQuote,
        'doctor_name': doctorName,
        'specialty': specialty,
        'product_concerned': productConcerned,
        'response_summary': responseSummary,
      };

  DoctorObjectionEntity toDomain() => DoctorObjectionEntity(
        id: id,
        doctorQuote: doctorQuote,
        doctorName: doctorName,
        specialty: specialty,
        productConcerned: productConcerned,
        responseSummary: responseSummary,
      );
}

class MaterialUpdateDto {
  final String id;
  final String title;
  final String specialty;
  final String badgeType; // 'new' or 'updated'
  final String updatedAt;

  const MaterialUpdateDto({
    required this.id,
    required this.title,
    required this.specialty,
    required this.badgeType,
    required this.updatedAt,
  });

  factory MaterialUpdateDto.fromJson(Map<String, dynamic> json) {
    return MaterialUpdateDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      badgeType: json['badge_type'] as String? ?? 'new',
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'specialty': specialty,
        'badge_type': badgeType,
        'updated_at': updatedAt,
      };

  MaterialUpdateEntity toDomain() => MaterialUpdateEntity(
        id: id,
        title: title,
        specialty: specialty,
        badgeType: badgeType == 'updated' ? MaterialBadgeType.updated : MaterialBadgeType.newRelease,
        updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      );
}

class RepStatsDto {
  final int points;
  final int streakDays;
  final int quizzesCompleted;

  const RepStatsDto({
    required this.points,
    required this.streakDays,
    required this.quizzesCompleted,
  });

  factory RepStatsDto.fromJson(Map<String, dynamic> json) {
    return RepStatsDto(
      points: json['points'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      quizzesCompleted: json['quizzes_completed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points,
        'streak_days': streakDays,
        'quizzes_completed': quizzesCompleted,
      };

  RepStatsEntity toDomain() => RepStatsEntity(
        points: points,
        streakDays: streakDays,
        quizzesCompleted: quizzesCompleted,
      );
}
