import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/notification_dto.dart';

abstract class NotificationsRemoteDatasource {
  Future<List<NotificationDto>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDatasourceImpl implements NotificationsRemoteDatasource {
  final Dio dio;
  final bool simulateError;

  NotificationsRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<NotificationDto>> getNotifications() async {
    if (simulateError) {
      throw const ServerException('Failed to load notifications');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.notifications);
    final list = ApiResponseParser.unwrapList(
      response.data,
      nestedKeys: const ['items', 'notifications', 'results'],
    );
    return list.map(NotificationDto.fromJson).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await dio.patch<dynamic>(ApiEndpoints.notificationRead(id));
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.patch<dynamic>(ApiEndpoints.notificationsReadAll);
  }
}
