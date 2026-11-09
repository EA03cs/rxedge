import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entities.dart';

class ProfileController extends AutoDisposeAsyncNotifier<UserProfileEntity> {
  @override
  Future<UserProfileEntity> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final result = await repo.getProfile();
    return result.when(
      success: (profile) => profile,
      failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load profile'),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.getProfile();
      return result.when(
        success: (profile) => profile,
        failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load profile'),
      );
    });
  }

  Future<void> updatePreferences(NotificationPreferencesEntity preferences) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    state = AsyncValue.data(current.copyWith(notificationPreferences: preferences));

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateNotificationPreferences(preferences);
    result.when(
      success: (_) {},
      failure: (_) {
        // Rollback
        state = AsyncValue.data(current);
      },
    );
  }

  Future<void> clearDownloads() async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.clearCachedDownloads();
    result.when(
      success: (_) {
        state = AsyncValue.data(current.copyWith(storageUsageBytes: 0));
      },
      failure: (_) {},
    );
  }
}

final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, UserProfileEntity>(
  ProfileController.new,
);
