import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/app_info_repository_impl.dart';
import '../../domain/entities/app_info_entity.dart';

/// App Info Controller
///
/// Follows Architecture Contract:
/// 1. "AsyncNotifier per screen or flow."
/// 2. "Every async state is exposed as AsyncValue and rendered with the shared widgets."
/// 3. "Widgets are dumb: no business logic, no API calls inside widgets."
class AppInfoController extends AutoDisposeAsyncNotifier<AppInfoEntity> {
  @override
  Future<AppInfoEntity> build() async {
    final repository = ref.watch(appInfoRepositoryProvider);
    final result = await repository.getAppInfo();

    return result.when(
      success: (data) => data,
      failure: (failure) => throw failure,
    );
  }

  /// Forces remote refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(appInfoRepositoryProvider);
      final result = await repository.getAppInfo(forceRefresh: true);

      return result.when(
        success: (data) => data,
        failure: (failure) => throw failure,
      );
    });
  }
}

/// Riverpod Provider for AppInfoController
final appInfoControllerProvider =
    AutoDisposeAsyncNotifierProvider<AppInfoController, AppInfoEntity>(
  AppInfoController.new,
);
