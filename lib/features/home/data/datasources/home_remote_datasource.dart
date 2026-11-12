import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/home_dashboard_dto.dart';

/// Remote Datasource Contract for Home Dashboard
abstract class HomeRemoteDatasource {
  Future<HomeDashboardDto> getHomeDashboard();
}

/// Real REST implementation querying `GET /dashboard/home`
/// and optionally `GET /learn/progress` for accurate lesson module ratios.
class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio _dio;

  HomeRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<HomeDashboardDto> getHomeDashboard() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.homeDashboard);
    final payload = Map<String, dynamic>.from(
      ApiResponseParser.unwrapMap(response.data),
    );

    if (payload['continueLearningLesson'] != null &&
        payload['lessonProgress'] == null) {
      try {
        final progressResp = await _dio.get<dynamic>(ApiEndpoints.learnProgress);
        final progressMap = ApiResponseParser.unwrapMap(progressResp.data);
        if (progressMap.isNotEmpty) {
          payload['lessonProgress'] = progressMap;
        }
      } catch (_) {
        // Non-fatal: dashboard continues cleanly with default ratio.
      }
    }

    return HomeDashboardDto.fromJson(payload);
  }
}
