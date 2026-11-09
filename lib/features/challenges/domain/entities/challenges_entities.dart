library;

/// Pure Dart Domain Entities for Challenges & Gamification
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."
/// Professional gamification: restrained amber accent, no confetti spam.

class LeaderboardEntry {
  final int rank;
  final String repName;
  final String territory;
  final int points;
  final bool isCurrentUser;
  final String? avatarInitials;

  const LeaderboardEntry({
    required this.rank,
    required this.repName,
    required this.territory,
    required this.points,
    this.isCurrentUser = false,
    this.avatarInitials,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntry &&
          runtimeType == other.runtimeType &&
          rank == other.rank &&
          repName == other.repName &&
          points == other.points &&
          isCurrentUser == other.isCurrentUser;

  @override
  int get hashCode => rank.hashCode ^ repName.hashCode ^ points.hashCode;
}

class MonthlyChallengeEntity {
  final String id;
  final String title;
  final DateTime deadline;
  final List<String> rules;
  final double currentProgress;
  final int completedMilestones;
  final int totalMilestones;
  final int userRank;
  final int totalParticipants;
  final List<String> rewards;
  final List<LeaderboardEntry> leaderboard;

  const MonthlyChallengeEntity({
    required this.id,
    required this.title,
    required this.deadline,
    required this.rules,
    required this.currentProgress,
    required this.completedMilestones,
    required this.totalMilestones,
    required this.userRank,
    required this.totalParticipants,
    required this.rewards,
    required this.leaderboard,
  });

  int get daysLeft {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get hoursLeft {
    final diff = deadline.difference(DateTime.now()).inHours % 24;
    return diff < 0 ? 0 : diff;
  }

  MonthlyChallengeEntity copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    List<String>? rules,
    double? currentProgress,
    int? completedMilestones,
    int? totalMilestones,
    int? userRank,
    int? totalParticipants,
    List<String>? rewards,
    List<LeaderboardEntry>? leaderboard,
  }) {
    return MonthlyChallengeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      rules: rules ?? this.rules,
      currentProgress: currentProgress ?? this.currentProgress,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      userRank: userRank ?? this.userRank,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      rewards: rewards ?? this.rewards,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyChallengeEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          currentProgress == other.currentProgress;

  @override
  int get hashCode => id.hashCode ^ currentProgress.hashCode;
}

class QuizQuestionEntity {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestionEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class QuickQuizEntity {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final int rewardPoints;
  final List<QuizQuestionEntity> questions;
  final bool isCompleted;
  final int? lastScore;
  final int? lastMaxScore;

  const QuickQuizEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.rewardPoints,
    required this.questions,
    this.isCompleted = false,
    this.lastScore,
    this.lastMaxScore,
  });

  QuickQuizEntity copyWith({
    String? id,
    String? title,
    String? category,
    int? durationMinutes,
    int? rewardPoints,
    List<QuizQuestionEntity>? questions,
    bool? isCompleted,
    int? lastScore,
    int? lastMaxScore,
  }) {
    return QuickQuizEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      questions: questions ?? this.questions,
      isCompleted: isCompleted ?? this.isCompleted,
      lastScore: lastScore ?? this.lastScore,
      lastMaxScore: lastMaxScore ?? this.lastMaxScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickQuizEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isCompleted == other.isCompleted &&
          lastScore == other.lastScore;

  @override
  int get hashCode => id.hashCode ^ isCompleted.hashCode ^ (lastScore ?? 0);
}

class ObjectionOfTheMonthEntity {
  final String id;
  final String doctorQuote;
  final String doctorName;
  final String doctorSpecialty;
  final String productConcerned;
  final String recommendedResponse;
  final List<String> talkingPoints;
  final String studyReference;
  final int helpfulCount;
  final String? userFeedback; // 'helpful', 'needs_improvement', null
  final int communityResponseCount;

  const ObjectionOfTheMonthEntity({
    required this.id,
    required this.doctorQuote,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.productConcerned,
    required this.recommendedResponse,
    required this.talkingPoints,
    required this.studyReference,
    this.helpfulCount = 42,
    this.userFeedback,
    this.communityResponseCount = 9,
  });

  ObjectionOfTheMonthEntity copyWith({
    String? id,
    String? doctorQuote,
    String? doctorName,
    String? doctorSpecialty,
    String? productConcerned,
    String? recommendedResponse,
    List<String>? talkingPoints,
    String? studyReference,
    int? helpfulCount,
    String? userFeedback,
    int? communityResponseCount,
  }) {
    return ObjectionOfTheMonthEntity(
      id: id ?? this.id,
      doctorQuote: doctorQuote ?? this.doctorQuote,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      productConcerned: productConcerned ?? this.productConcerned,
      recommendedResponse: recommendedResponse ?? this.recommendedResponse,
      talkingPoints: talkingPoints ?? this.talkingPoints,
      studyReference: studyReference ?? this.studyReference,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      userFeedback: userFeedback ?? this.userFeedback,
      communityResponseCount: communityResponseCount ?? this.communityResponseCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjectionOfTheMonthEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userFeedback == other.userFeedback;

  @override
  int get hashCode => id.hashCode ^ (userFeedback?.hashCode ?? 0);
}

class PastChallengeHistoryEntity {
  final String id;
  final String title;
  final DateTime completedAt;
  final int finalRank;
  final int totalParticipants;
  final int pointsEarned;
  final String? badgeEarned;

  const PastChallengeHistoryEntity({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.finalRank,
    required this.totalParticipants,
    required this.pointsEarned,
    this.badgeEarned,
  });
}

class QuizResultHistoryEntity {
  final String id;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int pointsEarned;
  final int timeTakenSeconds;
  final DateTime completedAt;

  const QuizResultHistoryEntity({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.timeTakenSeconds,
    required this.completedAt,
  });

  double get percentage => totalQuestions == 0 ? 0.0 : score / totalQuestions;
  bool get isHighScore => percentage >= 0.8;
}
