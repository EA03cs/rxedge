import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/challenges_entities.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../datasources/challenges_local_datasource.dart';
import '../datasources/challenges_remote_datasource.dart';
import '../models/challenges_dto.dart';

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
    } catch (e) {
      AppLogger.w('Remote monthly challenge fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedMonthlyChallenge();
      if (stale != null) {
        _memoryMonthlyChallenge = stale.toDomain();
        return Result.success(_memoryMonthlyChallenge!);
      }
      return Result.failure(ExceptionMapper.map(e));
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
      if (cached != null && cached.isNotEmpty) {
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
    } catch (e) {
      AppLogger.w('Remote quick quizzes fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedQuickQuizzes();
      if (stale != null && stale.isNotEmpty) {
        _memoryQuickQuizzes = stale.map((e) => e.toDomain()).toList();
        return Result.success(_memoryQuickQuizzes!);
      }
      return Result.failure(ExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<QuickQuizEntity>> getQuizById(String quizId) async {
    QuickQuizEntity? existing;
    if (_memoryQuickQuizzes != null) {
      final found = _memoryQuickQuizzes!.where((q) => q.id == quizId);
      if (found.isNotEmpty) {
        existing = found.first;
        if (existing.questions.isNotEmpty) {
          return Result.success(existing);
        }
      }
    }

    try {
      final remoteQuiz = await _remoteDatasource.getQuizById(quizId);
      var domainQuiz = remoteQuiz.toDomain();
      if (existing != null && existing.isCompleted && !domainQuiz.isCompleted) {
        domainQuiz = domainQuiz.copyWith(
          isCompleted: true,
          lastScore: domainQuiz.lastScore ?? existing.lastScore,
          lastMaxScore: domainQuiz.lastMaxScore ?? existing.lastMaxScore,
        );
      }
      if (_memoryQuickQuizzes != null) {
        _memoryQuickQuizzes = _memoryQuickQuizzes!
            .map((q) => q.id == quizId ? domainQuiz : q)
            .toList();
      }
      return Result.success(domainQuiz);
    } catch (e, st) {
      final quizzesResult = await getQuickQuizzes();
      return quizzesResult.when(
        success: (list) {
          final found = list.where((q) => q.id == quizId && q.questions.isNotEmpty);
          if (found.isNotEmpty) {
            return Result.success(found.first);
          }
          return Result.failure(ExceptionMapper.map(e, st));
        },
        failure: (_) => Result.failure(ExceptionMapper.map(e, st)),
      );
    }
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
    } catch (e) {
      AppLogger.w('Remote objection fetch failed, checking stale cache: $e');
      final stale = await _localDatasource.getCachedObjection();
      if (stale != null) {
        _memoryObjection = stale.toDomain();
        return Result.success(_memoryObjection!);
      }
      return Result.success(ChallengesRemoteDatasourceImpl.defaultRohtoObjection.toDomain());
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
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  Future<String> _markQuizCompletedInCache(
    String quizId, {
    int? score,
    int? maxScore,
  }) async {
    String quizTitle = '';
    if (_memoryQuickQuizzes != null) {
      _memoryQuickQuizzes = _memoryQuickQuizzes!.map((q) {
        if (q.id == quizId) {
          quizTitle = q.title;
          return q.copyWith(
            isCompleted: true,
            lastScore: score ?? q.lastScore,
            lastMaxScore: maxScore ?? q.lastMaxScore,
          );
        }
        return q;
      }).toList();
      try {
        await _localDatasource.cacheQuickQuizzes(
          _memoryQuickQuizzes!.map(QuickQuizDto.fromDomain).toList(),
        );
      } catch (_) {}
    }
    return quizTitle;
  }

  @override
  Future<Result<QuizSubmissionResultEntity>> submitQuizAnswers({
    required String quizId,
    required List<Map<String, String>> answers,
  }) async {
    try {
      final dto = await _remoteDatasource.submitQuizAnswers(
        quizId: quizId,
        answers: answers,
      );
      final domain = dto.toDomain();

      final correctCount = domain.answers.where((a) => a.isCorrect).length;
      final totalQuestions =
          domain.answers.isNotEmpty ? domain.answers.length : answers.length;

      final quizTitle = await _markQuizCompletedInCache(
        quizId,
        score: correctCount,
        maxScore: totalQuestions,
      );

      _localQuizHistory.insert(
        0,
        QuizResultHistoryEntity(
          id: domain.attemptId,
          quizId: quizId,
          quizTitle: quizTitle,
          score: correctCount,
          totalQuestions: totalQuestions,
          pointsEarned: domain.pointsAwarded,
          timeTakenSeconds: 0,
          completedAt: DateTime.now(),
        ),
      );

      return Result.success(domain);
    } catch (e, st) {
      final mapped = ExceptionMapper.map(e, st);
      if (mapped is NetworkFailure) {
        return const Result.failure(
          NetworkFailure(
            debugMessage: 'Connect to the internet to submit your answers.',
          ),
        );
      }
      final msg = (mapped.debugMessage ?? mapped.toString()).toLowerCase();
      final isConflict = (mapped is ServerFailure && mapped.statusCode == 409) ||
          msg.contains('already completed') ||
          msg.contains('single attempt') ||
          msg.contains('attempt_already_exists');
      if (isConflict) {
        await _markQuizCompletedInCache(quizId);
      }
      return Result.failure(mapped);
    }
  }

  @override
  Future<Result<QuizSubmissionResultEntity>> getQuizAttemptReview(String quizId) async {
    try {
      final dto = await _remoteDatasource.getQuizAttemptReview(quizId);
      return Result.success(dto.toDomain());
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
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
  return ChallengesLocalDatasourceImpl(
    cacheService: cache,
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
