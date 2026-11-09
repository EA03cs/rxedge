library;

import '../../../../core/utils/result.dart';
import '../entities/learning_entities.dart';

/// Abstract Contract for Smart Learning Hub Repository
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class LearnRepository {
  Future<Result<List<ProductLearningEntity>>> getProducts({bool forceRefresh = false});
  Future<Result<ProductLearningEntity>> getProductById(String id);
  Future<Result<LessonEntity>> getLessonById(String lessonId);
  Future<Result<LessonEntity>> markLessonCompleted(String lessonId);
  Future<Result<LessonEntity>> toggleLessonBookmark(String lessonId);
  Future<Result<List<LessonEntity>>> getBookmarkedLessons();
}
