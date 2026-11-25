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
    final name =
        json['repName']?.toString() ?? json['name']?.toString() ?? '';
    return LeaderboardEntryDto(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      repName: name,
      territory: (json['territory'] is Map
              ? (json['territory'] as Map)['name']?.toString()
              : json['territory']?.toString()) ??
          '',
      points: ((json['points'] ?? json['totalPoints']) as num?)?.toInt() ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ??
          (name.toLowerCase().contains('ahmed') ||
              name.toLowerCase().contains('you') ||
              name.contains('أحمد')),
      avatarInitials:
          json['avatarInitials']?.toString() ?? _initialsFromName(name),
    );
  }

  static String? _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
    final userProgress = json['userProgress'] as Map<String, dynamic>?;
    final currentPoints = (userProgress?['currentPoints'] as num?)?.toInt() ?? 0;
    final targetPoints = (userProgress?['targetPoints'] as num?)?.toInt() ??
        (json['targetPoints'] as num?)?.toInt() ??
        100;
    final rawPercentage = (userProgress?['percentage'] as num?)?.toDouble();
    final currentProgress = (json['currentProgress'] as num?)?.toDouble() ??
        (rawPercentage != null
            ? (rawPercentage / 100.0).clamp(0.0, 1.0)
            : (targetPoints > 0
                ? (currentPoints / targetPoints).clamp(0.0, 1.0)
                : 0.0));

    final rawRules = json['rules'];
    final rules = rawRules is List
        ? rawRules.map((e) => e.toString()).toList()
        : (rawRules is String && rawRules.trim().isNotEmpty
            ? rawRules
                .split(RegExp(r'\r?\n'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : const <String>[]);

    final rewardsRaw = json['rewards'];
    List<String> rewards = const [];
    if (rewardsRaw is List && rewardsRaw.isNotEmpty) {
      rewards = rewardsRaw.map((e) => e.toString()).toList();
    } else {
      final pts = (json['pointsReward'] as num?)?.toInt() ??
          (json['rewardPoints'] as num?)?.toInt() ??
          (json['reward'] is num ? (json['reward'] as num).toInt() : null);
      final list = <String>[];
      if (pts != null && pts > 0) {
        list.add('+$pts Marks Reward');
      } else if (json['reward'] != null && json['reward'].toString().isNotEmpty) {
        list.add(json['reward'].toString());
      }
      rewards = list;
    }

    return MonthlyChallengeDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      deadlineIso: json['deadlineIso']?.toString() ??
          json['endDate']?.toString() ??
          DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      rules: rules,
      currentProgress: currentProgress,
      completedMilestones:
          (json['completedMilestones'] as num?)?.toInt() ?? currentPoints,
      totalMilestones:
          (json['totalMilestones'] as num?)?.toInt() ?? targetPoints,
      userRank: (json['userRank'] as num?)?.toInt() ?? 0,
      totalParticipants: (json['totalParticipants'] as num?)?.toInt() ?? 0,
      rewards: rewards,
      leaderboard: (json['leaderboard'] as List<dynamic>? ?? const [])
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
  final List<String> optionIds;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestionDto({
    required this.id,
    required this.question,
    required this.options,
    this.optionIds = const [],
    required this.correctOptionIndex,
    required this.explanation,
  });

  factory QuizQuestionDto.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    final optionTexts = <String>[];
    final optionIds = <String>[];
    for (final opt in rawOptions) {
      if (opt is Map) {
        optionTexts.add((opt['optionText'] ?? opt['text'] ?? '').toString());
        final oid = opt['id']?.toString();
        if (oid != null) optionIds.add(oid);
      } else {
        optionTexts.add(opt.toString());
      }
    }

    final savedOptionIds = (json['optionIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        optionIds;

    return QuizQuestionDto(
      id: json['id']?.toString() ?? '',
      question:
          json['question']?.toString() ?? json['questionText']?.toString() ?? '',
      options: optionTexts,
      optionIds: savedOptionIds,
      correctOptionIndex: (json['correctOptionIndex'] as num?)?.toInt() ?? -1,
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        if (optionIds.isNotEmpty) 'optionIds': optionIds,
        'correctOptionIndex': correctOptionIndex,
        'explanation': explanation,
      };

  QuizQuestionEntity toDomain() => QuizQuestionEntity(
        id: id,
        question: question,
        options: options,
        optionIds: optionIds,
        correctOptionIndex: correctOptionIndex,
        explanation: explanation,
      );
}

/// DTO for Quick Quiz
class QuickQuizDto {
  final String id;
  final String? lessonId;
  final String title;
  final String category;
  final int durationMinutes;
  final int rewardPoints;
  final List<QuizQuestionDto> questions;
  final int? questionCount;
  final bool isCompleted;
  final int? lastScore;
  final int? lastMaxScore;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? completionWindowDays;

  const QuickQuizDto({
    required this.id,
    this.lessonId,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.rewardPoints,
    required this.questions,
    this.questionCount,
    this.isCompleted = false,
    this.lastScore,
    this.lastMaxScore,
    this.startDate,
    this.endDate,
    this.completionWindowDays,
  });

  factory QuickQuizDto.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    final timeLimitSec = (json['timeLimitSeconds'] as num?)?.toInt();
    final derivedMinutes = (json['durationMinutes'] as num?)?.toInt() ??
        (timeLimitSec != null ? (timeLimitSec / 60).ceil().clamp(1, 60) : 3);
    final qCount = (json['questionCount'] as num?)?.toInt() ??
        (json['questionsCount'] as num?)?.toInt() ??
        rawQuestions.length;

    final startStr = json['startDate']?.toString();
    final endStr = json['endDate']?.toString();
    final startDate = startStr != null ? DateTime.tryParse(startStr) : null;
    final endDate = endStr != null ? DateTime.tryParse(endStr) : null;
    final completionWindowDays = (json['completionWindowDays'] as num?)?.toInt();

    return QuickQuizDto(
      id: json['id']?.toString() ?? '',
      lessonId: json['lessonId']?.toString(),
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ??
          json['productName']?.toString() ??
          json['lessonTitle']?.toString() ??
          '',
      durationMinutes: derivedMinutes,
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ??
          (json['pointsReward'] as num?)?.toInt() ??
          0,
      questions: rawQuestions
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => QuizQuestionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      questionCount: qCount,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastScore: (json['lastScore'] as num?)?.toInt(),
      lastMaxScore: (json['lastMaxScore'] as num?)?.toInt(),
      startDate: startDate,
      endDate: endDate,
      completionWindowDays: completionWindowDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (lessonId != null) 'lessonId': lessonId,
        'title': title,
        'category': category,
        'durationMinutes': durationMinutes,
        'rewardPoints': rewardPoints,
        'questions': questions.map((e) => e.toJson()).toList(),
        if (questionCount != null) 'questionCount': questionCount,
        'isCompleted': isCompleted,
        'lastScore': lastScore,
        'lastMaxScore': lastMaxScore,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (completionWindowDays != null)
          'completionWindowDays': completionWindowDays,
      };

  QuickQuizEntity toDomain() => QuickQuizEntity(
        id: id,
        lessonId: lessonId,
        title: title,
        category: category,
        durationMinutes: durationMinutes,
        rewardPoints: rewardPoints,
        questions: questions.map((e) => e.toDomain()).toList(),
        questionCount: questionCount,
        isCompleted: isCompleted,
        lastScore: lastScore,
        lastMaxScore: lastMaxScore,
        startDate: startDate,
        endDate: endDate,
        completionWindowDays: completionWindowDays,
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
    final recommended = json['recommendedResponse']?.toString() ?? '';
    final rawPoints = json['talkingPoints'];
    final talkingPoints = rawPoints is List
        ? rawPoints.map((e) => e.toString()).toList()
        : recommended
            .split(RegExp(r'\r?\n|[•\.]\s+'))
            .map((e) => e.trim())
            .where((e) => e.length > 6)
            .toList();

    return ObjectionOfTheMonthDto(
      id: json['id']?.toString() ?? '',
      doctorQuote: json['doctorQuote']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? '',
      doctorSpecialty: json['doctorSpecialty']?.toString() ?? '',
      productConcerned: json['productConcerned']?.toString() ??
          json['productName']?.toString() ??
          '',
      recommendedResponse: recommended,
      talkingPoints: talkingPoints,
      studyReference: json['studyReference']?.toString() ??
          json['supportingReferences']?.toString() ??
          '',
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      userFeedback: json['userFeedback']?.toString(),
      communityResponseCount:
          (json['communityResponseCount'] as num?)?.toInt() ?? 0,
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      completedAtIso: json['completedAtIso']?.toString() ?? json['createdAt']?.toString() ?? '',
      finalRank: (json['finalRank'] as num?)?.toInt() ?? 0,
      totalParticipants: (json['totalParticipants'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      badgeEarned: json['badgeEarned']?.toString(),
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
      id: json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? json['referenceId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? json['title']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      timeTakenSeconds: (json['timeTakenSeconds'] as num?)?.toInt() ?? 0,
      completedAtIso: json['completedAtIso']?.toString() ?? json['createdAt']?.toString() ?? '',
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

class QuizAnswerEvaluationDto {
  final String questionId;
  final String? selectedOptionId;
  final bool isCorrect;
  final String? explanation;
  final String? correctOptionId;
  final String? correctOptionText;

  const QuizAnswerEvaluationDto({
    required this.questionId,
    this.selectedOptionId,
    required this.isCorrect,
    this.explanation,
    this.correctOptionId,
    this.correctOptionText,
  });

  factory QuizAnswerEvaluationDto.fromJson(Map<String, dynamic> json) {
    return QuizAnswerEvaluationDto(
      questionId: json['questionId']?.toString() ?? '',
      selectedOptionId: json['selectedOptionId']?.toString(),
      isCorrect: json['isCorrect'] as bool? ?? false,
      explanation: json['explanation']?.toString(),
      correctOptionId: json['correctOptionId']?.toString(),
      correctOptionText: json['correctOptionText']?.toString(),
    );
  }

  QuizAnswerEvaluationEntity toDomain() => QuizAnswerEvaluationEntity(
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        isCorrect: isCorrect,
        explanation: explanation,
        correctOptionId: correctOptionId,
        correctOptionText: correctOptionText,
      );
}

class QuizSubmissionResultDto {
  final String attemptId;
  final int score;
  final bool isPassed;
  final int passingScore;
  final int pointsAwarded;
  final List<QuizAnswerEvaluationDto> answers;

  const QuizSubmissionResultDto({
    required this.attemptId,
    required this.score,
    required this.isPassed,
    required this.passingScore,
    required this.pointsAwarded,
    required this.answers,
  });

  factory QuizSubmissionResultDto.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionResultDto(
      attemptId: json['attemptId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      isPassed: json['isPassed'] as bool? ?? false,
      passingScore: (json['passingScore'] as num?)?.toInt() ?? 70,
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      answers: (json['answers'] as List<dynamic>? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => QuizAnswerEvaluationDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  QuizSubmissionResultEntity toDomain() => QuizSubmissionResultEntity(
        attemptId: attemptId,
        scorePercentage: score,
        isPassed: isPassed,
        passingScore: passingScore,
        pointsAwarded: pointsAwarded,
        answers: answers.map((e) => e.toDomain()).toList(),
      );
}
