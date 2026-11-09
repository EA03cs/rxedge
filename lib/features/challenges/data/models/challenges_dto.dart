import '../../domain/entities/challenges_entities.dart';

/// DTO for Leaderboard Entry
class LeaderboardEntryDto {
  final int rank;
  final String repName;
  final String territory;
  final int points;
  final bool isCurrentUser;
  final String? avatarInitials;

  const LeaderboardEntryDto({
    required this.rank,
    required this.repName,
    required this.territory,
    required this.points,
    this.isCurrentUser = false,
    this.avatarInitials,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryDto(
      rank: json['rank'] as int,
      repName: json['repName'] as String,
      territory: json['territory'] as String,
      points: json['points'] as int,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      avatarInitials: json['avatarInitials'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'repName': repName,
        'territory': territory,
        'points': points,
        'isCurrentUser': isCurrentUser,
        'avatarInitials': avatarInitials,
      };

  LeaderboardEntry toDomain() => LeaderboardEntry(
        rank: rank,
        repName: repName,
        territory: territory,
        points: points,
        isCurrentUser: isCurrentUser,
        avatarInitials: avatarInitials,
      );
}

/// DTO for Monthly Challenge
class MonthlyChallengeDto {
  final String id;
  final String title;
  final String deadlineIso;
  final List<String> rules;
  final double currentProgress;
  final int completedMilestones;
  final int totalMilestones;
  final int userRank;
  final int totalParticipants;
  final List<String> rewards;
  final List<LeaderboardEntryDto> leaderboard;

  const MonthlyChallengeDto({
    required this.id,
    required this.title,
    required this.deadlineIso,
    required this.rules,
    required this.currentProgress,
    required this.completedMilestones,
    required this.totalMilestones,
    required this.userRank,
    required this.totalParticipants,
    required this.rewards,
    required this.leaderboard,
  });

  factory MonthlyChallengeDto.fromJson(Map<String, dynamic> json) {
    return MonthlyChallengeDto(
      id: json['id'] as String,
      title: json['title'] as String,
      deadlineIso: json['deadlineIso'] as String,
      rules: (json['rules'] as List<dynamic>).map((e) => e as String).toList(),
      currentProgress: (json['currentProgress'] as num).toDouble(),
      completedMilestones: json['completedMilestones'] as int,
      totalMilestones: json['totalMilestones'] as int,
      userRank: json['userRank'] as int,
      totalParticipants: json['totalParticipants'] as int,
      rewards: (json['rewards'] as List<dynamic>).map((e) => e as String).toList(),
      leaderboard: (json['leaderboard'] as List<dynamic>)
          .map((e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deadlineIso': deadlineIso,
        'rules': rules,
        'currentProgress': currentProgress,
        'completedMilestones': completedMilestones,
        'totalMilestones': totalMilestones,
        'userRank': userRank,
        'totalParticipants': totalParticipants,
        'rewards': rewards,
        'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
      };

  MonthlyChallengeEntity toDomain() => MonthlyChallengeEntity(
        id: id,
        title: title,
        deadline: DateTime.tryParse(deadlineIso) ?? DateTime.now().add(const Duration(days: 4)),
        rules: rules,
        currentProgress: currentProgress,
        completedMilestones: completedMilestones,
        totalMilestones: totalMilestones,
        userRank: userRank,
        totalParticipants: totalParticipants,
        rewards: rewards,
        leaderboard: leaderboard.map((e) => e.toDomain()).toList(),
      );
}

/// DTO for Quiz Question
class QuizQuestionDto {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestionDto({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  factory QuizQuestionDto.fromJson(Map<String, dynamic> json) {
    return QuizQuestionDto(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'explanation': explanation,
      };

  QuizQuestionEntity toDomain() => QuizQuestionEntity(
        id: id,
        question: question,
        options: options,
        correctOptionIndex: correctOptionIndex,
        explanation: explanation,
      );
}

/// DTO for Quick Quiz
class QuickQuizDto {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final int rewardPoints;
  final List<QuizQuestionDto> questions;
  final bool isCompleted;
  final int? lastScore;
  final int? lastMaxScore;

  const QuickQuizDto({
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

  factory QuickQuizDto.fromJson(Map<String, dynamic> json) {
    return QuickQuizDto(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      durationMinutes: json['durationMinutes'] as int,
      rewardPoints: json['rewardPoints'] as int,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuizQuestionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastScore: json['lastScore'] as int?,
      lastMaxScore: json['lastMaxScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'durationMinutes': durationMinutes,
        'rewardPoints': rewardPoints,
        'questions': questions.map((e) => e.toJson()).toList(),
        'isCompleted': isCompleted,
        'lastScore': lastScore,
        'lastMaxScore': lastMaxScore,
      };

  QuickQuizEntity toDomain() => QuickQuizEntity(
        id: id,
        title: title,
        category: category,
        durationMinutes: durationMinutes,
        rewardPoints: rewardPoints,
        questions: questions.map((e) => e.toDomain()).toList(),
        isCompleted: isCompleted,
        lastScore: lastScore,
        lastMaxScore: lastMaxScore,
      );
}

/// DTO for Objection of the Month
class ObjectionOfTheMonthDto {
  final String id;
  final String doctorQuote;
  final String doctorName;
  final String doctorSpecialty;
  final String productConcerned;
  final String recommendedResponse;
  final List<String> talkingPoints;
  final String studyReference;
  final int helpfulCount;
  final String? userFeedback;
  final int communityResponseCount;

  const ObjectionOfTheMonthDto({
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

  factory ObjectionOfTheMonthDto.fromJson(Map<String, dynamic> json) {
    return ObjectionOfTheMonthDto(
      id: json['id'] as String,
      doctorQuote: json['doctorQuote'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      productConcerned: json['productConcerned'] as String,
      recommendedResponse: json['recommendedResponse'] as String,
      talkingPoints: (json['talkingPoints'] as List<dynamic>).map((e) => e as String).toList(),
      studyReference: json['studyReference'] as String,
      helpfulCount: json['helpfulCount'] as int? ?? 42,
      userFeedback: json['userFeedback'] as String?,
      communityResponseCount: json['communityResponseCount'] as int? ?? 9,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorQuote': doctorQuote,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'productConcerned': productConcerned,
        'recommendedResponse': recommendedResponse,
        'talkingPoints': talkingPoints,
        'studyReference': studyReference,
        'helpfulCount': helpfulCount,
        'userFeedback': userFeedback,
        'communityResponseCount': communityResponseCount,
      };

  ObjectionOfTheMonthEntity toDomain() => ObjectionOfTheMonthEntity(
        id: id,
        doctorQuote: doctorQuote,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        productConcerned: productConcerned,
        recommendedResponse: recommendedResponse,
        talkingPoints: talkingPoints,
        studyReference: studyReference,
        helpfulCount: helpfulCount,
        userFeedback: userFeedback,
        communityResponseCount: communityResponseCount,
      );
}

/// DTO for Past Challenge History
class PastChallengeHistoryDto {
  final String id;
  final String title;
  final String completedAtIso;
  final int finalRank;
  final int totalParticipants;
  final int pointsEarned;
  final String? badgeEarned;

  const PastChallengeHistoryDto({
    required this.id,
    required this.title,
    required this.completedAtIso,
    required this.finalRank,
    required this.totalParticipants,
    required this.pointsEarned,
    this.badgeEarned,
  });

  factory PastChallengeHistoryDto.fromJson(Map<String, dynamic> json) {
    return PastChallengeHistoryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      completedAtIso: json['completedAtIso'] as String,
      finalRank: json['finalRank'] as int,
      totalParticipants: json['totalParticipants'] as int,
      pointsEarned: json['pointsEarned'] as int,
      badgeEarned: json['badgeEarned'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completedAtIso': completedAtIso,
        'finalRank': finalRank,
        'totalParticipants': totalParticipants,
        'pointsEarned': pointsEarned,
        'badgeEarned': badgeEarned,
      };

  PastChallengeHistoryEntity toDomain() => PastChallengeHistoryEntity(
        id: id,
        title: title,
        completedAt: DateTime.tryParse(completedAtIso) ?? DateTime.now(),
        finalRank: finalRank,
        totalParticipants: totalParticipants,
        pointsEarned: pointsEarned,
        badgeEarned: badgeEarned,
      );
}

/// DTO for Quiz Result History
class QuizResultHistoryDto {
  final String id;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int pointsEarned;
  final int timeTakenSeconds;
  final String completedAtIso;

  const QuizResultHistoryDto({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.timeTakenSeconds,
    required this.completedAtIso,
  });

  factory QuizResultHistoryDto.fromJson(Map<String, dynamic> json) {
    return QuizResultHistoryDto(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      pointsEarned: json['pointsEarned'] as int,
      timeTakenSeconds: json['timeTakenSeconds'] as int,
      completedAtIso: json['completedAtIso'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'pointsEarned': pointsEarned,
        'timeTakenSeconds': timeTakenSeconds,
        'completedAtIso': completedAtIso,
      };

  QuizResultHistoryEntity toDomain() => QuizResultHistoryEntity(
        id: id,
        quizId: quizId,
        quizTitle: quizTitle,
        score: score,
        totalQuestions: totalQuestions,
        pointsEarned: pointsEarned,
        timeTakenSeconds: timeTakenSeconds,
        completedAt: DateTime.tryParse(completedAtIso) ?? DateTime.now(),
      );
}
