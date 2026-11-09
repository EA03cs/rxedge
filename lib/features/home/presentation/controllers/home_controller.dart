import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// Home Controller managing Home Dashboard state
///
/// Follows Architecture Contracts:
/// 1. "AsyncNotifier per screen or flow."
/// 2. "Every async state is exposed as AsyncValue and rendered with shared widgets."
/// 3. "Widgets are dumb: no business logic, no API calls inside widgets."
class HomeController extends AutoDisposeAsyncNotifier<HomeDashboardEntity> {
  @override
  Future<HomeDashboardEntity> build() async {
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.getHomeDashboard();

    return result.when(
      success: (data) => data,
      failure: (failure) => throw failure,
    );
  }

  /// Forces remote refresh (e.g. from pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeRepositoryProvider);
      final result = await repository.getHomeDashboard(forceRefresh: true);

      return result.when(
        success: (data) => data,
        failure: (failure) => throw failure,
      );
    });
  }
}

/// Riverpod Provider for HomeController
final homeControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeController, HomeDashboardEntity>(
  HomeController.new,
);
