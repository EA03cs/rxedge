import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/offline_queue_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_local_datasource.dart';
import '../datasources/learn_remote_datasource.dart';
import '../models/learning_dto.dart';

/// Repository Implementation for Learn
///
/// Strategy:
/// - In-memory cache first for snappy UI reactivity
/// - Fresh Hive cache next (`learn_products_list`)
/// - Remote API (`GET /products`, `GET /learn/lessons`, `GET /competitors`)
/// - Stale cache fallback offline
/// - Lesson completions and bookmarks synced to backend with offline queue fallback
class LearnRepositoryImpl implements LearnRepository {
  final LearnRemoteDatasource _remoteDatasource;
  final LearnLocalDatasource _localDatasource;
  final OfflineQueueService? _queueService;

  List<ProductLearningEntity>? _memoryProducts;

  LearnRepositoryImpl({
    required LearnRemoteDatasource remoteDatasource,
    required LearnLocalDatasource localDatasource,
    OfflineQueueService? queueService,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _queueService = queueService;

  @override
  Future<Result<List<ProductLearningEntity>>> getProducts({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memoryProducts != null) {
      return Result.success(_memoryProducts!);
    }

    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedProducts();
        if (cached != null) {
          AppLogger.d('Returning fresh cached Products & Lessons');
          _memoryProducts = await _mergeWithOverrides(cached);
          return Result.success(_memoryProducts!);
        }
      } catch (e) {
        AppLogger.w('Failed reading cached products: $e');
      }
    }

    try {
      AppLogger.d('Fetching remote Learn Products & Lessons...');
      final remoteDtos = await _remoteDatasource.getProducts();
      await _localDatasource.cacheProducts(remoteDtos);

      _memoryProducts = await _mergeWithOverrides(remoteDtos);
      return Result.success(_memoryProducts!);
    } catch (e, st) {
      AppLogger.w('Remote fetch failed for Learn, attempting stale cache fallback',
          error: e);
      try {
        final stale = await _localDatasource.getCachedProducts();
        if (stale != null) {
          _memoryProducts = await _mergeWithOverrides(stale);
          return Result.success(_memoryProducts!);
        }
      } catch (_) {}

      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<ProductLearningEntity>> getProductById(String id) async {
    if (_memoryProducts != null) {
      final found = _memoryProducts!.where((p) => p.id == id);
      if (found.isNotEmpty) return Result.success(found.first);
    }

    final productsResult = await getProducts();
    return productsResult.when(
      success: (list) {
        final found = list.where((p) => p.id == id);
        if (found.isNotEmpty) return Result.success(found.first);
        return Result.failure(
          ExceptionMapper.map(Exception('Product not found: $id')),
        );
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<LessonEntity>> getLessonById(String lessonId) async {
    if (_memoryProducts != null) {
      for (final product in _memoryProducts!) {
        final found = product.lessons.where((l) => l.id == lessonId);
        if (found.isNotEmpty) return Result.success(found.first);
      }
    }

    final productsResult = await getProducts();
    return productsResult.when(
      success: (list) {
        for (final product in list) {
          final found = product.lessons.where((l) => l.id == lessonId);
          if (found.isNotEmpty) return Result.success(found.first);
        }
        return Result.failure(
          ExceptionMapper.map(Exception('Lesson not found: $lessonId')),
        );
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<LessonEntity>> markLessonCompleted(String lessonId) async {
    try {
      try {
        await _remoteDatasource.completeLesson(lessonId);
      } catch (e, st) {
        final mapped = ExceptionMapper.map(e, st);
        if (mapped is NetworkFailure && _queueService != null) {
          _queueService.enqueue(
            OfflineQueueItem(
              id: 'lesson_complete_$lessonId',
              endpoint: ApiEndpoints.completeLesson(lessonId),
              httpMethod: 'POST',
              payload: const <String, dynamic>{},
              createdAt: DateTime.now(),
            ),
          );
          AppLogger.i('Lesson completion queued offline: $lessonId');
        } else if (mapped is! NetworkFailure) {
          rethrow;
        }
      }

      final completed = await _localDatasource.getCompletedLessonIds();
      final updatedCompleted = Set<String>.from(completed)..add(lessonId);
      await _localDatasource.saveCompletedLessonIds(updatedCompleted);

      LessonEntity? updatedLesson;
      if (_memoryProducts != null) {
        _memoryProducts = _memoryProducts!.map((product) {
          final updatedLessons = product.lessons.map((lesson) {
            if (lesson.id == lessonId) {
              updatedLesson = lesson.copyWith(isCompleted: true);
              return updatedLesson!;
            }
            return lesson;
          }).toList();
          return product.copyWith(lessons: updatedLessons);
        }).toList();
      }

      if (updatedLesson != null) {
        return Result.success(updatedLesson!);
      }

      final lessonResult = await getLessonById(lessonId);
      return lessonResult.when(
        success: (l) => Result.success(l.copyWith(isCompleted: true)),
        failure: (f) => Result.failure(f),
      );
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<LessonEntity>> toggleLessonBookmark(String lessonId) async {
    try {
      try {
        await _remoteDatasource.bookmarkLesson(lessonId);
      } catch (e, st) {
        final mapped = ExceptionMapper.map(e, st);
        if (mapped is NetworkFailure && _queueService != null) {
          _queueService.enqueue(
            OfflineQueueItem(
              id: 'lesson_bookmark_${lessonId}_${DateTime.now().millisecondsSinceEpoch}',
              endpoint: ApiEndpoints.bookmarkLesson(lessonId),
              httpMethod: 'POST',
              payload: const <String, dynamic>{},
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      final bookmarks = await _localDatasource.getBookmarkedLessonIds();
      final isBookmarked = bookmarks.contains(lessonId);

      final updatedBookmarks = Set<String>.from(bookmarks);
      if (isBookmarked) {
        updatedBookmarks.remove(lessonId);
      } else {
        updatedBookmarks.add(lessonId);
      }
      await _localDatasource.saveBookmarkedLessonIds(updatedBookmarks);

      LessonEntity? updatedLesson;
      if (_memoryProducts != null) {
        _memoryProducts = _memoryProducts!.map((product) {
          final updatedLessons = product.lessons.map((lesson) {
            if (lesson.id == lessonId) {
              updatedLesson = lesson.copyWith(isBookmarked: !isBookmarked);
              return updatedLesson!;
            }
            return lesson;
          }).toList();
          return product.copyWith(lessons: updatedLessons);
        }).toList();
      }

      if (updatedLesson != null) {
        return Result.success(updatedLesson!);
      }

      final lessonResult = await getLessonById(lessonId);
      return lessonResult.when(
        success: (l) => Result.success(l.copyWith(isBookmarked: !isBookmarked)),
        failure: (f) => Result.failure(f),
      );
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<List<LessonEntity>>> getBookmarkedLessons() async {
    final productsResult = await getProducts();
    return productsResult.when(
      success: (list) {
        final bookmarked = <LessonEntity>[];
        for (final product in list) {
          for (final lesson in product.lessons) {
            if (lesson.isBookmarked) {
              bookmarked.add(lesson);
            }
          }
        }
        return Result.success(bookmarked);
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<List<ProductLearningEntity>> _mergeWithOverrides(
    List<ProductLearningDto> dtoList,
  ) async {
    final completed = await _localDatasource.getCompletedLessonIds();
    final bookmarks = await _localDatasource.getBookmarkedLessonIds();

    return dtoList.map((dto) {
      final domainProduct = dto.toDomain();
      final updatedLessons = domainProduct.lessons.map((lesson) {
        final isDone = lesson.isCompleted || completed.contains(lesson.id);
        final isMarked = lesson.isBookmarked || bookmarks.contains(lesson.id);
        return lesson.copyWith(
          isCompleted: isDone,
          isBookmarked: isMarked,
        );
      }).toList();

      return domainProduct.copyWith(lessons: updatedLessons);
    }).toList();
  }
}

final learnRemoteDatasourceProvider = Provider<LearnRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LearnRemoteDatasourceImpl(dio: dio);
});

final learnLocalDatasourceProvider = Provider<LearnLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return LearnLocalDatasourceImpl(cache);
});

final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  final remote = ref.watch(learnRemoteDatasourceProvider);
  final local = ref.watch(learnLocalDatasourceProvider);
  final queue = ref.watch(offlineQueueServiceProvider);
  return LearnRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
    queueService: queue,
  );
});
