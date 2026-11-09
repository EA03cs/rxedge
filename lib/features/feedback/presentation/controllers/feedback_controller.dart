import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/entities/feedback_entities.dart';

/// Controller managing the list of user submissions
class FeedbackListController extends AutoDisposeAsyncNotifier<List<FeedbackItemEntity>> {
  @override
  Future<List<FeedbackItemEntity>> build() async {
    final repo = ref.watch(feedbackRepositoryProvider);
    final result = await repo.getSubmissions(forceRefresh: false);
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load submissions'),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedbackRepositoryProvider);
      final result = await repo.getSubmissions(forceRefresh: true);
      return result.when(
        success: (list) => list,
        failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load submissions'),
      );
    });
  }

  void addSubmission(FeedbackItemEntity item) {
    state = state.whenData((list) => [item, ...list]);
  }
}

/// Provider for submissions list
final feedbackListControllerProvider =
    AutoDisposeAsyncNotifierProvider<FeedbackListController, List<FeedbackItemEntity>>(
  FeedbackListController.new,
);

/// Family provider for a single submission detail
final feedbackDetailProvider =
    Provider.autoDispose.family<FeedbackItemEntity?, String>((ref, id) {
  final listAsync = ref.watch(feedbackListControllerProvider);
  return listAsync.maybeWhen(
    data: (list) => list.cast<FeedbackItemEntity?>().firstWhere(
          (item) => item?.id == id,
          orElse: () => null,
        ),
    orElse: () => null,
  );
});
