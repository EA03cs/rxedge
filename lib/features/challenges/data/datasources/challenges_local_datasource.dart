import 'dart:convert';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/offline_queue_service.dart';
import '../models/challenges_dto.dart';

/// Local Datasource Contract for Challenges
abstract class ChallengesLocalDatasource {
  Future<MonthlyChallengeDto?> getCachedMonthlyChallenge();
  Future<void> cacheMonthlyChallenge(MonthlyChallengeDto challenge);

  Future<List<QuickQuizDto>?> getCachedQuickQuizzes();
  Future<void> cacheQuickQuizzes(List<QuickQuizDto> quizzes);

  Future<ObjectionOfTheMonthDto?> getCachedObjection();
  Future<void> cacheObjection(ObjectionOfTheMonthDto objection);

  Future<void> queueQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  });

  Future<void> queueDoctorObjectionResponse({
    required String objectionId,
    required String userResponse,
  });

  bool isCacheFresh(String key);
}

/// Local Datasource Implementation using LocalCacheService & OfflineQueueService
class ChallengesLocalDatasourceImpl implements ChallengesLocalDatasource {
  final LocalCacheService _cacheService;
  final OfflineQueueService _queueService;

  static const String _monthlyChallengeKey = 'challenges_monthly';
  static const String _quickQuizzesKey = 'challenges_quizzes';
  static const String _objectionKey = 'challenges_objection';

  ChallengesLocalDatasourceImpl({
    required LocalCacheService cacheService,
    required OfflineQueueService queueService,
  })  : _cacheService = cacheService,
        _queueService = queueService;

  @override
  bool isCacheFresh(String key) {
    return _cacheService.isFresh(key);
  }

  @override
  Future<MonthlyChallengeDto?> getCachedMonthlyChallenge() async {
    final raw = _cacheService.get<String>(_monthlyChallengeKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return MonthlyChallengeDto.fromJson(map);
    } catch (e) {
      AppLogger.w('Failed parsing cached monthly challenge: $e');
      return null;
    }
  }

  @override
  Future<void> cacheMonthlyChallenge(MonthlyChallengeDto challenge) async {
    _cacheService.put<String>(_monthlyChallengeKey, jsonEncode(challenge.toJson()));
  }

  @override
  Future<List<QuickQuizDto>?> getCachedQuickQuizzes() async {
    final raw = _cacheService.get<String>(_quickQuizzesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => QuickQuizDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.w('Failed parsing cached quick quizzes: $e');
      return null;
    }
  }

  @override
  Future<void> cacheQuickQuizzes(List<QuickQuizDto> quizzes) async {
    final list = quizzes.map((q) => q.toJson()).toList();
    _cacheService.put<String>(_quickQuizzesKey, jsonEncode(list));
  }

  @override
  Future<ObjectionOfTheMonthDto?> getCachedObjection() async {
    final raw = _cacheService.get<String>(_objectionKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ObjectionOfTheMonthDto.fromJson(map);
    } catch (e) {
      AppLogger.w('Failed parsing cached objection: $e');
      return null;
    }
  }

  @override
  Future<void> cacheObjection(ObjectionOfTheMonthDto objection) async {
    _cacheService.put<String>(_objectionKey, jsonEncode(objection.toJson()));
  }

  @override
  Future<void> queueQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  }) async {
    _queueService.enqueue(
      OfflineQueueItem(
        id: 'quiz_result_${DateTime.now().millisecondsSinceEpoch}',
        endpoint: '/api/v1/challenges/quizzes/$quizId/submit',
        httpMethod: 'POST',
        payload: {
          'quizId': quizId,
          'score': score,
          'totalQuestions': totalQuestions,
          'timeTakenSeconds': timeTakenSeconds,
          'completedAt': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
      ),
    );
    AppLogger.d('Queued quiz result submission offline for $quizId');
  }

  @override
  Future<void> queueDoctorObjectionResponse({
    required String objectionId,
    required String userResponse,
  }) async {
    _queueService.enqueue(
      OfflineQueueItem(
        id: 'objection_response_${DateTime.now().millisecondsSinceEpoch}',
        endpoint: '/api/v1/challenges/objections/$objectionId/responses',
        httpMethod: 'POST',
        payload: {
          'objectionId': objectionId,
          'userResponse': userResponse,
          'submittedAt': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
      ),
    );
    AppLogger.d('Queued doctor objection response offline for $objectionId');
  }
}
