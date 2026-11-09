import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/learning_entities.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_local_datasource.dart';
import '../datasources/learn_remote_datasource.dart';
import '../models/learning_dto.dart';

/// Repository Implementation for Smart Learning Hub
class LearnRepositoryImpl implements LearnRepository {
  final LearnRemoteDatasource _remoteDatasource;
  final LearnLocalDatasource _localDatasource;

  List<ProductLearningEntity>? _memoryProducts;

  LearnRepositoryImpl({
    required LearnRemoteDatasource remoteDatasource,
    required LearnLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<List<ProductLearningEntity>>> getProducts({bool forceRefresh = false}) async {
    // 1. In-memory cache
    if (!forceRefresh && _memoryProducts != null && _memoryProducts!.isNotEmpty) {
      return Result.success(_memoryProducts!);
    }

    // 2. Local fresh cache
    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedProducts();
        if (cached != null) {
          AppLogger.d('Returning fresh cached Learn products');
          final domainItems = await _mergeWithOverrides(cached);
          _memoryProducts = domainItems;
          return Result.success(domainItems);
        }
      } catch (e) {
        AppLogger.w('Failed reading cached learning products: $e');
      }
    }

    // 3. Remote fetch
    try {
      AppLogger.d('Fetching remote Learn products...');
      final remoteList = await _remoteDatasource.getProducts();
      await _localDatasource.cacheProducts(remoteList);

      final domainItems = await _mergeWithOverrides(remoteList);
      _memoryProducts = domainItems;
      return Result.success(domainItems);
    } catch (e, st) {
      AppLogger.w('Remote learning fetch failed, attempting stale fallback', error: e);

      try {
        final staleCache = await _localDatasource.getCachedProducts();
        if (staleCache != null) {
          final domainItems = await _mergeWithOverrides(staleCache);
          _memoryProducts = domainItems;
          return Result.success(domainItems);
        }
      } catch (_) {}

      final failure = ExceptionMapper.map(e, st);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<ProductLearningEntity>> getProductById(String id) async {
    final productsResult = await getProducts();
    return productsResult.when(
      success: (list) {
        final found = list.where((p) => p.id == id);
        if (found.isNotEmpty) {
          return Result.success(found.first);
        }
        return Result.failure(ExceptionMapper.map(Exception('Product not found: $id')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<LessonEntity>> getLessonById(String lessonId) async {
    final productsResult = await getProducts();
    return productsResult.when(
      success: (list) {
        for (final product in list) {
          for (final lesson in product.lessons) {
            if (lesson.id == lessonId) {
              return Result.success(lesson);
            }
          }
        }
        return Result.failure(ExceptionMapper.map(Exception('Lesson not found: $lessonId')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  @override
  Future<Result<LessonEntity>> markLessonCompleted(String lessonId) async {
    try {
      final completed = await _localDatasource.getCompletedLessonIds();
      final updatedCompleted = Set<String>.from(completed)..add(lessonId);
      await _localDatasource.saveCompletedLessonIds(updatedCompleted);

      // Update in memory
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
        final isDone = completed.isNotEmpty ? completed.contains(lesson.id) : lesson.isCompleted;
        final isMarked = bookmarks.isNotEmpty ? bookmarks.contains(lesson.id) : lesson.isBookmarked;
        return lesson.copyWith(
          isCompleted: isDone,
          isBookmarked: isMarked,
        );
      }).toList();

      return domainProduct.copyWith(lessons: updatedLessons);
    }).toList();
  }
}

/// Riverpod Providers for Learn Data Layer
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
  return LearnRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
