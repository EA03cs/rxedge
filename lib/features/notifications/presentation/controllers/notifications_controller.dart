import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_entities.dart';

class NotificationsController extends AutoDisposeAsyncNotifier<List<NotificationItemEntity>> {
  @override
  Future<List<NotificationItemEntity>> build() async {
    final repo = ref.watch(notificationsRepositoryProvider);
    final result = await repo.getNotifications();
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load notifications'),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationsRepositoryProvider);
      final result = await repo.getNotifications(forceRefresh: true);
      return result.when(
        success: (list) => list,
        failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load notifications'),
      );
    });
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    state = AsyncValue.data(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );

    final repo = ref.read(notificationsRepositoryProvider);
    await repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    state = AsyncValue.data(
      current.map((n) => n.copyWith(isRead: true)).toList(),
    );

    final repo = ref.read(notificationsRepositoryProvider);
    await repo.markAllAsRead();
  }
}

final notificationsControllerProvider =
    AutoDisposeAsyncNotifierProvider<NotificationsController, List<NotificationItemEntity>>(
  NotificationsController.new,
);

/// Computed Provider for total unread notifications count
final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifs = ref.watch(notificationsControllerProvider);
  return notifs.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () =>
        ref.watch(homeControllerProvider).valueOrNull?.unreadNotificationCount ?? 0,
  );
});
