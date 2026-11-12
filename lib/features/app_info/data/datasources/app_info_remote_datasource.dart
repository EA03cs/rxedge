import 'package:dio/dio.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/flavor_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/url_resolver.dart';
import '../models/app_info_dto.dart';

/// Contract for Remote App Info Datasource
abstract class AppInfoRemoteDatasource {
  Future<AppInfoDto> getAppInfo();
}

/// Remote Datasource fetching live backend health/version from `GET /health`
class AppInfoRemoteDatasourceImpl implements AppInfoRemoteDatasource {
  final Dio _dio;

  AppInfoRemoteDatasourceImpl(this._dio);

  @override
  Future<AppInfoDto> getAppInfo() async {
    Response<dynamic> response;
    final rootHealthUrl = UrlResolver.resolve(
      ApiEndpoints.health,
      apiBaseUrl: _dio.options.baseUrl,
    );
    try {
      response = await _dio.get<dynamic>(rootHealthUrl ?? ApiEndpoints.health);
    } on DioException {
      if (rootHealthUrl == null || rootHealthUrl == ApiEndpoints.health) {
        rethrow;
      }
      response = await _dio.get<dynamic>(ApiEndpoints.health);
    }
    final payload = ApiResponseParser.unwrapMap(response.data);
    if (payload.isEmpty) {
      return AppInfoDto(
        appName: 'RxEdge',
        version: '1.0.0',
        buildNumber: '1',
        environment: FlavorConfig.isInitialized
            ? FlavorConfig.instance.flavor.name
            : 'dev',
        apiEndpoint: EnvConfig.baseUrl,
        minSupportedVersion: '1.0.0',
        maintenanceMode: false,
        serverTimestamp: DateTime.now(),
      );
    }
    return AppInfoDto.fromJson(payload);
  }
}
