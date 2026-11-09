import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/app_info_dto.dart';

/// Remote Datasource contract for App Info
abstract class AppInfoRemoteDatasource {
  Future<AppInfoDto> getAppInfo();
}

/// Remote Datasource implementation via Dio
class AppInfoRemoteDatasourceImpl implements AppInfoRemoteDatasource {
  final Dio _dio;

  AppInfoRemoteDatasourceImpl(this._dio);

  @override
  Future<AppInfoDto> getAppInfo() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.appInfo);

      if (response.statusCode == 200 && response.data != null) {
        return AppInfoDto.fromJson(response.data!);
      }

      throw ServerException(
        'Failed to load app info from server',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error!;
      }
      throw ServerException(e.message ?? 'Network error fetching app info');
    } catch (e) {
      throw UnknownException('Unexpected error parsing app info', e);
    }
  }
}
