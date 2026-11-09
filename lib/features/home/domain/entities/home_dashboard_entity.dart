library;

/// Pure Dart Domain Entities for Home Dashboard
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."

enum MaterialBadgeType {
  newRelease,
  updated,
}

class ContinueLearningEntity {
  final String id;
  final String productName;
  final String lessonTitle;
  final double progress; // 0.0 to 1.0
  final int totalModules;
  final int completedModules;

  const ContinueLearningEntity({
    required this.id,
    required this.productName,
    required this.lessonTitle,
    required this.progress,
    required this.totalModules,
    required this.completedModules,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinueLearningEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productName == other.productName &&
          lessonTitle == other.lessonTitle &&
          progress == other.progress;

  @override
  int get hashCode =>
      id.hashCode ^ productName.hashCode ^ lessonTitle.hashCode ^ progress.hashCode;
}

class RecommendedProductEntity {
  final String id;
  final String productName;
  final String therapeuticArea;
  final String description;

  const RecommendedProductEntity({
    required this.id,
    required this.productName,
    required this.therapeuticArea,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productName == other.productName;

  @override
  int get hashCode => id.hashCode ^ productName.hashCode;
}

class MonthlyChallengeEntity {
  final String id;
  final String title;
  final int daysLeft;
  final double progress; // 0.0 to 1.0
  final int currentRank;
  final int totalParticipants;

  const MonthlyChallengeEntity({
    required this.id,
    required this.title,
    required this.daysLeft,
    required this.progress,
    required this.currentRank,
    required this.totalParticipants,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyChallengeEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          daysLeft == other.daysLeft &&
          progress == other.progress;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ daysLeft.hashCode ^ progress.hashCode;
}

class DoctorObjectionEntity {
  final String id;
  final String doctorQuote;
  final String doctorName;
  final String specialty;
  final String productConcerned;
  final String responseSummary;

  const DoctorObjectionEntity({
    required this.id,
    required this.doctorQuote,
    required this.doctorName,
    required this.specialty,
    required this.productConcerned,
    required this.responseSummary,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorObjectionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          doctorQuote == other.doctorQuote;

  @override
  int get hashCode => id.hashCode ^ doctorQuote.hashCode;
}

class MaterialUpdateEntity {
  final String id;
  final String title;
  final String specialty;
  final MaterialBadgeType badgeType;
  final DateTime updatedAt;

  const MaterialUpdateEntity({
    required this.id,
    required this.title,
    required this.specialty,
    required this.badgeType,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialUpdateEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

class RepStatsEntity {
  final int points;
  final int streakDays;
  final int quizzesCompleted;

  const RepStatsEntity({
    required this.points,
    required this.streakDays,
    required this.quizzesCompleted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepStatsEntity &&
          runtimeType == other.runtimeType &&
          points == other.points &&
          streakDays == other.streakDays &&
          quizzesCompleted == other.quizzesCompleted;

  @override
  int get hashCode => points.hashCode ^ streakDays.hashCode ^ quizzesCompleted.hashCode;
}

/// Aggregated Home Dashboard Entity
class HomeDashboardEntity {
  final ContinueLearningEntity? continueLesson;
  final RecommendedProductEntity? recommendedProduct;
  final MonthlyChallengeEntity challenge;
  final DoctorObjectionEntity objection;
  final List<MaterialUpdateEntity> recentMaterials;
  final RepStatsEntity stats;

  const HomeDashboardEntity({
    this.continueLesson,
    this.recommendedProduct,
    required this.challenge,
    required this.objection,
    required this.recentMaterials,
    required this.stats,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeDashboardEntity &&
          runtimeType == other.runtimeType &&
          continueLesson == other.continueLesson &&
          recommendedProduct == other.recommendedProduct &&
          challenge == other.challenge &&
          objection == other.objection &&
          stats == other.stats;

  @override
  int get hashCode =>
      continueLesson.hashCode ^
      recommendedProduct.hashCode ^
      challenge.hashCode ^
      objection.hashCode ^
      stats.hashCode;
}
