import 'dart:math' as math;
import '../../domain/entities/home_dashboard_entity.dart';

/// DTOs for RxEdge Home Dashboard
/// Supports both `D:\Backend\rxedge` `GET /dashboard/home` JSON shape and
/// cached/test snake_case maps seamlessly.
class HomeDashboardDto {
  final ContinueLearningDto? continueLesson;
  final RecommendedProductDto? recommendedProduct;
  final MonthlyChallengeDto challenge;
  final DoctorObjectionDto objection;
  final List<MaterialUpdateDto> recentMaterials;
  final RepStatsDto stats;
  final int unreadNotificationCount;

  const HomeDashboardDto({
    this.continueLesson,
    this.recommendedProduct,
    required this.challenge,
    required this.objection,
    required this.recentMaterials,
    required this.stats,
    this.unreadNotificationCount = 0,
  });

  factory HomeDashboardDto.fromJson(Map<String, dynamic> json) {
    final bool isBackendPayload = json.containsKey('userPoints') ||
        json.containsKey('continueLearningLesson') ||
        json.containsKey('recommendedProduct') ||
        json.containsKey('monthlyChallenge') ||
        json.containsKey('objectionOfTheMonth');

    if (isBackendPayload) {
      return HomeDashboardDto._fromBackendJson(json);
    }

    final rawMaterials = json['recent_materials'] as List<dynamic>? ?? [];
    return HomeDashboardDto(
      continueLesson: json['continue_lesson'] is Map
          ? ContinueLearningDto.fromJson(
              Map<String, dynamic>.from(json['continue_lesson'] as Map),
            )
          : null,
      recommendedProduct: json['recommended_product'] is Map
          ? RecommendedProductDto.fromJson(
              Map<String, dynamic>.from(json['recommended_product'] as Map),
            )
          : null,
      challenge: MonthlyChallengeDto.fromJson(
        Map<String, dynamic>.from(json['challenge'] as Map? ?? const {}),
      ),
      objection: DoctorObjectionDto.fromJson(
        Map<String, dynamic>.from(json['objection'] as Map? ?? const {}),
      ),
      recentMaterials: rawMaterials
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => MaterialUpdateDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      stats: RepStatsDto.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
      ),
      unreadNotificationCount:
          (json['unread_notification_count'] as num?)?.toInt() ?? 0,
    );
  }

  factory HomeDashboardDto._fromBackendJson(Map<String, dynamic> json) {
    final rawLesson = json['continueLearningLesson'];
    final rawProgress = json['lessonProgress'];
    ContinueLearningDto? continueLesson;
    if (rawLesson is Map) {
      final lessonMap = Map<String, dynamic>.from(rawLesson);
      if (rawProgress is Map) {
        lessonMap['completed_modules'] = rawProgress['completedCount'] ??
            rawProgress['completedLessons'] ??
            1;
        lessonMap['total_modules'] =
            rawProgress['totalCount'] ?? rawProgress['totalLessons'] ?? 4;
      }
      continueLesson = ContinueLearningDto.fromJson(lessonMap);
    }

    final rawProduct = json['recommendedProduct'];
    final rawChallenge = json['monthlyChallenge'];
    final rawObjection = json['objectionOfTheMonth'];
    final rawMaterials = json['recentClinicalMaterials'] as List<dynamic>? ?? [];

    final challengeMap = rawChallenge is Map
        ? Map<String, dynamic>.from(rawChallenge)
        : <String, dynamic>{};
    if (json['currentChallengeRank'] != null) {
      challengeMap['current_rank'] = json['currentChallengeRank'];
    }

    return HomeDashboardDto(
      continueLesson: continueLesson,
      recommendedProduct: rawProduct is Map
          ? RecommendedProductDto.fromJson(Map<String, dynamic>.from(rawProduct))
          : null,
      challenge: MonthlyChallengeDto.fromJson(challengeMap),
      objection: DoctorObjectionDto.fromJson(
        rawObjection is Map
            ? Map<String, dynamic>.from(rawObjection)
            : const <String, dynamic>{},
      ),
      recentMaterials: rawMaterials
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => MaterialUpdateDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      stats: RepStatsDto(
        points: (json['userPoints'] as num?)?.toInt() ?? 0,
        streakDays: (json['currentStreak'] as num?)?.toInt() ?? 0,
        quizzesCompleted: (json['completedQuizzes'] as num?)?.toInt() ?? 0,
      ),
      unreadNotificationCount:
          (json['relevantNotificationCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'continue_lesson': continueLesson?.toJson(),
        'recommended_product': recommendedProduct?.toJson(),
        'challenge': challenge.toJson(),
        'objection': objection.toJson(),
        'recent_materials': recentMaterials.map((e) => e.toJson()).toList(),
        'stats': stats.toJson(),
        'unread_notification_count': unreadNotificationCount,
      };

  HomeDashboardEntity toDomain() => HomeDashboardEntity(
        continueLesson: continueLesson?.toDomain(),
        recommendedProduct: recommendedProduct?.toDomain(),
        challenge: challenge.toDomain(),
        objection: objection.toDomain(),
        recentMaterials: recentMaterials.map((e) => e.toDomain()).toList(),
        stats: stats.toDomain(),
        unreadNotificationCount: unreadNotificationCount,
      );
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
    final completed = (json['completed_modules'] as num?)?.toInt() ?? 0;
    final total = math.max(1, (json['total_modules'] as num?)?.toInt() ?? 1);
    final rawProgress = (json['progress'] as num?)?.toDouble();
    final derivedProgress = rawProgress ??
        (json['completed_modules'] != null
            ? (completed / total).clamp(0.0, 1.0)
            : 0.25);

    return ContinueLearningDto(
      id: json['id']?.toString() ?? '',
      productName: json['product_name']?.toString() ??
          json['productName']?.toString() ??
          '',
      lessonTitle: json['lesson_title']?.toString() ??
          json['title']?.toString() ??
          '',
      progress: derivedProgress,
      totalModules: total,
      completedModules: completed,
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
  final String? boxImageUrl;

  const RecommendedProductDto({
    required this.id,
    required this.productName,
    required this.therapeuticArea,
    required this.description,
    this.boxImageUrl,
  });

  factory RecommendedProductDto.fromJson(Map<String, dynamic> json) =>
      RecommendedProductDto(
        id: json['id']?.toString() ?? '',
        productName: json['product_name']?.toString() ??
            json['name']?.toString() ??
            '',
        therapeuticArea: json['therapeuticAreaName']?.toString() ??
            json['therapeutic_area']?.toString() ??
            json['therapeuticArea']?.toString() ??
            '',
        description: json['description']?.toString() ??
            json['keyMessage']?.toString() ??
            '',
        boxImageUrl:
            json['box_image_url']?.toString() ?? json['boxImageUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'therapeutic_area': therapeuticArea,
        'description': description,
        if (boxImageUrl != null) 'box_image_url': boxImageUrl,
      };

  RecommendedProductEntity toDomain() => RecommendedProductEntity(
        id: id,
        productName: productName,
        therapeuticArea: therapeuticArea,
        description: description,
        boxImageUrl: boxImageUrl,
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
    final userProgress = json['userProgress'];
    double parsedProgress = (json['progress'] as num?)?.toDouble() ?? 0.0;
    if (userProgress is Map) {
      final pct = (userProgress['percentage'] as num?)?.toDouble();
      if (pct != null) {
        parsedProgress = (pct / 100.0).clamp(0.0, 1.0);
      } else {
        final cur = (userProgress['currentPoints'] as num?)?.toDouble() ?? 0.0;
        final target = (userProgress['targetPoints'] as num?)?.toDouble() ?? 1.0;
        parsedProgress = target > 0 ? (cur / target).clamp(0.0, 1.0) : 0.0;
      }
    }

    int parsedDaysLeft = (json['days_left'] as num?)?.toInt() ?? 0;
    if (json['days_left'] == null && json['endDate'] != null) {
      final endDate = DateTime.tryParse(json['endDate'].toString());
      if (endDate != null) {
        parsedDaysLeft = math.max(0, endDate.difference(DateTime.now()).inDays);
      }
    }

    return MonthlyChallengeDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      daysLeft: parsedDaysLeft,
      progress: parsedProgress,
      currentRank: (json['current_rank'] as num?)?.toInt() ??
          (json['currentChallengeRank'] as num?)?.toInt() ??
          1,
      totalParticipants: (json['total_participants'] as num?)?.toInt() ??
          (json['totalParticipants'] as num?)?.toInt() ??
          0,
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

  factory DoctorObjectionDto.fromJson(Map<String, dynamic> json) =>
      DoctorObjectionDto(
        id: json['id']?.toString() ?? '',
        doctorQuote: json['doctor_quote']?.toString() ??
            json['doctorQuote']?.toString() ??
            '',
        doctorName: json['doctor_name']?.toString() ??
            json['doctorName']?.toString() ??
            '',
        specialty: json['specialty']?.toString() ??
            json['doctorSpecialty']?.toString() ??
            '',
        productConcerned: json['product_concerned']?.toString() ??
            json['productName']?.toString() ??
            '',
        responseSummary: json['response_summary']?.toString() ??
            json['recommendedResponse']?.toString() ??
            '',
      );

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
  final String badgeType;
  final String updatedAt;
  final String? thumbnailUrl;
  final String? fileUrl;

  const MaterialUpdateDto({
    required this.id,
    required this.title,
    required this.specialty,
    required this.badgeType,
    required this.updatedAt,
    this.thumbnailUrl,
    this.fileUrl,
  });

  factory MaterialUpdateDto.fromJson(Map<String, dynamic> json) {
    final createdIso = json['updated_at']?.toString() ??
        json['createdAt']?.toString() ??
        DateTime.now().toIso8601String();
    final createdAt = DateTime.tryParse(createdIso) ?? DateTime.now();
    final isRecent = DateTime.now().difference(createdAt).inDays <= 7;
    final version = (json['version'] as num?)?.toInt() ?? 1;

    final rawBadge = json['badge_type']?.toString() ??
        (version > 1 ? 'updated' : (isRecent ? 'new' : 'updated'));

    return MaterialUpdateDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      specialty: json['specialty']?.toString() ??
          json['productName']?.toString() ??
          json['type']?.toString() ??
          '',
      badgeType: rawBadge,
      updatedAt: createdIso,
      thumbnailUrl:
          json['thumbnail_url']?.toString() ?? json['thumbnailUrl']?.toString(),
      fileUrl: json['file_url']?.toString() ?? json['fileUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'specialty': specialty,
        'badge_type': badgeType,
        'updated_at': updatedAt,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (fileUrl != null) 'file_url': fileUrl,
      };

  MaterialUpdateEntity toDomain() => MaterialUpdateEntity(
        id: id,
        title: title,
        specialty: specialty,
        badgeType: badgeType == 'new' || badgeType == 'newRelease'
            ? MaterialBadgeType.newRelease
            : MaterialBadgeType.updated,
        updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
        thumbnailUrl: thumbnailUrl,
        fileUrl: fileUrl,
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

  factory RepStatsDto.fromJson(Map<String, dynamic> json) => RepStatsDto(
        points: (json['points'] as num?)?.toInt() ??
            (json['userPoints'] as num?)?.toInt() ??
            0,
        streakDays: (json['streak_days'] as num?)?.toInt() ??
            (json['currentStreak'] as num?)?.toInt() ??
            0,
        quizzesCompleted: (json['quizzes_completed'] as num?)?.toInt() ??
            (json['completedQuizzes'] as num?)?.toInt() ??
            0,
      );

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
