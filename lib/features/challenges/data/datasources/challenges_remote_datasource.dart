import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/challenges_dto.dart';

/// Remote Datasource Contract for Challenges & Gamification
abstract class ChallengesRemoteDatasource {
  Future<MonthlyChallengeDto> getMonthlyChallenge();
  Future<List<QuickQuizDto>> getQuickQuizzes();
  Future<QuickQuizDto> getQuizById(String quizId);
  Future<ObjectionOfTheMonthDto> getObjectionOfTheMonth();
  Future<ObjectionOfTheMonthDto> submitObjectionFeedback(String objectionId, String feedbackType);
  Future<void> submitDoctorObjectionResponse(String objectionId, String userResponse);
  Future<QuizSubmissionResultDto> submitQuizAnswers({
    required String quizId,
    required List<Map<String, String>> answers,
  });
  Future<QuizSubmissionResultDto> getQuizAttemptReview(String quizId);
  Future<List<PastChallengeHistoryDto>> getPastChallengesHistory();
  Future<List<QuizResultHistoryDto>> getQuizResultsHistory();
}

/// Remote Datasource Implementation backed by Gamification & Competitors APIs
class ChallengesRemoteDatasourceImpl implements ChallengesRemoteDatasource {
  final Dio dio;
  final bool simulateError;

  ChallengesRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<MonthlyChallengeDto> getMonthlyChallenge() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve monthly challenge data from server');
    }

    final responses = await Future.wait([
      dio.get<dynamic>(ApiEndpoints.monthlyChallenge),
      dio.get<dynamic>(ApiEndpoints.leaderboard),
    ]);

    final challengeData = ApiResponseParser.unwrapMap(responses[0].data);
    final leaderboardData = ApiResponseParser.unwrapMap(responses[1].data);

    final merged = Map<String, dynamic>.from(challengeData);
    final topUsers = leaderboardData['leaderboard'];
    if (topUsers is List) {
      merged['leaderboard'] = topUsers;
      merged['totalParticipants'] ??= topUsers.length;
    }
    final currentUser = leaderboardData['currentUser'];
    if (currentUser is Map && currentUser['rank'] != null) {
      merged['userRank'] = currentUser['rank'];
    }
    if (merged['id'] == null || merged['id'].toString().isEmpty) {
      return MonthlyChallengeDto(
        id: 'none',
        title: '',
        deadlineIso: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        rules: const [],
        currentProgress: 0,
        completedMilestones: 0,
        totalMilestones: 0,
        userRank: (merged['userRank'] as num?)?.toInt() ?? 0,
        totalParticipants: (merged['totalParticipants'] as num?)?.toInt() ?? 0,
        rewards: const [],
        leaderboard: (merged['leaderboard'] as List<dynamic>? ?? const [])
            .map((e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return MonthlyChallengeDto.fromJson(merged);
  }

  @override
  Future<List<QuickQuizDto>> getQuickQuizzes() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve quick quizzes');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.quizzes);
    final list = ApiResponseParser.unwrapList(response.data);
    return list.map(QuickQuizDto.fromJson).toList();
  }

  @override
  Future<QuickQuizDto> getQuizById(String quizId) async {
    final response = await dio.get<dynamic>(ApiEndpoints.quizById(quizId));
    final map = ApiResponseParser.unwrapMap(response.data);
    return QuickQuizDto.fromJson(map);
  }

  static const ObjectionOfTheMonthDto defaultRohtoObjection = ObjectionOfTheMonthDto(
    id: 'obj_nov_2026',
    doctorQuote:
        '“Why switch patients to Rohto Dry Aid from basic artificial tears? Saline drops are cheap and familiar.”',
    doctorName: 'Dr. Tarek El-Khouly',
    doctorSpecialty: 'Consultant Ophthalmologist, Eye & Laser Center',
    productConcerned: 'Rohto Dry Aid (Tearshield Technology™)',
    recommendedResponse:
        'Acknowledge standard lubricating drops, then pivot to retention and multi-layer restoration: Basic saline drops wash out within 15-20 minutes requiring frequent re-application and causing blurry vision. Rohto Dry Aid with Tearshield Technology restores all 3 natural tear film layers (lipid, aqueous, mucin) keeping the corneal surface lubricated for up to 12 hours with zero vision blur.',
    talkingPoints: [
      'Highlight Tearshield Technology stabilizing the natural lipid layer preventing tear evaporation.',
      'Contrast 12h long-lasting relief vs 15-minute washout of ordinary saline drops.',
      'Emphasize non-blurring formulation enabling immediate return to screen work and driving.',
      'Clinically proven relief for both evaporative dry eye and Meibomian Gland Dysfunction (MGD).',
    ],
    studyReference:
        'Journal of Ocular Pharmacology & Therapeutics Multi-Center Dry Eye Trial (p < 0.001)',
    helpfulCount: 48,
    communityResponseCount: 14,
  );

  @override
  Future<ObjectionOfTheMonthDto> getObjectionOfTheMonth() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve objection of the month');
    }

    try {
      final response = await dio.get<dynamic>(ApiEndpoints.objectionOfMonth);
      final raw = ApiResponseParser.unwrapData(response.data);
      if (raw is Map<String, dynamic> && raw.isNotEmpty) {
        return ObjectionOfTheMonthDto.fromJson(raw);
      }
      if (raw is List && raw.isNotEmpty && raw.first is Map) {
        return ObjectionOfTheMonthDto.fromJson(
          Map<String, dynamic>.from(raw.first as Map),
        );
      }
      return defaultRohtoObjection;
    } on DioException catch (e) {
      // Fallback to default objection only if endpoint returns 404
      if (e.response?.statusCode == 404) {
        return defaultRohtoObjection;
      }
      rethrow;
    }
  }

  @override
  Future<ObjectionOfTheMonthDto> submitObjectionFeedback(
    String objectionId,
    String feedbackType,
  ) async {
    final objection = await getObjectionOfTheMonth();
    final newCount = feedbackType == 'helpful' ? objection.helpfulCount + 1 : objection.helpfulCount;
    return ObjectionOfTheMonthDto(
      id: objection.id,
      doctorQuote: objection.doctorQuote,
      doctorName: objection.doctorName,
      doctorSpecialty: objection.doctorSpecialty,
      productConcerned: objection.productConcerned,
      recommendedResponse: objection.recommendedResponse,
      talkingPoints: objection.talkingPoints,
      studyReference: objection.studyReference,
      helpfulCount: newCount,
      userFeedback: feedbackType,
      communityResponseCount: objection.communityResponseCount,
    );
  }

  @override
  Future<void> submitDoctorObjectionResponse(String objectionId, String userResponse) async {
    throw const NotFoundException('Objection responses endpoint is not available');
  }

  @override
  Future<QuizSubmissionResultDto> submitQuizAnswers({
    required String quizId,
    required List<Map<String, String>> answers,
  }) async {
    final response = await dio.post<dynamic>(
      ApiEndpoints.submitQuiz(quizId),
      data: <String, dynamic>{'answers': answers},
    );
    final map = ApiResponseParser.unwrapMap(response.data);
    return QuizSubmissionResultDto.fromJson(map);
  }

  @override
  Future<QuizSubmissionResultDto> getQuizAttemptReview(String quizId) async {
    final response = await dio.get<dynamic>(
      ApiEndpoints.quizAttemptReview(quizId),
    );
    final map = ApiResponseParser.unwrapMap(response.data);
    return QuizSubmissionResultDto.fromJson(map);
  }

  @override
  Future<List<PastChallengeHistoryDto>> getPastChallengesHistory() async {
    final response = await dio.get<dynamic>(ApiEndpoints.pointsHistory);
    final list = ApiResponseParser.unwrapList(
      response.data,
      nestedKeys: const ['items', 'transactions', 'results'],
    );
    return list
        .where((item) => item['type'] == 'challenge_reward')
        .map((item) {
          return PastChallengeHistoryDto(
            id: item['id']?.toString() ?? '',
            title: item['description']?.toString() ?? '',
            completedAtIso: item['createdAt']?.toString() ??
                DateTime.now().toIso8601String(),
            finalRank: 0,
            totalParticipants: 0,
            pointsEarned: (item['amount'] as num?)?.toInt() ?? 0,
            badgeEarned: null,
          );
        })
        .toList();
  }

  @override
  Future<List<QuizResultHistoryDto>> getQuizResultsHistory() async {
    final response = await dio.get<dynamic>(ApiEndpoints.myQuizAttempts);
    final list = ApiResponseParser.unwrapList(
      response.data,
      nestedKeys: const ['items', 'attempts', 'results'],
    );
    return list.map((item) => QuizResultHistoryDto.fromJson(item)).toList();
  }
}
