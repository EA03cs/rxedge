import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/offline_queue_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/feedback_entities.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_local_datasource.dart';
import '../datasources/feedback_remote_datasource.dart';
import '../models/feedback_dto.dart';

/// Repository Implementation for Live Marketing Feedback
class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDatasource _remoteDatasource;
  final FeedbackLocalDatasource _localDatasource;

  List<FeedbackItemEntity>? _memorySubmissions;
  final List<FeedbackItemEntity> _pendingSubmissions = [];

  FeedbackRepositoryImpl({
    required FeedbackRemoteDatasource remoteDatasource,
    required FeedbackLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<List<FeedbackItemEntity>>> getSubmissions({bool forceRefresh = false}) async {
    // 1. In-memory
    if (!forceRefresh && _memorySubmissions != null && _memorySubmissions!.isNotEmpty) {
      return Result.success(_combineWithPending(_memorySubmissions!));
    }

    // 2. Fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh('feedback_submissions')) {
      final cached = await _localDatasource.getCachedSubmissions();
      if (cached != null) {
        _memorySubmissions = cached.map((e) => e.toDomain()).toList();
        return Result.success(_combineWithPending(_memorySubmissions!));
      }
    }

    // 3. Remote fetch
    try {
      final remoteList = await _remoteDatasource.getSubmissions();
      await _localDatasource.cacheSubmissions(remoteList);
      _memorySubmissions = remoteList.map((e) => e.toDomain()).toList();
      return Result.success(_combineWithPending(_memorySubmissions!));
    } catch (e, st) {
      AppLogger.w('Remote feedback fetch failed, checking local cache: $e');
      final stale = await _localDatasource.getCachedSubmissions();
      if (stale != null) {
        _memorySubmissions = stale.map((e) => e.toDomain()).toList();
        return Result.success(_combineWithPending(_memorySubmissions!));
      }

      if (_pendingSubmissions.isNotEmpty) {
        return Result.success(_pendingSubmissions);
      }

      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<FeedbackItemEntity>> getSubmissionById(String id) async {
    final listResult = await getSubmissions();
    return listResult.when(
      success: (list) {
        final found = list.where((item) => item.id == id);
        if (found.isNotEmpty) {
          return Result.success(found.first);
        }
        return Result.failure(ExceptionMapper.map(Exception('Submission not found: $id')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<FeedbackItemEntity>> submitFeedback(FeedbackItemEntity item) async {
    try {
      final dto = FeedbackItemDto.fromDomain(item);
      final remoteDto = await _remoteDatasource.submitFeedback(dto);
      final domainResult = remoteDto.toDomain();

      // Insert into local memory
      _memorySubmissions ??= [];
      _memorySubmissions!.insert(0, domainResult);

      // Clear draft for this type
      await clearDraft(item.type);

      return Result.success(domainResult);
    } catch (e) {
      AppLogger.i('Remote feedback submission failed, saving locally as pending');

      final pendingItem = item.copyWith(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        status: FeedbackStatus.pending,
        submittedAt: DateTime.now(),
      );

      _pendingSubmissions.insert(0, pendingItem);
      await _localDatasource.queueFeedbackSubmission(FeedbackItemDto.fromDomain(pendingItem));

      // Clear draft for this type
      await clearDraft(item.type);

      return Result.success(pendingItem);
    }
  }

  @override
  Future<Result<FeedbackDraftEntity?>> getDraft(FeedbackType type) async {
    try {
      final dto = await _localDatasource.getDraft(type.name);
      return Result.success(dto?.toDomain());
    } catch (e) {
      return const Result.success(null);
    }
  }

  @override
  Future<Result<void>> saveDraft(FeedbackDraftEntity draft) async {
    try {
      final dto = FeedbackDraftDto.fromDomain(draft);
      await _localDatasource.saveDraft(dto);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> clearDraft(FeedbackType type) async {
    try {
      await _localDatasource.clearDraft(type.name);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  List<FeedbackItemEntity> _combineWithPending(List<FeedbackItemEntity> items) {
    if (_pendingSubmissions.isEmpty) return items;
    final combined = List<FeedbackItemEntity>.from(_pendingSubmissions);
    for (final it in items) {
      if (!combined.any((p) => p.id == it.id)) {
        combined.add(it);
      }
    }
    return combined;
  }
}

/// Riverpod Providers for Feedback Data Layer
final feedbackRemoteDatasourceProvider = Provider<FeedbackRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FeedbackRemoteDatasourceImpl(dio: dio);
});

final feedbackLocalDatasourceProvider = Provider<FeedbackLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  final queue = ref.watch(offlineQueueServiceProvider);
  return FeedbackLocalDatasourceImpl(
    cacheService: cache,
    queueService: queue,
  );
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final remote = ref.watch(feedbackRemoteDatasourceProvider);
  final local = ref.watch(feedbackLocalDatasourceProvider);
  return FeedbackRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
