library;

import '../../../../core/utils/result.dart';
import '../entities/challenges_entities.dart';

/// Abstract Contract for Challenges & Gamification Repository
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class ChallengesRepository {
  Future<Result<MonthlyChallengeEntity>> getMonthlyChallenge({bool forceRefresh = false});
  Future<Result<List<QuickQuizEntity>>> getQuickQuizzes({bool forceRefresh = false});
  Future<Result<QuickQuizEntity>> getQuizById(String quizId);
  Future<Result<ObjectionOfTheMonthEntity>> getObjectionOfTheMonth({bool forceRefresh = false});
  Future<Result<ObjectionOfTheMonthEntity>> submitObjectionFeedback(String objectionId, String feedbackType);
  Future<Result<void>> submitDoctorObjectionResponse({
    required String objectionId,
    required String userResponse,
  });
  Future<Result<QuizResultHistoryEntity>> submitQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  });
  Future<Result<List<PastChallengeHistoryEntity>>> getPastChallengesHistory();
  Future<Result<List<QuizResultHistoryEntity>>> getQuizResultsHistory();
}
