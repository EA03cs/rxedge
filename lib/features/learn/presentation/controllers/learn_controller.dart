import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/entities/learning_entities.dart';
import '../../data/repositories/learn_repository_impl.dart';

/// Notifier managing the list of products and learning progress
class LearnController extends AutoDisposeAsyncNotifier<List<ProductLearningEntity>> {
  @override
  Future<List<ProductLearningEntity>> build() async {
    return _fetchProducts(forceRefresh: false);
  }

  Future<List<ProductLearningEntity>> _fetchProducts({bool forceRefresh = false}) async {
    final repo = ref.watch(learnRepositoryProvider);
    final result = await repo.getProducts(forceRefresh: forceRefresh);
    return result.when(
      success: (products) {
        final sorted = List<ProductLearningEntity>.from(products);
        sorted.sort(_compareProducts);
        return sorted;
      },
      failure: (failure) => throw Exception(failure.debugMessage ?? 'Failed to load products'),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts(forceRefresh: true));
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final repo = ref.read(learnRepositoryProvider);
    final result = await repo.markLessonCompleted(lessonId);

    result.when(
      success: (updatedLesson) {
        state = state.whenData((products) {
          final updated = products.map((product) {
            final updatedLessons = product.lessons.map((lesson) {
              if (lesson.id == lessonId) {
                return updatedLesson;
              }
              return lesson;
            }).toList();
            return product.copyWith(lessons: updatedLessons);
          }).toList();
          updated.sort(_compareProducts);
          return updated;
        });
        ref.read(localCacheServiceProvider).remove('home_dashboard_cache');
        ref.read(localCacheServiceProvider).remove('user_profile_cache');
        ref.invalidate(homeControllerProvider);
        ref.invalidate(profileControllerProvider);
      },
      failure: (_) {
        // Leave current state as is
      },
    );
  }

  Future<void> toggleLessonBookmark(String lessonId) async {
    final repo = ref.read(learnRepositoryProvider);
    final result = await repo.toggleLessonBookmark(lessonId);

    result.when(
      success: (updatedLesson) {
        state = state.whenData((products) {
          final updated = products.map((product) {
            final updatedLessons = product.lessons.map((lesson) {
              if (lesson.id == lessonId) {
                return updatedLesson;
              }
              return lesson;
            }).toList();
            return product.copyWith(lessons: updatedLessons);
          }).toList();
          return updated;
        });
      },
      failure: (_) {
        // Leave current state as is
      },
    );
  }

  static int _compareProducts(ProductLearningEntity a, ProductLearningEntity b) {
    // 1. Recommended and In-Progress products come first
    final aScore = (a.isRecommended ? 2 : 0) + (a.isInProgress ? 1 : 0);
    final bScore = (b.isRecommended ? 2 : 0) + (b.isInProgress ? 1 : 0);

    if (aScore != bScore) {
      return bScore.compareTo(aScore); // higher score first
    }
    return a.name.compareTo(b.name);
  }
}

/// Provider for LearnController
final learnControllerProvider =
    AutoDisposeAsyncNotifierProvider<LearnController, List<ProductLearningEntity>>(
  LearnController.new,
);

/// Derived provider for bookmarked lessons
final bookmarkedLessonsProvider = Provider.autoDispose<List<LessonEntity>>((ref) {
  final learnAsync = ref.watch(learnControllerProvider);
  return learnAsync.maybeWhen(
    data: (products) => products
        .expand((p) => p.lessons)
        .where((l) => l.isBookmarked)
        .toList(),
    orElse: () => const [],
  );
});

/// Family provider for a single product by ID
final productLearningDetailProvider =
    Provider.autoDispose.family<ProductLearningEntity?, String>((ref, productId) {
  final learnAsync = ref.watch(learnControllerProvider);
  return learnAsync.maybeWhen(
    data: (products) => products.cast<ProductLearningEntity?>().firstWhere(
          (p) => p?.id == productId,
          orElse: () => null,
        ),
    orElse: () => null,
  );
});
