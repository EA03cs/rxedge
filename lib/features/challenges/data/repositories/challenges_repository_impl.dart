import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/offline_queue_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/challenges_entities.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../datasources/challenges_local_datasource.dart';
import '../datasources/challenges_remote_datasource.dart';

/// Repository Implementation for Challenges & Professional Gamification
class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDatasource _remoteDatasource;
  final ChallengesLocalDatasource _localDatasource;

  MonthlyChallengeEntity? _memoryMonthlyChallenge;
  List<QuickQuizEntity>? _memoryQuickQuizzes;
  ObjectionOfTheMonthEntity? _memoryObjection;
  final List<QuizResultHistoryEntity> _localQuizHistory = [];

  ChallengesRepositoryImpl({
    required ChallengesRemoteDatasource remoteDatasource,
    required ChallengesLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<MonthlyChallengeEntity>> getMonthlyChallenge({bool forceRefresh = false}) async {
    // 1. In-memory
    if (!forceRefresh && _memoryMonthlyChallenge != null) {
      return Result.success(_memoryMonthlyChallenge!);
    }

    // 2. Fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh('challenges_monthly')) {
      final cached = await _localDatasource.getCachedMonthlyChallenge();
      if (cached != null) {
        _memoryMonthlyChallenge = cached.toDomain();
        return Result.success(_memoryMonthlyChallenge!);
      }
    }

    // 3. Remote fetch
    try {
      final remoteDto = await _remoteDatasource.getMonthlyChallenge();
      await _localDatasource.cacheMonthlyChallenge(remoteDto);
      _memoryMonthlyChallenge = remoteDto.toDomain();
      return Result.success(_memoryMonthlyChallenge!);
    } catch (e, st) {
      AppLogger.w('Remote monthly challenge fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedMonthlyChallenge();
      if (stale != null) {
        _memoryMonthlyChallenge = stale.toDomain();
        return Result.success(_memoryMonthlyChallenge!);
      }
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<List<QuickQuizEntity>>> getQuickQuizzes({bool forceRefresh = false}) async {
    // 1. In-memory
    if (!forceRefresh && _memoryQuickQuizzes != null && _memoryQuickQuizzes!.isNotEmpty) {
      return Result.success(_memoryQuickQuizzes!);
    }

    // 2. Fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh('challenges_quizzes')) {
      final cached = await _localDatasource.getCachedQuickQuizzes();
      if (cached != null) {
        _memoryQuickQuizzes = cached.map((e) => e.toDomain()).toList();
        return Result.success(_memoryQuickQuizzes!);
      }
    }

    // 3. Remote fetch
    try {
      final remoteList = await _remoteDatasource.getQuickQuizzes();
      await _localDatasource.cacheQuickQuizzes(remoteList);
      _memoryQuickQuizzes = remoteList.map((e) => e.toDomain()).toList();
      return Result.success(_memoryQuickQuizzes!);
    } catch (e, st) {
      AppLogger.w('Remote quick quizzes fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedQuickQuizzes();
      if (stale != null) {
        _memoryQuickQuizzes = stale.map((e) => e.toDomain()).toList();
        return Result.success(_memoryQuickQuizzes!);
      }
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<QuickQuizEntity>> getQuizById(String quizId) async {
    final quizzesResult = await getQuickQuizzes();
    return quizzesResult.when(
      success: (list) {
        final found = list.where((q) => q.id == quizId);
        if (found.isNotEmpty) {
          return Result.success(found.first);
        }
        return Result.failure(ExceptionMapper.map(Exception('Quiz not found: $quizId')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<ObjectionOfTheMonthEntity>> getObjectionOfTheMonth({bool forceRefresh = false}) async {
    // 1. In-memory
    if (!forceRefresh && _memoryObjection != null) {
      return Result.success(_memoryObjection!);
    }

    // 2. Fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh('challenges_objection')) {
      final cached = await _localDatasource.getCachedObjection();
      if (cached != null) {
        _memoryObjection = cached.toDomain();
        return Result.success(_memoryObjection!);
      }
    }

    // 3. Remote fetch
    try {
      final remoteDto = await _remoteDatasource.getObjectionOfTheMonth();
      await _localDatasource.cacheObjection(remoteDto);
      _memoryObjection = remoteDto.toDomain();
      return Result.success(_memoryObjection!);
    } catch (e, st) {
      AppLogger.w('Remote objection fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedObjection();
      if (stale != null) {
        _memoryObjection = stale.toDomain();
        return Result.success(_memoryObjection!);
      }
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<ObjectionOfTheMonthEntity>> submitObjectionFeedback(
    String objectionId,
    String feedbackType,
  ) async {
    try {
      final updatedDto = await _remoteDatasource.submitObjectionFeedback(objectionId, feedbackType);
      await _localDatasource.cacheObjection(updatedDto);
      _memoryObjection = updatedDto.toDomain();
      return Result.success(_memoryObjection!);
    } catch (e) {
      // Local optimistic update
      if (_memoryObjection != null) {
        final newCount = feedbackType == 'helpful'
            ? _memoryObjection!.helpfulCount + 1
            : _memoryObjection!.helpfulCount;
        _memoryObjection = _memoryObjection!.copyWith(
          userFeedback: feedbackType,
          helpfulCount: newCount,
        );
        return Result.success(_memoryObjection!);
      }
      return Result.failure(ExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> submitDoctorObjectionResponse({
    required String objectionId,
    required String userResponse,
  }) async {
    try {
      await _remoteDatasource.submitDoctorObjectionResponse(objectionId, userResponse);
      return const Result.success(null);
    } catch (e) {
      AppLogger.i('Submitting objection response failed remotely, enqueuing offline');
      await _localDatasource.queueDoctorObjectionResponse(
        objectionId: objectionId,
        userResponse: userResponse,
      );
      return const Result.success(null);
    }
  }

  @override
  Future<Result<QuizResultHistoryEntity>> submitQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  }) async {
    try {
      final dto = await _remoteDatasource.submitQuizResult(
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
        timeTakenSeconds: timeTakenSeconds,
      );
      final domainResult = dto.toDomain();
      _localQuizHistory.insert(0, domainResult);

      // Update quiz state in memory
      if (_memoryQuickQuizzes != null) {
        _memoryQuickQuizzes = _memoryQuickQuizzes!.map((q) {
          if (q.id == quizId) {
            return q.copyWith(
              isCompleted: true,
              lastScore: score,
              lastMaxScore: totalQuestions,
            );
          }
          return q;
        }).toList();
      }

      return Result.success(domainResult);
    } catch (e) {
      AppLogger.i('Submitting quiz result failed remotely, enqueuing offline');
      await _localDatasource.queueQuizResult(
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
        timeTakenSeconds: timeTakenSeconds,
      );

      final points = (score * 10) + (score == totalQuestions ? 10 : 0);
      final localResult = QuizResultHistoryEntity(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        quizId: quizId,
        quizTitle: 'Quick Detailing Quiz',
        score: score,
        totalQuestions: totalQuestions,
        pointsEarned: points,
        timeTakenSeconds: timeTakenSeconds,
        completedAt: DateTime.now(),
      );
      _localQuizHistory.insert(0, localResult);

      if (_memoryQuickQuizzes != null) {
        _memoryQuickQuizzes = _memoryQuickQuizzes!.map((q) {
          if (q.id == quizId) {
            return q.copyWith(
              isCompleted: true,
              lastScore: score,
              lastMaxScore: totalQuestions,
            );
          }
          return q;
        }).toList();
      }

      return Result.success(localResult);
    }
  }

  @override
  Future<Result<List<PastChallengeHistoryEntity>>> getPastChallengesHistory() async {
    try {
      final dtos = await _remoteDatasource.getPastChallengesHistory();
      return Result.success(dtos.map((e) => e.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<List<QuizResultHistoryEntity>>> getQuizResultsHistory() async {
    try {
      final dtos = await _remoteDatasource.getQuizResultsHistory();
      final remoteList = dtos.map((e) => e.toDomain()).toList();
      // Merge with recent local submissions
      final combined = [..._localQuizHistory, ...remoteList];
      return Result.success(combined);
    } catch (e, st) {
      if (_localQuizHistory.isNotEmpty) {
        return Result.success(_localQuizHistory);
      }
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }
}

/// Riverpod Providers for Challenges Data Layer
final challengesRemoteDatasourceProvider = Provider<ChallengesRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ChallengesRemoteDatasourceImpl(dio: dio);
});

final challengesLocalDatasourceProvider = Provider<ChallengesLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  final queue = ref.watch(offlineQueueServiceProvider);
  return ChallengesLocalDatasourceImpl(
    cacheService: cache,
    queueService: queue,
  );
});

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) {
  final remote = ref.watch(challengesRemoteDatasourceProvider);
  final local = ref.watch(challengesLocalDatasourceProvider);
  return ChallengesRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
