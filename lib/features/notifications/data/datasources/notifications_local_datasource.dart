import '../../../../core/storage/local_cache_service.dart';
import '../models/notification_dto.dart';

abstract class NotificationsLocalDatasource {
  Future<List<NotificationDto>?> getCachedNotifications();
  Future<void> cacheNotifications(List<NotificationDto> items);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationsLocalDatasourceImpl implements NotificationsLocalDatasource {
  final LocalCacheService _cacheService;
  static const String _cacheKey = 'notifications_list_cache';

  NotificationsLocalDatasourceImpl({required LocalCacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<List<NotificationDto>?> getCachedNotifications() async {
    final raw = _cacheService.get<List<dynamic>>(_cacheKey);
    if (raw == null) return null;
    return raw
        .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheNotifications(List<NotificationDto> items) async {
    _cacheService.put<List<dynamic>>(
      _cacheKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    final cached = await getCachedNotifications();
    if (cached == null) return;
    final updated = cached.map((item) {
      if (item.id == id) {
        return NotificationDto(
          id: item.id,
          typeString: item.typeString,
          title: item.title,
          body: item.body,
          timestampIso: item.timestampIso,
          isRead: true,
          targetRoute: item.targetRoute,
          targetId: item.targetId,
        );
      }
      return item;
    }).toList();
    await cacheNotifications(updated);
  }

  @override
  Future<void> markAllAsRead() async {
    final cached = await getCachedNotifications();
    if (cached == null) return;
    final updated = cached.map((item) {
      return NotificationDto(
        id: item.id,
        typeString: item.typeString,
        title: item.title,
        body: item.body,
        timestampIso: item.timestampIso,
        isRead: true,
        targetRoute: item.targetRoute,
        targetId: item.targetId,
      );
    }).toList();
    await cacheNotifications(updated);
  }
}
